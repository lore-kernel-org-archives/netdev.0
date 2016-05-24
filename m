From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 3/7] ipv4: Support TOU
Date: Mon, 23 May 2016 20:16:24 -0700
Message-ID: <1464059784.5939.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
	 <1464043706-2843932-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35098 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbcEXDQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 23:16:27 -0400
Received: by mail-pa0-f68.google.com with SMTP id gp3so593673pac.2
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 20:16:27 -0700 (PDT)
In-Reply-To: <1464043706-2843932-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-23 at 15:48 -0700, Tom Herbert wrote:

...

>  static int
>  ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
> @@ -382,11 +383,36 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
>  	struct rtable *rt;
>  	struct iphdr *iph;
>  	int res;
> +	__be16 dport, sport;
> +	u8 protocol = sk->sk_protocol;
>  
>  	/* Skip all of this if the packet is already routed,
>  	 * f.e. by something like SCTP.
>  	 */
>  	rcu_read_lock();
> +
> +	if (inet->tou_encap) {
> +		struct ip_tunnel_encap *e = inet->tou_encap;

You seem to rely on RCU, in spirit at least.

But ...

1) You read inet->tou_encap twice, so the second time could read a NULL
and then crash on a NULL dereference.

2) No RCU grace period is respected in tou_encap_setsockopt(), so use
after free is possible.

> +		const struct ip_tunnel_encap_ops *ops;
> +
> +		/* Transport layer protocol over UDP enapsulation */


> +		dport = e->dport;
> +		sport = e->sport;
