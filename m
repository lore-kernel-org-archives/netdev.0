From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: lan9303: Fixed MDIO interface
Date: Tue, 25 Jul 2017 15:15:26 -0400
Message-ID: <878tjc49bl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no> <20170725161553.30147-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, corbet@lwn.net,
        andrew@lunn.ch, f.fainelli@gmail.com, davem@davemloft.net,
        kernel@pengutronix.de, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36504 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751960AbdGYTSP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 15:18:15 -0400
In-Reply-To: <20170725161553.30147-2-privat@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Fixes after testing on actual HW:
>
> - lan9303_mdio_write()/_read() must multiply register number
>   by 4 to get offset
>
> - Indirect access (PMI) to phy register only work in I2C mode. In
>   MDIO mode phy registers must be accessed directly. Introduced
>   struct lan9303_phy_ops to handle the two modes. Renamed functions
>   to clarify.
>
> - lan9303_detect_phy_setup() : Failed MDIO read return 0xffff.
>   Handle that.

Small patch series when possible are better. Bullet points in commit
messages are likely to describe how a patch or series may be split up
;-)

This patch seems to be the unique patch of the series resolving what is
described in the cover letter as "Make the MDIO interface work".

I'd suggest you to split up this one commit in several *atomic* and easy
to review patches and send them separately as on thread named "net: dsa:
lan9303: fix MDIO interface" (also note that imperative is prefered for
subject lines, see: https://chris.beams.io/posts/git-commit/#imperative)

<...>

> -static int lan9303_port_phy_reg_wait_for_completion(struct lan9303 *chip)
> +static int lan9303_indirect_phy_wait_for_completion(struct lan9303 *chip)

For instance you can have a first commit only renaming the functions.
The reason for it is to separate the functional changes from cosmetic
changes, which makes it easier for review.

<...>

> -	if (reg != 0)
> +	if ((reg != 0) && (reg != 0xffff))

if (reg && reg != 0xffff) should be enough.

>  		chip->phy_addr_sel_strap = 1;
>  	else
>  		chip->phy_addr_sel_strap = 0;

<...>

> +struct lan9303;
> +
> +struct lan9303_phy_ops {
> +	/* PHY 1 &2 access*/

The spacing is weird in the comment. "/* PHY 1 & 2 access */" maybe?

<...>

> +int lan9303_mdio_phy_write(struct lan9303 *chip, int phy, int regnum, u16 val)
> +{
> +	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
> +	struct mdio_device *mdio = sw_dev->device;
> +
> +	mutex_lock(&mdio->bus->mdio_lock);
> +	mdio->bus->write(mdio->bus, phy, regnum, val);
> +	mutex_unlock(&mdio->bus->mdio_lock);

This is exactly what mdiobus_write(mdio->bus, phy, regnum, val) is
doing. There are very few valid reasons to go play in the mii_bus
structure, using generic APIs are strongly prefered. Plus you have
checks and traces for free!

> +
> +	return 0;
> +}
> +
> +int lan9303_mdio_phy_read(struct lan9303 *chip, int phy,  int reg)
> +{
> +	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
> +	struct mdio_device *mdio = sw_dev->device;
> +	int val;
> +
> +	mutex_lock(&mdio->bus->mdio_lock);
> +	val  =  mdio->bus->read(mdio->bus, phy, reg);
> +	mutex_unlock(&mdio->bus->mdio_lock);

Same here, mdiobus_read().


Thanks,

        Vivien
