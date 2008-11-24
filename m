From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] Could we avoid touching dst->refcount in some cases ?
Date: Mon, 24 Nov 2008 10:42:42 +0100
Message-ID: <87y6z9h33h.fsf@basil.nowhere.org>
References: <492A6C94.7030308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35617 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbYKXJmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 04:42:42 -0500
In-Reply-To: <492A6C94.7030308@cosmosbay.com> (Eric Dumazet's message of "Mon, 24 Nov 2008 09:57:56 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> writes:

> tbench has hard time incrementing decrementing the route cache refcount
> shared by all communications on localhost.

iirc there was a patch some time ago to use per CPU loopback devices to 
avoid this, but it was considered too much a benchmark hack.
As core counts increase it might stop being that though.

>
> On real world, we also have this problem on RTP servers sending many UDP
> frames to mediagateways, especially big ones handling thousand of streams.
>
> Given that route entries are using RCU, we probably can avoid incrementing
> their refcount in case of connected sockets ?

Normally they can be hold over sleeps or queuing of skbs too, and RCU
doesn't handle that. To make it handle that you would need to define a
custom RCU period designed for this case, but this would be probably
tricky and fragile: especially I'm not sure even if you had a "any
packet queued" RCU method it be guaranteed to always finish 
because there is no fixed upper livetime of a packet.

The other issue is that on preemptible kernels you would need to 
disable preemption all the time such a routing entry is hold, which
could be potentially quite long.

-Andi

-- 
ak@linux.intel.com
