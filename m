From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Sat, 31 May 2003 11:02:49 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030531.110249.12960077.yoshfuji@linux-ipv6.org>
References: <3ED80230.2030508@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <3ED80230.2030508@us.ibm.com>
List-Id: netdev.vger.kernel.org

In article <3ED80230.2030508@us.ibm.com> (at Fri, 30 May 2003 18:15:28 -0700), Krishna Kumar <krkumar@us.ibm.com> says:

> +/* prefix list returned to user space in this structure */
> +struct plist_user_info {
          ^ip6 or ipv6 or so.
> +	char name[IFNAMSIZ];		/* interface name */
        ~~~~~~~~~~~~~~~~~~~duplicate information.
> +	int ifindex;			/* interface index */
> +	int nprefixes;			/* number of elements in 'prefix' */
> +	struct var_plist_user_info {	/* multiple elements */
> +		char flags[3];		/* router advertised flags */
                     ~~~~~~~~this is not good interface.
> +		int plen;		/* prefix length */
> +		__u32 valid;		/* valid lifetime */
> +		struct in6_addr ra_addr;/* advertising router */
> +		struct in6_addr prefix;	/* prefix */
> +	} plist_vars[0];
> +};
> +
>   extern void			addrconf_init(void);
>   extern void			addrconf_cleanup(void);
> 

:

I think we should use 1 fixed-length message per prefix,
instead of variable length message.


> +			pinfo->plist_vars[count].plen = p_el->pinfo.prefix_len;
> +			pinfo->plist_vars[count].valid = p_el->pinfo.valid -
> +				(jiffies - p_el->timestamp)/HZ;
> +			if ((p_el->ra_flags & (ND_RA_FLAG_MANAGED |
> +			    ND_RA_FLAG_OTHER))
> +			    == (ND_RA_FLAG_MANAGED|ND_RA_FLAG_OTHER))
> +				strcpy(pinfo->plist_vars[count].flags, "MO");
> +			else if (p_el->ra_flags & ND_RA_FLAG_MANAGED)
> +				strcpy(pinfo->plist_vars[count].flags, "M");
> +			else if (p_el->ra_flags & ND_RA_FLAG_OTHER)
> +				strcpy(pinfo->plist_vars[count].flags, "O");
> +			else
> +				strcpy(pinfo->plist_vars[count].flags, "-");
> +			ipv6_addr_copy(&pinfo->plist_vars[count].ra_addr,
> +			    &p_el->ra_addr);
> +			for (i = 0; i < 8; i++)
> +				pinfo->plist_vars[count].ra_addr.s6_addr16[i] =
> +				    __constant_ntohs(pinfo->plist_vars[count].ra_addr.s6_addr16[i]);
> +			ipv6_addr_copy(&pinfo->plist_vars[count].prefix,
> +			    &p_el->pinfo.prefix);
> +			for (i = 0; i < p_el->pinfo.prefix_len/16; i++)
> +				pinfo->plist_vars[count].prefix.s6_addr16[i] =
> +				    __constant_ntohs(pinfo->plist_vars[count].prefix.s6_addr16[i]);

Absoletely nasty.
- don't use charaters to represent flags; use real flags.
- use network-byte order.


> +static int prefix_list_proc_dump(char *buffer, char **start, off_t offset,
> +			   int length)
> +{
:

Please use seq_file.


Again, what I proposed was to store prefix information on fib with 
some flags to represent advertised by routers and give user-space 
the RA information using new rtattr (RTA_RA6INFO or something like that).

struct rta_ra6info {
     u32 rta_ra6flags;
};

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA


