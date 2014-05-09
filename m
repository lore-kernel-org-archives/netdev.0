From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [RFC PATCH] net:Add basic DWC Ethernet QoS Driver
Date: Fri, 9 May 2014 17:19:46 +0200
Message-ID: <20140509151946.GM6455@distanz.ch>
References: <201405081450.14449.Andreas.Irestal@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"maxime.ripard@free-electrons.com" <maxime.ripard@free-electrons.com>,
	"abrodkin@synopsys.com" <abrodkin@synopsys.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"sr@denx.de" <sr@denx.de>,
	"jonas.jensen@gmail.com" <jonas.jensen@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Jesper Nilsson <jespern@axis.com>
To: Andreas Irestal <andreas.irestal@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201405081450.14449.Andreas.Irestal@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014-05-08 at 14:50:14 +0200, Andreas Irestal <andreas.irestal@axis.com> wrote:
> This is an early version of a driver for the Synopsys DWC Ethernet QoS IP
> version 4. Unfortunately, version 4.00a and onwards of this IP is totally
> different from earlier versions used in the STMicroelectronics drivers. Both
> functionality and registers are different. As this is my first network driver
> I am submitting an RFC to catch design flaws and bad coding standards at an
> early stage. Also, others looking at this IP could hopefully be helped by this
> early code.
> 
> The driver is quite inefficient, yet still functional (Gbit only) and uses a
> polling-driven TX-approach. For the RX side NAPI and interrupts are used.
> There are still quite a lot of work to do. Link handling, more robust
> error-handling, HW Checksumming, scatter-gather and TCP Segmentation and
> checksum offloading to name a few.
> 
> All code has been developed and tested using an FPGA implementation of the IP,
> with an ARM Cortex A9 as the main CPU, running Linux 3.13.
> 
> Signed-off-by: Andreas Irestaal <Andreas.Irestal@axis.com>
> ---
>  drivers/net/ethernet/Kconfig                |    1 +
>  drivers/net/ethernet/Makefile               |    1 +
>  drivers/net/ethernet/synopsys/Kconfig       |   24 +
>  drivers/net/ethernet/synopsys/Makefile      |    5 +
>  drivers/net/ethernet/synopsys/dwc_eth_qos.c |  706 +++++++++++++++++++++++++++
>  drivers/net/ethernet/synopsys/dwc_eth_qos.h |  308 ++++++++++++
>  6 files changed, 1045 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/ethernet/synopsys/Kconfig
>  create mode 100644 drivers/net/ethernet/synopsys/Makefile
>  create mode 100644 drivers/net/ethernet/synopsys/dwc_eth_qos.c
>  create mode 100644 drivers/net/ethernet/synopsys/dwc_eth_qos.h

[...]

> diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
> new file mode 100644
> index 0000000..20b1a9e
> --- /dev/null
> +++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
> @@ -0,0 +1,706 @@

[...]

