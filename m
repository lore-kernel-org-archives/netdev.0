From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6
	addresses
Date: Fri, 10 Aug 2007 11:06:43 +1000
Message-ID: <18107.47651.887742.434626@notabene.brown>
References: <46BAC0B9.1020207@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev ML <netdev@vger.kernel.org>,
	Mailing list NFSv4 <nfsv4@linux-nfs.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: message from Aurélien Charbon on Thursday August 9
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-Id: netdev.vger.kernel.org

On Thursday August 9, aurelien.charbon@ext.bull.net wrote:
> Here is a small part of missing pieces of IPv6 support for the server.
> It deals with the ip_map caching code part.
> 
> It changes the ip_map structure to be able to store INET6 addresses.
> It adds also the changes in address hashing, and mapping to test it with 
> INET addresses.

Thanks - this generally seems to make sense.  A few specific comments:

> @@ -1558,6 +1558,7 @@

Please use "diff -p" to include the C function name.  It makes the
patch easier to read.


> +    for (i = 0; i < ncp->cl_naddr; i++) {
> +        /* Mapping address */
> +            addr6.s6_addr32[0] = 0;
> +            addr6.s6_addr32[1] = 0;
> +            addr6.s6_addr32[2] = htonl(0xffff);
> +            addr6.s6_addr32[3] = (uint32_t)ncp->cl_addrlist[i].s_addr;
> +        auth_unix_add_addr(addr6, dom);
> +    }

You do this conversion several times, and each time it is indented
strangely...  Maybe create an inline (if there isn't one already) to
do this.

>  extern void auth_domain_put(struct auth_domain *item);
> -extern int auth_unix_add_addr(struct in_addr addr, struct auth_domain 
> *dom);
> +extern int auth_unix_add_addr(struct in6_addr addr, struct auth_domain 
> *dom);

Your mailer is wrapping long lines.  This is bad.

>  static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
>  {
>      struct ip_map *orig = container_of(corig, struct ip_map, h);
>      struct ip_map *new = container_of(cnew, struct ip_map, h);
>      return strcmp(orig->m_class, new->m_class) == 0
> -        && orig->m_addr.s_addr == new->m_addr.s_addr;
> +        && memcmp(orig->m_addr.s6_addr, 
> new->m_addr.s6_addr,sizeof(struct in6_addr));
>  }

I think you have inverted the sense of the test.  The original tests
for equality.  The new tests for inequality.  For memcmp (and strcmp),
always use   "function(arg1, argc) COMPARE_OP 0"
e.g.
            memcmp(orig, new, size) == 0
or use ipv6_addr_equal.


Also please run ./scripts/checkpatch.pl on the patch.  You need a
space after that comma.

   
> @@ -125,7 +129,7 @@
>      struct ip_map *item = container_of(citem, struct ip_map, h);
>  
>      strcpy(new->m_class, item->m_class);
> -    new->m_addr.s_addr = item->m_addr.s_addr;
> +    memcpy(&new->m_addr.s6_addr, 
> &item->m_addr.s6_addr,sizeof(item->m_addr.s6_addr));

Ditto..... did you test this code?


>  }
>  static void update(struct cache_head *cnew, struct cache_head *citem)
>  {
> @@ -151,20 +155,28 @@
>  {
>      char text_addr[20];
>      struct ip_map *im = container_of(h, struct ip_map, h);
> -    __be32 addr = im->m_addr.s_addr;
> +   
> +    __be32 addr[4];
> +    int i;
> +    for (i=0;i<4;i++)
> +        addr[i] = im->m_addr.s6_addr[i];
                                   ^^^^

I think you mean "s6_addr32" ??


>  
> -    snprintf(text_addr, 20, "%u.%u.%u.%u",
> -         ntohl(addr) >> 24 & 0xff,
> -         ntohl(addr) >> 16 & 0xff,
> -         ntohl(addr) >>  8 & 0xff,
> -         ntohl(addr) >>  0 & 0xff);
> +    snprintf(text_addr, 20, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x",
> +            ntohl(addr[3]) >> 16 & 0xff,
                                      ^^^^
should be 0xffff ???

Now I know you didn't test the code :-)

> +            ntohl(addr[3]) >>  0 & 0xff,
> +            ntohl(addr[2]) >> 16 & 0xff,
> +            ntohl(addr[2]) >>  0 & 0xff,
> +            ntohl(addr[1]) >> 16 & 0xff,
> +            ntohl(addr[1]) >>  0 & 0xff,
> +            ntohl(addr[0]) >> 16 & 0xff,
> +            ntohl(addr[0]) >>  0 & 0xff);

This code would read better if you did
   __be16 addr[8];
   for (i = 0; i < 8 ; i++)
	addr[i] = im->m_addr.s6_addr16[i];
   snprintf(........
		ntohs(addr[7]),
		ntohs(addr[6]),
		....

Also, I think that if it is a (converted) IPv4 address, it should be
printed as a dotted-quad.


> +               addr.s6_addr32[0] = htonl((b1<<16)|b2);
> +               addr.s6_addr32[1] = htonl((b3<<16)|b4);
> +               addr.s6_addr32[2] = htonl((b5<<16)|b6);
> +               addr.s6_addr32[3] = htonl((b7<<16)|b8);

Assign to addr.s6_addr16[].

> -    seq_printf(m, "%s %d.%d.%d.%d %s\n",
> +    seq_printf(m, "%s %04x.%04x.%04x.%04x.%04x.%04x.%04x.%04x %s\n",
>             im->m_class,
> -           ntohl(addr.s_addr) >> 24 & 0xff,
> -           ntohl(addr.s_addr) >> 16 & 0xff,
> -           ntohl(addr.s_addr) >>  8 & 0xff,
> -           ntohl(addr.s_addr) >>  0 & 0xff,
> +           ntohl(addr.s6_addr32[3]) >> 16 & 0xffff,
> +           ntohl(addr.s6_addr32[3]) & 0xffff,
> +           ntohl(addr.s6_addr32[2]) >> 16 & 0xffff,
> +           ntohl(addr.s6_addr32[2]) & 0xffff,
> +           ntohl(addr.s6_addr32[1]) >> 16 & 0xffff,
> +           ntohl(addr.s6_addr32[1]) & 0xffff,
> +           ntohl(addr.s6_addr32[0]) >> 16 & 0xffff,
> +           ntohl(addr.s6_addr32[0]) & 0xffff,

Again, s6_addr16[], and keep the dotted-quad for IPv4.
In fact ( borrowing Chuck's suggestion)
 if (is_ipv4)
	seq_printf(m, "%s "NIPQUAD_FMT" %s\n", im->m_class,
			NIPQUAD((addr.s6_addr32[0])), ....);
 else
	seq_printf(m, "%s "NIP6_FMT" %s\n", im->m_class,
			NIP6(addr), ...);



Thanks,
NeilBrown
