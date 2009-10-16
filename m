From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 1/4 v2] net: Introduce sk_tx_queue_mapping
Date: Fri, 16 Oct 2009 18:28:37 +0530
Message-ID: <OF57EE3C38.CD9A83EC-ON65257651.00405FE1-65257651.0047491F@in.ibm.com>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain> <20091016072120.24384.54449.sendpatchset@localhost.localdomain> <4AD84375.9020400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:43758 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621AbZJPM7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 08:59:42 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9GCwqLS032042
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:28:52 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9GCwpoS1994794
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:28:51 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9GCwpHR012119
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 23:58:51 +1100
In-Reply-To: <4AD84375.9020400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 10/16/2009 03:27:09 PM:

>
> > Introduce sk_tx_queue_mapping; and functions that set, test and get
> > this value. Reset sk_tx_queue_mapping to -1 whenever the dst cache
> > is set/reset, and in socket alloc & free (free probably doesn't need
> > it).
> >
>
> Could you please use an u16 instead, and take the convention of 0
> being the 'unitialized value' ?

I wanted to use a signed number to avoid doing an unnecessary sub
on every iteration. I feel u16 is good for incoming path since
skb->queue_mapping is set to 0 by default, and only those drivers
doing rx recording needs to set this value. So queue_mapping reqd
the logic of using !0 to mean rx is set and the subsequent sub on
all retrieves. But on tx path where sk->txq# is saved permanently,
I feel it is not required.

If that sounds reasonable, I can change to a signed short.

> And define sk_tx_queue_clear(sk) instead of sk_record_tx_queue(sk, -1);
>
> I also suggest using following names :
>
> static inline void sk_tx_queue_set(struct sock *sk, u16 tx_queue)
> {
>    sk->sk_tx_queue_mapping = tx_queue + 1;
> }
>
> static inline u16 sk_tx_queue_get(const struct sock *sk)
> {
>    return sk->sk_tx_queue_mapping - 1;
> }
>
> static inline u16 sk_tx_queue_clear(struct sock *sk) // or _reset
> {
>    sk->sk_tx_queue_mapping = 0;
> }
>
> static inline bool sk_tx_queue_recorded(const struct sock *sk)
> {
>    return (sk && sk->sk_tx_queue_mapping > 0);
> }
> >
> > @@ -1016,6 +1019,8 @@ static void sk_prot_free(struct proto *p
> >     struct kmem_cache *slab;
> >     struct module *owner;
> >
> > +   sk_record_tx_queue(sk, -1);
> > +
> >     owner = prot->owner;
> >     slab = prot->slab;
> >
>
> This is not necessary, we are going to kfree(sk) anyway !

Yes, will make these changes, but please let me know your opinion on
"return sk->sk_tx_queue_mapping - 1" vs "return sk->sk_tx_queue_mapping".

Thanks,

- KK

