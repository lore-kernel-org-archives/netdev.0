From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: qmgr for ixp4xx
Date: Fri, 5 Dec 2008 09:51:18 +0100
Message-ID: <b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	 <m3zljby7jm.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:39365 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbYLEIvU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 03:51:20 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1922672yxm.1
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2008 00:51:18 -0800 (PST)
In-Reply-To: <m3zljby7jm.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

2008/12/4 Krzysztof Halasa <khc@pm.waw.pl>:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>> As I am trying to use my HSSs as 4E1, I find that the FIFOs for each
>> HDLC should be 1 word wide and not 4 words wide. I think that this
>> finally means that when accessing the queues, I have to do the
>> following modification.
>>
>> +++ linux-2.6.26.7/include/asm-arm/arch-ixp4xx/qmgr.h 2008-12-02
>> 10:47:23.000000000 +0100
>> @@ -67,16 +67,17 @@
>>  void qmgr_release_queue(unsigned int queue);
>>
>>
>> -static inline void qmgr_put_entry(unsigned int queue, u32 val)
>> +static inline void qmgr_put_entry(unsigned int queue, unsigned int =
pipe,
>> +                   u32 val)
>>  {
>>       extern struct qmgr_regs __iomem *qmgr_regs;
>> -     __raw_writel(val, &qmgr_regs->acc[queue][0]);
>> +     __raw_writel(val, &qmgr_regs->acc[queue][pipe]);
>>  }
>>
>> -static inline u32 qmgr_get_entry(unsigned int queue)
>> +static inline u32 qmgr_get_entry(unsigned int queue, unsigned int p=
ipe)
>>  {
>>       extern struct qmgr_regs __iomem *qmgr_regs;
>> -     return __raw_readl(&qmgr_regs->acc[queue][0]);
>> +     return __raw_readl(&qmgr_regs->acc[queue][pipe]);
>>  }
>
> The FIFOs are some internal property of HDLC controller (it isn't
> documented but they probably connect the bus master DMA controller to
> the bit-stuffer and transmitter (and bit-destuffer and receiver in th=
e
> RX path)). You just need to send a message to HSS to tell it the
> correct value.
>
=BFThe message is the HSS_CONFIG_CORE_CR containing the
CCR_NPE_HFIFO_3_OR_4HDLC flag?

> Queues, on the other hand, can be 1, 2 or 4-words wide (32, 64 or 128
> bits). I think nothing uses/needs 2 or 4-word queues so they aren't
> implemented.
>
> 4E1 mode uses the same 1-word queues. It just uses more queues :-)

I understand this, but I do not know exactly how to use it. I mean...
- I have seen that more queues are added for tx and rxfree, but not rx
or txdone... Are they not require?
- Must we use different txreadyq for each hdlc?
- The values you have chosen for txreadyq are 2 and 19. Does it not
conflict with HSS0_PKT_RXFREE1_QUEUE and HSS1_PKT_RXFREE1_QUEUE.
Shouldn't we use 23 and 24 (for example)?
- I am not sure which documentation did you use for this (great)
implementation of eth and hss. The intel manuals lack all information
about this, so I am trying to check differences with Intel's software
library (a nightmare), and have found that in "ixHssAccPktTxInternal"
they add the hdlc port to the entry (which at last seemed to me that
they were accessing consecutive memory positions from the entry for
hdlc0). So that is why I thought acc represented the same thing. If
not... What you are saying is that if I send the data to the correct
tx queue, it will reach the correct FIFO... OK. And reception? If I
have only one reception queue how could I manage to know to which
channel have I received the data?
- Do you know where can it be found more information about this
relation between queues, dmas and FIFOs? You are helping me greatly,
but I do not want to make you loose so much time.

Thanks

Miguel =C1ngel =C1lvarez
