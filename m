From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [RFC] tcp: How does SACK or FACK determine the time to start fast retransmition?
Date: Thu, 21 Jun 2012 01:42:43 -0700
Message-ID: <CAGK4HS_CN53EtQvPm2H7Qn85eXRz7hiEQvs3bU3xXpcNeg4byg@mail.gmail.com>
References: <CAAA3+BpRQ24HED6a+yCF+A_q=vJ7nHexLJd1U+-50pb43MVa5w@mail.gmail.com>
	<4FE2C03C.6030102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, kernelnewbies@kernelnewbies.org
To: =?UTF-8?B?5p2O5piT?= <lovelylich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:60037 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758853Ab2FUImp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 04:42:45 -0400
Received: by gglu4 with SMTP id u4so247015ggl.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 01:42:44 -0700 (PDT)
In-Reply-To: <4FE2C03C.6030102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 June 2012 23:33, =E6=9D=8E=E6=98=93 <lovelylich@gmail.com> wrote:
> HI all,
> =C2=A0 =C2=A0 When tcp uses reno as its congestion control algothim, =
it uses
> tp->sacked_out as dup-ack. When the third dup-ack(under default
> condition) comes, tcp will initiate its fast retransmition.
> =C2=A0 =C2=A0 But how about sack ?
> =C2=A0 =C2=A0 According to kernel source code comments, when sack or =
fack tcp option
> is enabled, there is no dup-ack counter. See comments for function
> tcp_dupack_heuristics():
> http://lxr.linux.no/linux+v2.6.37/net/ipv4/tcp_input.c#L2300
> =C2=A0 =C2=A0 So , how does tcp know the current dup-ack is the last =
one which
> triggers the fast retransmition?

With SACK, number of  dupacks does not have much meaning. What matters =
is
--how the SACK scoreboard looks like i.e. which packets are tagged
Lost/Sacked/Retransmitted
-- Whether FACK is in use (this assumes holes in between sacked
packets are lost and have left the network and so we can send out more
packets)

So, stack does not count the number of dupacks that have come in. Only
SACK blocks matter.
You can try to track the following path:
tcp_ack() deals with incoming acks and if it sees a dupack (does not
matter what number), or incoming packet contains SACK it calls
tcp_fastretrans_alert() which calls  tcp_xmit_retransmit_queue().

tcp_xmit_retransmit_queue() decides which packets to retransmit. The
first packet to start retransmitting from is tracked in
tp->retransmit_skb_hint.
Note that the dupThresh is actually tracked by tp->reordering which
measures  the reordering in the network and is not fixed at 3.  So, if
more than
tp->reordering packets have been acked above a given packet, this
packet is a candidate for retransmisson. See tcp_mark_head_lost() to
see how the
reordering metric is used to mark packets as lost. This corresponds to
the check you mentioned in the RFC.

So, window permitting, packets are sent as follows;
(a)-- Packets marked lost as per description above
(b)-- new packets (if any)
(c)-- Holes between sacked packets  which are not reliably lost.

choice between (b) and (c) is made in tcp_can_forward_retransmit().

Hope this helps.
Vijay
