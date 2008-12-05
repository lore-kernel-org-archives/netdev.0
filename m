From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: qmgr for ixp4xx
Date: Fri, 05 Dec 2008 17:03:06 +0100
Message-ID: <m31vwmlidh.fsf@maximus.localdomain>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	<m3zljby7jm.fsf@maximus.localdomain>
	<b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:44592 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbYLEQDJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 11:03:09 -0500
In-Reply-To: <b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Fri\, 5 Dec
 2008 09\:51\:18 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C3=81ngel =C3=81lvarez" <gotzoncabanes@gmail.com> writes:

>> The FIFOs are some internal property of HDLC controller (it isn't
>> documented but they probably connect the bus master DMA controller t=
o
>> the bit-stuffer and transmitter (and bit-destuffer and receiver in t=
he
>> RX path)). You just need to send a message to HSS to tell it the
>> correct value.
>>
> =C2=BFThe message is the HSS_CONFIG_CORE_CR containing the
> CCR_NPE_HFIFO_3_OR_4HDLC flag?

Well right, this one, too. I missed this one.

So it seems the following are needed (and 128-bit LUT):

#define PKT_NUM_PIPES           1 /* 1, 2 or 4 */
#define PKT_NUM_PIPES_WRITE             0x52

#define PKT_PIPE_FIFO_SIZEW     4 /* total 4 dwords per HSS */
(=3D 1 word for 4E1, 2 words for 2E1, 4 for 1E1)
#define PKT_PIPE_FIFO_SIZEW_WRITE       0x53

#define CCR_NPE_HFIFO_2_HDLC            0x04000000
#define CCR_NPE_HFIFO_3_OR_4HDLC        0x08000000
(to be set in the CORE register).

> I understand this, but I do not know exactly how to use it. I mean...
> - I have seen that more queues are added for tx and rxfree, but not r=
x
> or txdone... Are they not require?

The HSS uses 4 TX queues (each for 1 HDLC/packetized stream), and it
sends all used descriptors back to TXDONE queue (all 4 streams).

The same with RX, you have 4 RXFREE queues (=3D "RX empty" descriptors,
waiting for RX data), but when the data is ready, they are going back
to the CPU in a single RX queue. There is a stream# in the descriptor.

> - Must we use different txreadyq for each hdlc?

Yes, otherwise one HSS could grab all descriptors thus making the
other HSS (temporarily) unusable. Actually we need a TXREADY queues
per HDLC stream (4 per 4E1 port).

> - The values you have chosen for txreadyq are 2 and 19. Does it not
> conflict with HSS0_PKT_RXFREE1_QUEUE and HSS1_PKT_RXFREE1_QUEUE.

It does certainly conflict. For now there are no problems because MVIP
isn't supported. I guess we need 64-queue support. Fortunately, Karl
Hiramoto already has a patch for 64 queues, almost ready for merge.

We also have to make sure the queues don't conflict with the Ethernet
driver and (if used) with the crypto code.

> - I am not sure which documentation did you use for this (great)
> implementation of eth and hss. The intel manuals lack all information
> about this, so I am trying to check differences with Intel's software
> library (a nightmare),

I was using the library, though I processed it first with some custom
scripts to make it easier to read. Christian Hohnstaedt's code was
also a great help to understand what's going on.

> and have found that in "ixHssAccPktTxInternal"
> they add the hdlc port to the entry (which at last seemed to me that
> they were accessing consecutive memory positions from the entry for
> hdlc0).

Do you mean this?
/* Set the least significant 2 bits of the queue entry to the HDLC port=
 number. */
qEntry |=3D (hdlcPortId & IX_HSSACC_QM_Q_CHAN_NUM_MASK);

They want it when the packet is back in TXDONE queue.

> So that is why I thought acc represented the same thing.

No, acc is a private thing of queue manager. HSS code don't know about
it.

> What you are saying is that if I send the data to the correct
> tx queue, it will reach the correct FIFO... OK.

Yes.

> And reception? If I
> have only one reception queue how could I manage to know to which
> channel have I received the data?

The descriptor will have an ID in it.

> - Do you know where can it be found more information about this
> relation between queues, dmas and FIFOs? You are helping me greatly,
> but I do not want to make you loose so much time.

We only have ixp4xx library code. Few small minutes of my time are
not a problem when spent to help implement a useful feature.

I wonder what should I do now with all this. Perhaps integrating
Karl's 64-queue patch and making the HDLC part of HSS driver able to
be merged upstream... I will look if it does make sense.
--=20
Krzysztof Halasa
