From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH 0/3][v2] tcp: fix ICMP-RTO war
Date: Tue, 09 Feb 2010 23:29:08 +0100
Message-ID: <op.u7vsquqxp498uc@nexus>
References: <4B635E17.406@tvk.rwth-aachen.de>
 <20100131.233338.254690877.davem@davemloft.net> <op.u7s6j0qup498uc@nexus>
 <4B708913.906@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.1002091433230.7063@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:64779 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754373Ab0BIW3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 17:29:13 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KXL002VDIGOKW60@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 09 Feb 2010 23:29:12 +0100 (CET)
In-reply-to: <alpine.DEB.2.00.1002091433230.7063@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.02.2010, 13:37 Uhr, schrieb Ilpo J=C3=A4rvinen =20
<ilpo.jarvinen@helsinki.fi>:

> On Mon, 8 Feb 2010, Damian Lukowski wrote:
>
>> Damian Lukowski schrieb:
>> > Am 01.02.2010, 08:33 Uhr, schrieb David Miller <davem@davemloft.ne=
t>:
>> >
>> >> From: Damian Lukowski <damian@tvk.rwth-aachen.de>
>> >> Date: Fri, 29 Jan 2010 23:15:51 +0100
>> >>
>> >>> This patches fix the current RTO calculation routine, when
>> >>> srtt and rttvar are zero, yielding an RTO of zero
>> >>> Under some circumstances, TCPs srtt and rttvar are zero,
>> >>> yielding a calculated RTO of zero.
>> >>> This is particularly unfortunate for ICMP based RTO recalculatio=
n
>> >>> as introduced in f1ecd5d9e736660 (Revert Backoff [v3]: Revert RT=
O
>> >>> on ICMP destination unreachable), as it results in RTO =20
>> retransmission
>> >>> flooding.
>> >>>
>> >>> Thanks to Ilpo Jarvinen for providing debug patches and to
>> >>> Denys Fedoryshchenko for reporting and testing.
>> >>>
>> >>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>> >>
>> >> I still haven't seen a detailed enough analysis of why these
>> >> tiny RTOs can come to exist in the first place.
>> >>
>> >> Please show me a list of events, function by function, the value =
of
>> >> relevant variables and per-socket TCP state, in the TCP stack, th=
at
>> >> show how this ends up happening.
>> >>
>> >> Thanks for all of your work on this so far.
>> >
>> > I might have figured it out, but could not verify it, so maybe you=
 can
>> > comment my thought.
>> >
>> > When a listening TCP receives a SYN, it will send a SYN+ACK
>> > and wait for an ACK to complete the handshake.
>> > Look at tcp_rcv_state_process::step 5::case SYN_RECV::acceptable
>> > and the code after the comment "tcp_ack considers this ACK as =20
>> duplicate
>> > and does not calculate rtt".
>> >
>> > If the connecting client has disabled timestamps, the rtt statisti=
cs
>> > won't be updated here, while the state is changed above.
>> > I printk'ed at the very end of TCP_SYN_RECV and got the following:
>> > state 1 (ESTABLISHED), srtt 0, rttvar 0.
>> >
>> > So my suspicion is: If connectivity breaks right after a listening=
 TCP
>> > has completed the handshake without timestamps, and the listening =
TCP
>> > sends data after establishing the connection, we will get the obse=
rved
>> > behaviour.
>>
>> Just verified that by dropping pure ACKs coming from the originally
>> listening TCP using iptables.
>
> Isn't that "tcp_ack considers" comment like this: we have bug elsewhe=
re =20
> in
> the code but workaround it here, at least for some of the cases? (I'd=
 put
> it other way around: but alas, only for part of the cases.) ...It sou=
nd
> like that to me. What exactly is the reason why rtt shouldn't be
> calculated/initialized on such ACK, anything I'm missing?


The RTT is extracted when traversing tcp_write_queue_head() in
tcp_clean_rtx_queue() but is null when the SYNACK is acknowledged,
so it may have seemed to be a harder issue for the commentator.
I also have been thinking a while how to obtain the timestamp of the
sent SYNACK, but there is no need for it.
We just need to call tcp_ack_no_tstamp(), which will set the
RTO to 3 seconds as defined in RFC 2988.

Regards
   Damian
