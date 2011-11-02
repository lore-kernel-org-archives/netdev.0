From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 2 Nov 2011 20:42:29 +0000
Message-ID: <1320266549.2782.21.camel@bwh-desktop>
References: <4EA89972.5060101@teksavvy.com>
	 <20111026.194045.2019668159403582571.davem@davemloft.net>
	 <4EA8B283.3010105@teksavvy.com>
	 <20111026.221719.2216112919297458522.davem@davemloft.net>
	 <4EB19BBE.5050602@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Mark Lord <kernel@teksavvy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EB19BBE.5050602@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-02 at 15:36 -0400, Mark Lord wrote:
[...]
> First cut (for review) at updating the in-kernel asix usb/network driver
> from the latest vendor GPL version of the driver, obtained from here:
> 
>   http://www.asix.com.tw/download.php?sub=searchresult&PItemID=84&download=driver
> 
> The original vendor copy used a local "axusbnet" middleware (rather than "usbnet").
> I've converted it back to using "usbnet", made a ton of cosmetic changes
> to get it to pass checkpatch.pl, and removed a small amount of code duplication.
> 
> It can use more work going forward, but it is important to get it upstream
> sooner than later -- the current in-kernel driver fails with many devices,
> both old and new.  This updated version works with everything I have available
> to test with, and also handles suspend / resume (unlike the in-kernel one).
> 
> Signed-off-by: Mark Lord <mlord@pobox.com>
> 
> --- linux-3.0/drivers/net/usb/asix.c	2011-10-12 17:59:03.000000000 -0400
> +++ linux/drivers/net/usb/asix.c	2011-11-01 19:00:50.051289683 -0400
[...]
> +static u32 ax88772b_get_tx_csum(struct net_device *netdev)
[...]
> +static u32 ax88772b_get_rx_csum(struct net_device *netdev)
[...]
> +static int ax88772b_set_rx_csum(struct net_device *netdev, u32 val)
[...]
> +static int ax88772b_set_tx_csum(struct net_device *netdev, u32 val)
[...]
> +static struct ethtool_ops ax88772b_ethtool_ops = {
> +	.get_drvinfo		= ax8817x_get_drvinfo,
> +	.get_link		= ethtool_op_get_link,
> +	.get_msglevel		= usbnet_get_msglevel,
> +	.set_msglevel		= usbnet_set_msglevel,
> +	.get_wol		= ax8817x_get_wol,
> +	.set_wol		= ax8817x_set_wol,
> +	.get_eeprom_len		= ax8817x_get_eeprom_len,
> +	.get_eeprom		= ax8817x_get_eeprom,
> +	.get_settings		= ax8817x_get_settings,
> +	.set_settings		= ax8817x_set_settings,
> +	.set_tx_csum		= ax88772b_set_tx_csum,
> +	.get_tx_csum		= ax88772b_get_tx_csum,
> +	.get_rx_csum		= ax88772b_get_rx_csum,
> +	.set_rx_csum		= ax88772b_set_rx_csum,
> +};
[...]

The various ethtool operations for offload flags are being (or have
been) removed.  The driver must set net_device::hw_features and
implement net_device_ops::ndo_set_features instead.

> --- pristine/drivers/net/usb/asix.h	1969-12-31 19:00:00.000000000 -0500
> +++ linux/drivers/net/usb/asix.h	2011-11-02 15:15:34.099164264 -0400
[...]
> +struct {unsigned short size, byte_cnt, threshold; } AX88772B_BULKIN_SIZE[] = {
> +	{2048, 0x8000, 0x8001},		/* 2k */
> +	{4096, 0x8100, 0x8147},		/* 4k */
> +	{6144, 0x8200, 0x81EB},		/* 6k */
> +	{8192, 0x8300, 0x83D7},		/* 8k */
> +	{16384, 0x8400, 0x851E},	/* 16 */
> +	{20480, 0x8500, 0x8666},	/* 20k */
> +	{24576, 0x8600, 0x87AE},	/* 24k */
> +	{32768, 0x8700, 0x8A3D},	/* 32k */
> +};

Either define this as a macro and use it in the .c file, or just define
it there.  In either case, declare it as 'static const'.

[...]
> +/* GMII register numbers */
> +#define GMII_PHY_CONTROL		0x00	/* control */
> +#define GMII_PHY_STATUS			0x01	/* status */
> +#define GMII_PHY_OUI			0x02	/* most of the OUI bits */
> +#define GMII_PHY_MODEL			0x03	/* model/rev & rest of OUI */
> +#define GMII_PHY_ANAR			0x04	/* AN advertisement */
> +#define GMII_PHY_ANLPAR			0x05	/* AN Link Partner */
> +#define GMII_PHY_ANER			0x06	/* AN expansion */
> +#define GMII_PHY_1000BT_CONTROL		0x09	/* control for 1000BT */
> +#define GMII_PHY_1000BT_STATUS		0x0A	/* status for 1000BT */

These are MDIO registers and we have names for them in <linux/mii.h>.
Similarly for the following bit definitions.

[...]
> +/* Bit definitions: 1000BaseT AUX Control.
> + * FD="Full-Duplex", HD="Half-Duplex"
> + */
> +#define GMII_1000_AUX_CTRL_MASTER_SLAVE		0x1000
> +#define GMII_1000_AUX_CTRL_FD_CAPABLE		0x0200
> +#define GMII_1000_AUX_CTRL_HD_CAPABLE		0x0100
> +
> +/* Bit definitions: 1000BaseT AUX Status */
> +#define GMII_1000_AUX_STATUS_FD_CAPABLE		0x0800
> +#define GMII_1000_AUX_STATUS_HD_CAPABLE		0x0400
> +
> +/* Cicada MII Registers */
> +#define GMII_AUX_CTRL_STATUS			0x1C
> +#define GMII_AUX_ANEG_CPLT			0x8000
> +#define GMII_AUX_FDX				0x0020
> +#define GMII_AUX_SPEED_1000			0x0010
> +#define GMII_AUX_SPEED_100			0x0008

These appear to be extensions and would have to be kept.

> +#ifndef ADVERTISE_PAUSE_CAP
> +#define ADVERTISE_PAUSE_CAP			0x0400
> +#endif
> +
> +#ifndef MII_STAT1000
> +#define MII_STAT1000				0x000A
> +#endif
> +
> +#ifndef LPA_1000FULL
> +#define LPA_1000FULL				0x0800
> +#endif
[...]

These are exact duplicates of definitions in <linux/mii.h>, so should be
removed.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