> +struct net_local {
> +       void __iomem *baseaddr;
> +       struct clk *phy_ref_clk;
> +       struct clk *apb_pclk;
> +
> +       struct net_device *ndev;
> +       struct platform_device *pdev;
> +
> +       volatile struct dwc_eth_qos_txdesc *tx_descs;
> +       volatile struct dwc_eth_qos_rxdesc *rx_descs;
> +
> +       void *tx_buf;
> +
> +       struct ring_info *rx_skb;
> +
> +       dma_addr_t tx_descs_addr;
> +       dma_addr_t rx_descs_addr;
> +
> +       u32 next_tx;
> +       u32 next_rx;
> +
> +       struct napi_struct napi;
> +
> +       struct net_device_stats stats;

You don't need a private copy of struct net_device_stats, just use the
one from struct net_device. It looks like the driver is not returning
these stats currently anyway. If you use ndev->stats, they will be
picked up by dev_get_stats() and i.e. show up in ifconfig output.

> +       spinlock_t rx_lock;
> +};
> +
> +/* Allocate DMA helper structure at position given by index */
> +static void dwceqos_alloc_rxring_desc(struct net_local *lp, int index)
> +{
> +       struct sk_buff *new_skb;
> +       u32 new_skb_baddr = 0;
> +       new_skb = netdev_alloc_skb(lp->ndev, DWCEQOS_RX_BUF_SIZE);
> +       if (!new_skb) {
> +               dev_err(&lp->ndev->dev, "alloc_skb error for desc %d\n", index);
> +               goto out;
> +       }
> +
> +       /* Get dma handle of skb->data */
> +       new_skb_baddr = (u32)dma_map_single(lp->ndev->dev.parent,
> +               new_skb->data, DWCEQOS_RX_BUF_SIZE, DMA_FROM_DEVICE);
> +       if (dma_mapping_error(lp->ndev->dev.parent, new_skb_baddr)) {
> +               dev_err(&lp->pdev->dev, "DMA map error\n");
> +               dev_kfree_skb(new_skb);
> +               new_skb = NULL;
> +       }
> +out:
> +       lp->rx_skb[index].skb = new_skb;
> +       lp->rx_skb[index].mapping = new_skb_baddr;
> +       lp->rx_skb[index].len = DWCEQOS_RX_BUF_SIZE;
> +
> +       return;
> +}
> +
> +static void dwceqos_mtl_init(struct net_local *lp)
> +{
> +       dwceqos_write(lp->baseaddr, DWCEQOS_MTL_OP_MODE, 0x00000060);
> +}
> +
> +static void dwceqos_mtl_tx_init(struct net_local *lp)
> +{
> +       dwceqos_write(lp->baseaddr, DWCEQOS_MTL_TXQ0_OP_MODE,
> +                       DWCEQOS_MTL_TXQ_EN);
> +}
> +
> +static void dwceqos_mtl_rx_init(struct net_local *lp)
> +{
> +       dwceqos_write(lp->baseaddr, DWCEQOS_MTL_RXQ0_OP_MODE,
> +               DWCEQOS_MTL_RXQ_RQS256 | DWCEQOS_MTL_RXQ_DIS_TCP_EF |
> +               DWCEQOS_MTL_RXQ_FEP | DWCEQOS_MTL_RXQ_FUP |
> +               DWCEQOS_MTL_RXQ_RTC32);
> +}
> +
> +static void dwceqos_mac_rx_init(struct net_local *lp)
> +{
> +       u32 val;
> +       dwceqos_write(lp->baseaddr, DWCEQOS_MAC_RXQ_CTRL0, 2);
> +       val = DWCEQOS_MAC_PKT_FILTER_RX_ALL | DWCEQOS_MAC_PKT_FILTER_PCF_ALL |
> +               DWCEQOS_MAC_PKT_FILTER_PROMISCUOUS;
> +       dwceqos_write(lp->baseaddr, DWCEQOS_MAC_PKT_FILTER, val);
> +}
> +
> +static int dwceqos_mac_enable(struct net_local *lp)
> +{
> +       dwceqos_write(lp->baseaddr, DWCEQOS_MAC_CFG,
> +               DWCEQOS_MAC_CFG_DM | DWCEQOS_MAC_CFG_TE |
> +               DWCEQOS_MAC_CFG_RE);
> +       return 0;
> +}
> +
> +static void dwceqos_dma_wake_rx(struct net_local *lp)
> +{
> +       u32 offset;
> +       offset = DWCEQOS_RX_DCNT * sizeof(struct dwc_eth_qos_rxdesc);
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RXDESC_TAIL,
> +               (u32)lp->rx_descs_addr + offset);
> +}
> +
> +static inline void dwceqos_dma_rx_start(struct net_local *lp)
> +{
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RX_CTRL,
> +               DWCEQOS_DMA_CH0_TXRX_CONTROL_START |
> +               DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16 |
> +               DWCEQOS_RX_BUF_SIZE);
> +       dwceqos_dma_wake_rx(lp);
> +}
> +
> +static inline void dwceqos_dma_tx_start(struct net_local *lp)
> +{
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TX_CTRL,
> +               DWCEQOS_DMA_CH0_TXRX_CONTROL_START |
> +               DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16);
> +}
> +
> +static void dwceqos_dma_setmode(struct net_local *lp)
> +{
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_MODE,
> +               DWCEQOS_DMA_MODE_TXPR | DWCEQOS_DMA_MODE_DA);
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_SYSBUS_MODE,
> +               DWCEQOS_DMA_SYSBUS_MB);
> +}
> +
> +static void dwceqos_dma_txenable(struct net_local *lp)
> +{
> +       u32 val;
> +       val = DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16 |
> +               DWCEQOS_DMA_CH0_TXRX_CONTROL_START;
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TX_CTRL, val);
> +}
> +
> +static void dwceqos_dma_rx_enable(struct net_local *lp)
> +{
> +       u32 val;
> +       val = DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16 |
> +               DWCEQOS_RX_BUF_SIZE | DWCEQOS_DMA_CH0_TXRX_CONTROL_START;
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RX_CTRL, val);
> +}
> +
> +/* Initialize DMA descriptors to their start values */
> +static void dwceqos_dma_prepare(struct net_local *lp)
> +{
> +       int i;
> +       for (i = 0; i < DWCEQOS_TX_DCNT; ++i) {
> +               lp->tx_descs[i].tdes0.raw = 0;
> +               lp->tx_descs[i].tdes1.raw = 0;
> +               lp->tx_descs[i].tdes2.raw = 0;
> +               lp->tx_descs[i].tdes3.raw = 0;
> +       }
> +
> +       for (i = 0; i < DWCEQOS_RX_DCNT; ++i) {
> +               lp->rx_descs[i].rdes0.rd.buffer1 = lp->rx_skb[i].mapping;
> +               lp->rx_descs[i].rdes1.raw = 0;
> +               lp->rx_descs[i].rdes2.rd.buffer2 = 0;
> +               lp->rx_descs[i].rdes3.raw = 0;
> +               lp->rx_descs[i].rdes3.rd.buf1v = 1;
> +               lp->rx_descs[i].rdes3.rd.inte = 1;
> +               lp->rx_descs[i].rdes3.rd.own = 1;
> +       }
> +       lp->next_tx = 0;
> +       lp->next_rx = 0;
> +}
> +
> +/* Allocate and initiate DMA rings for TX and RX. Also allocates RX buffers for
> + * incoming packets.
> + */
> +static int dwceqos_dma_alloc(struct net_local *lp)
> +{
> +       u32 size;
> +       int i;
> +
> +       size = DWCEQOS_RX_DCNT * sizeof(struct ring_info);
> +       lp->rx_skb = kzalloc(size, GFP_KERNEL);
> +       if (!lp->rx_skb) {
> +               dev_err(&lp->pdev->dev, "Unable to allocate ring descriptor area\n");
> +               return -ENOMEM;
> +       }
> +
> +       /* Allocate DMA descriptors */
> +       size = DWCEQOS_TX_DCNT * sizeof(struct dwc_eth_qos_txdesc);
> +       lp->tx_descs = dma_alloc_coherent(&lp->pdev->dev, size,
> +                       &lp->tx_descs_addr, 0);
> +       if (!lp->tx_descs) {
> +               dev_err(&lp->pdev->dev, "Failed to allocate TX DMA descriptors\n");
> +               /* Should deallocate memory here */
> +               return -ENOMEM;
> +       }
> +       size = DWCEQOS_RX_DCNT * sizeof(struct dwc_eth_qos_rxdesc);
> +       lp->rx_descs = dma_alloc_coherent(&lp->pdev->dev, size,
> +                       &lp->rx_descs_addr, 0);
> +       if (!lp->rx_descs) {
> +               dev_err(&lp->pdev->dev, "Failed to allocate RX DMA descriptors\n");
> +               /* Should deallocate memory here */
> +               return -ENOMEM;
> +       }
> +
> +       for (i = 0; i < DWCEQOS_RX_DCNT; ++i) {
> +               dwceqos_alloc_rxring_desc(lp, i);
> +               if (!(lp->rx_skb[lp->next_rx].skb)) {
> +                       dev_err(&lp->pdev->dev, "Unable to map descriptor %d to DMA\n",
> +                               lp->next_rx);
> +                       /* What error code to return for mapping error? */
> +                       return -1;
> +               }
> +       }
> +
> +       dwceqos_dma_prepare(lp);
> +
> +       /* Tell HW where to look*/
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RXDESC_RING_LEN,
> +               DWCEQOS_RX_DCNT-1);
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TXDESC_RING_LEN,
> +               DWCEQOS_TX_DCNT-1);
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RXDESC_LIST_ADDR,
> +               (u32)lp->rx_descs_addr);
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TXDESC_LIST_ADDR,
> +               (u32)lp->tx_descs_addr);
> +       return 0;
> +}
> +
> +/* Checks if there are any available incoming packets ready for processing */
> +int dwceqos_packet_avail(struct net_local *lp)

