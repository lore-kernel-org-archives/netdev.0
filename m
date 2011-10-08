From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Sat, 08 Oct 2011 10:57:18 +0200
Message-ID: <1318064238.5276.2.camel@edumazet-laptop>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <20111007.133356.489094996618032061.davem@davemloft.net>
	 <20111008075719.GA2284@netboy.at.omicron.at>
	 (sfid-20111008_095753_882744_64F82E9F)  <1318061808.3991.12.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53664 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab1JHI5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 04:57:24 -0400
Received: by wyg34 with SMTP id 34so4563939wyg.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 01:57:23 -0700 (PDT)
In-Reply-To: <1318061808.3991.12.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 08 octobre 2011 =C3=A0 10:16 +0200, Johannes Berg a =C3=A9cri=
t :

> I'm not terribly familiar with struct sock. Looking at it, I'm a bit
> confused by skb_orphan() -- it doesn't put the sock reference. So are
> sockets not refcounted for skbs in this way? They seem to use
> sock_wfree() which does a bit more than this it seems, and I don't se=
e
> it using sk_refcnt anywhere so I'm a bit confused now.

Check following commit changelog to get some information on this.

commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Jun 11 02:55:43 2009 -0700

    net: No more expensive sock_hold()/sock_put() on each tx
   =20
    One of the problem with sock memory accounting is it uses
    a pair of sock_hold()/sock_put() for each transmitted packet.
   =20
    This slows down bidirectional flows because the receive path
    also needs to take a refcount on socket and might use a different
    cpu than transmit path or transmit completion path. So these
    two atomic operations also trigger cache line bounces.
   =20
    We can see this in tx or tx/rx workloads (media gateways for exampl=
e),
    where sock_wfree() can be in top five functions in profiles.
   =20
    We use this sock_hold()/sock_put() so that sock freeing
    is delayed until all tx packets are completed.
   =20
    As we also update sk_wmem_alloc, we could offset sk_wmem_alloc
    by one unit at init time, until sk_free() is called.
    Once sk_free() is called, we atomic_dec_and_test(sk_wmem_alloc)
    to decrement initial offset and atomicaly check if any packets
    are in flight.
   =20
    skb_set_owner_w() doesnt call sock_hold() anymore
   =20
    sock_wfree() doesnt call sock_put() anymore, but check if sk_wmem_a=
lloc
    reached 0 to perform the final freeing.
   =20
    Drawback is that a skb->truesize error could lead to unfreeable soc=
kets, or
    even worse, prematurely calling __sk_free() on a live socket.
   =20
    Nice speedups on SMP. tbench for example, going from 2691 MB/s to 2=
711 MB/s
    on my 8 cpu dev machine, even if tbench was not really hitting sk_r=
efcnt
    contention point. 5 % speedup on a UDP transmit workload (depends
    on number of flows), lowering TX completion cpu usage.
