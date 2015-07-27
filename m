From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCHv2] net/ipv6: add sysctl option accept_ra_hop_limit
Date: Tue, 28 Jul 2015 08:50:07 +0900
Message-ID: <55B6C3AF.1050504@miraclelinux.com>
References: <1437978942-7047-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35279 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932334AbbG0XuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 19:50:11 -0400
Received: by pdrg1 with SMTP id g1so59773394pdr.2
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 16:50:11 -0700 (PDT)
In-Reply-To: <1437978942-7047-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hangbin Liu wrote:
> Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
> disabled accept hop limit from RA if it is higher than the current hop
> limit for security stuff. But this behavior kind of break the RFC definition.
> 
> RFC 4861, 6.3.4.  Processing Received Router Advertisements
>    If the received Cur Hop Limit value is non-zero, the host SHOULD set
>    its CurHopLimit variable to the received value.
> 
> So add sysctl option accept_ra_hop_limit to let user choose whether accept
> hop limit info in RA.
> 

How about introducing "minimum hop limit", instead?

|commit 6fd99094de2b83d1d4c8457f2c83483b2828e75a
|Author: D.S. Ljungmark <ljungmark@modio.se>
|Date:   Wed Mar 25 09:28:15 2015 +0100
|
|    ipv6: Don't reduce hop limit for an interface
:
|    RFC 3756, Section 4.2.7, "Parameter Spoofing"
|    
:
|   >   As an example, one possible approach to mitigate this threat is to
|    >   ignore very small hop limits.  The nodes could implement a
|    >   configurable minimum hop limit, and ignore attempts to set it below
|    >   said limit.

--yoshfuji


> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  Documentation/networking/ip-sysctl.txt | 11 +++++++++++
>  include/linux/ipv6.h                   |  1 +
>  include/uapi/linux/ipv6.h              |  1 +
>  net/ipv6/addrconf.c                    | 10 ++++++++++
>  net/ipv6/ndisc.c                       | 17 +++++++++++------
>  5 files changed, 34 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 5fae770..778c479 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1346,6 +1346,17 @@ accept_ra_pinfo - BOOLEAN
>  	Functional default: enabled if accept_ra is enabled.
>  			    disabled if accept_ra is disabled.
>  
> +accept_ra_hop_limit - INTEGER
> +	Learn hop limit in Router Advertisement.
> +
> +	Possible values are:
> +		0 Do not accept hop limit in Router Advertisements.
> +		1 Accept hop limit in Router Advertisements if it is higher
> +		  than the current hop limit.
> +		2 Accept hop limit in Router Advertisements anyway.
> +
> +	Default: 1
> +
>  accept_ra_rt_info_max_plen - INTEGER
>  	Maximum prefix length of Route Information in RA.
>  
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 82806c6..a21a9c6 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -30,6 +30,7 @@ struct ipv6_devconf {
>  	__s32		max_addresses;
>  	__s32		accept_ra_defrtr;
>  	__s32		accept_ra_pinfo;
> +	__s32           accept_ra_hop_limit;
>  #ifdef CONFIG_IPV6_ROUTER_PREF
>  	__s32		accept_ra_rtr_pref;
>  	__s32		rtr_probe_interval;
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 5efa54a..a8c1083 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -171,6 +171,7 @@ enum {
>  	DEVCONF_USE_OPTIMISTIC,
>  	DEVCONF_ACCEPT_RA_MTU,
>  	DEVCONF_STABLE_SECRET,
> +	DEVCONF_ACCEPT_RA_HOP_LIMIT,
>  	DEVCONF_MAX
>  };
>  
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 21c2c81..486a7a5 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -196,6 +196,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
>  	.accept_ra_defrtr	= 1,
>  	.accept_ra_from_local	= 0,
>  	.accept_ra_pinfo	= 1,
> +	.accept_ra_hop_limit    = 1,
>  #ifdef CONFIG_IPV6_ROUTER_PREF
>  	.accept_ra_rtr_pref	= 1,
>  	.rtr_probe_interval	= 60 * HZ,
> @@ -237,6 +238,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>  	.accept_ra_defrtr	= 1,
>  	.accept_ra_from_local	= 0,
>  	.accept_ra_pinfo	= 1,
> +	.accept_ra_hop_limit    = 1,
>  #ifdef CONFIG_IPV6_ROUTER_PREF
>  	.accept_ra_rtr_pref	= 1,
>  	.rtr_probe_interval	= 60 * HZ,
> @@ -4561,6 +4563,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
>  	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
>  	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
>  	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
> +	array[DEVCONF_ACCEPT_RA_HOP_LIMIT] = cnf->accept_ra_hop_limit;
>  #ifdef CONFIG_IPV6_ROUTER_PREF
>  	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
>  	array[DEVCONF_RTR_PROBE_INTERVAL] =
> @@ -5462,6 +5465,13 @@ static struct addrconf_sysctl_table
>  			.mode		= 0644,
>  			.proc_handler	= proc_dointvec,
>  		},
> +		{
> +			.procname	= "accept_ra_hop_limit",
> +			.data		= &ipv6_devconf.accept_ra_hop_limit,
> +			.maxlen		= sizeof(int),
> +			.mode		= 0644,
> +			.proc_handler	= proc_dointvec,
> +		},
>  #ifdef CONFIG_IPV6_ROUTER_PREF
>  		{
>  			.procname	= "accept_ra_rtr_pref",
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 0a05b35..aca67da 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1226,13 +1226,18 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>  	if (rt)
>  		rt6_set_expires(rt, jiffies + (HZ * lifetime));
>  	if (ra_msg->icmph.icmp6_hop_limit) {
> -		/* Only set hop_limit on the interface if it is higher than
> -		 * the current hop_limit.
> -		 */
> -		if (in6_dev->cnf.hop_limit < ra_msg->icmph.icmp6_hop_limit) {
> +		switch (in6_dev->cnf.accept_ra_hop_limit) {
> +		case 0:
> +			break;
> +		case 1:
> +			if (in6_dev->cnf.hop_limit > ra_msg->icmph.icmp6_hop_limit) {
> +				ND_PRINTK(2, warn,
> +					  "RA: Got route advertisement with lower hop_limit than current\n");
> +				break;
> +			}
> +		default:
>  			in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
> -		} else {
> -			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than current\n");
> +			break;
>  		}
>  		if (rt)
>  			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
> 

-- 
吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
ミラクル・リナックス株式会社 技術本部 サポート部
