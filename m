From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v5] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Thu, 17 Jul 2014 11:52:26 +0800
Message-ID: <CAJxxZ0Pw+Lw1n3OgRDjBN47BHNM07fY33fy-1n_ZbGoCPVyC5A@mail.gmail.com>
References: <1405504302-21344-1-git-send-email-sonic.adi@gmail.com>
	<1405516649.10255.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Varka Bhadram <varkabhadram@gmail.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:50178 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbaGQDw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 23:52:27 -0400
Received: by mail-ig0-f172.google.com with SMTP id h15so5321593igd.5
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 20:52:27 -0700 (PDT)
In-Reply-To: <1405516649.10255.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Wed, Jul 16, 2014 at 9:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-07-16 at 17:51 +0800, Sonic Zhang wrote:
>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>> Ethernet RX DMA buffers are polled in NAPI work queue other than received
>> directly in DMA RX interrupt handler.
>>
>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>>
>> ---
>> v2-changes:
>> - avoid test NAPI_STATE_NPSVC bit in net device driver
>>
>> v3-changes:
>> - use tabs while indenting the code
>>
>> v4-changes:
>> - unconditionally complete the NAPI poll and re-enable the MAC_RX IRQ
>>
>> v5-changes:
>> - should match open parenthesis
>>
>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>> ---
>>  drivers/net/ethernet/adi/bfin_mac.c | 80 +++++++++++++++++++++++--------------
>>  drivers/net/ethernet/adi/bfin_mac.h |  1 +
>>  2 files changed, 51 insertions(+), 30 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
>> index 7ae74d4..6dde102 100644
>> --- a/drivers/net/ethernet/adi/bfin_mac.c
>> +++ b/drivers/net/ethernet/adi/bfin_mac.c
>> @@ -1218,11 +1218,14 @@ out:
>>  #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
>>       RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
>>
>> -static void bfin_mac_rx(struct net_device *dev)
>> +static void bfin_mac_rx(struct napi_struct *napi, int budget)
>
>
> budget seems unused in this function.
>
>>  {
>> +     struct bfin_mac_local *lp = container_of(napi,
>> +                                              struct bfin_mac_local,
>> +                                              napi);
>> +     struct net_device *dev = lp->ndev;
>>       struct sk_buff *skb, *new_skb;
>>       unsigned short len;
>> -     struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
>>  #if defined(BFIN_MAC_CSUM_OFFLOAD)
>>       unsigned int i;
>>       unsigned char fcs[ETH_FCS_LEN + 1];
>> @@ -1256,7 +1259,7 @@ static void bfin_mac_rx(struct net_device *dev)
>>       current_rx_ptr->skb = new_skb;
>>       current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
>>
>> -     len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
>> +     len = (unsigned short)(current_rx_ptr->status.status_word & RX_FRLEN);
>>       /* Deduce Ethernet FCS length from Ethernet payload length */
>>       len -= ETH_FCS_LEN;
>>       skb_put(skb, len);
>> @@ -1294,7 +1297,8 @@ static void bfin_mac_rx(struct net_device *dev)
>>       }
>>  #endif
>>
>> -     netif_rx(skb);
>> +     napi_gro_receive(&lp->napi, skb);
>> +
>>       dev->stats.rx_packets++;
>>       dev->stats.rx_bytes += len;
>>  out:
>> @@ -1302,41 +1306,51 @@ out:
>>       current_rx_ptr = current_rx_ptr->next;
>>  }
>>
>> +static int bfin_mac_poll(struct napi_struct *napi, int budget)
>> +{
>> +     int i = 0;
>> +     unsigned long flags;
>> +
>> +     while (current_rx_ptr->status.status_word != 0 && i < budget) {
>> +             bfin_mac_rx(napi, budget);
>> +             i++;
>> +     }
>> +
>> +     if (i < budget) {
>> +             napi_gro_flush(napi, false);
>> +             local_irq_save(flags);
>> +             __napi_complete(napi);
>> +             local_irq_restore(flags);
>> +             enable_irq(IRQ_MAC_RX);
>
> I have no idea why you open-code napi_complete();
>

In the case of netpoll_poll_dev() is invoked repeatedly from an
exception handler, the NAPI poll() callback is always called with bit
NAPI_STATE_NPSVC set in poll_one_napi(). But, when bit
NAPI_STATE_NPSVC is set, napi_complete() doesn't deque and clear the
NAPI_STATE_SCHED. The MAC_RX interrupt is never disabled in net poll
loop when bit NAPI_STATE_SCHED is set. So, the call to enable_irq() in
next NAPI poll() callback triggers the warning "Unbalanced enable for
IRQ %d\n".

The other Ethernet drivers don't call enable_irq() after
napi_complete(). They disable the interrupt in their device
controller. But, bfin mac has no such capability and has to disable
the MAC_RX interrupt by enable_irq().


> Why cant you just copy/paste what other drivers do here ?
>
>         if (i < budget) {
>                 napi_complete(napi);
>                 enable_irq(IRQ_MAC_RX);
>         }
>

I checked other other drivers in driver/net/ethernet/

In realtek/8139cp.c
------------------------------------------------
                napi_gro_flush(napi, false);
                spin_lock_irqsave(&cp->lock, flags);
                __napi_complete(napi);
                cpw16_f(IntrMask, cp_intr_mask);
                spin_unlock_irqrestore(&cp->lock, flags);
------------------------------------------------
The same as my code.

In intel/e1000/e1000_main.c
------------------------------------------------
                napi_complete(napi);
                if (!test_bit(__E1000_DOWN, &adapter->flags))
                        e1000_irq_enable(adapter);

static void e1000_irq_enable(struct e1000_adapter *adapter)
{
        struct e1000_hw *hw = &adapter->hw;

        ew32(IMS, IMS_ENABLE_MASK);
        E1000_WRITE_FLUSH();
}
-------------------------------------------------
e1000_irq_enable() other than the system enable_irq() is called after
napi_complete(). e1000_irq_enable() writes the register in e1000
ethernet controller directly. Even if it is invoked more timers than
the e1000_irq_disable() is in the net_poll(), no unbalanced IRQ
enabling warning is printed in kernel.

> ...
>
>>
>> @@ -1689,6 +1704,8 @@ static int bfin_mac_probe(struct platform_device *pdev)
>>       lp->tx_reclaim_timer.data = (unsigned long)lp;
>>       lp->tx_reclaim_timer.function = tx_reclaim_skb_timeout;
>>
>> +     netif_napi_add(ndev, &lp->napi, bfin_mac_poll, CONFIG_BFIN_RX_DESC_NUM);
>
>
> Have you checked kernel log ?
>
> You should have hit :
>
>         if (weight > NAPI_POLL_WEIGHT)
>                 pr_err_once("netif_napi_add() called with weight %d on device %s\n",
>                             weight, dev->name);
>
>

The default value of CONFIG_BFIN_RX_DESC_NUM is 20 while
NAPI_POLL_WEIGHT is 64. I don't see this checking is hit. I can set
the range of CONFIG_BFIN_RX_DESC_NUM to be 20 ~ 64 in Kconfig as well.

Regards,

Sonic
