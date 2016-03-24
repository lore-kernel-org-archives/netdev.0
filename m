From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFT Patch net 1/2] ipv6: invalidate the socket cached route on
 pmtu events if possible
Date: Thu, 24 Mar 2016 13:35:40 -0700
Message-ID: <1458851740.12033.24.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiwan@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35998 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbcCXUfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 16:35:43 -0400
Received: by mail-pa0-f43.google.com with SMTP id tt10so30900900pab.3
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 13:35:42 -0700 (PDT)
In-Reply-To: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 12:25 -0700, Cong Wang wrote:

>  void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
>  {
> -	ip6_update_pmtu(skb, sock_net(sk), mtu,
> -			sk->sk_bound_dev_if, sk->sk_mark);
> +	const struct ipv6hdr *iph = (struct ipv6hdr *)skb->data;
> +	struct net *net = sock_net(sk);
> +	struct dst_entry *ndst, *dst;
> +	struct flowi6 fl6;
> +	bool new = false;
> +
> +	memset(&fl6, 0, sizeof(fl6));
> +
> +	bh_lock_sock(sk);
> +


This is not clear why you need to acquire socket lock.

sk_dst_cache is protected by an atomic operation.

udp for example calls ip6_dst_store() without socket being locked.
