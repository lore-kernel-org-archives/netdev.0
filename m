From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v3 net-next 2/6] net: mvneta: Use cacheable memory to
 store the rx buffer virtual address
Date: Tue, 29 Nov 2016 11:34:10 +0100
Message-ID: <CAPv3WKetQf_tqva2jaF1y79EWxDo3=yuvbK3jp2uFOqQSGweyA@mail.gmail.com>
References: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
 <a010f2cde3de80132d82acb2812b82343ea54c95.1480412215.git-series.gregory.clement@free-electrons.com>
 <CAPv3WKeFXJA1RjFZ5VoRfBtU+QGUx+AT3LYuoMHamQtNWCCMVA@mail.gmail.com> <87shqafv07.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Jisheng Zhang <jszhang@marvell.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Nadav Haklai <nadavh@marvell.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36712 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754395AbcK2KeL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 05:34:11 -0500
Received: by mail-io0-f173.google.com with SMTP id m5so143794313ioe.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 02:34:11 -0800 (PST)
In-Reply-To: <87shqafv07.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory,

2016-11-29 11:19 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
> Hi Marcin,
>
>  On mar., nov. 29 2016, Marcin Wojtas <mw@semihalf.com> wrote:
>
>> Hi Gregory,
>>
>> Another remark below, sorry for noise.
>>
>> 2016-11-29 10:37 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
>>> Until now the virtual address of the received buffer were stored in the
>>> cookie field of the rx descriptor. However, this field is 32-bits only
>>> which prevents to use the driver on a 64-bits architecture.
>>>
>>> With this patch the virtual address is stored in an array not shared with
>>> the hardware (no more need to use the DMA API). Thanks to this, it is
>>> possible to use cache contrary to the access of the rx descriptor member.
>>>
>>> The change is done in the swbm path only because the hwbm uses the cookie
>>> field, this also means that currently the hwbm is not usable in 64-bits.
>>>
>>> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
>>> ---
>>>  drivers/net/ethernet/marvell/mvneta.c | 93 ++++++++++++++++++++++++----
>>>  1 file changed, 81 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>>> index 1b84f746d748..32b142d0e44e 100644
>>> --- a/drivers/net/ethernet/marvell/mvneta.c
>>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>>> @@ -561,6 +561,9 @@ struct mvneta_rx_queue {
>>>         u32 pkts_coal;
>>>         u32 time_coal;
>>>
>>> +       /* Virtual address of the RX buffer */
>>> +       void  **buf_virt_addr;
>>> +
>>>         /* Virtual address of the RX DMA descriptors array */
>>>         struct mvneta_rx_desc *descs;
>>>
>>> @@ -1573,10 +1576,14 @@ static void mvneta_tx_done_pkts_coal_set(struct mvneta_port *pp,
>>>
>>>  /* Handle rx descriptor fill by setting buf_cookie and buf_phys_addr */
>>>  static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
>>> -                               u32 phys_addr, u32 cookie)
>>> +                               u32 phys_addr, void *virt_addr,
>>> +                               struct mvneta_rx_queue *rxq)
>>>  {
>>> -       rx_desc->buf_cookie = cookie;
>>> +       int i;
>>> +
>>>         rx_desc->buf_phys_addr = phys_addr;
>>> +       i = rx_desc - rxq->descs;
>>> +       rxq->buf_virt_addr[i] = virt_addr;
>>>  }
>>>
>>>  /* Decrement sent descriptors counter */
>>> @@ -1781,7 +1788,8 @@ EXPORT_SYMBOL_GPL(mvneta_frag_free);
>>>
>>>  /* Refill processing for SW buffer management */
>>>  static int mvneta_rx_refill(struct mvneta_port *pp,
>>> -                           struct mvneta_rx_desc *rx_desc)
>>> +                           struct mvneta_rx_desc *rx_desc,
>>> +                           struct mvneta_rx_queue *rxq)
>>>
>>>  {
>>>         dma_addr_t phys_addr;
>>> @@ -1799,7 +1807,7 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
>>>                 return -ENOMEM;
>>>         }
>>>
>>> -       mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
>>> +       mvneta_rx_desc_fill(rx_desc, phys_addr, data, rxq);
>>>         return 0;
>>>  }
>>>
>>> @@ -1861,7 +1869,12 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
>>>
>>>         for (i = 0; i < rxq->size; i++) {
>>>                 struct mvneta_rx_desc *rx_desc = rxq->descs + i;
>>> -               void *data = (void *)rx_desc->buf_cookie;
>>> +               void *data;
>>> +
>>> +               if (!pp->bm_priv)
>>> +                       data = rxq->buf_virt_addr[i];
>>> +               else
>>> +                       data = (void *)(uintptr_t)rx_desc->buf_cookie;
>>
>> Dropping packets for HWBM (in fact returning dropped buffers to the
>> pool) is done a couple of lines above. This point will never be
>
> indeed I changed the code at every place the buf_cookie was used and
> missed the fact that for HWBM this code was never reached.
>
>> reached with HWBM enabled (and it's also incorrect).
>
> What is incorrect?
>

Possible dma_unmapping + mvneta_frag_free for buffers in HWBM, when
dropping packets.

Thanks,
Marcin
