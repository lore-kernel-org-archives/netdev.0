From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Fri, 13 Mar 2009 23:30:31 +0100
Message-ID: <49BADE87.40407@cosmosbay.com>
References: <49B3F655.6030308@cosmosbay.com>	<20090308.194922.267426196.davem@davemloft.net>	<49B4B909.7050002@cosmosbay.com> <20090313.145152.121603300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org, bmb@athenacr.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46303 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbZCMWbq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:31:46 -0400
In-Reply-To: <20090313.145152.121603300.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 09 Mar 2009 07:36:57 +0100
>=20
>> I chose cmpxchg() because I needed some form of exclusion here.
>> I first added a spinlock inside "struct softirq_del" then I realize
>> I could use cmpxchg() instead and keep the structure small. As the
>> synchronization is only needed at queueing time, we could pass
>> the address of a spinlock XXX to sofirq_del() call.
>=20
> I don't understand why you need the mutual exclusion in the
> first place.  The function pointer always has the same value.
> And this locking isn't protecting the list insertion either,
> as that isn't even necessary.
>=20
> It just looks like plain overhead to me.

I was lazy to check all callers (all protocols) had a lock on sock,
and prefered safety.

I was fooled by the read_lock(), and though several cpus could call
this function in //


>=20
>> Also, when an event was queued for later invocation, I also needed t=
o keep
>> a reference on "struct socket" to make sure it doesnt disappear befo=
re
>> the invocation. Not all sockets are RCU guarded (we added RCU only f=
or=20
>> some protocols (TCP, UDP ...). So I found keeping a read_lock
>> on callback was the easyest thing to do. I now realize we might
>> overflow preempt_count, so special care is needed.
>=20
> You're using this in UDP so... make the rule that you can't use
> this with a non-RCU-quiescent protocol.

UDP/TCP only ? I though many other protocols (not all using RCU) were
using sock_def_readable() too...


