From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/8] dsa: Move gpio reset into switch driver
Date: Wed, 13 Apr 2016 22:03:13 -0400 (EDT)
Message-ID: <20160413.220313.1257029315478740404.davem@davemloft.net>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
	<1460591998-20598-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbcDNCDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 22:03:16 -0400
In-Reply-To: <1460591998-20598-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 14 Apr 2016 01:59:54 +0200

> @@ -3178,6 +3178,7 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
>  	struct mv88e6xxx_priv_state *ps;
>  	struct dsa_switch *ds;
>  	const char *name;
> +	int err;
>  
>  	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*ps), GFP_KERNEL);
>  	if (!ds)
> @@ -3199,6 +3200,17 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
>  		return -ENODEV;
>  	}
>  
> +	ps->reset = devm_gpiod_get(&mdiodev->dev, "reset", GPIOD_ASIS);
> +	err = PTR_ERR(ps->reset);
> +	if (err) {
> +		if (err == -ENOENT) {
> +			/* Optional, so not an error */
> +			ps->reset = NULL;
> +		} else {
> +			return err;
> +		}
> +	}

PTR_ERR() just casts the pointer into an integer, regardless of it's
value, and regardless of whether it is an error code or a real pointer
successfully returned from devm_gpiod_get().

So I don't think this code is correct.

You need an IS_ERR() check in there somewhere.
