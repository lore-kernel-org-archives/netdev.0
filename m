From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next 28/30] netfilter: Pass struct net into the netfilter
 hooks
Date: Thu, 17 Sep 2015 18:25:54 +0200
Message-ID: <55FAE992.9060103@6wind.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <1442365458-16349-28-git-send-email-ebiederm@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37304 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbbIQQZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 12:25:57 -0400
Received: by wicfx3 with SMTP id fx3so34539319wic.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 09:25:56 -0700 (PDT)
In-Reply-To: <1442365458-16349-28-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/09/2015 03:04, Eric W. Biederman a =C3=A9crit :
> Pass a network namespace parameter into the netfilter hooks.  At the
> call site of the netfilter hooks the path a packet is taking through
> the network stack is well known which allows the network namespace to
> be easily and reliabily.
>
> This allows the replacement of magic code like
> "dev_net(state->in?:state->out)" that appears at the start of most
> netfilter hooks with "state->net".
>
> In almost all cases the network namespace passed in is derived
> from the first network device passed in, guaranteeing those
> paths will not see any changes in practice.
>
> The exceptions are:
> xfrm/xfrm_output.c:xfrm_output_resume()         xs_net(skb_dst(skb)->=
xfrm)
> ipvs/ip_vs_xmit.c:ip_vs_nat_send_or_cont()      ip_vs_conn_net(cp)
> ipvs/ip_vs_xmit.c:ip_vs_send_or_cont()          ip_vs_conn_net(cp)
> ipv4/raw.c:raw_send_hdrinc()                    sock_net(sk)
> ipv6/ip6_output.c:ip6_xmit()			sock_net(sk)
> ipv6/ndisc.c:ndisc_send_skb()                   dev_net(skb->dev) not=
 dev_net(dst->dev)
> ipv6/raw.c:raw6_send_hdrinc()                   sock_net(sk)
> br_netfilter_hooks.c:br_nf_pre_routing_finish() dev_net(skb->dev) bef=
ore skb->dev is set to nf_bridge->physindev
>
> In all cases these exceptions seem to be a better expression for the
> network namespace the packet is being processed in then the historic
> "dev_net(in?in:out)".  I am documenting them in case something odd
> pops up and someone starts trying to track down what happened.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
[snip]
>   int br_forward_finish(struct sock *sk, struct sk_buff *skb)
>   {
> -	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, sk, skb,
> -		       NULL, skb->dev,
> +	struct net *net =3D dev_net(skb->dev);
nit: blank line after the declaration

> +	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING,
> +		       net, sk, skb, NULL, skb->dev,
>   		       br_dev_queue_push_xmit);
>
>   }
[snip]
>   int xfrm4_output(struct sock *sk, struct sk_buff *skb)
>   {
> -	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
> -			    NULL, skb_dst(skb)->dev, __xfrm4_output,
> +	struct net *net =3D dev_net(skb_dst(skb)->dev);
nit: same here

> +	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
> +			    net, sk, skb, NULL, skb_dst(skb)->dev,
> +			    __xfrm4_output,
>   			    !(IPCB(skb)->flags & IPSKB_REROUTED));
>   }
[snip]
>   int xfrm6_output(struct sock *sk, struct sk_buff *skb)
>   {
> -	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb,
> -			    NULL, skb_dst(skb)->dev, __xfrm6_output,
> +	struct net *net =3D dev_net(skb_dst(skb)->dev);
nit: same here

> +	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
> +			    net, sk, skb,  NULL, skb_dst(skb)->dev,
> +			    __xfrm6_output,
>   			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
>   }
[snip]
>   int xfrm_output_resume(struct sk_buff *skb, int err)
>   {
> +	struct net *net =3D xs_net(skb_dst(skb)->xfrm);
nit: same here

>   	while (likely((err =3D xfrm_output_one(skb, err)) =3D=3D 0)) {
>   		nf_reset(skb);
