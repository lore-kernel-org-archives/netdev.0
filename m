From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: stmmac: RX queue routing configuration
Date: Thu, 16 Mar 2017 10:12:57 -0700
Message-ID: <d63aca9d-4110-9c7b-5981-87ef01ccd5e9@gmail.com>
References: <cover.1489661229.git.jpinto@synopsys.com>
 <625ef961b7fd7bda4f92180afce299fc9c887e77.1489661229.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34953 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752031AbdCPSIG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 14:08:06 -0400
Received: by mail-wm0-f68.google.com with SMTP id z133so4213260wmb.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 11:08:05 -0700 (PDT)
In-Reply-To: <625ef961b7fd7bda4f92180afce299fc9c887e77.1489661229.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2017 03:56 AM, Joao Pinto wrote:
> This patch adds the configuration of RX queues' routing.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt   | 19 ++++++-
>  drivers/net/ethernet/stmicro/stmmac/common.h       |  9 ++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h       | 18 +++++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 63 ++++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 25 +++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  8 +++
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 49 +++++++++++++++++
>  include/linux/stmmac.h                             | 12 +++++
>  8 files changed, 202 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index b9a9ae9..9c9e774 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -84,6 +84,16 @@ Optional properties:
>  			- snps,avb-algorithm: Queue to be enabled as AVB
>  		- snps,map-to-dma-channel: Channel to map
>  	- snps,priority: RX queue priority
> +	- Specifiy RX Queue for processing certain types of packets:
> +		- snps,avcp-to-queue: AV Untagged Control packets
> +		- snps,ptp-to-queue: PTP Packets
> +		- snps,dcbcp-to-queue: DCB Control Packets
> +		- snps,up-to-queue: Untagged Packets
> +		- snps,multi-broad-cast-queue: Multicast & Broadcast Packets
> +		- snps,tpqc-queue: Tagged PTPoE Packets Queuing Control. Values:
> +			0x0 - Priority based (RX queues non-AV)
> +			0x1 - Routes to queue indicated in "snps,ptp-to-queue"
> +			0x2 - Priority based (RX queues AV enabled)
>  - Multiple TX Queues parameters: below the list of all the parameters to
>  				 configure the multiple TX queues:
>  	- snps,tx-queues-to-use: number of TX queues to be used in the driver

You are allowing a policy to be defined with Device Tree here which is
usually frowned upon. Can you look into existing facilities offered by
tc offloads, e.g: mqprio etc. to allow users to dynamically configure
the queue mappings at runtime?

