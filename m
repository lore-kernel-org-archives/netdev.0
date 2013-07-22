From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net: Add MOXA ART SoCs ethernet driver
Date: Mon, 22 Jul 2013 12:09:34 +0100
Message-ID: <CAGVrzcYdisg5AXMBa5q74GPz7ckWeoXJ9H5di2CGN41VyZ_4vw@mail.gmail.com>
References: <1374140806-12485-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>, linux-doc@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	arm@kernel.org
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1374140806-12485-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jonas,

A bunch of comments inline.

2013/7/18 Jonas Jensen <jonas.jensen@gmail.com>:
> The MOXA UC-711X hardware(s) has an ethernet controller that seem to be
> developed internally. The IC used is "RTL8201CP".
>
> Since there is no public documentation, this driver is mostly the one
> published by MOXA that has been heavily cleaned up / ported from linux 2.6.9.
>
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
> ---
>
> Notes:
>     Applies to next-20130716
>
>  .../devicetree/bindings/net/moxa,moxart-mac.txt    |  25 +
>  drivers/net/ethernet/Kconfig                       |   1 +
>  drivers/net/ethernet/Makefile                      |   1 +
>  drivers/net/ethernet/moxa/Kconfig                  |  30 ++
>  drivers/net/ethernet/moxa/Makefile                 |   6 +
>  drivers/net/ethernet/moxa/moxart_ether.c           | 544 +++++++++++++++++++++
>  drivers/net/ethernet/moxa/moxart_ether.h           | 525 ++++++++++++++++++++
>  7 files changed, 1132 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
>  create mode 100644 drivers/net/ethernet/moxa/Kconfig
>  create mode 100644 drivers/net/ethernet/moxa/Makefile
>  create mode 100644 drivers/net/ethernet/moxa/moxart_ether.c
>  create mode 100644 drivers/net/ethernet/moxa/moxart_ether.h
>
> diff --git a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
> new file mode 100644
> index 0000000..12e12a5
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
> @@ -0,0 +1,25 @@
> +MOXA ART Ethernet Controller
> +
> +Required properties:
> +
> +- compatible : Should be "moxa,moxart-mac"
> +- reg : Should contain registers location and length
> +  index 0 : main register
> +  index 1 : mac address (stored on flash)

That is kind of unusual, since the MAC register is within the range of
the MAC base register, just read the MAC from the base register and
use that to fill in dev->dev_addr in your ndo_open() callback.

[snip]

