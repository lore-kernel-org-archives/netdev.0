From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 27 Mar 2014 14:27:20 +0800
Message-ID: <CAMj5Bkj1RPVSoksTotueKbKF0Sc4QboTX563Qx=sTDLdPtRi+w@mail.gmail.com>
References: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org>
	<1395670496-17381-4-git-send-email-zhangfei.gao@linaro.org>
	<CAGVrzcaY257MAjjmkXDi_fD5TxSanmx9Jpvx-yg7vT3-GUjz3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:58647 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbaC0G1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 02:27:22 -0400
In-Reply-To: <CAGVrzcaY257MAjjmkXDi_fD5TxSanmx9Jpvx-yg7vT3-GUjz3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian

Thanks for the kind suggestion.

On Tue, Mar 25, 2014 at 12:32 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-03-24 7:14 GMT-07:00 Zhangfei Gao <zhangfei.gao@linaro.org>:
>> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller
>>
>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>> ---
>>  drivers/net/ethernet/hisilicon/Makefile    |    2 +-
>>  drivers/net/ethernet/hisilicon/hip04_eth.c |  728 ++++++++++++++++++++++++++++
>>  2 files changed, 729 insertions(+), 1 deletion(-)
>>  create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c
>
> [snip]
>
>> +static void hip04_config_port(struct hip04_priv *priv, u32 speed, u32 duplex)
>> +{
>> +       u32 val;
>> +
>> +       priv->speed = speed;
>> +       priv->duplex = duplex;
>> +
>> +       switch (priv->phy_mode) {
>> +       case PHY_INTERFACE_MODE_SGMII:
>> +               if (speed == SPEED_1000)
>> +                       val = 8;
>> +               else
>> +                       val = 7;
>> +               break;
>> +       case PHY_INTERFACE_MODE_MII:
>> +               val = 1;        /* SPEED_100 */
>> +               break;
>> +       default:
>> +               val = 0;
>> +               break;
>
> Is 0 valid for e.g: 10Mbits/sec, regardless of the phy_mode?

0 is only 10M for MII mode, will add warning here.

        switch (priv->phy_mode) {
        case PHY_INTERFACE_MODE_SGMII:
                if (speed == SPEED_1000)
                        val = 8;
                else if (speed == SPEED_100)
                        val = 7;
                else
                        val = 6;        /* SPEED_10 */
                break;
        case PHY_INTERFACE_MODE_MII:
                if (speed == SPEED_100)
                        val = 1;
                else
                        val = 0;        /* SPEED_10 */
                break;
        default:
                netdev_warn(ndev, "not supported mode\n");
                val = 0;
                break;
        }

>> +
>> +static void hip04_mac_enable(struct net_device *ndev, bool enable)
>> +{
>> +       struct hip04_priv *priv = netdev_priv(ndev);
>> +       u32 val;
>> +
>> +       if (enable) {
>> +               /* enable tx & rx */
>> +               val = readl_relaxed(priv->base + GE_PORT_EN);
>> +               val |= BIT(1);          /* rx*/
>> +               val |= BIT(2);          /* tx*/
>> +               writel_relaxed(val, priv->base + GE_PORT_EN);
>> +
>> +               /* enable interrupt */
>> +               priv->reg_inten = DEF_INT_MASK;
>> +               writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
>> +
>> +               /* clear rx int */
>> +               val = RCV_INT;
>> +               writel_relaxed(val, priv->base + PPE_RINT);
>
> Should not you first clear the interrupt and then DEF_INT_MASK? Why is
OK, got it.

> there a RCV_INT applied to PPE_RINT register in the enable path, but
> there is no such thing in the "disable" branch of your function?

This required here since setting the following cmd, /* config recv int*/
Otherwise, the setting does not take effect.

>
>> +
>> +               /* config recv int*/
>> +               val = BIT(6);           /* int threshold 1 package */
>> +               val |= 0x4;             /* recv timeout */
>> +               writel_relaxed(val, priv->base + PPE_CFG_RX_PKT_INT);
>> +       } else {
>> +               /* disable int */
>> +               priv->reg_inten &= ~(RCV_INT | RCV_NOBUF);
>> +               writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
>> +
>> +               /* disable tx & rx */
>> +               val = readl_relaxed(priv->base + GE_PORT_EN);
>> +               val &= ~(BIT(1));       /* rx*/
>> +               val &= ~(BIT(2));       /* tx*/
>> +               writel_relaxed(val, priv->base + GE_PORT_EN);
>> +       }
>
> There is little to no sharing between the two branches, I would have
> created separate helper functions for the enable/disable logic.
OK, got it.

>
>> +}
>> +
>> +static void hip04_set_xmit_desc(struct hip04_priv *priv, dma_addr_t phys)
>> +{
>> +       writel(phys, priv->base + PPE_CFG_TX_PKT_BD_ADDR);
>
> This is not 64-bits/LPAE safe, do you have a High address part and a
> Low address part for your address in the buffer descriptor address, if
> so, better use it now.

Unfortunately it is true, only 32bytes for this controller on A15.
Bits [33:32] of desc can be set in [5:4], but it may be ignored,
RX register is only have 32bits too.
So the controller is only for 32 bits.

The next version can be used on 64bits, and there is high address part.
Still not get spec yet.

>> +
>> +static int hip04_rx_poll(struct napi_struct *napi, int budget)
>> +{
>> +       struct hip04_priv *priv = container_of(napi, struct hip04_priv, napi);
>> +       struct net_device *ndev = priv->ndev;
>> +       struct net_device_stats *stats = &ndev->stats;
>> +       unsigned int cnt = hip04_recv_cnt(priv);
>> +       struct sk_buff *skb;
>> +       struct rx_desc *desc;
>> +       unsigned char *buf;
>> +       dma_addr_t phys;
>> +       int rx = 0;
>> +       u16 len;
>> +       u32 err;
>> +
>> +       while (cnt) {
>> +               buf = priv->rx_buf[priv->rx_head];
>> +               skb = build_skb(buf, priv->rx_buf_size);
>> +               if (unlikely(!skb))
>> +                       net_dbg_ratelimited("build_skb failed\n");
>> +
>> +               dma_unmap_single(&ndev->dev, priv->rx_phys[priv->rx_head],
>> +                               RX_BUF_SIZE, DMA_FROM_DEVICE);
>> +               priv->rx_phys[priv->rx_head] = 0;
>> +
>> +               desc = (struct rx_desc *)skb->data;
>> +               len = be16_to_cpu(desc->pkt_len);
>> +               err = be32_to_cpu(desc->pkt_err);
>> +
>> +               if (len > RX_BUF_SIZE)
>> +                       len = RX_BUF_SIZE;
>> +               if (0 == len)
>> +                       break;
>
> Should not this be a continue? This is an error packet, so you should
> keep on processing the others, or does this have a special meaning?
len=0 indicates the last packet.
Will change the behavior here.
   if (0 == len) {
                        dev_kfree_skb_any(skb);
                        last = true;
                } else if (err & RX_PKT_ERR) {
                        dev_kfree_skb_any(skb);
                        stats->rx_dropped++;
                        stats->rx_errors++;
                } else {
                        skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
                        skb_put(skb, len);
                        skb->protocol = eth_type_trans(skb, ndev);
                        napi_gro_receive(&priv->napi, skb);
                        stats->rx_packets++;
                        stats->rx_bytes += len;
                }
>
>> +
>> +               if (err & RX_PKT_ERR) {
>> +                       dev_kfree_skb_any(skb);
>> +                       stats->rx_dropped++;
>> +                       stats->rx_errors++;
>> +                       continue;
>> +               }
>> +
>> +               stats->rx_packets++;
>> +               stats->rx_bytes += len;
>> +
>> +               skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
>> +               skb_put(skb, len);
>> +               skb->protocol = eth_type_trans(skb, ndev);
>> +               napi_gro_receive(&priv->napi, skb);
>> +
>> +               buf = netdev_alloc_frag(priv->rx_buf_size);
>> +               if (!buf)
>> +                       return -ENOMEM;
>> +               phys = dma_map_single(&ndev->dev, buf,
>> +                               RX_BUF_SIZE, DMA_FROM_DEVICE);
>
> Missing dma_mapping_error() check here.
Yes, thanks

>
>> +               priv->rx_buf[priv->rx_head] = buf;
>> +               priv->rx_phys[priv->rx_head] = phys;
>> +               hip04_set_recv_desc(priv, phys);
>> +
>> +               priv->rx_head = RX_NEXT(priv->rx_head);
>> +               if (rx++ >= budget)
>> +                       break;
>> +
>> +               if (--cnt == 0)
>> +                       cnt = hip04_recv_cnt(priv);
>
>> +       }
>> +
>> +       if (rx < budget) {
>> +               napi_complete(napi);
>> +
>> +               /* enable rx interrupt */
>> +               priv->reg_inten |= RCV_INT | RCV_NOBUF;
>> +               writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
>> +       }
>> +
>> +       return rx;
>> +}
>> +
>> +static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
>> +{
>> +       struct net_device *ndev = (struct net_device *) dev_id;
>> +       struct hip04_priv *priv = netdev_priv(ndev);
>> +       u32 ists = readl_relaxed(priv->base + PPE_INTSTS);
>> +       u32 val = DEF_INT_MASK;
>> +
>> +       writel_relaxed(val, priv->base + PPE_RINT);
>> +
>> +       if (ists & (RCV_INT | RCV_NOBUF)) {
>> +               if (napi_schedule_prep(&priv->napi)) {
>> +                       /* disable rx interrupt */
>> +                       priv->reg_inten &= ~(RCV_INT | RCV_NOBUF);
>> +                       writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
>> +                       __napi_schedule(&priv->napi);
>> +               }
>> +       }
>
> You should also process TX completion interrupts here
There is no such interrupt.
>
>> +
>> +       return IRQ_HANDLED;
>> +}
>> +
>> +static void hip04_tx_reclaim(struct net_device *ndev, bool force)
>> +{
>> +       struct hip04_priv *priv = netdev_priv(ndev);
>> +       unsigned tx_head = priv->tx_head;
>> +       unsigned tx_tail = priv->tx_tail;
>> +       struct tx_desc *desc = &priv->tx_desc[priv->tx_tail];
>> +
>> +       while (tx_tail != tx_head) {
>> +               if (desc->send_addr != 0) {
>> +                       if (force)
>> +                               desc->send_addr = 0;
>> +                       else
>> +                               break;
>> +               }
>> +               if (priv->tx_phys[tx_tail]) {
>> +                       dma_unmap_single(&ndev->dev, priv->tx_phys[tx_tail],
>> +                               priv->tx_skb[tx_tail]->len, DMA_TO_DEVICE);
>> +                       priv->tx_phys[tx_tail] = 0;
>> +               }
>> +               dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
>
> dev_kfree_skb_irq() bypasses all sort of SKB tracking, you might want
> to use kfree_skb() here instead.
OK, will use dev_kfree_skb instead.

>
>> +               priv->tx_skb[tx_tail] = NULL;
>> +               tx_tail = TX_NEXT(tx_tail);
>> +               priv->tx_count--;
>> +       }
>> +       priv->tx_tail = tx_tail;
>> +}
>> +
>> +static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>> +{
>> +       struct hip04_priv *priv = netdev_priv(ndev);
>> +       struct net_device_stats *stats = &ndev->stats;
>> +       unsigned int tx_head = priv->tx_head;
>> +       struct tx_desc *desc = &priv->tx_desc[tx_head];
>> +       dma_addr_t phys;
>> +
>> +       hip04_tx_reclaim(ndev, false);
>> +
>> +       if (priv->tx_count++ >= TX_DESC_NUM) {
>> +               net_dbg_ratelimited("no TX space for packet\n");
>> +               netif_stop_queue(ndev);
>> +               return NETDEV_TX_BUSY;
>> +       }
>> +
>> +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
>
> Missing dma_mapping_error() check here
>
>> +       priv->tx_skb[tx_head] = skb;
>> +       priv->tx_phys[tx_head] = phys;
>> +       desc->send_addr = cpu_to_be32(phys);
>> +       desc->send_size = cpu_to_be16(skb->len);
>> +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
>> +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
>> +       desc->wb_addr = cpu_to_be32(phys);
>
> Don't we need a barrier here to ensure that all stores are completed
> before we hand this descriptor address to hip40_set_xmit_desc() which
> should make DMA start processing it?
>
>> +       skb_tx_timestamp(skb);
>> +       hip04_set_xmit_desc(priv, phys);
>> +       priv->tx_head = TX_NEXT(tx_head);
>> +
>> +       stats->tx_bytes += skb->len;
>> +       stats->tx_packets++;
>
> You cannot update the transmit stats here, what start_xmit() does it
> just queue packets for the DMA engine to process them, but that does
> not mean DMA has completed those. You should update statistics in the
> tx_reclaim() function.
Yes, however, since no TX complete interrupt, tx_reclaim may be called
rather late, it may be more suitable to put here.

Thanks
