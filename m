From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 1/2] udp: UDP Fast Port
Date: Tue, 29 Jul 2014 16:21:22 -0700
Message-ID: <CA+mtBx_kXTU8Dyn-bR8W2EnrZqU8Rp-2MeP2R2nv3L67aoh==Q@mail.gmail.com>
References: <alpine.DEB.2.02.1407261519050.27164@tomh.mtv.corp.google.com>
	<1406557222.12728.23.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140729.152937.71880257673026429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36809 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbaG2XVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 19:21:23 -0400
Received: by mail-ig0-f182.google.com with SMTP id c1so1864224igq.3
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 16:21:22 -0700 (PDT)
In-Reply-To: <20140729.152937.71880257673026429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2014 at 3:29 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 28 Jul 2014 16:20:22 +0200
>
>> On Sat, 2014-07-26 at 15:29 -0700, Tom Herbert wrote:
>>> This patch implements fast ports in UDP. The idea is that a kernel
>>> module registers a port and associated receive function. In UDP receive,
>>> the list of fast ports is scanned and the destinaton port is matched
>>> against the registered port. If there is a match, then the receive
>>> function is called to process the packet. When a UDP fast port is used,
>>> we can receive encap'ed packets without performing or accessing a
>>> socket. This is a performance gain, especially since we don't need to
>>> take socket ref count on every packet.
>>>
>>> Signed-off-by: Tom Herbert <therbert@google.com>
>>> ---
>>>  include/net/udp.h | 23 +++++++++++++++++++
>>>  net/ipv4/udp.c    | 69 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
>>>  net/ipv6/udp.c    | 21 +++++++++++++++--
>>>  3 files changed, 108 insertions(+), 5 deletions(-)
>>
>> I find this very hacky. I do not think we should have different sorts of
>> UDP sockets.
>>
>> If we believe we need a fast UDP path, without socket refcount being
>> touched, we should remove the SLAB_DESTROY_BY_RCU and switch to rcu
>> socket freeing (call_rcu())
>>
>> At the time we added RCU lookups to UDP, we hadn't vxlan, and fear was
>> that the extra RCU grace period at socket dismantle was too heavy cost,
>> like TCP sockets.
>>
>> Meanwhile, RCU cleanups got lot of attention, and UDP sockets serve as
>> tunnels vehicle.
>
> I remember trying to move socket destruction fully to call_rcu() and
> noticing real increases in socket create/destroy latency.
>
> But like Eric I dislike these special cased demux objects, just do
> something with real sockets, UDP demux is already too complex.
>
> One idea is to add a ->decap() operation to the proto ops, and if
> non-NULL the socket demux invokes the ->decap() while still in the RCU
> protected section and returns a NULL socket.  It would elide the
> refcount in this path as well.

We still need a context to do the decap though. If we were able to use
the socket only with rcu and without taking a reference we could just
call encap_rcv directly from the lookup. I suppose it might be
plausible to have socket point to another context data structure which
could be accessed with just rcu protection...
