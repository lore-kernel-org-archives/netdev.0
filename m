From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v4 2/9] bgmac: leave interrupts disabled as long as there
 is work to do
Date: Mon, 13 Apr 2015 18:35:12 +0200
Message-ID: <CACna6rzUoCvceFDKHkFmj8SwXJkL_v28fwNZx-6R5inQaS1+Yg@mail.gmail.com>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
	<1428933162-26763-2-git-send-email-nbd@openwrt.org>
	<CACna6rxgjUPdMsnhgvoRQLaOZ+T1epyvj3cDbZnYRtOeG0irtA@mail.gmail.com>
	<552BDACD.1050306@openwrt.org>
	<CACna6rzASVB-j8TxDzybC5FC+BhJFA-3e9LGTXqfP8FgSnH0bA@mail.gmail.com>
	<552BE444.8040906@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34731 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179AbbDMQfM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 12:35:12 -0400
Received: by iedfl3 with SMTP id fl3so79196384ied.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 09:35:12 -0700 (PDT)
In-Reply-To: <552BE444.8040906@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 April 2015 at 17:44, Felix Fietkau <nbd@openwrt.org> wrote:
> On 2015-04-13 17:06, Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 13 April 2015 at 17:03, Felix Fietkau <nbd@openwrt.org> wrote:
>>> On 2015-04-13 16:34, Rafa=C5=82 Mi=C5=82ecki wrote:
>>>> On 13 April 2015 at 15:52, Felix Fietkau <nbd@openwrt.org> wrote:
>>>>> Always poll rx and tx during NAPI poll instead of relying on the =
status
>>>>> of the first interrupt. This prevents bgmac_poll from leaving unf=
inished
>>>>> work around until the next IRQ.
>>>>> In my tests this makes bridging/routing throughput under heavy lo=
ad more
>>>>> stable and ensures that no new IRQs arrive as long as bgmac_poll =
uses up
>>>>> the entire budget.
>>>>
>>>> What do you think about keeping u32 int_status; and just updating =
it
>>>> at the end of bgmac_poll? In case you decide to implement multiple=
 TX
>>>> queues, it may be cheaper to just check a single bit in memory ins=
tead
>>>> reading DMA ring status.
>>> Events might arrive in the mean time. I ran some tests, and not che=
cking
>>> the irq status for processing rx/tx gave me fewer total IRQs under =
load.
>>
>> But you do check the status, I mean the following line:
>> if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BGMAC_IS_R=
X))
>>
>> Would it make sense to do
>> bgmac->int_status =3D bgmac_read(bgmac, BGMAC_INT_STATUS);
> I don't really see the point in storing the status from the initial I=
RQ.
>
> The check there is only to decide whether the poll function should ru=
n
> at all. By the time bgmac_poll is called, more events may have arrive=
d
> already, making the initial status useless.

Ah, I didn't think about delay between bgmac_poll calls.

All my point was to not call bgmac_dma_tx_free or bgmac_dma_rx_read
when not needed. Imagine having 4 TX queues and 1 RX queue. You will
read 4 BGMAC_DMA_TX_STATUS registers and 1 BGMAC_DMA_RX_STATUS
registers plus do some calculations every time. By reading
BGMAC_INT_STATUS (and checking its bits) you could avoid this. In
theory a very tiny optimization, no idea if worth implement, I'll
leave it up to you.

--=20
Rafa=C5=82
