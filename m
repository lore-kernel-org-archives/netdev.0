From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v4 2/9] bgmac: leave interrupts disabled as long as there
 is work to do
Date: Mon, 13 Apr 2015 17:44:04 +0200
Message-ID: <552BE444.8040906@openwrt.org>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>	<1428933162-26763-2-git-send-email-nbd@openwrt.org>	<CACna6rxgjUPdMsnhgvoRQLaOZ+T1epyvj3cDbZnYRtOeG0irtA@mail.gmail.com>	<552BDACD.1050306@openwrt.org> <CACna6rzASVB-j8TxDzybC5FC+BhJFA-3e9LGTXqfP8FgSnH0bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:47649 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932615AbbDMPoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 11:44:11 -0400
In-Reply-To: <CACna6rzASVB-j8TxDzybC5FC+BhJFA-3e9LGTXqfP8FgSnH0bA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-13 17:06, Rafa=C5=82 Mi=C5=82ecki wrote:
> On 13 April 2015 at 17:03, Felix Fietkau <nbd@openwrt.org> wrote:
>> On 2015-04-13 16:34, Rafa=C5=82 Mi=C5=82ecki wrote:
>>> On 13 April 2015 at 15:52, Felix Fietkau <nbd@openwrt.org> wrote:
>>>> Always poll rx and tx during NAPI poll instead of relying on the s=
tatus
>>>> of the first interrupt. This prevents bgmac_poll from leaving unfi=
nished
>>>> work around until the next IRQ.
>>>> In my tests this makes bridging/routing throughput under heavy loa=
d more
>>>> stable and ensures that no new IRQs arrive as long as bgmac_poll u=
ses up
>>>> the entire budget.
>>>
>>> What do you think about keeping u32 int_status; and just updating i=
t
>>> at the end of bgmac_poll? In case you decide to implement multiple =
TX
>>> queues, it may be cheaper to just check a single bit in memory inst=
ead
>>> reading DMA ring status.
>> Events might arrive in the mean time. I ran some tests, and not chec=
king
>> the irq status for processing rx/tx gave me fewer total IRQs under l=
oad.
>=20
> But you do check the status, I mean the following line:
> if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BGMAC_IS_RX=
))
>=20
> Would it make sense to do
> bgmac->int_status =3D bgmac_read(bgmac, BGMAC_INT_STATUS);
I don't really see the point in storing the status from the initial IRQ=
=2E

The check there is only to decide whether the poll function should run
at all. By the time bgmac_poll is called, more events may have arrived
already, making the initial status useless.

- Felix
