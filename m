From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 8 Sep 2017 17:54:24 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:41294 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932336AbdIHRyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 13:54:37 -0400
In-Reply-To: <20170908091856.GB17738@amd>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Pavel Machek [mailto:pavel@ucw.cz]
> Sent: Friday, September 08, 2017 2:19 AM
> To: Tristram Ha - C24268
> Cc: andrew@lunn.ch; muvarov@gmail.com; nathan.leigh.conrad@gmail.com;
> vivien.didelot@savoirfairelinux.com; f.fainelli@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Woojung Huh - C21699
> Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
> 
> On Thu 2017-09-07 21:17:16, Tristram.Ha@microchip.com wrote:
> > From: Tristram Ha <Tristram.Ha@microchip.com>
> >
> > Add KSZ8795 switch support with function code.
> 
> English? "Add KSZ8795 switch support." ?
> 
> > Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> > ---
> > diff --git a/drivers/net/dsa/microchip/ksz8795.c
> b/drivers/net/dsa/microchip/ksz8795.c
> > new file mode 100644
> > index 0000000..e4d4e6a
> > --- /dev/null
> > +++ b/drivers/net/dsa/microchip/ksz8795.c
> > @@ -0,0 +1,2066 @@
> > +/*
> > + * Microchip KSZ8795 switch driver
> > + *
> > + * Copyright (C) 2017 Microchip Technology Inc.
> > + *	Tristram Ha <Tristram.Ha@microchip.com>
> > + *
> > + * Permission to use, copy, modify, and/or distribute this software for any
> > + * purpose with or without fee is hereby granted, provided that the above
> > + * copyright notice and this permission notice appear in all copies.
> > + *
> > + * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
> WARRANTIES
> > + * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
> OF
> > + * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE
> LIABLE FOR
> > + * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
> DAMAGES
> > + * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
> IN AN
> > + * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
> ARISING OUT OF
> > + * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
> > + */
> 
> This is not exactly GPL, right? But tagging below says it is
> GPL. Please fix one.
> 

This boilerplate paragraph was copied from the KSZ9477 driver, although I did
wonder why this was used.

> > +static int ksz_reset_switch(struct ksz_device *dev)
> > +{
> > +	/* reset switch */
> > +	ksz_write8(dev, REG_POWER_MANAGEMENT_1,
> > +		   SW_SOFTWARE_POWER_DOWN <<
> SW_POWER_MANAGEMENT_MODE_S);
> > +	ksz_write8(dev, REG_POWER_MANAGEMENT_1, 0);
> > +
> > +	return 0;
> > +}
> 
> This is going to be same in other drivers, right?
> 

The switch reset is different in each chip, although KSZ8795 and
KSZ8895 use the same mechanism.

> > +
> > +	for (timeout = 1; timeout > 0; timeout--) {
> > +		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
> > +
> > +		if (check & MIB_COUNTER_VALID) {
> > +			ksz_read32(dev, REG_IND_DATA_LO, &data);
> > +			if (addr < 2) {
> > +				u64 total;
> > +
> > +				total = check & MIB_TOTAL_BYTES_H;
> > +				total <<= 32;
> > +				*cnt += total;
> > +				*cnt += data;
> > +				if (check & MIB_COUNTER_OVERFLOW) {
> > +					total = MIB_TOTAL_BYTES_H + 1;
> > +					total <<= 32;
> > +					*cnt += total;
> > +				}
> > +			} else {
> > +				if (check & MIB_COUNTER_OVERFLOW)
> > +					*cnt += MIB_PACKET_DROPPED + 1;
> > +				*cnt += data & MIB_PACKET_DROPPED;
> > +			}
> > +			break;
> > +		}
> > +	}
> 
> Why do you need a loop here? This is quite strange code. (And you have
> similar strangeness elsewhere. Please fix.)
> 

The MIB_COUNTER_VALID bit may be invalid on first read, although in slow
SPI speed it never happens.  The timeout value should be increased to 2.

> > +static int valid_dyn_entry(struct ksz_device *dev, u8 *data)
> > +{
> > +	int timeout = 100;
> > +
> > +	do {
> > +		ksz_read8(dev, REG_IND_DATA_CHECK, data);
> > +		timeout--;
> > +	} while ((*data & DYNAMIC_MAC_TABLE_NOT_READY) && timeout);
> > +
> > +	/* Entry is not ready for accessing. */
> > +	if (*data & DYNAMIC_MAC_TABLE_NOT_READY) {
> > +		return 1;
> > +	/* Entry is ready for accessing. */
> > +	} else {
> > +		ksz_read8(dev, REG_IND_DATA_8, data);
> > +
> > +		/* There is no valid entry in the table. */
> > +		if (*data & DYNAMIC_MAC_TABLE_MAC_EMPTY)
> > +			return 2;
> > +	}
> > +	return 0;
> > +}
> 
> Normal calling convention is 0 / -ERROR, not 0,1,2.
>

This is an internal function that is not returning any error.  It just reports
different conditions so the calling function decides what to do.
 
