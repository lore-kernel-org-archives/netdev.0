From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] mdio-gpio: Optionally ignore TA errors
Date: Tue, 12 May 2015 10:08:57 -0700
Message-ID: <555233A9.1080109@gmail.com>
References: <1431442563-10218-1-git-send-email-bert@biot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Bert Vermeulen <bert@biot.com>, netdev@vger.kernel.org,
	jogo@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33878 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbbELRJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 13:09:13 -0400
Received: by pdbqa5 with SMTP id qa5so20075251pdb.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 10:09:13 -0700 (PDT)
In-Reply-To: <1431442563-10218-1-git-send-email-bert@biot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 07:56, Bert Vermeulen wrote:
> Some PHYs do not always drive TA low despite returning valid data. Allow
> ignoring the TA value if we know we are connected to one of these.
> 
> This is based on a patch by Jonas Gorski.

I think we need a more generic solution to this problem, not localized
only to the mdio-gpio driver as this also affects other systems using
non-bit banged MDIO bus controllers, and something that limits the TA
workaround to particular PHY addresses, not globally.

What I was thinking about is something along these lines:

- add a phy_ignore_ta_mask field to struct mii_bus

- when a MDIO bus is probed via Device Tree, scan for a "ignore-ta"
boolean property and set the phy_ignore_ta_mask bitmask accordingly

- when a MDIO bus is probed via regular platform data it can set the
phy_ignore_ta_mask directly while probing/connecting the PHY devices

- update the relevant MDIO bus drivers to check for this bit if they are
known to be interfaced with pathological PHY devices/switches that do
not release the drive TA low when expected

Does that sound reasonable to you?

> 
> Signed-off-by: Bert Vermeulen <bert@biot.com>
> ---
> This fixes MDIO communication with the second AR8316 on the Mikrotik RB493G.
> The board has an AR7161 SoC, which has only one MDIO interface, but there are
> two AR8316 switch chips. The first is handled by the SoC's MDIO pins, and
> enumerates fine. The second is wired into some GPIO pins, and thus uses the
> mdio-gpio driver.
> 
> Evidently, the AR8316 doesn't drive TA low when mdiobb_read() expects it, and
> the driver discards the data as a result. OpenWrt includes a simplified
> version of this patch: the check is removed altogether, and things just work.
> 
> A few problems with this patch:
> 
> - It's overly broad. As it turns out, this missing TA-low only happens once,
>   on the first read, which is done by get_phy_device() to read the PHY id.
>   Putting a discarded read in there before the real one ALSO fixes the problem:
>   the second and subsequent reads are fine. Unfortunately I can't force a
>   dummy read on this board without smashing through a bunch of layers.
> 
> - I'm not entirely convinced that the PHY's bringing TA low needs checking
>   to begin with. The standard clearly says that the PHY "shall" do it, but
>   it's equally clear that the MDIO interface on the AR7161 doesn't have a
>   problem talking to the AR8316. Presumably there are other SoCs in the wild
>   talking to AR8316 MDIO interfaces.
> 
> - It could also be a timing problem in mdiobb_read(), but I haven't been
>   able to find it if so. Unfortunately my board doesn't really allow me
>   to stick a logic analyzer on there and figure out what's different between
>   the two MDIO channels.
> 
> Advice, anyone?
> 
> 
>  drivers/net/phy/mdio-bitbang.c | 2 +-
>  drivers/net/phy/mdio-gpio.c    | 1 +
>  include/linux/mdio-bitbang.h   | 3 +++
>  include/linux/mdio-gpio.h      | 2 ++
>  4 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
> index daec9b0..306fb74 100644
> --- a/drivers/net/phy/mdio-bitbang.c
> +++ b/drivers/net/phy/mdio-bitbang.c
> @@ -166,7 +166,7 @@ static int mdiobb_read(struct mii_bus *bus, int phy, int reg)
>  	ctrl->ops->set_mdio_dir(ctrl, 0);
>  
>  	/* check the turnaround bit: the PHY should be driving it to zero */
> -	if (mdiobb_get_bit(ctrl) != 0) {
> +	if (mdiobb_get_bit(ctrl) != 0 && !ctrl->ignore_ta_errors) {
>  		/* PHY didn't drive TA low -- flush any bits it
>  		 * may be trying to send.
>  		 */
> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
> index 0a0578a..f5cddf5 100644
> --- a/drivers/net/phy/mdio-gpio.c
> +++ b/drivers/net/phy/mdio-gpio.c
> @@ -138,6 +138,7 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
>  	if (!bitbang)
>  		goto out;
>  
> +	bitbang->ctrl.ignore_ta_errors = pdata->ignore_ta_errors;
>  	bitbang->ctrl.ops = &mdio_gpio_ops;
>  	bitbang->ctrl.reset = pdata->reset;
>  	bitbang->mdc = pdata->mdc;
> diff --git a/include/linux/mdio-bitbang.h b/include/linux/mdio-bitbang.h
> index 76f52bb..3469bf2 100644
> --- a/include/linux/mdio-bitbang.h
> +++ b/include/linux/mdio-bitbang.h
> @@ -31,6 +31,9 @@ struct mdiobb_ops {
>  };
>  
>  struct mdiobb_ctrl {
> +	/* Some PHYs don't drive TA low even though they completed successfully. */
> +	unsigned int ignore_ta_errors:1;
> +
>  	const struct mdiobb_ops *ops;
>  	/* reset callback */
>  	int (*reset)(struct mii_bus *bus);
> diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
> index 66c30a7..cfe6d1b 100644
> --- a/include/linux/mdio-gpio.h
> +++ b/include/linux/mdio-gpio.h
> @@ -19,6 +19,8 @@ struct mdio_gpio_platform_data {
>  	unsigned int mdio;
>  	unsigned int mdo;
>  
> +	unsigned int ignore_ta_errors:1;
> +
>  	bool mdc_active_low;
>  	bool mdio_active_low;
>  	bool mdo_active_low;
> 


-- 
Florian
