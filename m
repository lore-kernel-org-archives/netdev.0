From: Gilad Avidov <gavidov@codeaurora.org>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Tue, 15 Dec 2015 15:49:04 -0700
Message-ID: <20151215154904.559bd0cb@gavidov-lnx.qualcomm.com>
References: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org>
	<566F6F3D.5050004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	timur@codeaurora.org, gregkh@linuxfoundation.org,
	vikrams@codeaurora.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <566F6F3D.5050004@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Dec 2015 17:39:09 -0800
Florian Fainelli <f.fainelli@gmail.com> wrote:

> On 14/12/15 16:19, Gilad Avidov wrote:
> 
> [snip]
> 
> > +			"sgmii_irq";
> > +		qcom,emac-gpio-mdc = <&msmgpio 123 0>;
> > +		qcom,emac-gpio-mdio = <&msmgpio 124 0>;
> > +		qcom,emac-tstamp-en;
> > +		qcom,emac-ptp-frac-ns-adj = <125000000 1>;
> > +		phy-addr = <0>;
> 
> Please use the standard Ethernet PHY and MDIO device tree bindings to
> describe your MAC to PHY connection here, that includes using a
> phy-connection-type property to describe the (x)MII lanes.
> 


Hi Florian,

Thank you for the review.

Unfortunately this Ethernet controller's PHY is non standard and fits
poorly into the standard MDIO framework layer. Rather than read/writs
over MDIO only, this hw have some of the PHY registers internal and
accessed by memory mapped IO, while others are accessed over the MDIO.
Some standard functions requires using both. Additionally a number
of different functions are controlled from different fields of the
same register.

> [snip]
> 
> > +/* EMAC_MAC_CTRL */
> > +#define SINGLE_PAUSE_MODE
> > 0x10000000 +#define
> > DEBUG_MODE                                           0x8000000
> > +#define BROAD_EN
> > 0x4000000 +#define
> > MULTI_ALL                                            0x2000000
> > +#define RX_CHKSUM_EN
> > 0x1000000 +#define
> > HUGE                                                  0x800000
> > +#define SPEED_BMSK
> > 0x300000 +#define
> > SPEED_SHFT                                                  20
> > +#define SIMR
> > 0x80000 +#define
> > TPAUSE                                                 0x10000
> > +#define PROM_MODE
> > 0x8000 +#define
> > VLAN_STRIP                                              0x4000
> > +#define PRLEN_BMSK
> > 0x3c00 +#define
> > PRLEN_SHFT                                                  10
> > +#define HUGEN
> > 0x200 +#define
> > FLCHK                                                    0x100
> > +#define PCRCE
> > 0x80 +#define
> > CRCE                                                      0x40
> > +#define FULLD
> > 0x20 +#define
> > MAC_LP_EN                                                 0x10
> > +#define RXFC
> > 0x8 +#define
> > TXFC                                                       0x4
> > +#define RXEN
> > 0x2 +#define
> > TXEN                                                       0x1
> 
> BIT(x)? which would avoid making this reverse christmas tree, I know
> this is the time of year though.
> 

:)
Agree.

> [snip]
> 
> > +/* DMA address */
> > +#define DMA_ADDR_HI_MASK
> > 0xffffffff00000000ULL +#define
> > DMA_ADDR_LO_MASK                         0x00000000ffffffffULL +
> > +#define
> > EMAC_DMA_ADDR_HI(_addr)                                      \
> > +		((u32)(((u64)(_addr) & DMA_ADDR_HI_MASK) >> 32))
> > +#define
> > EMAC_DMA_ADDR_LO(_addr)                                      \
> > +		((u32)((u64)(_addr) & DMA_ADDR_LO_MASK))
> 
> The kernel provides helpers for that: upper_32bits and lower_32bits().
> 

lower_32_bits(n) and upper_32_bits(n), thanks. I'll use them here.

> [snip]
> 
> > +struct emac_skb_cb {
> > +	u32           tpd_idx;
> > +	unsigned long jiffies;
> > +};
> > +
> > +struct emac_tx_ts_cb {
> > +	u32 sec;
> > +	u32 ns;
> > +};
> > +
> > +#define EMAC_SKB_CB(skb)	((struct emac_skb_cb *)(skb)->cb)
> > +#define EMAC_TX_TS_CB(skb)	((struct emac_tx_ts_cb
> > *)(skb)->cb)
> 
> Should not these two have different offsets within skb->cb in case
> they both end-up being added to the same SKB?
> 

Good point. I'll look into this.


> [snip]
> 
> > +
> > +	/* enable RX/TX Flow Control */
> > +	switch (phy->cur_fc_mode) {
> > +	case EMAC_FC_FULL:
> > +		mac |= (TXFC | RXFC);
> > +		break;
> > +	case EMAC_FC_RX_PAUSE:
> > +		mac |= RXFC;
> > +		break;
> > +	case EMAC_FC_TX_PAUSE:
> > +		mac |= TXFC;
> > +		break;
> > +	default:
> > +		break;
> > +	}
> > +
> > +	/* setup link speed */
> > +	mac &= ~SPEED_BMSK;
> > +	switch (phy->link_speed) {
> > +	case EMAC_LINK_SPEED_1GB_FULL:
> > +		mac |= ((emac_mac_speed_1000 << SPEED_SHFT) &
> > SPEED_BMSK);
> > +		csr1 |= FREQ_MODE;
> > +		break;
> > +	default:
> > +		mac |= ((emac_mac_speed_10_100 << SPEED_SHFT) &
> > SPEED_BMSK);
> > +		csr1 &= ~FREQ_MODE;
> > +		break;
> > +	}
> > +
> > +	switch (phy->link_speed) {
> > +	case EMAC_LINK_SPEED_1GB_FULL:
> > +	case EMAC_LINK_SPEED_100_FULL:
> > +	case EMAC_LINK_SPEED_10_FULL:
> > +		mac |= FULLD;
> > +		break;
> > +	default:
> > +		mac &= ~FULLD;
> > +	}
> 
> You should use the PHY library and implement an adjust_link callback
> which does exactly that above.
> [snip]
> 
> > +static bool emac_tx_has_enough_descs(struct emac_tx_queue *tx_q,
> > +				     const struct sk_buff *skb)
> > +{
> > +	u32 num_required = 1;
> > +	int i;
> > +	u16 proto_hdr_len = 0;
> > +
> > +	if (skb_is_gso(skb)) {
> > +		proto_hdr_len = skb_transport_offset(skb) +
> > tcp_hdrlen(skb);
> 
> You cannot do this until you have looked at skb->protocol AFAIR.
> 

Got it.

> [snip]
> 
> > diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c
> > b/drivers/net/ethernet/qualcomm/emac/emac-phy.c new file mode 100644
> > index 0000000..45571a5
> > --- /dev/null
> > +++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
> 
> [snip]
> 
> This file implement a large amount of what the PHY library already
> does for you if you simply provided a MDIO bus implementation
> instead, please consider dropping 80% of this file content and using
> what is already there to help you.

MDIO bus will not work for this hw due to the reasons explained above.

> 
> I stopped reading there because the driver is very large, I would
> really start submitting it in smaller piece that make it more
> readable, and dropping things that may not be necessary for now like
> RSS support, Wake-on-LAN etc. etc.

I'll work on that.


Thank you again for the review,
Gilad
