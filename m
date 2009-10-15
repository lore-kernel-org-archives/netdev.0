From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH 5/5] net: Encapsulate inner code of __sk_dst_reset
Date: Thu, 15 Oct 2009 18:23:13 +0530
Message-ID: <OF1DCFA864.CE6D7182-ON65257650.0040E50E-65257650.0046CA63@in.ibm.com>
References: <20091015055602.30145.65852.sendpatchset@localhost.localdomain> <20091015055758.30145.77495.sendpatchset@localhost.localdomain> <4AD6F11A.90908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:38602 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758267AbZJOMyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 08:54:39 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9FCrniI024536
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 18:23:49 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9FCrn5Y741586
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 18:23:49 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9FCrmUD032378
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 23:53:48 +1100
In-Reply-To: <4AD6F11A.90908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric Dumazet <eric.dumazet@gmail.com> wrote on 10/15/2009 03:23:30 PM:

I am responding in one post for your convenience.

> Hmm, why not cache ops->ndo_select_queue(dev, skb) choice too ?
>
>       if (ops->ndo_select_queue)
>          queue_index = ops->ndo_select_queue(dev, skb);
>       else {
>          queue_index = 0;
>          if (dev->real_num_tx_queues > 1)
>             queue_index = skb_tx_hash(dev, skb);
>       }
>       if (sk && sk->sk_dst_cache)
>          sk_record_tx_queue(sk, queue_index);
>
> Or should ndo_select_queue() method take care of calling
sk_record_tx_queue() itself ?

I initially cached for ndo_select_queue too, but felt it should not do
that and leave to the driver for each skb. But your idea of the driver
caching is good - I think ixgbe_select_queue & mlx4_en_select_queue
(but not iwm_select_queue) can internally cache it if they are calling
skb_tx_hash.

> > diff -ruNp org/net/ipv6/inet6_connection_sock.c
new/net/ipv6/inet6_connection_sock.c
> > --- org/net/ipv6/inet6_connection_sock.c   2009-10-14
18:00:17.000000000 +0530
> > +++ new/net/ipv6/inet6_connection_sock.c   2009-10-14
18:00:30.000000000 +0530
> > @@ -168,9 +168,7 @@ struct dst_entry *__inet6_csk_dst_check(
> >     if (dst) {
> >        struct rt6_info *rt = (struct rt6_info *)dst;
> >        if (rt->rt6i_flow_cache_genid != atomic_read(&flow_cache_genid))
{
> > -         sk_record_tx_queue(sk, -1);
> > -         sk->sk_dst_cache = NULL;
> > -         dst_release(dst);
> > +         ___sk_dst_reset(sk, dst);
> >           dst = NULL;
> >        }
> >     }
>
> Encapsulation seems un-necessary to me, since only use cases are
> ___sk_dst_reset(sk, sk->sk_dst_cache)
>
>
> static inline void __sk_dst_reset(struct sock *sk)
> {
>    struct dst_entry *old_dst = sk->sk_dst_cache;
>
>    sk_record_tx_queue(sk, -1);
>      sk->sk_dst_cache = NULL;
>     dst_release(old_dst);
> }

That's right. For the IPv6 case, I can simply call __sk_dst_reset(sk).
I will make this change and remove [patch 5/5].

> Hmm, two remarks :
>
> 1) It adds a 32bits hole on 64bit arches
> 2) sk_tx_queue_mapping is only read in tx path, but sits close to
> skc_refcnt, which is now only read/written in rx path (by socket lookups)
>
> But since sock_common is small, 56 bytes on x86_64,(under a cache line),
> there is nothing we can do at this moment.
>
> My plan is to move skc_refcnt at the end of sock_common and I'll need to
add
> new generic fields into sock_common to make offsetof(skc_refcnt) = 64.
>
> Next to sock_common, will be placed fields used in rx path.

So that will fix this problem too as tx mapping will then be part of
read-cache line, I guess.

> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks for your feedback and approval. I will wait for any more comments
(on the ndo_select_queue also), and resubmit v2 tomorrow.

Thanks,

- KK

