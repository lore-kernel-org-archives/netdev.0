From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 13:24:11 +0530
Message-ID: <OF802D1BE7.C2709B61-ON65257703.00235EF5-65257703.002B5F38@in.ibm.com>
References: <201004112338.47019.nuclearcat@nuclearcat.com>	 <1271025353.2078.155.camel@edumazet-laptop>
	 <OF19A2A36F.5B268C61-ON65257703.0012EB6A-65257703.0013F81C@in.ibm.com> <1271052111.2078.168.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Denys Fedorysychenko <nuclearcat@nuclearcat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:47831 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab0DLHxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 03:53:54 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id o3C7rm5G014429
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 13:23:48 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3C7rmg13256412
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 13:23:48 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3C7rlfw022731
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 13:23:48 +0530
In-Reply-To: <1271052111.2078.168.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for your patch, just one question on it though:

Eric Dumazet <eric.dumazet@gmail.com> wrote on 04/12/2010 11:31:51 AM:

> > When route changes, I think my patch had reset sk->sk_tx_queue_mapping
> > by calling sk_tx_queue_clear. I don't know if I missed any path where
> > the route changes and sk_dst_reset() was not called.
> >
>
> Problem is when you reset sk->sk_tx_queue_mapping at the very moment
> route (or destination) changes, we might have old packets queued in tx
> queues, of the old ethernet device (eth0 : multi queue compatable)

> 2) Application does a sendmsg() or connect() call and sk->sk_dst_cache
> is rebuild, it points to a dst_entry referring a new device (eth1 : non
> multiqueue)
>
> 3) When one old packet finally is transmitted, we do :
>
>    queue_index = 1; // any value > 0
>
>    if (sk && sk->sk_dst_cache)
>       sk_tx_queue_set(sk, queue_index); // remember a >0 value
>
> 4) application does a sendmsg(), enqueues a new skb on eth1
>
> 5) We re-enter dev_pick_tx(), and consider cached value in 3) is valid.
>    we pick a non existent txq for eth1 device.
>
> 6) We crash.
>
> > The following might be better to prove the panic is due to this, since
> > your suggestion will hide a panic that happens somewhat rare (according
> > to Denys):
> >
> >       if (sk_tx_queue_recorded(sk)) {
> >             queue_index = sk_tx_queue_get(sk);
> > +           queue_index = dev_cap_txqueue(dev, queue_index);
> >       } else {
> >
>
> Sure, but I thought I was clear enough to prove this commit was wrong,
> and we have to find a fix.

If the dst got changed between call to vlan_dev_hwaccel_hard_start_xmit
and it's call to dev_queue_xmit, that change to dst should have reset
sk_tx_queue_mapping to -1 by calling sk_tx_queue_clear (assuming that I
have changed in all paths, eg __sk_dst_reset), and thus result in a new
mapping in dev_pick_tx. Would the patch hide the actual bug where we do
not clear sk_tx_queue_mapping, eg __sk_dst_set does it? I agree the
patch will fix the panic, but this check could be removed if the code
which changes the dst is fixed to clear the mapping. I could check that
if you think this assumption is correct.

Thanks,

- KK

