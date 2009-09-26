From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Sat, 26 Sep 2009 12:13:48 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909261151560.16276@gentwo.org>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com>
 <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com> <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1> <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1> <4AAF263E.9010405@gmail.com>
 <alpine.DEB.1.10.0909151000230.20318@V090114053VZO-1> <4AAFCE3A.8060102@gmail.com> <alpine.DEB.1.10.0909151550200.3340@V090114053VZO-1> <4ABCD18E.2010501@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:41842 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751260AbZIZQRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 12:17:54 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D511782C74D
	for <netdev@vger.kernel.org>; Sat, 26 Sep 2009 12:20:36 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9Z0LQSccpFWz for <netdev@vger.kernel.org>;
	Sat, 26 Sep 2009 12:20:32 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B898982C4E8
	for <netdev@vger.kernel.org>; Sat, 26 Sep 2009 12:20:29 -0400 (EDT)
In-Reply-To: <4ABCD18E.2010501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Sep 2009, Eric Dumazet wrote:

> With my current kernel on receiver (linux-2.6 32bit + some networking
> patches + SLUB_STATS) mcast -n1 -b eth3 -r 2000 on the sender (2.6.29
> unfortunatly, I cannot change it at this moment)

My tests are all done using SLAB since I wanted to exclude differences as
much as possible.

>           <idle>-0     [000] 13580.504040: __kmalloc_track_caller <-__alloc_skb
>           <idle>-0     [000] 13580.504040: get_slab <-__kmalloc_track_caller
>           <idle>-0     [000] 13580.504040: __slab_alloc <-__kmalloc_track_caller
>
> hmm... is it normal we call deactivate_slab() ?

deactivate_slab() is called when the slab page we are allocating from runs
out of objects or is not fit for allocation (we want objects from a
different node etc).

>            mcast-21429 [000] 13580.504066: sock_rfree <-skb_release_head_state
>            mcast-21429 [000] 13580.504066: skb_release_data <-__kfree_skb
>            mcast-21429 [000] 13580.504066: kfree <-skb_release_data
>            mcast-21429 [000] 13580.504066: __slab_free <-kfree
>
>   is it normal we call add_partial() ?

add_partial is called when we free objects in a slab page that had all
objects allocated before. Then it can be used for allocations again and
must be tracked. Fully allocated slab pages are not tracked.

> Too many slowpaths for 4096 slabs ?
>
> $ cd /sys/kernel/slab/:t-0004096
> $ grep . *
> aliases:1
> align:8
> grep: alloc_calls: Function not implemented
> alloc_fastpath:416584 C0=234119 C1=52938 C2=18413 C3=4739 C4=49140 C5=14679 C6=39266 C7=3290
> alloc_from_partial:459402 C0=459391 C1=8 C2=1 C5=2
> alloc_refill:459619 C0=459460 C1=54 C2=1 C3=4 C4=52 C5=31 C6=2 C7=15
> alloc_slab:103 C0=45 C1=28 C3=1 C4=26 C5=1 C6=1 C7=1
> alloc_slowpath:459628 C0=459462 C1=55 C2=2 C3=5 C4=53 C5=32 C6=3 C7=16

Hmmm. That is a high percentage. All are refills. So there are remote
frees from the other processor to the slab page the first processor
allocates from. One processor allocates the object and then pushes it to
the other for freeing? Bad for caching.

> free_slowpath:657340 C0=656835 C1=119 C2=76 C3=36 C4=159 C5=69 C6=15 C7=31

Also quite high. Consistent with remote freeing of objects allocated on
the first processors. Objects are very short lived.

> comments :
> - lots of disable_bh()/enable_bh(), (enable_bh is slow), that could be avoided...
> - many ktime_get() calls
> - my HZ=1000 setup might be stupid on a CONFIG_NO_HZ=y kernel :(

There are 8 objects per slab (order 3 allocation). You could maybe tune
things a bit increasing the objects per slab which may cut down on the #
of deactivate_slab() calls and will also reduce the need for
add_partial(). But I dont see either call causing significant latencies.

both calls should happen on every 8th or so call of kfree/kmalloc.0

To increase the objects per slab to 32:

boot with slub_max_order=5

and then

echo 5 >/sys/slab/kmalloc-4096/order

Would require order 5 allocations. Dont expect it to make too much of a
difference.