> +static void moxart_mac_setup_desc_ring(struct net_device *ndev)
> +{
> +       struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> +       struct tx_desc_t *txdesc;
> +       struct rx_desc_t *rxdesc;
> +       unsigned char *virtbuf;
> +       unsigned int phybuf;
> +       int i;
> +
> +       virtbuf = priv->virt_tx_buf_baseaddr;
> +       phybuf = priv->phy_tx_buf_baseaddr;
> +       for (i = 0; i < TX_DESC_NUM; i++,
> +               virtbuf += TX_BUF_SIZE, phybuf += TX_BUF_SIZE) {
> +               txdesc = &priv->virt_tx_desc_baseaddr[i];
> +               memset(txdesc, 0, sizeof(struct tx_desc_t));
> +               txdesc->txdes2.phy_tx_buf_baseaddr = phybuf;
> +               txdesc->txdes2.virt_tx_buf_baseaddr = virtbuf;
> +       }
> +       priv->virt_tx_desc_baseaddr[TX_DESC_NUM - 1].txdes1.ubit.edotr = 1;
> +       priv->tx_desc_now = 0;
> +
> +       virtbuf = priv->virt_rx_buf_baseaddr;
> +       phybuf = priv->phy_rx_buf_baseaddr;
> +       for (i = 0; i < RX_DESC_NUM; i++,
> +               virtbuf += RX_BUF_SIZE, phybuf += RX_BUF_SIZE) {
> +               rxdesc = &priv->virt_rx_desc_baseaddr[i];
> +               memset(rxdesc, 0, sizeof(struct rx_desc_t));
> +               rxdesc->rxdes0.ubit.rx_dma_own = 1;
> +               rxdesc->rxdes1.ubit.rx_buf_size = RX_BUF_SIZE;
> +               rxdesc->rxdes2.phy_rx_buf_baseaddr = phybuf;
> +               rxdesc->rxdes2.virt_rx_buf_baseaddr = virtbuf;
> +       }

Your RX path is supposed to be preallocating SKBs, create a DMA
mapping for them and then only SKB refilling would then happen when
you process a SKB in your RX handler. I do not see you doing it here.

> +       priv->virt_rx_desc_baseaddr[RX_DESC_NUM - 1].rxdes1.ubit.edorr = 1;
> +       priv->rx_desc_now = 0;
> +
> +       /* reset the MAC controler TX/RX desciptor base address */
> +       writel(priv->phy_tx_desc_baseaddr, priv->base + TXR_BADR_REG_OFFSET);
> +       writel(priv->phy_rx_desc_baseaddr, priv->base + RXR_BADR_REG_OFFSET);
> +}
> +
> +static int moxart_mac_open(struct net_device *ndev)
> +{
> +       struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> +
> +       if (!is_valid_ether_addr(ndev->dev_addr))
> +               return -EADDRNOTAVAIL;
> +
> +       spin_lock_irq(&priv->txlock);
> +       moxart_mac_reset(ndev);
> +       moxart_update_mac_address(ndev);
> +       moxart_mac_setup_desc_ring(ndev);
> +       moxart_mac_enable(ndev);
> +       spin_unlock_irq(&priv->txlock);

Unless you did not properly disable interrupts at the MAC level,
taking a spinlock here does not seem to be required at all since the
various steps you call are done in the correct order.

> +       netif_start_queue(ndev);
> +
> +       netdev_dbg(ndev, "%s: IMR=0x%x, MACCR=0x%x\n",
> +                  __func__, readl(priv->base + IMR_REG_OFFSET),
> +                  readl(priv->base + MACCR_REG_OFFSET));
> +
> +       return 0;
> +}
> +
> +static int moxart_mac_stop(struct net_device *ndev)
> +{
> +       struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> +
> +       netif_stop_queue(ndev);
> +       spin_lock_irq(&priv->txlock);
> +
> +       /* disable all interrupts */
> +       writel(0, priv->base + IMR_REG_OFFSET);
> +
> +       /* disable all functions */
> +       writel(0, priv->base + MACCR_REG_OFFSET);
> +
> +       spin_unlock_irq(&priv->txlock);

Same here, the serialisation is not required here once you have
disabled the interrupts at the MAC level. You should also free the RX
buffers and the potentially remaining transmit SKBs.

> +
> +       return 0;
> +}
> +
> +static void moxart_mac_recv(struct work_struct *ptr)
> +{
> +       struct net_device *ndev = (struct net_device *) ptr;
> +       struct moxart_mac_priv_t *priv = netdev_priv((struct net_device *)ptr);
> +       struct rx_desc_t *rxdesc;
> +       struct sk_buff *skb;
> +       unsigned int ui, len;
> +       int rxnow = priv->rx_desc_now;
> +       int loops = RX_DESC_NUM;

This screams to me: implement NAPI. You are doing all of the
processing in an interrupt handler, which runs in hard IRQ context,
this is bad for latency. This very specific function won't change that
much once you convert it to NAPI.

> +
> +repeat_recv:
> +       rxdesc = &priv->virt_rx_desc_baseaddr[rxnow];
> +       ui = rxdesc->rxdes0.ui;
> +
> +       if (ui & RXDMA_OWN)
> +               return;
> +
> +       if (ui & (RX_ERR | CRC_ERR | FTL | RUNT | RX_ODD_NB)) {
> +               netdev_err(ndev, "%s: packet error\n", __func__);
> +               priv->stats.rx_dropped++;
> +               priv->stats.rx_errors++;
> +               goto recv_finish;
> +       }
> +
> +       len = ui & RFL_MASK;
> +
> +       if (len > RX_BUF_SIZE)
> +               len = RX_BUF_SIZE;
> +
> +       skb = dev_alloc_skb(len + 2);

You should use netdev_alloc_skb_ip_align() here.

> +       if (skb == NULL) {
> +               netdev_err(ndev, "%s: dev_alloc_skb failed\n", __func__);
> +               priv->stats.rx_dropped++;
> +               goto recv_finish;
> +       }
> +
> +       skb_reserve(skb, 2);

And remove this.

> +       skb->dev = ndev;

eth_type_trans() already does this for you.

> +       memcpy(skb_put(skb, len), rxdesc->rxdes2.virt_rx_buf_baseaddr, len);

You should use a dma_unmap_single() operation here.

> +       netif_rx(skb);
> +       skb->protocol = eth_type_trans(skb, ndev);

I think these two steps are inverted, you should first call eth_type_trans().

> +       ndev->last_rx = jiffies;
> +       priv->stats.rx_packets++;
> +       priv->stats.rx_bytes += len;
> +       if (ui & MULTICAST_RXDES0)
> +               priv->stats.multicast++;
> +
> +recv_finish:
> +       rxdesc->rxdes0.ui = RXDMA_OWN;
> +       rxnow++;
> +       rxnow &= RX_DESC_NUM_MASK;
> +       priv->rx_desc_now = rxnow;
> +       if (loops-- > 0)
> +               goto repeat_recv;

Better code this with a while() loop directly, using gotos here is
silly and I believe this might be bad for your CPU branch predictor as
well.

> +}
> +
> +static irqreturn_t moxart_mac_interrupt(int irq, void *dev_id)
> +{
> +       struct net_device *ndev = (struct net_device *) dev_id;
> +       struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> +       unsigned int ists = readl(priv->base + ISR_REG_OFFSET);
> +
> +       if (ists & RPKT_FINISH)
> +               moxart_mac_recv((void *) ndev);

Unnecessary void * casting here.

> +
> +       return IRQ_HANDLED;
> +}
> +
> +static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +       struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> +       struct tx_desc_t *txdesc;
> +       int len;
> +       int txnow = priv->tx_desc_now;
> +
> +       spin_lock_irq(&priv->txlock);
> +       txdesc = &priv->virt_tx_desc_baseaddr[txnow];
> +       if (txdesc->txdes0.ubit.tx_dma_own) {
> +               netdev_err(ndev, "%s: no TX space for packet\n", __func__);
> +               priv->stats.tx_dropped++;
> +               goto xmit_final;
> +       }

