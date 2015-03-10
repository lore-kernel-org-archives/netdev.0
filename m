From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: collect Rx discarded packet count
Date: Tue, 10 Mar 2015 13:52:32 -0700
Message-ID: <CAGXr9JEnP50ff+CzVVoBXa6iRKdbCKoaaZv0Zx-ndVN_gorKSw@mail.gmail.com>
References: <20150310191800.C5812220365@puck.mtv.corp.google.com>
	<54FF4973.30306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:37398 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbCJUwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 16:52:33 -0400
Received: by qcxr5 with SMTP id r5so5318231qcx.4
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 13:52:32 -0700 (PDT)
In-Reply-To: <54FF4973.30306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Tue, Mar 10, 2015 at 12:43 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 10/03/15 12:18, Petri Gynther wrote:
>> Bits 31:16 of RDMA_PROD_INDEX contain Rx discarded packet count, which
>> are the Rx packets that had to be dropped by MAC hardware since there
>> was no room on the Rx queue. Add code to collect this information into
>> the netdev stats.
>>
>> Signed-off-by: Petri Gynther <pgynther@google.com>
>> ---
>>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 10 ++++++++++
>>  1 file changed, 10 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> index 275be56..7aa1834 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> @@ -1384,9 +1384,19 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>>       int len, err;
>>       unsigned int rxpktprocessed = 0, rxpkttoprocess;
>>       unsigned int p_index;
>> +     unsigned int discards;
>>       unsigned int chksum_ok = 0;
>>
>>       p_index = bcmgenet_rdma_ring_readl(priv, index, RDMA_PROD_INDEX);
>> +
>> +     discards = (p_index >> DMA_P_INDEX_DISCARD_CNT_SHIFT) &
>> +                DMA_P_INDEX_DISCARD_CNT_MASK;
>> +     if (discards > 0) {
>> +             bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_PROD_INDEX);
>
> This adds an expensive register write (~300ns on MIPS, ~200ns on ARM) in
> the hot-path, and the counter saturation happens at 0xffff, which I
> would prefer we deal with explicitly, even though that means missing a
> bunch of discard events once we have already saturated, rather than
> resetting this counter *and* the producer index for every NAPI round we
> get called.
>
> You could also deal with this counter in the ethtool gstats functions
> and perform the saturation handle there, since this is a slow path already.
>

It is a rare event that discards > 0. Thus, the extra register write
happens very infrequently.

And, writing 0 to RDMA_PROD_INDEX does not reset the producer index
bits 15:0 that are used in Rx processing.

>> +             dev->stats.rx_missed_errors += discards;
>> +             dev->stats.rx_errors += discards;
>> +     }
>> +
>>       p_index &= DMA_P_INDEX_MASK;
>>
>>       if (likely(p_index >= ring->c_index))
>>
>
>
> --
> Florian
