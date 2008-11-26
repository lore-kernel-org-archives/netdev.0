From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Wed, 26 Nov 2008 01:09:09 +0100
Message-ID: <m3bpw3ic0q.fsf@maximus.localdomain>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	<m3fxlksncm.fsf@maximus.localdomain>
	<b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
	<b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
	<m3prkl14pf.fsf@maximus.localdomain>
	<b0438a630811240912v16db8ef8v660cb844979fe912@mail.gmail.com>
	<m3tz9wsmut.fsf@maximus.localdomain>
	<b0438a630811250851p18f5feabx7e744978555fa1d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38542 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240AbYKZAJM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 19:09:12 -0500
In-Reply-To: <b0438a630811250851p18f5feabx7e744978555fa1d1@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Tue\, 25 Nov
 2008 17\:51\:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> I think I do not make me understand myself... The question is: Do you
> know which message should I send to the NPE to configure it for MVIP
> mode?

You mean the low-level messages to NPE-A?

=46irst you need to set the frame length (max is 1024 bits)
and fill the LUT (the slot mapping table) correctly (max 128 slots).

If I understand and remember this correctly, for HDLC you need to send
PKT_NUM_PIPES_WRITE =3D 4 (or 2 for 2E1), and I think
PKT_PIPE_FIFO_SIZEW_WRITE must be reduced (to 1 for 4 HDLC pipes and
2 for 2 pipes?).

=46or channelized mode you need CHAN_NUM_CHANS_WRITE (0 - 128, number o=
f
active channels only).

Basically MVIP divides your entire frame into 2 or 4 parts.

> - If you have just one source of data, you can use packetized mode
> (and it does not care which clock rate you are using...).
> - If you have more than one sources of data and are working (for
> example) with an E1, you create a channel for each source, and the
> driver manages it.
> - But... If I want four sources of unstructured data (one for each
> "E1" in a 4E1), must I use a channelized mode, or a packetized mode?

These are unrelated.

a) all four E1s in 4E1 are completely independent. Their packetized
streams are, thus, independent as well. You may think about them as of
four (almost) separate physical interfaces. I think the NPE can do a
single HDLC stream over a 1024-bit frame, but this isn't technically
MVIP, it's a single logical interface with data rate up to 8 Mb/s.

b) packetized mode is mostly for HDLC. You need it if you want to have
=46rame-Relay, X.25, Cisco HDLC, synchronous PPP etc. over some
channels (timeslots) (partial E1/T1 etc) or over the full frame (all
channels). The chip has only one HDLC controller per logical interface
(E1 etc) so you can only have one HDLC stream per (member of MVIP) E1.

If you need multiple streams of packets (per logical interface), you
can use Frame-Relay with multiple PVCs, or, for example,
Ethernet-alike VLANs.

c) Channelized mode is for bit-transparent data - mainly voice
communications (circuit-switched, e.g. ISDN with 64 kb/s per channel),
or when you don't care what's being transmitted because you are only
forwarding the traffic (and not terminating it with e.g. HDLC).



You can have both channelized and packetized timeslots on your
interfaces (logical and physical). For purely packetized data ("full"
physical interface used by a single HDLC stream) you don't even need a
framer, because you don't care when the frame starts, or if there is
frame at all. Otherwise, you need a framer (for a single E1/(T1) there
is an experimental software framer, for MVIP you need a hardware
chip).


The clock is yet another thing independent of the above. If you
connect a DCE to the HSS, the DCE will usually provide the clock. The
(hardware) framers and/or E1/T1 transceivers will do as well.
The internal clock is usually needed when the HSS acts as DCE itself,
usually when you connect two similar devices together (two DTEs).
That's why it's currently fixed at 2 Mb/s, it's mostly for tests.
--=20
Krzysztof Halasa
