From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] genetlink: make netns aware
Date: Wed, 17 Jun 2009 22:10:52 -0400
Message-ID: <4A39A22C.6080005@hp.com>
References: <1245267218.31588.41.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:17444 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755403AbZFRCKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:10:51 -0400
In-Reply-To: <1245267218.31588.41.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> This makes generic netlink network namespace aware.
> No actual generic netlink families are made namespace
> aware, they need to be checked one by one and then
> set the family->netnsok member to true.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
...
> --- wireless-testing.orig/include/net/net_namespace.h	2009-06-17 20:36:59.000000000 +0200
> +++ wireless-testing/include/net/net_namespace.h	2009-06-17 21:05:52.000000000 +0200
> @@ -26,6 +26,7 @@ struct net_device;
>  struct sock;
>  struct ctl_table_header;
>  struct net_generic;
> +struct sock;
>  
>  struct net {
>  	atomic_t		count;		/* To decided when the network
> @@ -63,6 +64,7 @@ struct net {
>  	struct netns_packet	packet;
>  	struct netns_unix	unx;
>  	struct netns_ipv4	ipv4;
> +	struct sock		*genl_sock;
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>  	struct netns_ipv6	ipv6;
>  #endif

Maybe you want to move *genl_sock up near the *rtnl sock?  Just seemed
strange to be stuck in the middle here to me.

> @@ -429,6 +450,10 @@ static int genl_rcv_msg(struct sk_buff *
>  	if (family == NULL)
>  		return -ENOENT;
>  
> +	/* this family doesn't exist in this netns */
> +	if (!family->netnsok && net != &init_net)
> +		return -ENOENT;

I know there's a net_eq() inline that exists, and actually becomes a no-op
when namespaces aren't built-in, so it might be worthwhile to change it
throughout, even if the rest of networking isn't consistent in using it.

-Brian
