From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Sun, 27 Aug 2017 18:31:22 +0200
Message-ID: <20170827163122.GG13622@lunn.ch>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Pavel Machek <pavel@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170827123658.GA727@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/**
> + * sw_r_phy - read data from PHY register
> + * @sw:		The switch instance.
> + * @phy:	PHY address to read.
> + * @reg:	PHY register to read.
> + * @val:	Buffer to store the read data.
> + *
> + * This routine reads data from the PHY register.
> + */
> +static void sw_r_phy(struct ksz_device *sw, u16 phy, u16 reg, u16 *val)
> +{
> +	u8 ctrl;
> +	u8 restart;
> +	u8 link;
> +	u8 speed;
> +	u8 force;
> +	u8 p = phy;
> +	u16 data = 0;
> +
> +	switch (reg) {
> +	case PHY_REG_CTRL:
> +		ksz_pread8(sw, p, P_LOCAL_CTRL, &ctrl);
> +		ksz_pread8(sw, p, P_NEG_RESTART_CTRL, &restart);
> +		ksz_pread8(sw, p, P_SPEED_STATUS, &speed);
> +		ksz_pread8(sw, p, P_FORCE_CTRL, &force);
> +		if (restart & PORT_PHY_LOOPBACK)
> +			data |= PHY_LOOPBACK;
> +		if (force & PORT_FORCE_100_MBIT)
> +			data |= PHY_SPEED_100MBIT;
> +		if (!(force & PORT_AUTO_NEG_DISABLE))
> +			data |= PHY_AUTO_NEG_ENABLE;
> +		if (restart & PORT_POWER_DOWN)
> +			data |= PHY_POWER_DOWN;
> +		if (restart & PORT_AUTO_NEG_RESTART)
> +			data |= PHY_AUTO_NEG_RESTART;
> +		if (force & PORT_FORCE_FULL_DUPLEX)
> +			data |= PHY_FULL_DUPLEX;
> +		if (speed & PORT_HP_MDIX)
> +			data |= PHY_HP_MDIX;
> +		if (restart & PORT_FORCE_MDIX)
> +			data |= PHY_FORCE_MDIX;
> +		if (restart & PORT_AUTO_MDIX_DISABLE)
> +			data |= PHY_AUTO_MDIX_DISABLE;
> +		if (restart & PORT_TX_DISABLE)
> +			data |= PHY_TRANSMIT_DISABLE;
> +		if (restart & PORT_LED_OFF)
> +			data |= PHY_LED_DISABLE;
> +		break;
> +	case PHY_REG_STATUS:
> +		ksz_pread8(sw, p, P_LINK_STATUS, &link);
> +		ksz_pread8(sw, p, P_SPEED_STATUS, &speed);
> +		data = PHY_100BTX_FD_CAPABLE |
> +			PHY_100BTX_CAPABLE |
> +			PHY_10BT_FD_CAPABLE |
> +			PHY_10BT_CAPABLE |
> +			PHY_AUTO_NEG_CAPABLE;
> +		if (link & PORT_AUTO_NEG_COMPLETE)
> +			data |= PHY_AUTO_NEG_ACKNOWLEDGE;
> +		if (link & PORT_STAT_LINK_GOOD)
> +			data |= PHY_LINK_STATUS;
> +		break;
> +	case PHY_REG_ID_1:
> +		data = KSZ8895_ID_HI;
> +		break;
> +	case PHY_REG_ID_2:
> +		data = KSZ8895_ID_LO;
> +		break;

According to the datasheet, the PHY has the normal ID registers,
which have the value 0x0022, 0x1450. So it should be possible to have
a standard PHY driver in drivers/net/phy.

In fact, the IDs suggest it is a micrel phy, and 1430, 1435 are
already supported. So it could be you only need minor modifications to
the micrel.c.

    Andrew
