From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] e1000: Dump the eeprom when a user encounters a bad
	checksum
Date: Mon, 17 Dec 2007 14:14:58 -0800
Message-ID: <1197929698.27386.61.camel@localhost>
References: <20071217215023.26270.62396.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	randy.dunlap@oracle.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3622 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206AbXLQWPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 17:15:08 -0500
In-Reply-To: <20071217215023.26270.62396.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2007-12-17 at 13:50 -0800, Auke Kok wrote:
> diff --git a/drivers/net/e1000/e1000_main.c
> b/drivers/net/e1000/e1000_main.c
> index efd8c2d..aac55be 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -979,23 +1036,29 @@ e1000_probe(struct pci_dev *pdev,
>  	e1000_reset_hw(&adapter->hw);
>  
>  	/* make sure the EEPROM is good */
> -
>  	if (e1000_validate_eeprom_checksum(&adapter->hw) < 0) {
>  		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
> -		goto err_eeprom;
> +		e1000_dump_eeprom(adapter);
> +		/*
> +		 * set MAC address to all zeroes to invalidate and temporary
> +		 * disable this device for the user. This blocks regular
> +		 * traffic while still permitting ethtool ioctls from reaching
> +		 * the hardware as well as allowing the user to run the
> +		 * interface after manually setting a hw addr using
> +		 * `ip set address`
> +		 */
> +		memset(adapter->hw.mac_addr, 0, netdev->addr_len);

Do you need to set netdev->dev_addr too?

> +	} else {
> +		/* copy the MAC address out of the EEPROM */
> +		if (e1000_read_mac_addr(&adapter->hw))
> +			DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
>  	}
> -
> -	/* copy the MAC address out of the EEPROM */
> -
> -	if (e1000_read_mac_addr(&adapter->hw))
> -		DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
> +	/* don't block initalization here due to bad MAC address */

I just sent a patch to fix these typos and another pops up...

	initialization

cheers, Joe

