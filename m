From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v5] net: ipv6: fix code style error and warning
 of ndisc.c
Date: Sun, 21 May 2017 09:05:08 -0700
Message-ID: <1495382708.2093.10.camel@perches.com>
References: <1495328154-18653-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0225.hostedemail.com ([216.40.44.225]:43102 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752276AbdEUQFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:05:11 -0400
In-Reply-To: <1495328154-18653-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-05-21 at 08:55 +0800, yuan linyu wrote:
> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
[]
> @@ -512,7 +519,8 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
>  		in6_ifa_put(ifp);
>  	} else {
>  		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
> -				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
> +				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->
> +						srcprefs,

This is not a good change as it puts a single dereference
on multiple lines.

> @@ -896,20 +910,19 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  	else
>  		NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
>  
> -	/*
> -	 *	update / create cache entry
> +	/*	update / create cache entry
>  	 *	for the source address

Some of these comments could be single line

> @@ -1003,30 +1016,31 @@ static void ndisc_recv_na(struct sk_buff *skb)
[]
> 		ndisc_update(dev, neigh, lladdr,
> -			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
> -			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
> -			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0)|
> -			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
> -			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0),
> +			     msg->icmph.icmp6_solicited ?
> +				NUD_REACHABLE : NUD_STALE,
> +			     NEIGH_UPDATE_F_WEAK_OVERRIDE |
> +			     (msg->icmph.icmp6_override ?
> +				NEIGH_UPDATE_F_OVERRIDE : 0) |
> +			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER |
> +			     (msg->icmph.icmp6_router ?
> +				NEIGH_UPDATE_F_ISROUTER : 0),
>  			     NDISC_NEIGHBOUR_ADVERTISEMENT, &ndopts);

This is much more difficult to read now and could
be slightly improved by a temporary for msg->icmph,
removing unnecessary parentheses or using multiple
line tests for the flags argument of ndisc_update
instead of the slightly difficult to read uses of
multiple ternaries with bitwise ORs.

Something like:

	struct icmp6hdr *icmph = &msg->icmph;
	u32 flags;
[...]
		flags = NEIGH_UPDATE_F_WEAK_OVERRIDE | NEIGH_UPDATE_F_OVERRIDE_ISROUTER;
		if (icmph->icmp6_override)
			flags |= NEIGH_UPDATE_F_OVERRIDE;
		if (icmph->icmp6_router)
			flags |= NEIGH_UPDATE_F_ISROUTER;

		ndisc_update(dev, neigh, lladdr,
			     icmph->icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
			     flags, NDISC_NEIGHBOUR_ADVERTISEMENT, &ndopts);

But really, why bother?

Just because checkpatch bleats some message doesn't
mean it _has_ to be fixed.

Please strive to make the code more readable and
intelligible for _humans_.  Compilers don't care.