> > +static void ksz_r_phy(struct ksz_device *dev, u16 phy, u16 reg, u16 *val)
> > +{
> > +	struct ksz_port *port;
> > +	u8 ctrl;
> > +	u8 restart;
> > +	u8 link;
> > +	u8 speed;
> > +	u8 force;
> > +	u8 p = phy;
> > +	u16 data = 0;
> > +	int processed = true;
> > +
> > +	port = &dev->ports[p];
> > +	switch (reg) {
> > +	case PHY_REG_CTRL:
> > +		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
> > +		ksz_pread8(dev, p, P_NEG_RESTART_CTRL, &restart);
> > +		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
> > +		ksz_pread8(dev, p, P_FORCE_CTRL, &force);
> > +		if (restart & PORT_PHY_LOOPBACK)
> > +			data |= PHY_LOOPBACK;
> > +		if (force & PORT_FORCE_100_MBIT)
> > +			data |= PHY_SPEED_100MBIT;
> > +		if (!(force & PORT_AUTO_NEG_DISABLE))
> > +			data |= PHY_AUTO_NEG_ENABLE;
> > +		if (restart & PORT_POWER_DOWN)
> > +			data |= PHY_POWER_DOWN;
> > +		if (restart & PORT_AUTO_NEG_RESTART)
> > +			data |= PHY_AUTO_NEG_RESTART;
> > +		if (force & PORT_FORCE_FULL_DUPLEX)
> > +			data |= PHY_FULL_DUPLEX;
> > +		if (speed & PORT_HP_MDIX)
> > +			data |= PHY_HP_MDIX;
> > +		if (restart & PORT_FORCE_MDIX)
> > +			data |= PHY_FORCE_MDIX;
> > +		if (restart & PORT_AUTO_MDIX_DISABLE)
> > +			data |= PHY_AUTO_MDIX_DISABLE;
> > +		if (restart & PORT_TX_DISABLE)
> > +			data |= PHY_TRANSMIT_DISABLE;
> > +		if (restart & PORT_LED_OFF)
> > +			data |= PHY_LED_DISABLE;
> > +		break;
> > +	case PHY_REG_STATUS:
> > +		ksz_pread8(dev, p, P_LINK_STATUS, &link);
> > +		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
> > +		data = PHY_100BTX_FD_CAPABLE |
> > +			PHY_100BTX_CAPABLE |
> > +			PHY_10BT_FD_CAPABLE |
> > +			PHY_10BT_CAPABLE |
> > +			PHY_AUTO_NEG_CAPABLE;
> > +		if (link & PORT_AUTO_NEG_COMPLETE)
> > +			data |= PHY_AUTO_NEG_ACKNOWLEDGE;
> > +		if (link & PORT_STAT_LINK_GOOD) {
> > +			data |= PHY_LINK_STATUS;
> > +			if (!port->link_up) {
> > +				port->link_up = 1;
> > +				dev->live_ports |= (1 << phy) & dev->on_ports;
> > +			}
> > +		} else if (port->link_up) {
> > +			port->link_down = 1;
> > +			port->link_up = 0;
> > +			dev->live_ports &= ~(1 << phy);
> > +		}
> > +		break;
> > +	case PHY_REG_ID_1:
> > +		data = KSZ8795_ID_HI;
> > +		break;
> > +	case PHY_REG_ID_2:
> > +		data = KSZ8795_ID_LO;
> > +		break;
> > +	case PHY_REG_AUTO_NEGOTIATION:
> > +		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
> > +		data = PHY_AUTO_NEG_802_3;
> > +		if (ctrl & PORT_AUTO_NEG_SYM_PAUSE)
> > +			data |= PHY_AUTO_NEG_SYM_PAUSE;
> > +		if (ctrl & PORT_AUTO_NEG_100BTX_FD)
> > +			data |= PHY_AUTO_NEG_100BTX_FD;
> > +		if (ctrl & PORT_AUTO_NEG_100BTX)
> > +			data |= PHY_AUTO_NEG_100BTX;
> > +		if (ctrl & PORT_AUTO_NEG_10BT_FD)
> > +			data |= PHY_AUTO_NEG_10BT_FD;
> > +		if (ctrl & PORT_AUTO_NEG_10BT)
> > +			data |= PHY_AUTO_NEG_10BT;
> > +		break;
> > +	case PHY_REG_REMOTE_CAPABILITY:
> > +		ksz_pread8(dev, p, P_REMOTE_STATUS, &link);
> > +		data = PHY_AUTO_NEG_802_3;
> > +		if (link & PORT_REMOTE_SYM_PAUSE)
> > +			data |= PHY_AUTO_NEG_SYM_PAUSE;
> > +		if (link & PORT_REMOTE_100BTX_FD)
> > +			data |= PHY_AUTO_NEG_100BTX_FD;
> > +		if (link & PORT_REMOTE_100BTX)
> > +			data |= PHY_AUTO_NEG_100BTX;
> > +		if (link & PORT_REMOTE_10BT_FD)
> > +			data |= PHY_AUTO_NEG_10BT_FD;
> > +		if (link & PORT_REMOTE_10BT)
> > +			data |= PHY_AUTO_NEG_10BT;
> > +		break;
> > +	default:
> > +		processed = false;
> > +		break;
> > +	}
> > +	if (processed)
> > +		*val = data;
> > +}
> 
> Similar code will be needed by other drivers, right?
> 

Although KSZ8795 and KSZ8895 may use the same code, the other
chips will have different code.