Make this function static.

> +{
> +       return !lp->rx_descs[lp->next_rx].rdes3.wr.own;
> +}
> +
> +/* Free DMA descriptor area */
> +static void dwceqos_dma_free(struct net_local *lp)
> +{
> +       u32 size;
> +       size = DWCEQOS_TX_DCNT * sizeof(struct dwc_eth_qos_txdesc);
> +       if (lp->tx_descs)
> +               dma_free_coherent(&lp->pdev->dev, size,
> +                       lp->tx_descs, lp->tx_descs_addr);
> +       size = DWCEQOS_RX_DCNT * sizeof(struct dwc_eth_qos_rxdesc);
> +       if (lp->rx_descs)
> +               dma_free_coherent(&lp->pdev->dev, size,
> +                       lp->rx_descs, lp->rx_descs_addr);
> +}
> +
> +/* HW transmit function. */
> +static void dwceqos_dma_xmit(struct net_local *lp, void *data, int len)
> +{
> +       u32 regval;
> +       int i = lp->next_tx;
> +       int dwc_wait;
> +       dma_addr_t dma_handle;
> +
> +       dma_handle = dma_map_single(lp->ndev->dev.parent,
> +               data, DWCEQOS_RX_BUF_SIZE, DMA_TO_DEVICE);
> +       if (dma_mapping_error(lp->ndev->dev.parent, dma_handle)) {
> +               dev_err(&lp->pdev->dev, "DMA Mapping error\n");
> +               return;
> +       }
> +
> +       lp->tx_descs[i].tdes0.rd.buffer1 = dma_handle;
> +       lp->tx_descs[i].tdes2.rd.buf1len = len;
> +       lp->tx_descs[i].tdes3.rd.fl = len;
> +       lp->tx_descs[i].tdes3.rd.fd = 1;
> +       lp->tx_descs[i].tdes3.rd.ld = 1;
> +       lp->tx_descs[i].tdes3.rd.own = 1;
> +
> +       /* Issue Transmit Poll by writing address of next free descriptor */
> +       regval = lp->tx_descs_addr + (i+1) * sizeof(struct dwc_eth_qos_txdesc);
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TXDESC_TAIL, regval);
> +
> +       /* Set poll wait timeout to 2 seconds */
> +       dwc_wait = 200;
> +
> +       while (lp->tx_descs[i].tdes3.wr.own) {
> +               mdelay(10);
> +               if (!dwc_wait--)
> +                       break;
> +       }
> +       if (lp->tx_descs[i].tdes3.wr.own)
> +               dev_err(&lp->pdev->dev, "Failed to transmit: Timed out\n");
> +
> +       lp->next_tx = (lp->next_tx + 1) % DWCEQOS_TX_DCNT;
> +       dma_unmap_single(lp->ndev->dev.parent,
> +                       dma_handle, DWCEQOS_RX_BUF_SIZE, DMA_TO_DEVICE);
> +}
> +
> +/* Store HW Addr in MAC registers. Source Address Replacement not used yet */
> +static void dwceqos_set_hwaddr(struct net_local *lp)
> +{
> +       u32 val;
> +
> +       val = DWCEQOS_MAC_ADDR_HI_EN | (lp->ndev->dev_addr[0] << 8) |
> +               (lp->ndev->dev_addr[1]);
> +       dwceqos_write(lp->baseaddr, DWCEQOS_MAC_ADDR_HI, val);
> +       val = (lp->ndev->dev_addr[2] << 24) | (lp->ndev->dev_addr[3] << 16) |
> +               (lp->ndev->dev_addr[4] << 8)  | (lp->ndev->dev_addr[5]);
> +       dwceqos_write(lp->baseaddr, DWCEQOS_MAC_ADDR_LO, val);
> +}
> +
> +/* DMA reset. When issued also resets all MTL and MAC registers as well */
> +static void dwceqos_dma_reset(struct net_local *lp)
> +{
> +       /* Wait 5 seconds for DMA reset*/
> +       int i = 5000;
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_MODE, 1);
> +
> +       do {
> +               mdelay(1);
> +       } while ((dwceqos_read(lp->baseaddr, DWCEQOS_DMA_MODE) & 0x1) && i--);
> +}
> +
> +/* Interrupt handler. So far only RX interrupts are used */
> +static irqreturn_t dwceqos_interrupt(int irq, void *dev_id)
> +{
> +       struct net_device *ndev = dev_id;
> +       struct net_local *lp = netdev_priv(ndev);
> +
> +       u32 cause;
> +       u32 val;
> +
> +       cause = dwceqos_read(lp->baseaddr, DWCEQOS_DMA_INT_STAT);
> +       if (cause & 0x00000001) {
> +               /* DMA Channel 0 Interrupt. Assume RX interrupt for now */
> +               val = dwceqos_read(lp->baseaddr, DWCEQOS_DMA_CH0_STAT);
> +               /* Ack */
> +               dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_STAT, val);
> +               if (val & 0x00000040)
> +                       napi_schedule(&lp->napi);
> +       } else if (unlikely(!cause)) {
> +               return IRQ_NONE;
> +       }
> +       return IRQ_HANDLED;
> +}
> +
> +static int dwceqos_open(struct net_device *ndev)
> +{
> +       /* Allocate Buffers & DMA Descr. + Initiate DMA descriptors */
> +       struct net_local *lp = netdev_priv(ndev);
> +
> +       /* Set up hardware. It looks like order of writes is important here.
> +        * Only gigatbit support, no advanced MTL or MAC configuration yet.
> +        */
> +       dwceqos_dma_reset(lp);
> +       dwceqos_mtl_init(lp);
> +       dwceqos_mtl_tx_init(lp);
> +       dwceqos_dma_setmode(lp);
> +       dwceqos_dma_alloc(lp);
> +       dwceqos_dma_wake_rx(lp);
> +       dwceqos_dma_txenable(lp);
> +       dwceqos_mtl_rx_init(lp);
> +       dwceqos_mac_rx_init(lp);
> +       dwceqos_dma_rx_enable(lp);
> +       dwceqos_dma_wake_rx(lp);
> +       dwceqos_set_hwaddr(lp);
> +       dwceqos_mac_enable(lp);
> +
> +       /* Enable RX Interrupts */
> +       dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_INT_EN, 0x00010040);
> +
> +       napi_enable(&lp->napi);
> +       netif_carrier_on(ndev);
> +       netif_start_queue(ndev);
> +       return 0;
> +}
> +
> +
> +int dwceqos_stop(struct net_device *ndev)

