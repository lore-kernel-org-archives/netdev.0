From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v4 2/9] bgmac: leave interrupts disabled as long as there
 is work to do
Date: Mon, 13 Apr 2015 17:03:41 +0200
Message-ID: <552BDACD.1050306@openwrt.org>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>	<1428933162-26763-2-git-send-email-nbd@openwrt.org> <CACna6rxgjUPdMsnhgvoRQLaOZ+T1epyvj3cDbZnYRtOeG0irtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:46254 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753826AbbDMPDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 11:03:51 -0400
In-Reply-To: <CACna6rxgjUPdMsnhgvoRQLaOZ+T1epyvj3cDbZnYRtOeG0irtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-13 16:34, Rafa=C5=82 Mi=C5=82ecki wrote:
> On 13 April 2015 at 15:52, Felix Fietkau <nbd@openwrt.org> wrote:
>> Always poll rx and tx during NAPI poll instead of relying on the sta=
tus
>> of the first interrupt. This prevents bgmac_poll from leaving unfini=
shed
>> work around until the next IRQ.
>> In my tests this makes bridging/routing throughput under heavy load =
more
>> stable and ensures that no new IRQs arrive as long as bgmac_poll use=
s up
>> the entire budget.
>=20
> What do you think about keeping u32 int_status; and just updating it
> at the end of bgmac_poll? In case you decide to implement multiple TX
> queues, it may be cheaper to just check a single bit in memory instea=
d
> reading DMA ring status.
Events might arrive in the mean time. I ran some tests, and not checkin=
g
the irq status for processing rx/tx gave me fewer total IRQs under load=
=2E

>> @@ -1237,25 +1234,17 @@ static irqreturn_t bgmac_interrupt(int irq, =
void *dev_id)
>>  static int bgmac_poll(struct napi_struct *napi, int weight)
>>  {
>>         struct bgmac *bgmac =3D container_of(napi, struct bgmac, nap=
i);
>> -       struct bgmac_dma_ring *ring;
>>         int handled =3D 0;
>>
>> -       if (bgmac->int_status & BGMAC_IS_TX0) {
>> -               ring =3D &bgmac->tx_ring[0];
>> -               bgmac_dma_tx_free(bgmac, ring);
>> -               bgmac->int_status &=3D ~BGMAC_IS_TX0;
>> -       }
>> +       /* Ack */
>> +       bgmac_write(bgmac, BGMAC_INT_STATUS, ~0);
>=20
> Is this OK to ack every IRQ, even un handled ones?
Yes. The only IRQ types that matter are the ones handled by the poll
function.

>> +       /* poll again if more events arrived in the mean time */
>> +       if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BG=
MAC_IS_RX))
>> +               return handled;
>=20
> s/mean time/meantime/ (or meanwhile)
> And if you care to keep one type of comments:
> s/poll/Poll/
Will do.

- Felix
