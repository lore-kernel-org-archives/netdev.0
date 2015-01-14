From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet
 driver
Date: Wed, 14 Jan 2015 08:34:06 -0800
Message-ID: <1421253246.11734.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com>
	 <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, robh+dt@kernel.org, davem@davemloft.net,
	grant.likely@linaro.org, agraf@suse.de,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, xuwei5@hisilicon.com,
	zhangfei.gao@linaro.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:48525 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbbANQeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 11:34:09 -0500
In-Reply-To: <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-14 at 14:34 +0800, Ding Tianhong wrote:
> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
> 
> v13: Fix the problem of alignment parameters for function and checkpatch warming.
> 
> v12: According Alex's suggestion, modify the changelog and add MODULE_DEVICE_TABLE
>      for hip04 ethernet.
> 
> v11: Add ethtool support for tx coalecse getting and setting, the xmit_more
>      is not supported for this patch, but I think it could work for hip04,
>      will support it later after some tests for performance better.
> 
>      Here are some performance test results by ping and iperf(add tx_coalesce_frames/users),
>      it looks that the performance and latency is more better by tx_coalesce_frames/usecs.
> 
>      - Before:
>      $ ping 192.168.1.1 ...
>      === 192.168.1.1 ping statistics ===
>      24 packets transmitted, 24 received, 0% packet loss, time 22999ms
>      rtt min/avg/max/mdev = 0.180/0.202/0.403/0.043 ms
> 
>      $ iperf -c 192.168.1.1 ...
>      [ ID] Interval       Transfer     Bandwidth
>      [  3]  0.0- 1.0 sec   115 MBytes   945 Mbits/sec
> 
>      - After:
>      $ ping 192.168.1.1 ...
>      === 192.168.1.1 ping statistics ===
>      24 packets transmitted, 24 received, 0% packet loss, time 22999ms
>      rtt min/avg/max/mdev = 0.178/0.190/0.380/0.041 ms
> 
>      $ iperf -c 192.168.1.1 ...
>      [ ID] Interval       Transfer     Bandwidth
>      [  3]  0.0- 1.0 sec   115 MBytes   965 Mbits/sec
> 
> v10: According David Miller and Arnd Bergmann's suggestion, add some modification
>      for v9 version
>      - drop the workqueue
>      - batch cleanup based on tx_coalesce_frames/usecs for better throughput
>      - use a reasonable default tx timeout (200us, could be shorted
>        based on measurements) with a range timer
>      - fix napi poll function return value
>      - use a lockless queue for cleanup
> 
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/ethernet/hisilicon/Makefile    |   2 +-
>  drivers/net/ethernet/hisilicon/hip04_eth.c | 969 +++++++++++++++++++++++++++++
>  2 files changed, 970 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c
> 
> diff --git a/drivers/net/ethernet/hisilicon/Makefile b/drivers/net/ethernet/hisilicon/Makefile
> index 40115a7..6c14540 100644
> --- a/drivers/net/ethernet/hisilicon/Makefile
> +++ b/drivers/net/ethernet/hisilicon/Makefile
> @@ -3,4 +3,4 @@
>  #
>  
>  obj-$(CONFIG_HIX5HD2_GMAC) += hix5hd2_gmac.o
> -obj-$(CONFIG_HIP04_ETH) += hip04_mdio.o
> +obj-$(CONFIG_HIP04_ETH) += hip04_mdio.o hip04_eth.o
> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
> new file mode 100644
> index 0000000..525214e
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -0,0 +1,969 @@
> +
> +/* Copyright (c) 2014 Linaro Ltd.
> + * Copyright (c) 2014 Hisilicon Limited.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/etherdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/interrupt.h>
> +#include <linux/ktime.h>
> +#include <linux/of_address.h>
> +#include <linux/phy.h>
> +#include <linux/of_mdio.h>
> +#include <linux/of_net.h>
> +#include <linux/mfd/syscon.h>
> +#include <linux/regmap.h>
> +
> +#define PPE_CFG_RX_ADDR			0x100
> +#define PPE_CFG_POOL_GRP		0x300
> +#define PPE_CFG_RX_BUF_SIZE		0x400
> +#define PPE_CFG_RX_FIFO_SIZE		0x500
> +#define PPE_CURR_BUF_CNT		0xa200
> +
> +#define GE_DUPLEX_TYPE			0x08
> +#define GE_MAX_FRM_SIZE_REG		0x3c
> +#define GE_PORT_MODE			0x40
> +#define GE_PORT_EN			0x44
> +#define GE_SHORT_RUNTS_THR_REG		0x50
> +#define GE_TX_LOCAL_PAGE_REG		0x5c
> +#define GE_TRANSMIT_CONTROL_REG		0x60
> +#define GE_CF_CRC_STRIP_REG		0x1b0
> +#define GE_MODE_CHANGE_REG		0x1b4
> +#define GE_RECV_CONTROL_REG		0x1e0
> +#define GE_STATION_MAC_ADDRESS		0x210
> +#define PPE_CFG_CPU_ADD_ADDR		0x580
> +#define PPE_CFG_MAX_FRAME_LEN_REG	0x408
> +#define PPE_CFG_BUS_CTRL_REG		0x424
> +#define PPE_CFG_RX_CTRL_REG		0x428
> +#define PPE_CFG_RX_PKT_MODE_REG		0x438
> +#define PPE_CFG_QOS_VMID_GEN		0x500
> +#define PPE_CFG_RX_PKT_INT		0x538
> +#define PPE_INTEN			0x600
> +#define PPE_INTSTS			0x608
> +#define PPE_RINT			0x604
> +#define PPE_CFG_STS_MODE		0x700
> +#define PPE_HIS_RX_PKT_CNT		0x804
> +
> +/* REG_INTERRUPT */
> +#define RCV_INT				BIT(10)
> +#define RCV_NOBUF			BIT(8)
> +#define RCV_DROP			BIT(7)
> +#define TX_DROP				BIT(6)
> +#define DEF_INT_ERR			(RCV_NOBUF | RCV_DROP | TX_DROP)
> +#define DEF_INT_MASK			(RCV_INT | DEF_INT_ERR)
> +
> +/* TX descriptor config */
> +#define TX_FREE_MEM			BIT(0)
> +#define TX_READ_ALLOC_L3		BIT(1)
> +#define TX_FINISH_CACHE_INV		BIT(2)
> +#define TX_CLEAR_WB			BIT(4)
> +#define TX_L3_CHECKSUM			BIT(5)
> +#define TX_LOOP_BACK			BIT(11)
> +
> +/* RX error */
> +#define RX_PKT_DROP			BIT(0)
> +#define RX_L2_ERR			BIT(1)
> +#define RX_PKT_ERR			(RX_PKT_DROP | RX_L2_ERR)
> +
> +#define SGMII_SPEED_1000		0x08
> +#define SGMII_SPEED_100			0x07
> +#define SGMII_SPEED_10			0x06
> +#define MII_SPEED_100			0x01
> +#define MII_SPEED_10			0x00
> +
> +#define GE_DUPLEX_FULL			BIT(0)
> +#define GE_DUPLEX_HALF			0x00
> +#define GE_MODE_CHANGE_EN		BIT(0)
> +
> +#define GE_TX_AUTO_NEG			BIT(5)
> +#define GE_TX_ADD_CRC			BIT(6)
> +#define GE_TX_SHORT_PAD_THROUGH		BIT(7)
> +
> +#define GE_RX_STRIP_CRC			BIT(0)
> +#define GE_RX_STRIP_PAD			BIT(3)
> +#define GE_RX_PAD_EN			BIT(4)
> +
> +#define GE_AUTO_NEG_CTL			BIT(0)
> +
> +#define GE_RX_INT_THRESHOLD		BIT(6)
> +#define GE_RX_TIMEOUT			0x04
> +
> +#define GE_RX_PORT_EN			BIT(1)
> +#define GE_TX_PORT_EN			BIT(2)
> +
> +#define PPE_CFG_STS_RX_PKT_CNT_RC	BIT(12)
> +
> +#define PPE_CFG_RX_PKT_ALIGN		BIT(18)
> +#define PPE_CFG_QOS_VMID_MODE		BIT(14)
> +#define PPE_CFG_QOS_VMID_GRP_SHIFT	8
> +
> +#define PPE_CFG_RX_FIFO_FSFU		BIT(11)
> +#define PPE_CFG_RX_DEPTH_SHIFT		16
> +#define PPE_CFG_RX_START_SHIFT		0
> +#define PPE_CFG_RX_CTRL_ALIGN_SHIFT	11
> +
> +#define PPE_CFG_BUS_LOCAL_REL		BIT(14)
> +#define PPE_CFG_BUS_BIG_ENDIEN		BIT(0)
> +
> +#define RX_DESC_NUM			128
> +#define TX_DESC_NUM			256
> +#define TX_NEXT(N)			(((N) + 1) & (TX_DESC_NUM-1))
> +#define RX_NEXT(N)			(((N) + 1) & (RX_DESC_NUM-1))
> +
> +#define GMAC_PPE_RX_PKT_MAX_LEN		379
> +#define GMAC_MAX_PKT_LEN		1516
> +#define GMAC_MIN_PKT_LEN		31
> +#define RX_BUF_SIZE			1600
> +#define RESET_TIMEOUT			1000
> +#define TX_TIMEOUT			(6 * HZ)
> +
> +#define DRV_NAME			"hip04-ether"
> +#define DRV_VERSION			"v1.0"
> +
> +#define HIP04_MAX_TX_COALESCE_USECS	200
> +#define HIP04_MIN_TX_COALESCE_USECS	100
> +#define HIP04_MAX_TX_COALESCE_FRAMES	200
> +#define HIP04_MIN_TX_COALESCE_FRAMES	100
> +
> +struct tx_desc {
> +	u32 send_addr;

	__be32 send_adddr; ?

> +	u32 send_size;

	__be32

> +	u32 next_addr;
	__be32

> +	u32 cfg;
	__be32

> +	u32 wb_addr;
	__be32 wb_addr ?

> +} __aligned(64);
> +
> +struct rx_desc {
> +	u16 reserved_16;
> +	u16 pkt_len;
> +	u32 reserve1[3];
> +	u32 pkt_err;
> +	u32 reserve2[4];
> +};
> +
> +struct hip04_priv {
> +	void __iomem *base;
> +	int phy_mode;
> +	int chan;
> +	unsigned int port;
> +	unsigned int speed;
> +	unsigned int duplex;
> +	unsigned int reg_inten;
> +
> +	struct napi_struct napi;
> +	struct net_device *ndev;
> +
> +	struct tx_desc *tx_desc;
> +	dma_addr_t tx_desc_dma;
> +	struct sk_buff *tx_skb[TX_DESC_NUM];
> +	dma_addr_t tx_phys[TX_DESC_NUM];

This is not an efficient way to store skb/phys, as for each skb, info
will be store in 2 separate cache lines.

It would be better to use a 

struct hip04_tx_desc {
   struct sk_buff   *skb;
   dma_addr_t       phys;
} 

> +	unsigned int tx_head;
> +
> +	int tx_coalesce_frames;
> +	int tx_coalesce_usecs;
> +	struct hrtimer tx_coalesce_timer;
> +
> +	unsigned char *rx_buf[RX_DESC_NUM];
> +	dma_addr_t rx_phys[RX_DESC_NUM];

Same thing here : Use a struct to get better data locality.

> +	unsigned int rx_head;
> +	unsigned int rx_buf_size;
> +
> +	struct device_node *phy_node;
> +	struct phy_device *phy;
> +	struct regmap *map;
> +	struct work_struct tx_timeout_task;
> +
> +	/* written only by tx cleanup */
> +	unsigned int tx_tail ____cacheline_aligned_in_smp;
> +};
> +
> +static inline unsigned int tx_count(unsigned int head, unsigned int tail)
> +{
> +	return (head - tail) % (TX_DESC_NUM - 1);
> +}
> +
> +static void hip04_config_port(struct net_device *ndev, u32 speed, u32 duplex)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	u32 val;
> +
> +	priv->speed = speed;
> +	priv->duplex = duplex;
> +
> +	switch (priv->phy_mode) {
> +	case PHY_INTERFACE_MODE_SGMII:
> +		if (speed == SPEED_1000)
> +			val = SGMII_SPEED_1000;
> +		else if (speed == SPEED_100)
> +			val = SGMII_SPEED_100;
> +		else
> +			val = SGMII_SPEED_10;
> +		break;
> +	case PHY_INTERFACE_MODE_MII:
> +		if (speed == SPEED_100)
> +			val = MII_SPEED_100;
> +		else
> +			val = MII_SPEED_10;
> +		break;
> +	default:
> +		netdev_warn(ndev, "not supported mode\n");
> +		val = MII_SPEED_10;
> +		break;
> +	}
> +	writel_relaxed(val, priv->base + GE_PORT_MODE);
> +
> +	val = duplex ? GE_DUPLEX_FULL : GE_DUPLEX_HALF;
> +	writel_relaxed(val, priv->base + GE_DUPLEX_TYPE);
> +
> +	val = GE_MODE_CHANGE_EN;
> +	writel_relaxed(val, priv->base + GE_MODE_CHANGE_REG);
> +}
> +
> +static void hip04_reset_ppe(struct hip04_priv *priv)
> +{
> +	u32 val, tmp, timeout = 0;
> +
> +	do {
> +		regmap_read(priv->map, priv->port * 4 + PPE_CURR_BUF_CNT, &val);
> +		regmap_read(priv->map, priv->port * 4 + PPE_CFG_RX_ADDR, &tmp);
> +		if (timeout++ > RESET_TIMEOUT)
> +			break;
> +	} while (val & 0xfff);
> +}
> +
> +static void hip04_config_fifo(struct hip04_priv *priv)
> +{
> +	u32 val;
> +
> +	val = readl_relaxed(priv->base + PPE_CFG_STS_MODE);
> +	val |= PPE_CFG_STS_RX_PKT_CNT_RC;
> +	writel_relaxed(val, priv->base + PPE_CFG_STS_MODE);
> +
> +	val = BIT(priv->port);
> +	regmap_write(priv->map, priv->port * 4 + PPE_CFG_POOL_GRP, val);
> +
> +	val = priv->port << PPE_CFG_QOS_VMID_GRP_SHIFT;
> +	val |= PPE_CFG_QOS_VMID_MODE;
> +	writel_relaxed(val, priv->base + PPE_CFG_QOS_VMID_GEN);
> +
> +	val = RX_BUF_SIZE;
> +	regmap_write(priv->map, priv->port * 4 + PPE_CFG_RX_BUF_SIZE, val);
> +
> +	val = RX_DESC_NUM << PPE_CFG_RX_DEPTH_SHIFT;
> +	val |= PPE_CFG_RX_FIFO_FSFU;
> +	val |= priv->chan << PPE_CFG_RX_START_SHIFT;
> +	regmap_write(priv->map, priv->port * 4 + PPE_CFG_RX_FIFO_SIZE, val);
> +
> +	val = NET_IP_ALIGN << PPE_CFG_RX_CTRL_ALIGN_SHIFT;
> +	writel_relaxed(val, priv->base + PPE_CFG_RX_CTRL_REG);
> +
> +	val = PPE_CFG_RX_PKT_ALIGN;
> +	writel_relaxed(val, priv->base + PPE_CFG_RX_PKT_MODE_REG);
> +
> +	val = PPE_CFG_BUS_LOCAL_REL | PPE_CFG_BUS_BIG_ENDIEN;
> +	writel_relaxed(val, priv->base + PPE_CFG_BUS_CTRL_REG);
> +
> +	val = GMAC_PPE_RX_PKT_MAX_LEN;
> +	writel_relaxed(val, priv->base + PPE_CFG_MAX_FRAME_LEN_REG);
> +
> +	val = GMAC_MAX_PKT_LEN;
> +	writel_relaxed(val, priv->base + GE_MAX_FRM_SIZE_REG);
> +
> +	val = GMAC_MIN_PKT_LEN;
> +	writel_relaxed(val, priv->base + GE_SHORT_RUNTS_THR_REG);
> +
> +	val = readl_relaxed(priv->base + GE_TRANSMIT_CONTROL_REG);
> +	val |= GE_TX_AUTO_NEG | GE_TX_ADD_CRC | GE_TX_SHORT_PAD_THROUGH;
> +	writel_relaxed(val, priv->base + GE_TRANSMIT_CONTROL_REG);
> +
> +	val = GE_RX_STRIP_CRC;
> +	writel_relaxed(val, priv->base + GE_CF_CRC_STRIP_REG);
> +
> +	val = readl_relaxed(priv->base + GE_RECV_CONTROL_REG);
> +	val |= GE_RX_STRIP_PAD | GE_RX_PAD_EN;
> +	writel_relaxed(val, priv->base + GE_RECV_CONTROL_REG);
> +
> +	val = GE_AUTO_NEG_CTL;
> +	writel_relaxed(val, priv->base + GE_TX_LOCAL_PAGE_REG);
> +}
> +
> +static void hip04_mac_enable(struct net_device *ndev)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	u32 val;
> +
> +	/* enable tx & rx */
> +	val = readl_relaxed(priv->base + GE_PORT_EN);
> +	val |= GE_RX_PORT_EN | GE_TX_PORT_EN;
> +	writel_relaxed(val, priv->base + GE_PORT_EN);
> +
> +	/* clear rx int */
> +	val = RCV_INT;
> +	writel_relaxed(val, priv->base + PPE_RINT);
> +
> +	/* config recv int */
> +	val = GE_RX_INT_THRESHOLD | GE_RX_TIMEOUT;
> +	writel_relaxed(val, priv->base + PPE_CFG_RX_PKT_INT);
> +
> +	/* enable interrupt */
> +	priv->reg_inten = DEF_INT_MASK;
> +	writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
> +}
> +
> +static void hip04_mac_disable(struct net_device *ndev)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	u32 val;
> +
> +	/* disable int */
> +	priv->reg_inten &= ~(DEF_INT_MASK);
> +	writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
> +
> +	/* disable tx & rx */
> +	val = readl_relaxed(priv->base + GE_PORT_EN);
> +	val &= ~(GE_RX_PORT_EN | GE_TX_PORT_EN);
> +	writel_relaxed(val, priv->base + GE_PORT_EN);
> +}
> +
> +static void hip04_set_xmit_desc(struct hip04_priv *priv, dma_addr_t phys)
> +{
> +	writel(phys, priv->base + PPE_CFG_CPU_ADD_ADDR);
> +}
> +
> +static void hip04_set_recv_desc(struct hip04_priv *priv, dma_addr_t phys)
> +{
> +	regmap_write(priv->map, priv->port * 4 + PPE_CFG_RX_ADDR, phys);
> +}
> +
> +static u32 hip04_recv_cnt(struct hip04_priv *priv)
> +{
> +	return readl(priv->base + PPE_HIS_RX_PKT_CNT);
> +}
> +
> +static void hip04_update_mac_address(struct net_device *ndev)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +
> +	writel_relaxed(((ndev->dev_addr[0] << 8) | (ndev->dev_addr[1])),
> +		       priv->base + GE_STATION_MAC_ADDRESS);
> +	writel_relaxed(((ndev->dev_addr[2] << 24) | (ndev->dev_addr[3] << 16) |
> +			(ndev->dev_addr[4] << 8) | (ndev->dev_addr[5])),
> +		       priv->base + GE_STATION_MAC_ADDRESS + 4);
> +}
> +
> +static int hip04_set_mac_address(struct net_device *ndev, void *addr)
> +{
> +	eth_mac_addr(ndev, addr);
> +	hip04_update_mac_address(ndev);
> +	return 0;
> +}
> +
> +static int hip04_tx_reclaim(struct net_device *ndev, bool force)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	unsigned tx_tail = priv->tx_tail;
> +	struct tx_desc *desc;
> +	unsigned int bytes_compl = 0, pkts_compl = 0;
> +	unsigned int count;
> +
> +	smp_rmb();
> +	count = tx_count(ACCESS_ONCE(priv->tx_head), tx_tail);
> +	if (count == 0)
> +		goto out;
> +
> +	while (count) {
> +		desc = &priv->tx_desc[tx_tail];
> +		if (desc->send_addr != 0) {
> +			if (force)
> +				desc->send_addr = 0;
> +			else
> +				break;
> +		}
> +
> +		if (priv->tx_phys[tx_tail]) {
> +			dma_unmap_single(&ndev->dev, priv->tx_phys[tx_tail],
> +					 priv->tx_skb[tx_tail]->len,
> +					 DMA_TO_DEVICE);
> +			priv->tx_phys[tx_tail] = 0;
> +		}
> +		pkts_compl++;
> +		bytes_compl += priv->tx_skb[tx_tail]->len;
> +		dev_kfree_skb(priv->tx_skb[tx_tail]);
> +		priv->tx_skb[tx_tail] = NULL;
> +		tx_tail = TX_NEXT(tx_tail);
> +		count--;
> +	}
> +
> +	priv->tx_tail = tx_tail;
> +	smp_wmb(); /* Ensure tx_tail visible to xmit */
> +
> +out:
> +	if (pkts_compl || bytes_compl)

