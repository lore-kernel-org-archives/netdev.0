From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v8] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Thu, 24 Jul 2014 17:48:08 +0800
Message-ID: <CAJxxZ0Or+rg+x8kU_QqGuRAeSjWrV8XbxrtLJoNsoc+FCCpANg@mail.gmail.com>
References: <1406191171-9203-1-git-send-email-sonic.adi@gmail.com>
	<1406193211.3363.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:49833 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756924AbaGXJsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 05:48:09 -0400
Received: by mail-oa0-f41.google.com with SMTP id j17so3338111oag.28
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 02:48:08 -0700 (PDT)
In-Reply-To: <1406193211.3363.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Jul 24, 2014 at 5:13 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-07-24 at 16:39 +0800, Sonic Zhang wrote:
>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>> Ethernet RX DMA buffers are polled in NAPI work queue other than received
>> directly in DMA RX interrupt handler.
>>
>
>
>> ---
>>  drivers/net/ethernet/adi/bfin_mac.c | 79 +++++++++++++++++++++++--------------
>>  drivers/net/ethernet/adi/bfin_mac.h |  3 ++
>>  2 files changed, 52 insertions(+), 30 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
>> index 7ae74d4..c1f04aa 100644
>> --- a/drivers/net/ethernet/adi/bfin_mac.c
>> +++ b/drivers/net/ethernet/adi/bfin_mac.c
>> @@ -1218,11 +1218,11 @@ out:
>>  #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
>>       RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
>>
>> -static void bfin_mac_rx(struct net_device *dev)
>> +static void bfin_mac_rx(struct bfin_mac_local *lp, int budget)
>
> budget is not used in this function. (I already mentioned this)
OK

>
>>  {
>> +     struct net_device *dev = lp->ndev;
>>       struct sk_buff *skb, *new_skb;
>>       unsigned short len;
>> -     struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
>>  #if defined(BFIN_MAC_CSUM_OFFLOAD)
>>       unsigned int i;
>>       unsigned char fcs[ETH_FCS_LEN + 1];
>> @@ -1256,7 +1256,7 @@ static void bfin_mac_rx(struct net_device *dev)
>>       current_rx_ptr->skb = new_skb;
>>       current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
>>
>> -     len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
>> +     len = (unsigned short)(current_rx_ptr->status.status_word & RX_FRLEN);
>>       /* Deduce Ethernet FCS length from Ethernet payload length */
>>       len -= ETH_FCS_LEN;
>>       skb_put(skb, len);
>> @@ -1294,7 +1294,8 @@ static void bfin_mac_rx(struct net_device *dev)
>>       }
>>  #endif
>>
>> -     netif_rx(skb);
>> +     napi_gro_receive(&lp->napi, skb);
>> +
>>       dev->stats.rx_packets++;
>>       dev->stats.rx_bytes += len;
>>  out:
>> @@ -1302,41 +1303,52 @@ out:
>>       current_rx_ptr = current_rx_ptr->next;
>>  }
>
>
>> +     if ((status & DMA_DONE)) {
>> +             disable_irq_nosync(IRQ_MAC_RX);
>> +             set_bit(BFIN_MAC_RX_IRQ_DISABLED, &lp->flags);
>> +             napi_schedule(&lp->napi);
>>       }
>
>         No need for extra ()
>
>         if (status & DMA_DONE) {
>                 ...
>

My typo.

>
>
>>+       netif_napi_add(ndev, &lp->napi, bfin_mac_poll, CONFIG_BFIN_RX_DESC_NUM);
>
>
> I already gave a feedback on this. Could you address it ?
>
> Have you checked kernel log ?
>
> You should have hit :
>
>         if (weight > NAPI_POLL_WEIGHT)
>                 pr_err_once("netif_napi_add() called with weight %d on device %s\n",
>                             weight, dev->name);
>
> This is because CONFIG_BFIN_RX_DESC_NUM is 100, while NAPI_POLL_WEIGHT is 64.
>

The default value of CONFIG_BFIN_RX_DESC_NUM is 20 in Kconfig. I will
set the range to 20 ~ 64.


Thank,

Sonic Zhang
