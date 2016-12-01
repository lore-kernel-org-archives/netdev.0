From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v5 net-next 4/7] net: mvneta: Convert to be 64 bits compatible
Date: Thu, 1 Dec 2016 12:48:39 +0100
Message-ID: <CAPv3WKeJBL7_V_7QPVNDAd9H4bgeLcSF8enuD96sgEmecuRkRA@mail.gmail.com>
References: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
 <6b4d20a85b05e93d254e265eb07569dd1285d303.1480542157.git-series.gregory.clement@free-electrons.com>
 <20161201192604.07ed9516@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
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
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33075 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757406AbcLALsk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 06:48:40 -0500
Received: by mail-io0-f176.google.com with SMTP id j65so417566181iof.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 03:48:40 -0800 (PST)
In-Reply-To: <20161201192604.07ed9516@xhacker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jisheng,

Which baseline do you use?

It took me really lot of time to catch why RX broke after rebase from
LKv4.1 to LKv4.4. Between those two, in commit:
97303480753e ("arm64: Increase the max granular size")
L1_CACHE_BYTES for all ARMv8 platforms was increased to 128B and so
did NET_SKB_PAD.

And 128 is more than the maximum that can fit into packet offset
[11:8]@0x1400. In such case this correction is needed. Did it answer
your doubts?

Best regards,
Marcin



2016-12-01 12:26 GMT+01:00 Jisheng Zhang <jszhang@marvell.com>:
> Hi Gregory, Marcin,
>
> On Wed, 30 Nov 2016 22:42:49 +0100 Gregory CLEMENT wrote:
>
>> From: Marcin Wojtas <mw@semihalf.com>
>>
>> Prepare the mvneta driver in order to be usable on the 64 bits platform
>> such as the Armada 3700.
>>
>> [gregory.clement@free-electrons.com]: this patch was extract from a larger
>> one to ease review and maintenance.
>>
>> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
>> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> ---
>>  drivers/net/ethernet/marvell/mvneta.c | 17 ++++++++++++++++-
>>  1 file changed, 16 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>> index 92b9af14c352..8ef03fb69bcd 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -296,6 +296,12 @@
>>  /* descriptor aligned size */
>>  #define MVNETA_DESC_ALIGNED_SIZE     32
>>
>> +/* Number of bytes to be taken into account by HW when putting incoming data
>> + * to the buffers. It is needed in case NET_SKB_PAD exceeds maximum packet
>> + * offset supported in MVNETA_RXQ_CONFIG_REG(q) registers.
>
> We also brought up this driver on 64bit platforms, we doesn't have this
> patch. Maybe I'm wrong, I'm trying to understand why we need this
> modification. Let's assume the NET_SKB_PAD is 64B, we call
> mvneta_rxq_offset_set(pp, rxq, 64),
>
> {
>         u32 val;
>
>         val = mvreg_read(pp, MVNETA_RXQ_CONFIG_REG(rxq->id));
>         val &= ~MVNETA_RXQ_PKT_OFFSET_ALL_MASK;
>
>         /* Offset is in */
>         val |= MVNETA_RXQ_PKT_OFFSET_MASK(offset >> 3);
> // then this will be "val |= 8;" it doesn't exceeds the max offset of
> MVNETA_RXQ_CONFIG_REG(q) register.
>
> Could you please kindly point out where I am wrong?
>
>> + */
>> +#define MVNETA_RX_PKT_OFFSET_CORRECTION              64
>> +
>>  #define MVNETA_RX_PKT_SIZE(mtu) \
>>       ALIGN((mtu) + MVNETA_MH_SIZE + MVNETA_VLAN_TAG_LEN + \
>>             ETH_HLEN + ETH_FCS_LEN,                        \
>> @@ -416,6 +422,7 @@ struct mvneta_port {
>>       u64 ethtool_stats[ARRAY_SIZE(mvneta_statistics)];
>>
>>       u32 indir[MVNETA_RSS_LU_TABLE_SIZE];
>> +     u16 rx_offset_correction;
>>  };
>>
>>  /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
>> @@ -1807,6 +1814,7 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
>>               return -ENOMEM;
>>       }
>>
>> +     phys_addr += pp->rx_offset_correction;
>>       mvneta_rx_desc_fill(rx_desc, phys_addr, data, rxq);
>>       return 0;
>>  }
>> @@ -2782,7 +2790,7 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
>>       mvreg_write(pp, MVNETA_RXQ_SIZE_REG(rxq->id), rxq->size);
>>
>>       /* Set Offset */
>> -     mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD);
>> +     mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD - pp->rx_offset_correction);
>>
>>       /* Set coalescing pkts and time */
>>       mvneta_rx_pkts_coal_set(pp, rxq, rxq->pkts_coal);
>> @@ -4033,6 +4041,13 @@ static int mvneta_probe(struct platform_device *pdev)
>>
>>       pp->rxq_def = rxq_def;
>>
>> +     /* Set RX packet offset correction for platforms, whose
>> +      * NET_SKB_PAD, exceeds 64B. It should be 64B for 64-bit
>> +      * platforms and 0B for 32-bit ones.
>
> Even we need this patch, I'm not sure this last comment is correct or not.
> NET_SKB_PAD is defined as:
>
> #define NET_SKB_PAD     max(32, L1_CACHE_BYTES)
>
> we have 64B cacheline 32bit platforms, on this platforms, the NET_SKB_PAD
> should be 64B as well.
>
> Thanks,
> Jisheng
