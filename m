From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Introduce FCLONE_SCRATCH skbs to reduce stack memory useage and
 napi jitter
Date: Fri, 28 Oct 2011 00:55:46 +0200
Message-ID: <1319756146.19125.42.camel@edumazet-laptop>
References: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35091 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029Ab1J0Wz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 18:55:57 -0400
Received: by wwe6 with SMTP id 6so4945568wwe.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 15:55:55 -0700 (PDT)
In-Reply-To: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 octobre 2011 =C3=A0 15:53 -0400, Neil Horman a =C3=A9crit :
> I had this idea awhile ago while I was looking at the receive path fo=
r multicast
> frames.   The top of the mcast recieve path (in __udp4_lib_mcast_deli=
ver, has a
> loop in which we traverse a hash list linearly, looking for sockets t=
hat are
> listening to a given multicast group.  For each matching socket we cl=
one the skb
> to enqueue it to the corresponding socket.  This creates two problems=
:
>=20
> 1) Application driven jitter in the receive path
>    As you add processes that listen to the same multcast group, you i=
ncrease the
> number of iterations you have to preform in this loop, which can lead=
 to
> increases in the amount of time you spend processing each frame in so=
ftirq
> context, expecially if you are memory constrained, and the skb_clone =
operation
> has to call all the way back into the buddy allocator for more ram.  =
This can
> lead to needlessly dropped frames as rx latency increases in the stac=
k.
>=20

Hmm... time to perform this loop not depends on memory constraints,
since GFP_ATOMIC allocations are done. It succeed or not, immediately.

Time is consumed on the copy of the skb head, and refcnt
increases/decreases on datarefcnt. Your patch doesnt avoid this.

When application calls recvmsg() we then perform the two atomics on skb
refcnt and data refcnt and free them, with cache line false sharing...

> 2) Increased memory usage
>    As you increase the number of listeners to a multicast group, you =
directly
> increase the number of times you clone and skb, putting increased mem=
ory
> pressure on the system.
>=20

One skb_head is about 256 bytes (232 bytes on 64bit arches)

> while neither of these problems is a huge concern, I thought it would=
 be nice if
> we could mitigate the effects of increased application instances on p=
erformance
> in this area.  As such I came up with this patch set.  I created a ne=
w skb
> fclone type called FCLONE_SCRATCH.  When available, it commandeers th=
e
> internally fragmented space of an skb data buffer and uses that to al=
locate
> additional skbs during the clone operation. Since the skb->data area =
is
> allocated with a kmalloc operation (and is therefore nominally a powe=
r of 2 in
> size), and nominally network interfaces tend to have an mtu of around=
 1500
> bytes, we typically can reclaim several hundred bytes of space at the=
 end of an
> skb (more if the incomming packet is not a full MTU in size).  This s=
pace, being
> exclusively accessible to the softirq doing the reclaim, can be quick=
ly accesed
> without the need for additional locking, potntially providing lower j=
itter in
> napi context per frame during a receive operation, as well as some me=
mory
> savings.
>=20
> I'm still collecting stats on its performance, but I thought I would =
post now to
> get some early reviews and feedback on it.
>=20

I really doubt you'll find a significative performance increase.

I do believe its a too complex : skb code is already a nightmare if you
ask me.

And your hack/idea wont work quite well if you have 8 receivers for eac=
h
frame.

What about finding another way to queue one skb to N receive queue(s),
so that several multicast sockets can share same skb head ?

I always found sk_receive queue being very inefficient, since a queue o=
r
dequeue must dirty a lot of cache lines.

This forces us to use a spinlock to protect queue/enqueue operations,
but also the socket lock (because of the MSG_PEEK stuff and
sk_rmem_alloc / sk_forward_alloc)

sk_receive_queue.lock is the real jitter source.

Ideally, we could have a fast path using a small circular array per
socket, of say 8 or 16 pointers to skbs, or allow application or
sysadmin to size this array.

A circular buffer can be handled without any lock, using atomic
operations (cmpxchg()) on load/unload indexes. The array of pointers is
written only by the softirq handler cpu, read by consumers.

Since this array is small [and finite size], and skb shared, we dont
call skb_set_owner_r() anymore, avoiding expensive atomic ops on
sk->sk_rmem_alloc.

UDP receive path could become lockless, allowing the softirq handler to
run without being slowed down by concurrent recvmsg()

At recvmsg() time, N-1 threads would only perform the skb->refcnt
decrement, and the last one would free the skb and data as well.
