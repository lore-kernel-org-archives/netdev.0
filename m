From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Mon, 02 Jun 2003 10:32:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EDB8A41.2080305@us.ibm.com>
References: <3ED80230.2030508@us.ibm.com> <20030531.110249.12960077.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030531.110249.12960077.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Yoshifuji,

Thanks for your comments.

>>+/* prefix list returned to user space in this structure */
>>+struct plist_user_info {
> 
>           ^ip6 or ipv6 or so.
> 
>>+	char name[IFNAMSIZ];		/* interface name */
> 
>         ~~~~~~~~~~~~~~~~~~~duplicate information.
> 

Point noted. That can be removed (prefer to have name instead of ifindex).

>>+	int ifindex;			/* interface index */
>>+	int nprefixes;			/* number of elements in 'prefix' */
>>+	struct var_plist_user_info {	/* multiple elements */
>>+		char flags[3];		/* router advertised flags */
> 
>                      ~~~~~~~~this is not good interface.

This is my mistake. When I added the original interface, it was using the proc
filesystem and it made sense at that time for a user to cat /proc/net/<file> and
actually see the flags. While converting to use netlink, I forgot to change this
to real flags. This was not intended interface :-)


>>+		int plen;		/* prefix length */
>>+		__u32 valid;		/* valid lifetime */
>>+		struct in6_addr ra_addr;/* advertising router */
>>+		struct in6_addr prefix;	/* prefix */
>>+	} plist_vars[0];
>>+};
>>+
>>  extern void			addrconf_init(void);
>>  extern void			addrconf_cleanup(void);
>>
> 
> 
> :
> 
> I think we should use 1 fixed-length message per prefix,
> instead of variable length message.

I had got this idea from "struct fib_info" which also has variable size
structure, but probably it is not worth the extra effort to save a few bytes.

>>+			ipv6_addr_copy(&pinfo->plist_vars[count].ra_addr,
>>+			    &p_el->ra_addr);
>>+			for (i = 0; i < 8; i++)
>>+				pinfo->plist_vars[count].ra_addr.s6_addr16[i] =
>>+				    __constant_ntohs(pinfo->plist_vars[count].ra_addr.s6_addr16[i]);
>>+			ipv6_addr_copy(&pinfo->plist_vars[count].prefix,
>>+			    &p_el->pinfo.prefix);
>>+			for (i = 0; i < p_el->pinfo.prefix_len/16; i++)
>>+				pinfo->plist_vars[count].prefix.s6_addr16[i] =
>>+				    __constant_ntohs(pinfo->plist_vars[count].prefix.s6_addr16[i]);
> 
> 
> Absoletely nasty.
> - don't use charaters to represent flags; use real flags.
> - use network-byte order.

network-byte order ? User will get prefix in network byte order, is that correct  ?

>>+static int prefix_list_proc_dump(char *buffer, char **start, off_t offset,
>>+			   int length)
>>+{
> 
> :
> 
> Please use seq_file.

OK.

> Again, what I proposed was to store prefix information on fib with 
> some flags to represent advertised by routers and give user-space 
> the RA information using new rtattr (RTA_RA6INFO or something like that).
> 
> struct rta_ra6info {
>      u32 rta_ra6flags;
> };
>

In my mail, I had given problems with doing that in the fib. I can look to
convert to fib, but please let me know which kernel routines I should look at.

Thanks,

- KK
