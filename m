From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: qmgr for ixp4xx
Date: Fri, 5 Dec 2008 17:59:17 +0100
Message-ID: <b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	 <m3zljby7jm.fsf@maximus.localdomain>
	 <b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
	 <m31vwmlidh.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:55859 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbYLEQ7S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 11:59:18 -0500
Received: by yx-out-2324.google.com with SMTP id 8so50621yxm.1
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2008 08:59:17 -0800 (PST)
In-Reply-To: <m31vwmlidh.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Fri, Dec 5, 2008 at 5:03 PM, Krzysztof Halasa <khc@pm.waw.pl> wrote:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>>> The FIFOs are some internal property of HDLC controller (it isn't
>>> documented but they probably connect the bus master DMA controller =
to
>>> the bit-stuffer and transmitter (and bit-destuffer and receiver in =
the
>>> RX path)). You just need to send a message to HSS to tell it the
>>> correct value.
>>>
>> =BFThe message is the HSS_CONFIG_CORE_CR containing the
>> CCR_NPE_HFIFO_3_OR_4HDLC flag?
>
> Well right, this one, too. I missed this one.
>
> So it seems the following are needed (and 128-bit LUT):
>
> #define PKT_NUM_PIPES           1 /* 1, 2 or 4 */
> #define PKT_NUM_PIPES_WRITE             0x52
>
> #define PKT_PIPE_FIFO_SIZEW     4 /* total 4 dwords per HSS */
> (=3D 1 word for 4E1, 2 words for 2E1, 4 for 1E1)
> #define PKT_PIPE_FIFO_SIZEW_WRITE       0x53
>
> #define CCR_NPE_HFIFO_2_HDLC            0x04000000
> #define CCR_NPE_HFIFO_3_OR_4HDLC        0x08000000
> (to be set in the CORE register).
>

Perfect... The ones I were using.

>> I understand this, but I do not know exactly how to use it. I mean..=
=2E
>> - I have seen that more queues are added for tx and rxfree, but not =
rx
>> or txdone... Are they not require?
>
> The HSS uses 4 TX queues (each for 1 HDLC/packetized stream), and it
> sends all used descriptors back to TXDONE queue (all 4 streams).
>
> The same with RX, you have 4 RXFREE queues (=3D "RX empty" descriptor=
s,
> waiting for RX data), but when the data is ready, they are going back
> to the CPU in a single RX queue. There is a stream# in the descriptor=
=2E
>
OK.

>> - Must we use different txreadyq for each hdlc?
>
> Yes, otherwise one HSS could grab all descriptors thus making the
> other HSS (temporarily) unusable. Actually we need a TXREADY queues
> per HDLC stream (4 per 4E1 port).
>
>> - The values you have chosen for txreadyq are 2 and 19. Does it not
>> conflict with HSS0_PKT_RXFREE1_QUEUE and HSS1_PKT_RXFREE1_QUEUE.
>
> It does certainly conflict. For now there are no problems because MVI=
P
> isn't supported. I guess we need 64-queue support. Fortunately, Karl
> Hiramoto already has a patch for 64 queues, almost ready for merge.
>
> We also have to make sure the queues don't conflict with the Ethernet
> driver and (if used) with the crypto code.
>
The queues are different for each NPE, aren' t they?

I will check for the 64-queue support patch (thanks Karl). However, if
I am not sure they are required. I mean...
- HSS0 uses queues 12-22.
- HSS1 uses queues 0-10.
- That leaves us 10 queues free, doesn't it? Couldn't we use queue 11
for eth txreadyq, 23-26 for HSS0 txreadyq, 27-30 for HSS1 txreadyq and
31 for crypto code (which I do not know?)

>> - I am not sure which documentation did you use for this (great)
>> implementation of eth and hss. The intel manuals lack all informatio=
n
>> about this, so I am trying to check differences with Intel's softwar=
e
>> library (a nightmare),
>
> I was using the library, though I processed it first with some custom
> scripts to make it easier to read. Christian Hohnstaedt's code was
> also a great help to understand what's going on.
>
I am trying to follow Intel's code... and it is difficult...

>> and have found that in "ixHssAccPktTxInternal"
>> they add the hdlc port to the entry (which at last seemed to me that
>> they were accessing consecutive memory positions from the entry for
>> hdlc0).
>
> Do you mean this?
> /* Set the least significant 2 bits of the queue entry to the HDLC po=
rt number. */
> qEntry |=3D (hdlcPortId & IX_HSSACC_QM_Q_CHAN_NUM_MASK);
>
> They want it when the packet is back in TXDONE queue.
>
Ummm? To know which queue should be refeeded? How could we do that?

>> So that is why I thought acc represented the same thing.
>
> No, acc is a private thing of queue manager. HSS code don't know abou=
t
> it.
>
OK.

>> What you are saying is that if I send the data to the correct
>> tx queue, it will reach the correct FIFO... OK.
>
> Yes.
>
Perfect.

>> And reception? If I
>> have only one reception queue how could I manage to know to which
>> channel have I received the data?
>
> The descriptor will have an ID in it.
>
Where?

>> - Do you know where can it be found more information about this
>> relation between queues, dmas and FIFOs? You are helping me greatly,
>> but I do not want to make you loose so much time.
>
> We only have ixp4xx library code. Few small minutes of my time are
> not a problem when spent to help implement a useful feature.
>
> I wonder what should I do now with all this. Perhaps integrating
> Karl's 64-queue patch and making the HDLC part of HSS driver able to
> be merged upstream... I will look if it does make sense.
>

I think your code is quite useful and structured, so it will be very
interesting to have it mainstream.

I was trying to improve your code to make it work in a 4E1. Before
making it configurable, I have made a first implementation considering
only my problem (which is not completely fixed yet). I will send you a
patch with my development (too large to add it in the list), so that
you could give me your oppinion if you want to. I would like to merge
it with your code when it is working (and the clean-up is made).

Thanks

Miguel =C1ngel
