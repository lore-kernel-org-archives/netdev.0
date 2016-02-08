From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 4/7] net: phy: spi_ks8995: add support for resetting
 switch using GPIO
Date: Mon, 8 Feb 2016 10:22:06 +0100
Message-ID: <20160208092206.GB1820@lunn.ch>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
 <1454884753-4560-5-git-send-email-helmut.buchsbaum@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51671 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245AbcBHJWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 04:22:08 -0500
Content-Disposition: inline
In-Reply-To: <1454884753-4560-5-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 07, 2016 at 11:39:10PM +0100, Helmut Buchsbaum wrote:
> When using device tree it is no more possible to reset the PHY at board
> level. Furthermore, doing in the driver allows to power down the switch
> when the it is not used any more.
> 
> The patch introduces a new optional property "reset-gpios" denoting an
> appropriate GPIO handle, e.g.:
> 
> reset-gpios = <&gpio0 46 1>

The 1 here means active low flag.

>  
> +	pdata->reset_gpio = of_get_named_gpio(np, "reset-gpios", 0);
> +

Here you don't take any notice of the flags.

>  	/* we have something like:
>  	 * settings = <0x22 0x80 0xF0>;
>  	 *               ^   ^    ^
> @@ -484,6 +489,8 @@ static int ks8995_probe(struct spi_device *spi)
>  		if (!ks->pdata)
>  			return -ENOMEM;
>  
> +		ks->pdata->reset_gpio = -1;
> +
>  		err = ks8995_parse_dt(ks);
>  		if (err) {
>  			dev_err(&ks->spi->dev, "bad data DT data\n");
> @@ -494,6 +501,18 @@ static int ks8995_probe(struct spi_device *spi)
>  	if (!ks->pdata)
>  		ks->pdata = spi->dev.platform_data;
>  
> +	if (ks->pdata && gpio_is_valid(ks->pdata->reset_gpio)) {
> +		err = devm_gpio_request_one(&spi->dev,
> +					    ks->pdata->reset_gpio,
> +					    GPIOF_OUT_INIT_HIGH,

Hard coded HIGH. You should determine this from the flag....

DSA has the same functionality and does support the flag. You can copy
it from there.

     Andrew
