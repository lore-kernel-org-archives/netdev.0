From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6
 addresses
Date: Thu, 09 Aug 2007 08:16:54 -0400
Message-ID: <46BB05B6.5080301@oracle.com>
References: <46BAC0B9.1020207@ext.bull.net>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080200060504040304010706"
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>, Neil Brown <neilb@suse.de>
To: =?UTF-8?B?QXVyw6lsaWVuIENoYXJib24=?=
	<aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49384 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765206AbXHIMTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 08:19:32 -0400
In-Reply-To: <46BAC0B9.1020207@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080200060504040304010706
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Aurélien Charbon wrote:
> Here is a small part of missing pieces of IPv6 support for the server.
> It deals with the ip_map caching code part.
> 
> It changes the ip_map structure to be able to store INET6 addresses.
> It adds also the changes in address hashing, and mapping to test it with 
> INET addresses.

Thanks for posting your patch.

Your strategy is to convert all incoming IPv4 addresses in the ip_map 
cache to IPv6 addresses, and use only IPv6 internally (often suggested 
by IPv6 books I've encountered).  For NFS, that is problematic because 
these addresses are used as the target of access control rules for 
exports; thus sys admins will expect to see IPv4 addresses in the output 
of NFS utilities if they specified IPv4 addresses in their /etc/exports 
file, for example.

Some naive questions:

1.  If IPv6 support is not configured into the kernel, how does an 
IPv6-only cache work?

2.  I seem to recall (only quite vaguely) that at some point the server 
might need to use one of the stored addresses to, say, open a socket to 
the client?  In that case, on a system with NICs configured only with 
IPv4, is the cached IPv6 address properly converted back to IPv4 
somehow?  Can the cache code tell the difference between a cached IPv6 
address that was converted from IPv4 and one that was added to the cache 
as IPv6?  Sorry I can't remember more clearly.

3.  Would it be better to make the m_addr field a struct sockaddr, store 
a whole address (with address family), and switch on the sa_family field?

> diff -u -r -N linux-2.6.23-rc1/fs/nfsd/export.c 
> linux-2.6.23-rc1-IPv6-ip_map/fs/nfsd/export.c
> --- linux-2.6.23-rc1/fs/nfsd/export.c    2007-08-08 17:52:58.000000000 +0200
> +++ linux-2.6.23-rc1-IPv6-ip_map/fs/nfsd/export.c    2007-08-08 
> 17:49:09.000000000 +0200
> @@ -1558,6 +1558,7 @@
>  {
>      struct auth_domain    *dom;
>      int            i, err;
> +    struct in6_addr addr6;
>  
>      /* First, consistency check. */
>      err = -EINVAL;
> @@ -1576,9 +1577,14 @@
>          goto out_unlock;
>  
>      /* Insert client into hashtable. */
> -    for (i = 0; i < ncp->cl_naddr; i++)
> -        auth_unix_add_addr(ncp->cl_addrlist[i], dom);
> -
> +    for (i = 0; i < ncp->cl_naddr; i++) {
> +        /* Mapping address */
> +            addr6.s6_addr32[0] = 0;
> +            addr6.s6_addr32[1] = 0;
> +            addr6.s6_addr32[2] = htonl(0xffff);
> +            addr6.s6_addr32[3] = (uint32_t)ncp->cl_addrlist[i].s_addr;
> +        auth_unix_add_addr(addr6, dom);
> +    }
>      auth_unix_forget_old(dom);
>      auth_domain_put(dom);

This converts IPv4 addresses to canonical IPv6 as it stores them.  What 
happens if a full-blown IPv6 address is encountered?  Likewise, in nfsctl.c?

> @@ -112,12 +112,16 @@
>      return (hash ^ (hash>>8)) & 0xff;
>  }
>  #endif
> +static inline int hash_ip6(struct in6_addr ip)
> +{
> +        return (hash_ip(ip.s6_addr32[0]) ^ hash_ip(ip.s6_addr32[1]) ^ 
> hash_ip(ip.s6_addr32[2]) ^ hash_ip(ip.s6_addr32[3])) ;
> +}

How have you tested the effectiveness of the new hash function?

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
>  
> -    snprintf(text_addr, 20, "%u.%u.%u.%u",
> -         ntohl(addr) >> 24 & 0xff,
> -         ntohl(addr) >> 16 & 0xff,
> -         ntohl(addr) >>  8 & 0xff,
> -         ntohl(addr) >>  0 & 0xff);
> +    snprintf(text_addr, 20, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x",
> +            ntohl(addr[3]) >> 16 & 0xff,
> +            ntohl(addr[3]) >>  0 & 0xff,
> +            ntohl(addr[2]) >> 16 & 0xff,
> +            ntohl(addr[2]) >>  0 & 0xff,
> +            ntohl(addr[1]) >> 16 & 0xff,
> +            ntohl(addr[1]) >>  0 & 0xff,
> +            ntohl(addr[0]) >> 16 & 0xff,
> +            ntohl(addr[0]) >>  0 & 0xff);

The snprintf() format strings should use NIP6_FMT.

> @@ -197,8 +209,21 @@
>      len = qword_get(&mesg, buf, mlen);
>      if (len <= 0) return -EINVAL;
>  
> -    if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
> -        return -EINVAL;
> +    if (sscanf(buf, "%d.%d.%d.%d%c", &b1, &b2, &b3, &b4, &c) == 4) {
> +               addr.s6_addr32[0] = 0;
> +               addr.s6_addr32[1] = 0;
> +               addr.s6_addr32[2] = htonl(0xffff);
> +               addr.s6_addr32[3] =
> +               htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
> +       } else if (sscanf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x%c",
> +                         &b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 
> 8) {
> +               addr.s6_addr32[0] = htonl((b1<<16)|b2);
> +               addr.s6_addr32[1] = htonl((b3<<16)|b4);
> +               addr.s6_addr32[2] = htonl((b5<<16)|b6);
> +               addr.s6_addr32[3] = htonl((b7<<16)|b8);
> +       } else
> +                return -EINVAL;
> +

Likewise, the sscanf() format strings should use NIP6_FMT.

> @@ -247,18 +269,22 @@
>      }
>      im = container_of(h, struct ip_map, h);
>      /* class addr domain */
> -    addr = im->m_addr;
> +    memcpy(&addr, &im->m_addr, sizeof(struct in6_addr));
>  
>      if (test_bit(CACHE_VALID, &h->flags) &&
>          !test_bit(CACHE_NEGATIVE, &h->flags))
>          dom = im->m_client->h.name;
>  
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
>             dom
>             );
>      return 0;

And I think here NIP6_FMT should be used, but you're not using colons 
between the hex digits.  Was that intentional?

--------------080200060504040304010706
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2MTQg
NTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnVybDpodHRwOi8vb3NzLm9yYWNsZS5jb20v
fmNlbA0KdmVyc2lvbjoyLjENCmVuZDp2Y2FyZA0KDQo=
--------------080200060504040304010706--