> @@ -112,8 +122,15 @@ Examples:
>  	};
>  
>  	mtl_rx_setup: rx-queues-config {
> -		snps,rx-queues-to-use = <1>;
> +		snps,rx-queues-to-use = <0>;
>  		snps,rx-sched-sp;
> +		snps,avcp-to-queue = <0>;
> +		snps,ptp-to-queue = <0>;
> +		snps,dcbcp-to-queue = <0>;
> +		snps,up-to-queue = <0>;
> +		snps,multi-broad-cast-queue = <0>;
> +		snps,tpqc-queue = <0>;
> +
>  		queue0 {
>  			snps,dcb-algorithm;
>  			snps,map-to-dma-channel = <0x0>;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index e0b31e7..e08c4c4 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -473,6 +473,15 @@ struct stmmac_ops {
>  	void (*rx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
>  	/* TX Queues Priority */
>  	void (*tx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
> +	/* RX Queues Routing */
> +	void (*rx_queue_routing)(struct mac_device_info *hw,
> +				 bool route_avcp_enable, u8 route_avcp_queue,
> +				 bool route_ptp_enable, u8 route_ptp_queue,
> +				 bool route_dcbcp_enable, u8 route_dcbcp_queue,
> +				 bool route_up_enable, u8 route_up_queue,
> +				 bool route_multi_broad_enable,
> +				 u8 route_multi_broad_queue,
> +				 bool route_tpqc_enable, u8 route_tpqc_queue);
>  	/* Program RX Algorithms */
>  	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
>  	/* Program TX Algorithms */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> index a6c382d..93cc3f6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> @@ -44,6 +44,24 @@
>  #define GMAC_ADDR_HIGH(reg)		(0x300 + reg * 8)
>  #define GMAC_ADDR_LOW(reg)		(0x304 + reg * 8)
>  
> +/* RX Queues Routing */
> +#define GMAC_RXQCTRL_AVCPQ_MASK		GENMASK(2, 0)
> +#define GMAC_RXQCTRL_AVCPQ_SHIFT	0
> +#define GMAC_RXQCTRL_PTPQ_MASK		GENMASK(6, 4)
> +#define GMAC_RXQCTRL_PTPQ_SHIFT		4
> +#define GMAC_RXQCTRL_DCBCPQ_MASK	GENMASK(10, 8)
> +#define GMAC_RXQCTRL_DCBCPQ_SHIFT	8
> +#define GMAC_RXQCTRL_UPQ_MASK		GENMASK(14, 12)
> +#define GMAC_RXQCTRL_UPQ_SHIFT		12
> +#define GMAC_RXQCTRL_MCBCQ_MASK		GENMASK(18, 16)
> +#define GMAC_RXQCTRL_MCBCQ_SHIFT	16
> +#define GMAC_RXQCTRL_MCBCQEN		BIT(20)
> +#define GMAC_RXQCTRL_MCBCQEN_SHIFT	20
> +#define GMAC_RXQCTRL_TACPQE		BIT(21)
> +#define GMAC_RXQCTRL_TACPQE_SHIFT	21
> +#define GMAC_RXQCTRL_TPQC_MASK		GENMASK(24, 22)
> +#define GMAC_RXQCTRL_TPQC_SHIFT		22
> +
>  /* MAC Packet Filtering */
>  #define GMAC_PACKET_FILTER_PR		BIT(0)
>  #define GMAC_PACKET_FILTER_HMC		BIT(2)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> index 342f62a..8fc1f56 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> @@ -109,6 +109,68 @@ static void dwmac4_tx_queue_priority(struct mac_device_info *hw,
>  	writel(value, ioaddr + base_register);
>  }
>  
> +static void dwmac4_tx_queue_routing(struct mac_device_info *hw,
> +				    bool route_avcp_enable,
> +				    u8 route_avcp_queue,
> +				    bool route_ptp_enable,
> +				    u8 route_ptp_queue,
> +				    bool route_dcbcp_enable,
> +				    u8 route_dcbcp_queue,
> +				    bool route_up_enable,
> +				    u8 route_up_queue,
> +				    bool route_multi_broad_enable,
> +				    u8 route_multi_broad_queue,
> +				    bool route_tpqc_enable,
> +				    u8 route_tpqc_queue)
> +{

This is not looking good at all 13 parameters passed here... thankfully
this is not called in a hot path.

So here is what I would suggest:

- put the bool, u8, and masks, shifts, offsets parameters in a
structure, define an array of structures holding these variables in your
driver's private context, index them with an enumeration for each queue

- pass a reference to this structure here, and iterate over the array of
structures and do the programming based on what this structure contains
for MASK, SHIFT, base register etc...

> +	void __iomem *ioaddr = hw->pcsr;
> +	u32 value;
> +
> +	value = readl(ioaddr + GMAC_RXQ_CTRL1);
> +

>  static int quark_default_data(struct plat_stmmacenet_data *plat,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 77b0468..5e82379 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -165,6 +165,55 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
>  	else
>  		plat->rx_sched_algorithm = MTL_RX_ALGORITHM_SP;
>  
> +	/* RX routing configuration */
> +	if (of_property_read_u8(rx_node, "snps,avcp-to-queue",
> +				&plat->route_avcp_queue)) {
> +		plat->route_avcp_queue = 0;
> +		plat->route_avcp_enable = false;
> +	} else {
> +		plat->route_avcp_enable = true;
> +	}

This is very redundant too, see the suggestion above, define an array of
property names and look them up in a loop using the queue enumeration.

> +
> +	if (of_property_read_u8(rx_node, "snps,ptp-to-queue",
> +				&plat->route_ptp_queue)) {
> +		plat->route_ptp_queue = 0;
> +		plat->route_ptp_enable = false;
> +	} else {
> +		plat->route_ptp_enable = true;
> +	}
> +
> +	if (of_property_read_u8(rx_node, "snps,dcbcp-to-queue",
> +				&plat->route_dcbcp_queue)) {
> +		plat->route_dcbcp_queue = 0;
> +		plat->route_dcbcp_enable = false;
> +	} else {
> +		plat->route_dcbcp_enable = true;
> +	}
> +
> +	if (of_property_read_u8(rx_node, "snps,up-to-queue",
> +				&plat->route_up_queue)) {
> +		plat->route_up_queue = 0;
> +		plat->route_up_enable = false;
> +	} else {
> +		plat->route_up_enable = true;
> +	}
> +
> +	if (of_property_read_u8(rx_node, "snps,multi-broad-cast-queue",
> +				&plat->route_multi_broad_queue)) {
> +		plat->route_multi_broad_queue = 0;
> +		plat->route_multi_broad_enable = false;
> +	} else {
> +		plat->route_multi_broad_enable = true;
> +	}
> +
> +	if (of_property_read_u8(rx_node, "snps,tpqc-queue",
> +				&plat->route_tpqc_queue)) {
> +		plat->route_tpqc_queue = 0;
> +		plat->route_tpqc_enable = false;
> +	} else {
> +		plat->route_tpqc_enable = true;
> +	}
> +
>  	/* Processing individual RX queue config */
>  	for_each_child_of_node(rx_node, q_node) {
>  		if (queue >= plat->rx_queues_to_use)
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index b7d5e7a..8f5ebf5 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -171,6 +171,18 @@ struct plat_stmmacenet_data {
>  	u8 tx_queues_to_use;
>  	u8 rx_sched_algorithm;
>  	u8 tx_sched_algorithm;
> +	bool route_avcp_enable;
> +	u8 route_avcp_queue;
> +	bool route_ptp_enable;
> +	u8 route_ptp_queue;
> +	bool route_dcbcp_enable;
> +	u8 route_dcbcp_queue;
> +	bool route_up_enable;
> +	u8 route_up_queue;
> +	bool route_multi_broad_enable;
> +	u8 route_multi_broad_queue;
> +	bool route_tpqc_enable;
> +	u8 route_tpqc_queue;

Same here, this absolutely does not scale.

>  	struct stmmac_rxq_cfg rx_queues_cfg[MTL_MAX_RX_QUEUES];
>  	struct stmmac_txq_cfg tx_queues_cfg[MTL_MAX_TX_QUEUES];
>  	void (*fix_mac_speed)(void *priv, unsigned int speed);
> 


-- 
Florian