Make this function static.

> +{
> +       struct net_local *lp = netdev_priv(ndev);
> +       dwceqos_dma_free(lp);
> +       netif_stop_queue(ndev);
> +       napi_disable(&lp->napi);
> +       netif_carrier_off(ndev);
> +       return 0;
> +}
> +
> +/* Receive one packet and return skb */
> +struct sk_buff *
> +dwceqos_recv_packet(struct net_local *lp)

Make this function static.

> +{
> +       struct sk_buff *skb;
> +       u32 len;
> +
> +       skb = lp->rx_skb[lp->next_rx].skb;
> +       len = lp->rx_descs[lp->next_rx].rdes3.wr.length;
> +
> +       /* Unmap old buffer */
> +       dma_unmap_single(lp->ndev->dev.parent, lp->rx_skb[lp->next_rx].mapping,
> +               lp->rx_skb[lp->next_rx].len, DMA_FROM_DEVICE);
> +       skb_put(skb, len);
> +       skb->protocol = eth_type_trans(skb, lp->ndev);
> +       skb->ip_summed = 0;
> +
> +       /* Initialize new Buffer descriptor */
> +       dwceqos_alloc_rxring_desc(lp, lp->next_rx);
> +       if (!(lp->rx_skb[lp->next_rx].skb)) {
> +               dev_err(&lp->pdev->dev, "Unable to map descriptor %d to DMA\n",
> +                       lp->next_rx);
> +               return NULL;
> +       }
> +
> +       /* Initialize new DMA descriptor */
> +       lp->rx_descs[lp->next_rx].rdes0.rd.buffer1 =
> +               lp->rx_skb[lp->next_rx].mapping;
> +       lp->rx_descs[lp->next_rx].rdes1.raw = 0;
> +       lp->rx_descs[lp->next_rx].rdes2.rd.buffer2 = 0;
> +       lp->rx_descs[lp->next_rx].rdes3.raw = 0;
> +       lp->rx_descs[lp->next_rx].rdes3.rd.buf1v = 1;
> +       lp->rx_descs[lp->next_rx].rdes3.rd.inte = 1;
> +       lp->rx_descs[lp->next_rx].rdes3.rd.own = 1;
> +       lp->next_rx = (lp->next_rx + 1) % DWCEQOS_RX_DCNT;
> +       return skb;
> +}
> +
> +
> +/* NAPI poll routine */
> +int dwceqos_rx_poll(struct napi_struct *napi, int budget)
> +{
> +       struct net_local *lp = container_of(napi, struct net_local, napi);
> +       int npackets = 0;
> +       struct sk_buff *skb;
> +
> +       spin_lock(&lp->rx_lock);
> +       while (npackets < budget && dwceqos_packet_avail(lp)) {
> +
> +               skb = dwceqos_recv_packet(lp);
> +               if (!skb)
> +                       break;
> +
> +               netif_receive_skb(skb);
> +
> +               lp->stats.rx_packets++;
> +               lp->stats.rx_bytes += skb->len;
> +               npackets++;
> +       }
> +       if (npackets < budget)
> +               napi_complete(napi);
> +
> +       spin_unlock(&lp->rx_lock);
> +       return npackets;
> +}
> +
> +/* Main transmit function called from kernel */
> +int dwceqos_start_xmit(struct sk_buff *skb, struct net_device *ndev)

