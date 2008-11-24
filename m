From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] Could we avoid touching dst->refcount in some cases ?
Date: Mon, 24 Nov 2008 11:14:29 +0100
Message-ID: <492A7E85.3060502@cosmosbay.com>
References: <492A6C94.7030308@cosmosbay.com> <87y6z9h33h.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34920 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbYKXKOc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 05:14:32 -0500
In-Reply-To: <87y6z9h33h.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>=20
>> tbench has hard time incrementing decrementing the route cache refco=
unt
>> shared by all communications on localhost.
>=20
> iirc there was a patch some time ago to use per CPU loopback devices =
to=20
> avoid this, but it was considered too much a benchmark hack.
> As core counts increase it might stop being that though.

Well, you probably mention Stephen patch to avoid dirtying other conten=
ded
cache lines (one napi structure per cpu)

Having multiple loopback dev would really be a hack I agree.

>=20
>> On real world, we also have this problem on RTP servers sending many=
 UDP
>> frames to mediagateways, especially big ones handling thousand of st=
reams.
>>
>> Given that route entries are using RCU, we probably can avoid increm=
enting
>> their refcount in case of connected sockets ?
>=20
> Normally they can be hold over sleeps or queuing of skbs too, and RCU
> doesn't handle that. To make it handle that you would need to define =
a
> custom RCU period designed for this case, but this would be probably
> tricky and fragile: especially I'm not sure even if you had a "any
> packet queued" RCU method it be guaranteed to always finish=20
> because there is no fixed upper livetime of a packet.
>=20
> The other issue is that on preemptible kernels you would need to=20
> disable preemption all the time such a routing entry is hold, which
> could be potentially quite long.
>=20

Well, in case of UDP, we call ip_push_pending_frames() and this one
does the increment of refcount (again). I was not considering
avoiding the refcount hold we do when queing a skb in transmit
queue, only during a short period of time. Oh well, ip_append_data()
might sleep, so this cannot work...

I agree avoiding one refcount increment/decrement is probably
not a huge gain, considering we *have* to do the increment,
but when many cpus are using UDP send/receive in //, this might
show a gain somehow.

So maybe we could make ip_append_data() (or its callers) a
litle bit smarter, avoiding increment/decrement if possible.

