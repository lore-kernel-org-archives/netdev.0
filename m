From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [patch 5/9][NETNS][IPV6] make bindv6only sysctl per namespace
Date: Mon, 07 Jan 2008 17:32:02 +0100
Message-ID: <47825402.8030504@bull.net>
References: <20080104111226.776105484@localhost.localdomain> <20080104111431.444295890@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:48361 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755658AbYAGQcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 11:32:07 -0500
In-Reply-To: <20080104111431.444295890@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel,

The kernel fails to build with this patch applied when CONFIG_SYSCTL=n
See comment below.

Daniel Lezcano wrote:
> This patch moves the bindv6only sysctl to the network namespace
> structure. Until the ipv6 protocol is not per namespace, the sysctl
> variable is always from the initial network namespace.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> ---
>  include/net/ipv6.h         |    1 -
>  include/net/netns/ipv6.h   |    1 +
>  net/ipv6/af_inet6.c        |    4 +---
>  net/ipv6/sysctl_net_ipv6.c |    6 +++++-
>  4 files changed, 7 insertions(+), 5 deletions(-)
> 
> Index: net-2.6.25/include/net/ipv6.h
> ===================================================================
> --- net-2.6.25.orig/include/net/ipv6.h
> +++ net-2.6.25/include/net/ipv6.h
> @@ -109,7 +109,6 @@ struct frag_hdr {
>  #include <net/sock.h>
>  
>  /* sysctls */
> -extern int sysctl_ipv6_bindv6only;
>  extern int sysctl_mld_max_msf;
>  
>  #define _DEVINC(statname, modifier, idev, field)			\
> Index: net-2.6.25/include/net/netns/ipv6.h
> ===================================================================
> --- net-2.6.25.orig/include/net/netns/ipv6.h
> +++ net-2.6.25/include/net/netns/ipv6.h
> @@ -9,6 +9,7 @@ struct ctl_table_header;
>  
>  struct netns_sysctl_ipv6 {
>  	struct ctl_table_header *table;
> + 	int bindv6only;
>  };
>  
>  struct netns_ipv6 {
> Index: net-2.6.25/net/ipv6/af_inet6.c
> ===================================================================
> --- net-2.6.25.orig/net/ipv6/af_inet6.c
> +++ net-2.6.25/net/ipv6/af_inet6.c
> @@ -66,8 +66,6 @@ MODULE_AUTHOR("Cast of dozens");
>  MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
>  MODULE_LICENSE("GPL");
>  
> -int sysctl_ipv6_bindv6only __read_mostly;
> -
>  /* The inetsw6 table contains everything that inet6_create needs to
>   * build a new socket.
>   */
> @@ -193,7 +191,7 @@ lookup_protocol:
>  	np->mcast_hops	= -1;
>  	np->mc_loop	= 1;
>  	np->pmtudisc	= IPV6_PMTUDISC_WANT;
> -	np->ipv6only	= sysctl_ipv6_bindv6only;
> +	np->ipv6only	= init_net.ipv6.sysctl.bindv6only;


The problem is here:
init_net.ipv6.sysctl is not defined if CONFIG_SYSCTL=n.

Benjamin

>  
>  	/* Init the ipv4 part of the socket since we can have sockets
>  	 * using v6 API for ipv4.
> Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
> ===================================================================
> --- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
> +++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
> @@ -35,7 +35,7 @@ static ctl_table ipv6_table_template[] =
>  	{
>  		.ctl_name	= NET_IPV6_BINDV6ONLY,
>  		.procname	= "bindv6only",
> -		.data		= &sysctl_ipv6_bindv6only,
> +		.data		= &init_net.ipv6.sysctl.bindv6only,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec
> @@ -115,6 +115,10 @@ static int ipv6_sysctl_net_init(struct n
>     	ipv6_table[0].child = ipv6_route_table;
>     	ipv6_table[1].child = ipv6_icmp_table;
>  
> +  	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;
> +
> +	net->ipv6.sysctl.bindv6only = 0;
> +
>     	net->ipv6.sysctl.table = register_net_sysctl_table(net, ipv6_ctl_path, ipv6_table);
>     	if (!net->ipv6.sysctl.table)
>     		goto out_ipv6_icmp_table;
> 
> -- -- To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at http://vger.kernel.org/majordomo-info.html 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
