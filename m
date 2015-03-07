From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH] bgmac: ratelimit warning messages
Date: Sat, 7 Mar 2015 10:39:10 +0100
Message-ID: <CA+MoWDqir8MOaY1j=+BqCZGrkqP+mPUsCui84-Gex8=hUyZSDg@mail.gmail.com>
References: <1425665874-14870-1-git-send-email-peter.senna@gmail.com>
	<CACna6rz32WFHNNRLFNDv2E6RBcT_7vFYTOEu66ubvUCQz48udw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	Joe Perches <joe@perches.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:37093 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757121AbbCGJjM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 04:39:12 -0500
In-Reply-To: <CACna6rz32WFHNNRLFNDv2E6RBcT_7vFYTOEu66ubvUCQz48udw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 7, 2015 at 12:27 AM, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.=
com> wrote:
> On 6 March 2015 at 19:17, Peter Senna Tschudin <peter.senna@gmail.com=
> wrote:
>> On my test environment the troughput of a file transfer drops from
>> 4.4Mbps to 116Kbps due the number of repeated warning messages.
>> Adding printk_ratelimit() solves the issue without removing the
>> warning message.
>>
>> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
>> ---
>>  drivers/net/ethernet/broadcom/bgmac.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/eth=
ernet/broadcom/bgmac.c
>> index 676ffe0..d1a259b 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>> @@ -302,7 +302,7 @@ static int bgmac_dma_rx_skb_for_slot(struct bgma=
c *bgmac,
>>         slot->skb =3D skb;
>>         slot->dma_addr =3D dma_addr;
>>
>> -       if (slot->dma_addr & 0xC0000000)
>> +       if ((slot->dma_addr & 0xC0000000) && printk_ratelimit())
>>                 bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(=
s), it may need translation trick\n");
>>
>>         return 0;
>
> Nack. Please just drop this code.
>
> From what I understand network works for you. I've also checked
> Broadcom's open source code, and on SoC we can always safely write
> whole low 32b.

Yes, it works for me, even after:

-CONFIG_PAGE_OFFSET=3D0xC0000000
+CONFIG_PAGE_OFFSET=3D0x40000000
=2E..
+CONFIG_VMSPLIT_1G=3Dy
+# CONFIG_VMSPLIT_3G is not set

The page offset change was made by make menuconfig as a consequence of
CONFIG_VMSPLIT_1G. After the Kconfig changes the throughput is almost
40 times worst, but commenting the warnings fixes the issue. I'll send
V2 removing the messages completely.


--=20
Peter
