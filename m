From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Simplify lan9303_xxx_packet_processing() usage
Date: Mon, 31 Jul 2017 10:00:53 -0400
Message-ID: <87379c4sfe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no> <20170731113355.4284-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57188 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750987AbdGaODs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 10:03:48 -0400
In-Reply-To: <20170731113355.4284-3-privat@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Egil,

A few nitpicks below for lan9303_disable_processing.

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

>  static int lan9303_disable_processing(struct lan9303 *chip)
>  {
> -	int ret;
> +	int p;
>  
> -	ret = lan9303_disable_packet_processing(chip, 0);
> -	if (ret)
> -		return ret;
> -	ret = lan9303_disable_packet_processing(chip, 1);
> -	if (ret)
> -		return ret;
> -	return lan9303_disable_packet_processing(chip, 2);
> +	for (p = 0; p <= 2; p++) {

Exclusive limits are often prefer, i.e. 'p < 3'.

> +		int ret;
> +
> +		ret = lan9303_disable_packet_processing(chip, p);
> +		if (ret)
> +			return ret;

When any non-zero return code means an error, we usually see 'err'
instead of 'ret'.

> +	}

blank line before return statments are appreciated.

> +	return 0;
>  }
>  
>  static int lan9303_check_device(struct lan9303 *chip)
> @@ -760,7 +761,6 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
>  	/* enable internal packet processing */
>  	switch (port) {
>  	case 1:
> -		return lan9303_enable_packet_processing(chip, port);

Is this deletion intentional? The commit message does not explain this.

When possible, it is appreciated to separate functional from
non-functional changes. For example one commit adding the loop in
lan9303_disable_processing and another one to not enable/disable packet
processing on port 1.

>  	case 2:
>  		return lan9303_enable_packet_processing(chip, port);
>  	default:
> @@ -779,13 +779,9 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
>  	/* disable internal packet processing */
>  	switch (port) {
>  	case 1:
> -		lan9303_disable_packet_processing(chip, port);
> -		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 1,
> -				  MII_BMCR, BMCR_PDOWN);
> -		break;
>  	case 2:
>  		lan9303_disable_packet_processing(chip, port);
> -		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 2,
> +		lan9303_phy_write(ds, chip->phy_addr_sel_strap + port,
>  				  MII_BMCR, BMCR_PDOWN);
>  		break;

Thanks,

        Vivien