Make this function static.

> +{
> +       int len;
> +       struct net_local *lp = netdev_priv(ndev);
> +       char *data;
> +       data = skb->data;
> +       len = skb->len;
> +
> +       /* Send packet on wire */
> +       dwceqos_dma_xmit(lp, data, len);
> +
> +       skb_tx_timestamp(skb);
> +
> +       ndev->stats.tx_bytes += len;
> +       dev_kfree_skb(skb);
> +
> +       return 0;
> +}
> +
> +struct net_device_ops dwceq_netdev_ops;

Why not initialize this here?

> +#ifdef CONFIG_OF
> +static inline int dwceqos_probe_config_dt(struct platform_device *pdev)
> +{
> +       struct net_device *ndev;
> +       const void *mac_address;
> +
> +       ndev = platform_get_drvdata(pdev);
> +       /* Set the MAC address. */
> +       mac_address = of_get_mac_address(pdev->dev.of_node);
> +       if (mac_address)
> +               memcpy(ndev->dev_addr, mac_address, ETH_ALEN);
> +       else
> +               dev_warn(&pdev->dev, "No MAC address found\n");
> +       return 0;
> +}
> +#else
> +static inline int dwceqos_probe_config_dt()
> +{
> +       return -ENOSYS;
> +}
> +#endif
> +
> +
> +/**
> + * dwceqos_probe - Platform driver probe
> + * @pdev: Pointer to platform device structure
> + *
> + * Return 0 on success, negative value if error
> + */
> +int dwceqos_probe(struct platform_device *pdev)

