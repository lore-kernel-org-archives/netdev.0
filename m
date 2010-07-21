From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/2] net: dsa: introduce MICREL KSZ8893MQL/BL ethernet switch chip support
Date: Wed, 21 Jul 2010 17:16:08 +0200
Message-ID: <20100721151608.GM21121@mail.wantstofly.org>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org> <1279719442-10174-2-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Karl Beldan <karl.beldan@gmail.com>,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:59148 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab0GUPQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 11:16:10 -0400
Content-Disposition: inline
In-Reply-To: <1279719442-10174-2-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 09:37:22AM -0400, Mike Frysinger wrote:

> From: Graf Yang <graf.yang@analog.com>

Hurray for the first non-Marvell switch chip support in net/dsa!


> +#define pr_fmt(fmt) "ksz8893m: " fmt

This has no users.


> +static int ksz8893m_setup(struct dsa_switch *ds)
> +{
> +	int i;
> +	int ret;
> +
> +	ret = ksz8893m_switch_reset(ds);
> +	if (ret < 0)
> +		return ret;

It's pretty ugly that the mdiobus is passed in via the normal means,
but a reference to the SPI bus to use is just stuffed into some global
variable.

Can you not access all registers via MII?

(If not, struct dsa_chip_data will need go be extended with another
struct device pointer that we can use to find the spi bus with.)


> +static int ksz8893m_port_to_phy_addr(int port)
> +{
> +	if (port >= 1 && port <= KSZ8893M_PORT_NUM)
> +		return port;
> +
> +	pr_warning("use default phy addr 3\n");
> +	return 3;

Does this ever happen?  You should just be able to return -1 here, IMHO.


> +static int __devinit spi_switch_probe(struct spi_device *spi)
> +{
> +	if (sw.dev) {
> +		pr_err("only one instance supported at a time\n");
> +		return 1;
> +	}
> +	memset(&sw.xfer, 0, sizeof(sw.xfer));
> +	sw.dev = spi;
> +	return 0;
> +}
> +
> +static int __devexit spi_switch_remove(struct spi_device *spi)
> +{
> +	sw.dev = NULL;
> +	return 0;
> +}
> +
> +static struct spi_driver spi_switch_driver = {
> +	.driver = {
> +		.name	= "ksz8893m",
> +		.bus	= &spi_bus_type,
> +		.owner	= THIS_MODULE,
> +	},
> +	.probe	= spi_switch_probe,
> +	.remove	= __devexit_p(spi_switch_remove),
> +};

I'm not entirely happy with this.

Then again, there isn't really a clean way to deal with devices that
have multiple different host interfaces as far as I know..


> +#define KSZ8893M_PORT_NUM 3
> +#define KSZ8893M_CPU_PORT 3
> +
> +#define DEFAULT_PORT_VID  0
> +
> +#define SPI_READ          3
> +#define SPI_WRITE         2
>
> [snip]

Something tells me that half the defines (and register index definitions)
in this file aren't used.  Also:


> +/* MII Basic Control */
> +#define SOFT_RESET        0x8000
> +#define LOOPBACK          0x4000
> +#define FORCE_100         0x2000
> +#define AN_ENABLE         0x1000
> +#define POWER_DOWN        0x0800
> +#define ISOLATE           0x0400
> +#define RESTART_AN        0x0200
> +#define FORCE_FULL_DUPLEX 0x0100
> +#define COLLISION_TEST    0x0080

This part of the MII register is standard, and there are BMCR_*
definitions for this in mii.h, no need to duplicate them.


> +#define Force_MDI         0x0010

And please don't use mixed case.


> +#define FAMILY_ID         0x88
> +#define START_SWITCH      0x01
> +#define TAG_INSERTION     0x04
> +#define SPECIAL_TPID_MODE 0x01

It would be nice to mention what registers these bitfields are part of.


> +enum switch_phy_reg {
> +	/* Global Registers: 0-15 */
> +	ChipID0 = 0,
> +	ChipID1_StartSwitch,
> +	GlobalControl0,

And here, just define the registers you need only.
