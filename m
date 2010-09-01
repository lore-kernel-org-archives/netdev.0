From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Wed, 1 Sep 2010 09:24:18 -0700
Message-ID: <AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
References: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
	<20100823105933.27cd0b80@nehalam>
	<AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
	<1283356463.2556.351.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:51177 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032Ab0IAQY2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 12:24:28 -0400
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o81GOQAd024521
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 09:24:26 -0700
Received: from gxk24 (gxk24.prod.google.com [10.202.11.24])
	by wpaz5.hot.corp.google.com with ESMTP id o81GOEKC014158
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 09:24:25 -0700
Received: by gxk24 with SMTP id 24so3579967gxk.13
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 09:24:25 -0700 (PDT)
In-Reply-To: <1283356463.2556.351.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 1, 2010 at 8:54 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 01 septembre 2010 =E0 08:41 -0700, Tom Herbert a =E9crit =
:
>> > Why don't we do this in the normal transmit processing.
>> > There is already so much policy mechanism filters/actions/qdisc th=
at
>> > doing it in higher level is fighting against these.
>> >
>> Are you proposing that TX queue selection be done in the qdiscs? =A0=
The
>> queue has to be selected before taking the lock (cannot afford takin=
g
>> a lock over the whole interface). =A0This would necessitate moving t=
he
>> locking and probably rearranging a lot of the xmit code around that.
>
> Stephen point is not adding yet another layer 'before' qdisc layer.
>
> I would like something not as complex as your patch.
>
> 1) Why current selection fails ?
>
Current selection does a hash on 4-tuple to map packets to queues.  So
any CPU can send on any queue which leads to cache line bouncing of
transmit structures.  Also when sending from one CPU to a queue whose
transmit interrupt is on a CPU in another cache domain cause more
cache line bouncing with transmit completion.  So while the current
scheme nicely distributes load across the queues, it does nothing  to
promote locality.  Getting some reasonable locality is where the
benefits come from that we are demonstrating.

> 2) Could we change current selection to :
>
> =A0- Use a lightweight selection, with no special configuration.
>
> =A0- Use driver RX multiqueue information if available, in a one-to-o=
ne
> relationship.
>
Not generally.  It's very possible that the only a subset of CPUs are
getting RX interrupts in multiqueue (consider when #queues < #CPUs),
so there's really not an obvious 1-1 relationship.  But each CPU can
send and should be mapped to at least one transmit queue; the most
obvious plan would be to send in a queue in the same cache domain.

> 3) Eventually have a user selectable selection (socket option, or sys=
tem
> wide, but one sysctl, not many bitmasks ;) ).
>
Right, but it would also be nice if a single sysctl could optimally
set up multiqueue, RSS, RPS, and all my interrupt affinities for me
;-)

Tom
