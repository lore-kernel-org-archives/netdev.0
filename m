From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Mon, 14 Dec 2015 17:39:09 -0800
Message-ID: <566F6F3D.5050004@gmail.com>
References: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: sdharia@codeaurora.org, shankerd@codeaurora.org,
	timur@codeaurora.org, gregkh@linuxfoundation.org,
	vikrams@codeaurora.org
To: Gilad Avidov <gavidov@codeaurora.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33098 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932852AbbLOBjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 20:39:23 -0500
In-Reply-To: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/12/15 16:19, Gilad Avidov wrote:

[snip]

> +			"sgmii_irq";
> +		qcom,emac-gpio-mdc = <&msmgpio 123 0>;
> +		qcom,emac-gpio-mdio = <&msmgpio 124 0>;
> +		qcom,emac-tstamp-en;
> +		qcom,emac-ptp-frac-ns-adj = <125000000 1>;
> +		phy-addr = <0>;

Please use the standard Ethernet PHY and MDIO device tree bindings to
describe your MAC to PHY connection here, that includes using a
phy-connection-type property to describe the (x)MII lanes.

[snip]

> +/* EMAC_MAC_CTRL */
> +#define SINGLE_PAUSE_MODE                                   0x10000000
> +#define DEBUG_MODE                                           0x8000000
> +#define BROAD_EN                                             0x4000000
> +#define MULTI_ALL                                            0x2000000
> +#define RX_CHKSUM_EN                                         0x1000000
> +#define HUGE                                                  0x800000
> +#define SPEED_BMSK                                            0x300000
> +#define SPEED_SHFT                                                  20
> +#define SIMR                                                   0x80000
> +#define TPAUSE                                                 0x10000
> +#define PROM_MODE                                               0x8000
> +#define VLAN_STRIP                                              0x4000
> +#define PRLEN_BMSK                                              0x3c00
> +#define PRLEN_SHFT                                                  10
> +#define HUGEN                                                    0x200
> +#define FLCHK                                                    0x100
> +#define PCRCE                                                     0x80
> +#define CRCE                                                      0x40
> +#define FULLD                                                     0x20
> +#define MAC_LP_EN                                                 0x10
> +#define RXFC                                                       0x8
> +#define TXFC                                                       0x4
> +#define RXEN                                                       0x2
> +#define TXEN                                                       0x1

BIT(x)? which would avoid making this reverse christmas tree, I know
this is the time of year though.

[snip]

> +/* DMA address */
> +#define DMA_ADDR_HI_MASK                         0xffffffff00000000ULL
> +#define DMA_ADDR_LO_MASK                         0x00000000ffffffffULL
> +
> +#define EMAC_DMA_ADDR_HI(_addr)                                      \
> +		((u32)(((u64)(_addr) & DMA_ADDR_HI_MASK) >> 32))
> +#define EMAC_DMA_ADDR_LO(_addr)                                      \
> +		((u32)((u64)(_addr) & DMA_ADDR_LO_MASK))

The kernel provides helpers for that: upper_32bits and lower_32bits().

[snip]

> +struct emac_skb_cb {
> +	u32           tpd_idx;
> +	unsigned long jiffies;
> +};
> +
> +struct emac_tx_ts_cb {
> +	u32 sec;
> +	u32 ns;
> +};
> +
> +#define EMAC_SKB_CB(skb)	((struct emac_skb_cb *)(skb)->cb)
> +#define EMAC_TX_TS_CB(skb)	((struct emac_tx_ts_cb *)(skb)->cb)

Should not these two have different offsets within skb->cb in case they
both end-up being added to the same SKB?

[snip]

> +static void emac_mac_irq_enable(struct emac_adapter *adpt)
> +{
> +	int i;
> +
> +	for (i = 0; i < EMAC_NUM_CORE_IRQ; i++) {
> +		struct emac_irq			*irq = &adpt->irq[i];
> +		const struct emac_irq_config	*irq_cfg = &emac_irq_cfg_tbl[i];
> +
> +		writel_relaxed(~DIS_INT, adpt->base + irq_cfg->status_reg);
> +		writel_relaxed(irq->mask, adpt->base + irq_cfg->mask_reg);
> +	}
> +
> +	wmb(); /* ensure that irq and ptp setting are flushed to HW */

Would not using writel() make the appropriate thing here instead of
using _relaxed which has no barrier?

[snip]

> +	mta = readl_relaxed(adpt->base + EMAC_HASH_TAB_REG0 + (reg << 2));
> +	mta |= (0x1 << bit);
> +	writel_relaxed(mta, adpt->base + EMAC_HASH_TAB_REG0 + (reg << 2));
> +	wmb(); /* ensure that the mac address is flushed to HW */

This is getting too much here, just use the correct I/O accessor for
your platform, period.

[snip]

> +
> +	/* enable RX/TX Flow Control */
> +	switch (phy->cur_fc_mode) {
> +	case EMAC_FC_FULL:
> +		mac |= (TXFC | RXFC);
> +		break;
> +	case EMAC_FC_RX_PAUSE:
> +		mac |= RXFC;
> +		break;
> +	case EMAC_FC_TX_PAUSE:
> +		mac |= TXFC;
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	/* setup link speed */
> +	mac &= ~SPEED_BMSK;
> +	switch (phy->link_speed) {
> +	case EMAC_LINK_SPEED_1GB_FULL:
> +		mac |= ((emac_mac_speed_1000 << SPEED_SHFT) & SPEED_BMSK);
> +		csr1 |= FREQ_MODE;
> +		break;
> +	default:
> +		mac |= ((emac_mac_speed_10_100 << SPEED_SHFT) & SPEED_BMSK);
> +		csr1 &= ~FREQ_MODE;
> +		break;
> +	}
> +
> +	switch (phy->link_speed) {
> +	case EMAC_LINK_SPEED_1GB_FULL:
> +	case EMAC_LINK_SPEED_100_FULL:
> +	case EMAC_LINK_SPEED_10_FULL:
> +		mac |= FULLD;
> +		break;
> +	default:
> +		mac &= ~FULLD;
> +	}

You should use the PHY library and implement an adjust_link callback
which does exactly that above.
[snip]

> +static bool emac_tx_has_enough_descs(struct emac_tx_queue *tx_q,
> +				     const struct sk_buff *skb)
> +{
> +	u32 num_required = 1;
> +	int i;
> +	u16 proto_hdr_len = 0;
> +
> +	if (skb_is_gso(skb)) {
> +		proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);

You cannot do this until you have looked at skb->protocol AFAIR.

[snip]

> diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
> new file mode 100644
> index 0000000..45571a5
> --- /dev/null
> +++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c

[snip]

This file implement a large amount of what the PHY library already does
for you if you simply provided a MDIO bus implementation instead, please
consider dropping 80% of this file content and using what is already
there to help you.

I stopped reading there because the driver is very large, I would really
start submitting it in smaller piece that make it more readable, and
dropping things that may not be necessary for now like RSS support,
Wake-on-LAN etc. etc.
-- 
Florian
