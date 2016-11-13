From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit
 ethernet driver
Date: Sun, 13 Nov 2016 20:55:44 +0100
Message-ID: <20161113195544.GA18258@lunn.ch>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
 <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static const char slic_stats_strings[][ETH_GSTRING_LEN] = {
> +	"rx_packets     ",
> +	"rx_bytes       ",
> +	"rx_multicasts  ",
> +	"rx_errors      ",
> +	"rx_buff_miss   ",
> +	"rx_tp_csum     ",
> +	"rx_tp_oflow    ",
> +	"rx_tp_hlen     ",
> +	"rx_ip_csum     ",
> +	"rx_ip_len      ",

Are there any other drivers which pad the statistics strings?

> +static void slic_set_link_autoneg(struct slic_device *sdev)
> +{
> +	unsigned int subid = sdev->pdev->subsystem_device;
> +	u32 val;
> +
> +	if (sdev->is_fiber) {
> +		/* We've got a fiber gigabit interface, and register 4 is
> +		 * different in fiber mode than in copper mode.
> +		 */
> +		/* advertise FD only @1000 Mb */
> +		val = MII_ADVERTISE << 16 | SLIC_PAR_ADV1000XFD |
> +		      SLIC_PAR_ASYMPAUSE_FIBER;
> +		/* enable PAUSE frames */
> +		slic_write(sdev, SLIC_REG_WPHY, val);
> +		/* reset phy, enable auto-neg  */
> +		val = MII_BMCR << 16 | SLIC_PCR_RESET | SLIC_PCR_AUTONEG |
> +		      SLIC_PCR_AUTONEG_RST;
> +		slic_write(sdev, SLIC_REG_WPHY, val);
> +	} else {	/* copper gigabit */
> +		/* We've got a copper gigabit interface, and register 4 is
> +		 * different in copper mode than in fiber mode.
> +		 */
> +		/* advertise 10/100 Mb modes   */
> +		val = MII_ADVERTISE << 16 | SLIC_PAR_ADV100FD |
> +		      SLIC_PAR_ADV100HD | SLIC_PAR_ADV10FD | SLIC_PAR_ADV10HD;
> +		/* enable PAUSE frames  */
> +		val |= SLIC_PAR_ASYMPAUSE;
> +		/* required by the Cicada PHY  */
> +		val |= SLIC_PAR_802_3;
> +		slic_write(sdev, SLIC_REG_WPHY, val);
> +
> +		/* advertise FD only @1000 Mb  */
> +		val = MII_CTRL1000 << 16 | SLIC_PGC_ADV1000FD;
> +		slic_write(sdev, SLIC_REG_WPHY, val);
> +
> +		if (subid != PCI_SUBDEVICE_ID_ALACRITECH_CICADA) {
> +			 /* if a Marvell PHY enable auto crossover */
> +			val = SLIC_MIICR_REG_16 | SLIC_MRV_REG16_XOVERON;
> +			slic_write(sdev, SLIC_REG_WPHY, val);
> +
> +			/* reset phy, enable auto-neg  */
> +			val = MII_BMCR << 16 | SLIC_PCR_RESET |
> +			      SLIC_PCR_AUTONEG | SLIC_PCR_AUTONEG_RST;
> +			slic_write(sdev, SLIC_REG_WPHY, val);
> +		} else {
> +			/* enable and restart auto-neg (don't reset)  */
> +			val = MII_BMCR << 16 | SLIC_PCR_AUTONEG |
> +			      SLIC_PCR_AUTONEG_RST;
> +			slic_write(sdev, SLIC_REG_WPHY, val);
> +		}
> +	}
> +	sdev->autoneg = true;
> +}

Could this be pulled out into a standard PHY driver? All the SLIC
SLIC_PCR_ defines seems to be the same as those in mii.h. This could
be a standard PHY hidden behind a single register.

   Andrew
