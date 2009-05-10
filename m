From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Sun, 10 May 2009 09:09:18 +0200
Message-ID: <4A067D9E.7050706@cosmosbay.com>
References: <20090508.144859.152310605.davem@davemloft.net>	<4A057387.4080308@cosmosbay.com>	<20090509.133454.111098477.davem@davemloft.net> <20090509.134002.258408495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36373 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbZEJHJe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 03:09:34 -0400
In-Reply-To: <20090509.134002.258408495.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Sat, 09 May 2009 13:34:54 -0700 (PDT)
>=20
>> Consider the case where we always send some message on CPU A and
>> then process the ACK on CPU B.  We'll always be cancelling the
>> timer on a foreign cpu.
>=20
> I should also mention that TCP has a peculiar optimization of timers
> that is likely being thwarted by your workload.  It never deletes
> timers under normal operation, it simply lets them still expire
> and the handler notices that there is "nothing to do" and returns.

Yes, you refer to INET_CSK_CLEAR_TIMERS condition, never set.

>=20
> But when the connection does shut down, we have to purge all of
> these timers.
>=20
> That could be another part of why you see timers in your profile.
>=20
>=20

Well, in my workload they should never expire, since application exchan=
ge
enough data on both direction, and they are no losses (Gigabit LAN cont=
ext)

On machine acting as a server (the one I am focusing to, of course),
each incoming frame :

- Contains ACK for the previous sent frame
- Contains data provided by the client.
- Starts a timer for delayed ACK

Then server applications reacts and sends a new payload, and TCP stack
- Sends a frame including ACK for previous received frame
- Contains data provided by server application
- Starts a timer for retransmiting this frame if no ACK is received lat=
er.

So yes, each incoming and each outgoing frame is going to call mod_time=
r()

Problem is that incoming process is done by CPU 0 (the one that is dedi=
cated
to NAPI processing because of stress situation, cpu 100% in softirq lan=
d),
and outgoing processing done by other cpus in the machine.

offsetof(struct inet_connection_sock, icsk_retransmit_timer)=3D0x208
offsetof(struct inet_connection_sock, icsk_delack_timer)=3D0x238

So there are cache line ping-pongs, but oprofile seems to point
to a spinlock contention in lock_timer_base(), I dont know why...
shouldnt (in my workload) delack_timer all belongs to cpu 0, and=20
retransmit_timers to other cpus ?=20

Or is mod_timer never migrates an already established timer ?

That would explain the lock contention on timer_base, we should
take care of it if possible.

Thanks David


