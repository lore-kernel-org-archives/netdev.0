From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH 0/3][v2] tcp: fix ICMP-RTO war
Date: Mon, 08 Feb 2010 13:34:38 +0100
Message-ID: <op.u7s6j0qup498uc@nexus>
References: <4B635E17.406@tvk.rwth-aachen.de>
 <20100131.233338.254690877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:55994 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751032Ab0BHMem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 07:34:42 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KXI0034IW9T4R90@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 08 Feb 2010 13:34:41 +0100 (CET)
In-reply-to: <20100131.233338.254690877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 01.02.2010, 08:33 Uhr, schrieb David Miller <davem@davemloft.net>:

> From: Damian Lukowski <damian@tvk.rwth-aachen.de>
> Date: Fri, 29 Jan 2010 23:15:51 +0100
>
>> This patches fix the current RTO calculation routine, when
>> srtt and rttvar are zero, yielding an RTO of zero
>> Under some circumstances, TCPs srtt and rttvar are zero,
>> yielding a calculated RTO of zero.
>> This is particularly unfortunate for ICMP based RTO recalculation
>> as introduced in f1ecd5d9e736660 (Revert Backoff [v3]: Revert RTO
>> on ICMP destination unreachable), as it results in RTO retransmission
>> flooding.
>>
>> Thanks to Ilpo Jarvinen for providing debug patches and to
>> Denys Fedoryshchenko for reporting and testing.
>>
>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>
> I still haven't seen a detailed enough analysis of why these
> tiny RTOs can come to exist in the first place.
>
> Please show me a list of events, function by function, the value of
> relevant variables and per-socket TCP state, in the TCP stack, that
> show how this ends up happening.
>
> Thanks for all of your work on this so far.

I might have figured it out, but could not verify it, so maybe you can
comment my thought.

When a listening TCP receives a SYN, it will send a SYN+ACK
and wait for an ACK to complete the handshake.
Look at tcp_rcv_state_process::step 5::case SYN_RECV::acceptable
and the code after the comment "tcp_ack considers this ACK as duplicate
and does not calculate rtt".

If the connecting client has disabled timestamps, the rtt statistics
won't be updated here, while the state is changed above.
I printk'ed at the very end of TCP_SYN_RECV and got the following:
state 1 (ESTABLISHED), srtt 0, rttvar 0.

So my suspicion is: If connectivity breaks right after a listening TCP
has completed the handshake without timestamps, and the listening TCP
sends data after establishing the connection, we will get the observed
behaviour.

Regards
  Damian
