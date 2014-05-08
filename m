From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH] net:Add basic DWC Ethernet QoS Driver
Date: Thu, 08 May 2014 14:51:28 +0200
Message-ID: <20248221.mJ8pFfyc5U@wuerfel>
References: <201405081349.03139.Andreas.Irestal@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
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
In-Reply-To: <201405081349.03139.Andreas.Irestal@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 May 2014 13:49:02 Andreas Irestal wrote:
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
>  drivers/net/ethernet/synopsys/dwc_eth_qos.c |  710 +++++++++++++++++++++++++++
>  drivers/net/ethernet/synopsys/dwc_eth_qos.h |  308 ++++++++++++

Should we maybe move the dw_mac driver out of the stmicro directory into
synopsys as a preparation, to keep them in the same place?

> diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
> new file mode 100644
> index 0000000..bd37802
> --- /dev/null
> +++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
> @@ -0,0 +1,710 @@
> +
> +#define DRIVER_NAME			"dwceqos"
> +#define DRIVER_DESCRIPTION		"Synopsys DWC Ethernet QoS driver"
> +#define DRIVER_VERSION			"0.1"
> +
> +#ifdef DWCEQOS_DEBUG
> +static void dwceqos_write(void __iomem *p, u32 offset, u32 v)
> +{
> +	printk(KERN_DEBUG "Write: Addr=%08x, Data=%08x\n", (u32)p + offset , v);
> +	writel(v, p + offset);
> +}
> +
> +static u32 dwceqos_read(void __iomem *p, u32 offset)
> +{
> +	u32 v = 0;
> +	v = readl(p + offset);
> +	printk(KERN_DEBUG "Read: Addr=%08x, Data=%08x\n", (u32)p + offset, v);
> +	return v;
> +}
> +#else
> +#define dwceqos_read(base, reg)						\
> +	__raw_readl(((void __iomem *)(base)) + (reg))
> +#define dwceqos_write(base, reg, val)					\
> +	__raw_writel((val), ((void __iomem *)(base)) + (reg))
> +#endif

I think you should get rid of this debugging output for the final version that
gets included. If anyone needs to still do debugging on this level, they can
always put it back.

__raw_readl/__raw_writel is the wrong interface here, you should use
either readl/writel or (for better performance, but understanding what
it means for barriers) readl_relaxed/writel_relaxed.

If you want to keep the wrapper function, it makes more sense to pass
the net_local structure rather than the iomem pointer, but you can also
just open-code the readl_relaxed.