You should return NETDEV_TX_BUSY here if there are no TX descriptors available.

> +
> +       len = skb->len > TX_BUF_SIZE ? TX_BUF_SIZE : skb->len;
> +       memcpy(txdesc->txdes2.virt_tx_buf_baseaddr, skb->data, len);

This looks wrong, you should get a TX descriptor for this SKB, and
then perform a DMA mapping of skb->data for skb->len to that specific
TX descriptor address and set the transmit descriptor control words as
you do below.

> +
> +       if (skb->len < ETH_ZLEN) {
> +               memset(&txdesc->txdes2.virt_tx_buf_baseaddr[skb->len],
> +                      0, ETH_ZLEN - skb->len);
> +               len = ETH_ZLEN;
> +       }
> +
> +       txdesc->txdes1.ubit.lts = 1;
> +       txdesc->txdes1.ubit.fts = 1;
> +       txdesc->txdes1.ubit.tx2_fic = 0;
> +       txdesc->txdes1.ubit.tx_ic = 0;
> +       txdesc->txdes1.ubit.tx_buf_size = len;
> +       txdesc->txdes0.ui = TXDMA_OWN;
> +
> +       /* start to send packet */
> +       writel(0xffffffff, priv->base + TXPD_REG_OFFSET);
> +
> +       txnow++;
> +       txnow &= TX_DESC_NUM_MASK;
> +       priv->tx_desc_now = txnow;
> +       ndev->trans_start = jiffies;
> +       priv->stats.tx_packets++;
> +       priv->stats.tx_bytes += len;

Incrementing statistics must happen in the transmit completion
handler. At this point there is no guarantee that the hardware really
processed your packet (your DMA engine could signal an error like no
carrier or anything like that).

> +
> +xmit_final:
> +       spin_unlock_irq(&priv->txlock);
> +       dev_kfree_skb_any(skb);

This looks wrong, transmit buffer reclaim should happen once
transmission is complete. Your interrupt handler do not handle the
XPKT_FINISH_M bit which seems to indicate transmit completion of
buffers.