Testing bytes_compl should be enough : There is no way pkt_compl could
be 0 if bytes_compl is not 0.

> +		netdev_completed_queue(ndev, pkts_compl, bytes_compl);
> +
> +	if (unlikely(netif_queue_stopped(ndev)) && (count < (TX_DESC_NUM - 1)))
> +		netif_wake_queue(ndev);
> +
> +	return count;
> +}
> +
> +static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &ndev->stats;
> +	unsigned int tx_head = priv->tx_head, count;
> +	struct tx_desc *desc = &priv->tx_desc[tx_head];
> +	dma_addr_t phys;
> +
> +	smp_rmb();
> +	count = tx_count(tx_head, ACCESS_ONCE(priv->tx_tail));
> +	if (count == (TX_DESC_NUM - 1)) {
> +		netif_stop_queue(ndev);
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
> +	if (dma_mapping_error(&ndev->dev, phys)) {
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;
> +	}
> +
> +	priv->tx_skb[tx_head] = skb;
> +	priv->tx_phys[tx_head] = phys;
> +	desc->send_addr = cpu_to_be32(phys);
> +	desc->send_size = cpu_to_be32(skb->len);
> +	desc->cfg = cpu_to_be32(TX_CLEAR_WB | TX_FINISH_CACHE_INV);
> +	phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
> +	desc->wb_addr = cpu_to_be32(phys);
> +	skb_tx_timestamp(skb);
> +
> +	hip04_set_xmit_desc(priv, phys);
> +	priv->tx_head = TX_NEXT(tx_head);
> +	count++;

Starting from this point, skb might already have been freed by TX
completion.

Its racy to access skb->len 

> +	netdev_sent_queue(ndev, skb->len);
> +
> +	stats->tx_bytes += skb->len;
> +	stats->tx_packets++;
> +
> +	/* Ensure tx_head update visible to tx reclaim */
> +	smp_wmb();
> +
> +	/* queue is getting full, better start cleaning up now */
> +	if (count >= priv->tx_coalesce_frames) {
> +		if (napi_schedule_prep(&priv->napi)) {
> +			/* disable rx interrupt and timer */
> +			priv->reg_inten &= ~(RCV_INT);
> +			writel_relaxed(DEF_INT_MASK & ~RCV_INT,
> +				       priv->base + PPE_INTEN);
> +			hrtimer_cancel(&priv->tx_coalesce_timer);
> +			__napi_schedule(&priv->napi);
> +		}
> +	} else if (!hrtimer_is_queued(&priv->tx_coalesce_timer)) {
> +		/* cleanup not pending yet, start a new timer */
> +		hrtimer_start_expires(&priv->tx_coalesce_timer,
> +				      HRTIMER_MODE_REL);
> +	}
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static int hip04_rx_poll(struct napi_struct *napi, int budget)
> +{
> +	struct hip04_priv *priv = container_of(napi, struct hip04_priv, napi);
> +	struct net_device *ndev = priv->ndev;
> +	struct net_device_stats *stats = &ndev->stats;
> +	unsigned int cnt = hip04_recv_cnt(priv);
> +	struct rx_desc *desc;
> +	struct sk_buff *skb;
> +	unsigned char *buf;
> +	bool last = false;
> +	dma_addr_t phys;
> +	int rx = 0;
> +	int tx_remaining;
> +	u16 len;
> +	u32 err;
> +
> +	while (cnt && !last) {
> +		buf = priv->rx_buf[priv->rx_head];
> +		skb = build_skb(buf, priv->rx_buf_size);
> +		if (unlikely(!skb))
> +			net_dbg_ratelimited("build_skb failed\n");

Well, is skb is NULL, you're crashing later...
You really have to address a memory allocation error much better than
that !

> +
> +		dma_unmap_single(&ndev->dev, priv->rx_phys[priv->rx_head],
> +				 RX_BUF_SIZE, DMA_FROM_DEVICE);
> +		priv->rx_phys[priv->rx_head] = 0;
> +
> +		desc = (struct rx_desc *)skb->data;
> +		len = be16_to_cpu(desc->pkt_len);
> +		err = be32_to_cpu(desc->pkt_err);
> +
> +		if (0 == len) {
> +			dev_kfree_skb_any(skb);
> +			last = true;
> +		} else if ((err & RX_PKT_ERR) || (len >= GMAC_MAX_PKT_LEN)) {
> +			dev_kfree_skb_any(skb);
> +			stats->rx_dropped++;
> +			stats->rx_errors++;
> +		} else {
> +			skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
> +			skb_put(skb, len);
> +			skb->protocol = eth_type_trans(skb, ndev);
> +			napi_gro_receive(&priv->napi, skb);
> +			stats->rx_packets++;
> +			stats->rx_bytes += len;
> +			rx++;
> +		}
> +
> +		buf = netdev_alloc_frag(priv->rx_buf_size);
> +		if (!buf)
> +			goto done;

Same problem here : In case of memory allocation error, your driver is
totally screwed.

> +		phys = dma_map_single(&ndev->dev, buf,
> +				      RX_BUF_SIZE, DMA_FROM_DEVICE);
> +		if (dma_mapping_error(&ndev->dev, phys))
> +			goto done;

Same problem here : You really have to recover properly.

> +		priv->rx_buf[priv->rx_head] = buf;
> +		priv->rx_phys[priv->rx_head] = phys;
> +		hip04_set_recv_desc(priv, phys);
> +
> +		priv->rx_head = RX_NEXT(priv->rx_head);
> +		if (rx >= budget)
> +			goto done;
> +
> +		if (--cnt == 0)
> +			cnt = hip04_recv_cnt(priv);
> +	}
> +
> +	if (!(priv->reg_inten & RCV_INT)) {
> +		/* enable rx interrupt */
> +		priv->reg_inten |= RCV_INT;
> +		writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
> +	}
> +	napi_complete(napi);
> +done:
> +	/* clean up tx descriptors and start a new timer if necessary */
> +	tx_remaining = hip04_tx_reclaim(ndev, false);
> +	if (rx < budget && tx_remaining)
> +		hrtimer_start_expires(&priv->tx_coalesce_timer, HRTIMER_MODE_REL);
> +
> +	return rx;
> +}
> +
