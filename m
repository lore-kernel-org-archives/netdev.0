From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPV6: added sysctl for maximum number of addresses
Date: Thu, 15 Jan 2004 17:23:23 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401151721380.16629-100000@netcore.fi>
References: <20040115.213014.133549139.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <vnuorval@tcs.hut.fi>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040115.213014.133549139.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In some configuration, we need addresses more than 16 addresses per interface.
> This pach adds new sysctl for configuring the maximum number of addresses 
> per interface.

Doesn't 16 addresses per interface sound like an awfully small number?  
Consider a web service which wants to have a different IP address per 
virtual host.  These are not really uncommon.

Maybe 64 or 256 would be a better default?  After all, you shouldn't 
be able to crash the kernel using those numbers in any case, and if 
you can't, the default value should be something that's useful for as 
many people as reasonably?

> ===== Documentation/networking/ip-sysctl.txt 1.18 vs edited =====
> --- 1.18/Documentation/networking/ip-sysctl.txt	Thu Dec 25 12:32:23 2003
> +++ edited/Documentation/networking/ip-sysctl.txt	Thu Jan 15 21:25:49 2004
> @@ -667,6 +667,13 @@
>  	valid temporary addresses.
>  	Default: 5
>  
> +max_addresses - INTEGER
> +	Number of maximum addresses per interface.  0 disables limitation.
> +	It is recommended not set too large value (or 0) because it would 
> +	be too easy way to crash kernel to allow to create too much of 
> +	autoconfigured addresses.
> +	Default: 16
> +
>  icmp/*:
>  ratelimit - INTEGER
>  	Limit the maximal rates for sending ICMPv6 packets.
> ===== include/linux/ipv6.h 1.15 vs edited =====
> --- 1.15/include/linux/ipv6.h	Fri Jan  2 05:28:33 2004
> +++ edited/include/linux/ipv6.h	Thu Jan 15 21:17:23 2004
> @@ -143,6 +143,7 @@
>  	__s32		regen_max_retry;
>  	__s32		max_desync_factor;
>  #endif
> +	__s32		max_addresses;
>  	void		*sysctl;
>  };
>  
> @@ -165,6 +166,7 @@
>  	DEVCONF_REGEN_MAX_RETRY,
>  	DEVCONF_MAX_DESYNC_FACTOR,
>  #endif
> +	DEVCONF_MAX_ADDRESSES,
>  	DEVCONF_MAX
>  };
>  
> ===== include/linux/sysctl.h 1.54 vs edited =====
> --- 1.54/include/linux/sysctl.h	Thu Dec 25 12:32:23 2003
> +++ edited/include/linux/sysctl.h	Thu Jan 15 21:03:14 2004
> @@ -418,7 +418,8 @@
>  	NET_IPV6_TEMP_VALID_LFT=12,
>  	NET_IPV6_TEMP_PREFERED_LFT=13,
>  	NET_IPV6_REGEN_MAX_RETRY=14,
> -	NET_IPV6_MAX_DESYNC_FACTOR=15
> +	NET_IPV6_MAX_DESYNC_FACTOR=15,
> +	NET_IPV6_MAX_ADDRESSES=16
>  };
>  
>  /* /proc/sys/net/ipv6/icmp */
> ===== include/net/addrconf.h 1.11 vs edited =====
> --- 1.11/include/net/addrconf.h	Sun Jul  6 02:36:23 2003
> +++ edited/include/net/addrconf.h	Thu Jan 15 21:05:01 2004
> @@ -15,6 +15,8 @@
>  
>  #define ADDR_CHECK_FREQUENCY		(120*HZ)
>  
> +#define IPV6_MAX_ADDRESSES		16
> +
>  struct prefix_info {
>  	__u8			type;
>  	__u8			length;
> ===== net/ipv6/addrconf.c 1.79 vs edited =====
> --- 1.79/net/ipv6/addrconf.c	Thu Jan  8 05:17:40 2004
> +++ edited/net/ipv6/addrconf.c	Thu Jan 15 21:09:43 2004
> @@ -81,8 +81,6 @@
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  
> -#define IPV6_MAX_ADDRESSES 16
> -
>  /* Set to 3 to get tracing... */
>  #define ACONF_DEBUG 2
>  
> @@ -160,6 +158,7 @@
>  	.regen_max_retry	= REGEN_MAX_RETRY,
>  	.max_desync_factor	= MAX_DESYNC_FACTOR,
>  #endif
> +	.max_addresses		= IPV6_MAX_ADDRESSES,
>  };
>  
>  static struct ipv6_devconf ipv6_devconf_dflt = {
> @@ -180,6 +179,7 @@
>  	.regen_max_retry	= REGEN_MAX_RETRY,
>  	.max_desync_factor	= MAX_DESYNC_FACTOR,
>  #endif
> +	.max_addresses		= IPV6_MAX_ADDRESSES,
>  };
>  
>  /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
> @@ -630,6 +630,7 @@
>  	unsigned long tmp_prefered_lft, tmp_valid_lft;
>  	int tmp_plen;
>  	int ret = 0;
> +	int max_addresses;
>  
>  	if (ift) {
>  		spin_lock_bh(&ift->lock);
> @@ -685,9 +686,11 @@
>  				 ifp->prefered_lft, 
>  				 idev->cnf.temp_prefered_lft - desync_factor / HZ);
>  	tmp_plen = ifp->prefix_len;
> +	max_addresses = idev->cnf.max_addresses;
>  	write_unlock(&idev->lock);
>  	spin_unlock_bh(&ifp->lock);
> -	ift = ipv6_count_addresses(idev) < IPV6_MAX_ADDRESSES ?
> +	ift = !max_addresses ||
> +	      ipv6_count_addresses(idev) < max_addresses ? 
>  		ipv6_add_addr(idev, &addr, tmp_plen,
>  			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) : 0;
>  	if (!ift || IS_ERR(ift)) {
> @@ -1390,10 +1393,13 @@
>  		ifp = ipv6_get_ifaddr(&addr, dev);
>  
>  		if (ifp == NULL && valid_lft) {
> +			int max_addresses = in6_dev->cnf.max_addresses;
> +
>  			/* Do not allow to create too much of autoconfigured
>  			 * addresses; this would be too easy way to crash kernel.
>  			 */
> -			if (ipv6_count_addresses(in6_dev) < IPV6_MAX_ADDRESSES)
> +			if (!max_addresses ||
> +			    ipv6_count_addresses(in6_dev) < max_addresses)
>  				ifp = ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
>  						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);
>  
> @@ -2722,6 +2728,7 @@
>  	array[DEVCONF_REGEN_MAX_RETRY] = cnf->regen_max_retry;
>  	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
>  #endif
> +	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
>  }
>  
>  static int inet6_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
> @@ -3050,6 +3057,14 @@
>  	 		.proc_handler	=	&proc_dointvec,
>  		},
>  #endif
> +		{
> +			.ctl_name	=	NET_IPV6_MAX_ADDRESSES,
> +			.procname	=	"max_addresses",
> +			.data		=	&ipv6_devconf.max_addresses,
> +			.maxlen		=	sizeof(int),
> +			.mode		=	0644,
> +			.proc_handler	=	&proc_dointvec,
> +		},
>  	},
>  	.addrconf_dev = {
>  		{
> 
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