[snip]

> +
> +static int moxart_mac_probe(struct platform_device *pdev)
> +{
> +       struct device *p_dev = &pdev->dev;
> +       struct device_node *node = p_dev->of_node;
> +       struct net_device *ndev;
> +       struct moxart_mac_priv_t *priv;
> +       struct resource *res;
> +       unsigned int irq;
> +       void *tmp;
> +
> +       ndev = alloc_etherdev(sizeof(struct moxart_mac_priv_t));
> +       if (!ndev)
> +               return -ENOMEM;
> +
> +       irq = irq_of_parse_and_map(node, 0);
> +
> +       priv = netdev_priv(ndev);
> +
> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       ndev->base_addr = res->start;
> +       priv->base = devm_ioremap_resource(p_dev, res);
> +       if (IS_ERR(priv->base)) {
> +               dev_err(p_dev, "%s: devm_ioremap_resource res_mac failed\n",
> +                       __func__);
> +               goto init_fail;
> +       }
> +
> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +
> +       /* the flash driver (physmap_of) requests the same region
> +        * so use ioremap instead of devm_ioremap_resource
> +        */
> +       priv->flash_base = ioremap(res->start, resource_size(res));
> +       if (IS_ERR(priv->flash_base)) {
> +               dev_err(p_dev, "%s: devm_ioremap_resource res_flash failed\n",
> +                       __func__);
> +               goto init_fail;
> +       }

As stated above from the Device Tree binding documentation, this is
unnecessary, since you have a get_mac() function.

> +
> +       spin_lock_init(&priv->txlock);
> +
> +       tmp = dma_alloc_coherent(NULL, sizeof(struct tx_desc_t) * TX_DESC_NUM,
> +                                (dma_addr_t *) &priv->phy_tx_desc_baseaddr,
> +                                GFP_DMA | GFP_KERNEL);
> +       priv->virt_tx_desc_baseaddr = (struct tx_desc_t *) tmp;
> +       if (priv->virt_tx_desc_baseaddr == NULL ||
> +           (priv->phy_tx_desc_baseaddr & 0x0f)) {
> +               netdev_err(ndev, "TX descriptor alloc failed\n");
> +               goto init_fail;
> +       }
> +
> +       tmp = dma_alloc_coherent(NULL, sizeof(struct rx_desc_t) * RX_DESC_NUM,
> +                                (dma_addr_t *)&priv->phy_rx_desc_baseaddr,
> +                                GFP_DMA | GFP_KERNEL);
> +       priv->virt_rx_desc_baseaddr = (struct rx_desc_t *) tmp;
> +       if (priv->virt_rx_desc_baseaddr == NULL ||
> +           (priv->phy_rx_desc_baseaddr & 0x0f)) {
> +               netdev_err(ndev, "RX descriptor alloc failed\n");
> +               goto init_fail;
> +       }
> +
> +       tmp = dma_alloc_coherent(NULL, TX_BUF_SIZE * TX_DESC_NUM,
> +                                (dma_addr_t *)&priv->phy_tx_buf_baseaddr,
> +                                GFP_DMA | GFP_KERNEL);
> +       priv->virt_tx_buf_baseaddr = (unsigned char *) tmp;
> +       if (priv->virt_tx_buf_baseaddr == NULL ||
> +           (priv->phy_tx_buf_baseaddr & 0x03)) {
> +               netdev_err(ndev, "TX buffer alloc failed\n");
> +               goto init_fail;
> +       }
> +
> +       tmp = dma_alloc_coherent(NULL, RX_BUF_SIZE * RX_DESC_NUM,
> +                                (dma_addr_t *)&priv->phy_rx_buf_baseaddr,
> +                                GFP_DMA | GFP_KERNEL);
> +       priv->virt_rx_buf_baseaddr = (unsigned char *) tmp;
> +       if (priv->virt_rx_buf_baseaddr == NULL ||
> +           (priv->phy_rx_buf_baseaddr & 0x03)) {
> +               netdev_err(ndev, "RX buffer alloc failed\n");
> +               goto init_fail;
> +       }

This pool of buffers looks unnecessary, as stated above, you should
rather perform DMA map_single/unmap_single operations instead.
--
Florian