Make this function static.

> +{
> +       struct resource *r_mem = NULL;
> +       struct resource *r_irq = NULL;
> +       struct net_device *ndev;
> +       struct net_local *lp;
> +       int ret = -ENXIO;
> +
> +       r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       r_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +       if (!r_mem || !r_irq) {
> +               dev_err(&pdev->dev, "no IO resource defined.\n");
> +               return -ENXIO;
> +       }
> +       ndev = alloc_etherdev(sizeof(*lp));
> +       if (!ndev) {
> +               dev_err(&pdev->dev, "etherdev allocation failed.\n");
> +               return -ENOMEM;
> +       }
> +
> +       SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +       lp = netdev_priv(ndev);
> +       lp->ndev = ndev;
> +       lp->pdev = pdev;
> +
> +       lp->baseaddr = devm_ioremap_resource(&pdev->dev, r_mem);
> +       if (IS_ERR(lp->baseaddr)) {
> +               dev_err(&pdev->dev, "failed to map baseaddress.\n");
> +               ret = PTR_ERR(lp->baseaddr);
> +               goto err_out_free_netdev;
> +       }
> +
> +
> +       dev_dbg(&lp->pdev->dev, "BASEADDRESS hw: %p virt: %p\n",
> +                       (void *)r_mem->start, lp->baseaddr);
> +
> +       ndev->irq = platform_get_irq(pdev, 0);
> +       ndev->netdev_ops = &dwceq_netdev_ops;
> +       ndev->base_addr = r_mem->start;
> +       ndev->features = 0;
> +
> +       netif_napi_add(ndev, &lp->napi, dwceqos_rx_poll, 64);
> +
> +       ret = register_netdev(ndev);
> +       if (ret) {
> +               dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> +               goto err_out_free_netdev;
> +       }
> +
> +       lp->apb_pclk = devm_clk_get(&pdev->dev, "apb_pclk");
> +       if (IS_ERR(lp->apb_pclk)) {
> +               dev_err(&pdev->dev, "apb_pclk clock not found.\n");
> +               ret = PTR_ERR(lp->apb_pclk);
> +               goto err_out_unregister_netdev;
> +       }
> +       lp->phy_ref_clk = devm_clk_get(&pdev->dev, "phy_ref_clk");
> +       if (IS_ERR(lp->phy_ref_clk)) {
> +               dev_err(&pdev->dev, "phy_ref_clk clock not found.\n");
> +               ret = PTR_ERR(lp->phy_ref_clk);
> +               goto err_out_unregister_netdev;
> +       }
> +
> +       ret = clk_prepare_enable(lp->apb_pclk);
> +       if (ret) {
> +               dev_err(&pdev->dev, "Unable to enable APER clock.\n");
> +               goto err_out_unregister_netdev;
> +       }
> +       ret = clk_prepare_enable(lp->phy_ref_clk);
> +       if (ret) {
> +               dev_err(&pdev->dev, "Unable to enable device clock.\n");
> +               goto err_out_clk_dis_aper;
> +       }
> +
> +       platform_set_drvdata(pdev, ndev);
> +       dwceqos_probe_config_dt(pdev);
> +       dev_info(&lp->pdev->dev, "pdev->id %d, baseaddr 0x%08lx, irq %d\n",
> +                       pdev->id, ndev->base_addr, ndev->irq);
> +
> +       ret = devm_request_irq(&pdev->dev, ndev->irq, &dwceqos_interrupt, 0,
> +               ndev->name, ndev);
> +       if (ret) {
> +               dev_err(&lp->pdev->dev, "Unable to request IRQ %p, error %d\n",
> +                       r_irq, ret);
> +               goto err_out_unregister_clk_notifier;
> +       }
> +
> +       return 0;
> +
> +err_out_unregister_clk_notifier:
> +       clk_disable_unprepare(lp->phy_ref_clk);
> +err_out_clk_dis_aper:
> +       clk_disable_unprepare(lp->apb_pclk);
> +err_out_unregister_netdev:
> +       unregister_netdev(ndev);
> +err_out_free_netdev:
> +       free_netdev(ndev);
> +       platform_set_drvdata(pdev, NULL);
> +       return ret;
> +}
> +
> +int dwceqos_remove(struct platform_device *pdev)

Make this function static.

> +{
> +       struct net_device *ndev = platform_get_drvdata(pdev);
> +       unregister_netdev(ndev);
> +       free_netdev(ndev);
> +       return 0;
> +}
> +
> +struct net_device_ops dwceq_netdev_ops = {
> +       .ndo_open       = dwceqos_open,
> +       .ndo_stop       = dwceqos_stop,
> +       .ndo_start_xmit = dwceqos_start_xmit,
> +};

Move initialization to where it is declared and make the struct static.

> +
> +struct of_device_id dwceq_of_match[] = {
> +       { .compatible = "dwc,qos-ethernet", },
> +       {}
> +};

Make this struct static.

Make this struct static.
> +MODULE_DEVICE_TABLE(of, dwceq_of_match);
> +
> +struct platform_driver dwceqos_driver = {
> +       .probe   = dwceqos_probe,
> +       .remove  = dwceqos_remove,
> +       .driver  = {
> +               .name  = DRIVER_NAME,
> +               .owner = THIS_MODULE,
> +               .of_match_table = dwceq_of_match,
> +       },
> +};

Make this struct static.