> +/* DMA ring descriptor. These are used as support descriptors for the HW DMA */
> +struct ring_info {
> +	struct sk_buff *skb;
> +	dma_addr_t mapping;
> +	size_t len;
> +};
> +
> +struct net_local {
> +	void __iomem *baseaddr;
> +	struct clk *phy_ref_clk;
> +	struct clk *apb_pclk;
> +
> +	struct net_device *ndev;
> +	struct platform_device *pdev;
> +
> +	volatile struct dwc_eth_qos_txdesc *tx_descs;
> +	volatile struct dwc_eth_qos_rxdesc *rx_descs;

The volatile is probably unnecessary, possibly wrong here.

> +	void *tx_buf;

seems not to be used.

> +/* Allocate DMA helper structure at position given by index */
> +static void dwceqos_alloc_rxring_desc(struct net_local *lp, int index)
> +{
> +	struct sk_buff *new_skb;
> +	u32 new_skb_baddr = 0;
> +	new_skb = netdev_alloc_skb(lp->ndev, DWCEQOS_RX_BUF_SIZE);
> +	if (!new_skb) {
> +		dev_err(&lp->ndev->dev, "alloc_skb error for desc %d\n", index);
> +		goto out;
> +	}
> +
> +	/* Get dma handle of skb->data */
> +	new_skb_baddr = (u32)dma_map_single(lp->ndev->dev.parent,
> +		new_skb->data, DWCEQOS_RX_BUF_SIZE, DMA_FROM_DEVICE);
> +	if (dma_mapping_error(lp->ndev->dev.parent, new_skb_baddr)) {
> +		dev_err(&lp->pdev->dev, "DMA map error\n");
> +		dev_kfree_skb(new_skb);
> +		new_skb = NULL;
> +	}

dma_mapping_error() is never true when dma_addr_t is longer than 'u32'
here. Better get rid of the cast above.

> +/* Allocate and initiate DMA rings for TX and RX. Also allocates RX buffers for
> + * incoming packets.
> + */
> +static int dwceqos_dma_alloc(struct net_local *lp)
> +{
> +	u32 size;
> +	int i;
> +
> +	size = DWCEQOS_RX_DCNT * sizeof(struct ring_info);
> +	lp->rx_skb = kzalloc(size, GFP_KERNEL);
> +	if (!lp->rx_skb) {
> +		dev_err(&lp->pdev->dev, "Unable to allocate ring descriptor area\n");
> +		return -ENOMEM;
> +	}
> +
> +	/* Allocate DMA descriptors */
> +	size = DWCEQOS_TX_DCNT * sizeof(struct dwc_eth_qos_txdesc);
> +	lp->tx_descs = dma_alloc_coherent(&lp->pdev->dev, size,
> +			&lp->tx_descs_addr, 0);

Using '0' as the gfp flag looks wrong, better use GFP_KERNEL.

> +/* HW transmit function. */
> +static void dwceqos_dma_xmit(struct net_local *lp, void *data, int len)
> +{
> +	u32 regval;
> +	int i = lp->next_tx;
> +	int dwc_wait;
> +	dma_addr_t dma_handle;
> +
> +	dma_handle = dma_map_single(lp->ndev->dev.parent,
> +		data, DWCEQOS_RX_BUF_SIZE, DMA_TO_DEVICE);
> +	if (dma_mapping_error(lp->ndev->dev.parent, dma_handle)) {
> +		dev_err(&lp->pdev->dev, "DMA Mapping error\n");
> +		return;
> +	}
> +
> +	lp->tx_descs[i].tdes0.rd.buffer1 = dma_handle;
> +	lp->tx_descs[i].tdes2.rd.buf1len = len;
> +	lp->tx_descs[i].tdes3.rd.fl = len;
> +	lp->tx_descs[i].tdes3.rd.fd = 1;
> +	lp->tx_descs[i].tdes3.rd.ld = 1;
> +	lp->tx_descs[i].tdes3.rd.own = 1;
> +
> +	/* Issue Transmit Poll by writing address of next free descriptor */
> +	regval = lp->tx_descs_addr + (i+1) * sizeof(struct dwc_eth_qos_txdesc);
> +	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TXDESC_TAIL, regval);
> +
> +	/* Set poll wait timeout to 2 seconds */
> +	dwc_wait = 200;
> +
> +	while (lp->tx_descs[i].tdes3.wr.own) {
> +		mdelay(10);
> +		if (!dwc_wait--)
> +			break;
> +	}

This is really evil: you are blocking the CPU for up to two seconds!
You already mentioned that this is work-in-progress, but I guess it has
to be a little better than this and do something that doesn't block
out the CPU during TX.

> +/* NAPI poll routine */
> +int dwceqos_rx_poll(struct napi_struct *napi, int budget)
> +{
> +	struct net_local *lp = container_of(napi, struct net_local, napi);
> +	int npackets = 0;
> +	struct sk_buff *skb;
> +
> +	spin_lock(&lp->rx_lock);
> +	while (npackets < budget && dwceqos_packet_avail(lp)) {
> +
> +		skb = dwceqos_recv_packet(lp);
> +		if (!skb)
> +			break;
> +
> +		netif_receive_skb(skb);
> +
> +		lp->stats.rx_packets++;
> +		lp->stats.rx_bytes += skb->len;
> +		npackets++;
> +	}
> +	if (npackets < budget)
> +		napi_complete(napi);
> +
> +	spin_unlock(&lp->rx_lock);
> +	return npackets;
> +}

IIRC, you shouldn't need lock here, as only one CPU is in the poll
function for a given queue.

You should probably do the tx reclaim in this function as well.

> +struct net_device_ops dwceq_netdev_ops;

Just put the entire definition here, rather than just the forward
declaration.

> +#ifdef CONFIG_OF
> +static inline int dwceqos_probe_config_dt(struct platform_device *pdev)
> +{
> +	struct net_device *ndev;
> +	const void *mac_address;
> +
> +	ndev = platform_get_drvdata(pdev);
> +	/* Set the MAC address. */
> +	mac_address = of_get_mac_address(pdev->dev.of_node);
> +	if (mac_address)
> +		memcpy(ndev->dev_addr, mac_address, ETH_ALEN);
> +	else
> +		dev_warn(&pdev->dev, "No MAC address found\n");
> +	return 0;
> +}
> +#else
> +static inline int dwceqos_probe_config_dt()
> +{
> +	return -ENOSYS;
> +}
> +#endif

of_get_mac_address() is an empty function if CONFIG_OF is not
set. That means you can just remove the #ifdef here, in particular
since you don't actually support running this driver without a valid
DT.

You should also add a DT binding document.

> diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.h b/drivers/net/ethernet/synopsys/dwc_eth_qos.h
> new file mode 100644
> index 0000000..9aa84a0
> --- /dev/null
> +++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.h
> @@ -0,0 +1,308 @@
> +#ifndef DWC_ETH_QOS_H
> +#define DWC_ETH_QOS_H
> +
> +#define DWCEQOS_RX_BUF_SIZE 2048
> +
> +#define DWCEQOS_RX_DCNT 16
> +#define DWCEQOS_TX_DCNT 16
> +
> +/* DMA Registers */
> +#define DWCEQOS_DMA_MODE			0x1000
> +#define DWCEQOS_DMA_SYSBUS_MODE			0x1004
> +#define DWCEQOS_DMA_INT_STAT			0x1008
> +#define DWCEQOS_DMA_DEBUG_STAT0			0x100c
> +#define DWCEQOS_DMA_DEBUG_STAT1			0x1010

I generally recommend putting these definitions into the .c file in cases
where you only have a single file for the driver anyway.

> +/* Fields/constants */
> +#define DWCEQOS_DMA_MODE_SWR			1
> +#define DWCEQOS_DMA_MODE_TXPR			(1 << 11)
> +#define DWCEQOS_DMA_MODE_DA			(1 << 1)
> +#define DWCEQOS_DMA_SYSBUS_MB			(1 << 14)

I find it more readable to use hexadecimal notation here

#define DWCEQOS_DMA_MODE_SWR		0x0001
#define DWCEQOS_DMA_MODE_DA		0x0002
#define DWCEQOS_DMA_MODE_TXPR		0x0800
#define DWCEQOS_DMA_SYSBUS_MB		0x4000

> +
> +struct tdes2_rd {
> +	u32 buf1len:14;
> +	u32 vtir:2;
> +	u32 buf2len:14;
> +	u32 ttse:1;
> +	u32 ioc:1;
> +};
> +
> +struct tdes3_rd {
> +	u32 fl:15;
> +	u32 tiplh:1;
> +	u32 cic:2;
> +	u32 tse:1;
> +	u32 slotnum:4;
> +	u32 saic:3;
> +	u32 cpc:2;
> +	u32 ld:1;
> +	u32 fd:1;
> +	u32 ctxt:1;
> +	u32 own:1;
> +};

Bit fields are always problematic for hardware structures, in particular
regarding endianess. It's better to avoid them completely and use macros

	Arnd
