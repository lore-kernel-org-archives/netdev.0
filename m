From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 4/7] net: pch_gbe: Add device tree support
Date: Mon, 5 Jun 2017 20:54:51 +0200
Message-ID: <20170605185451.GE5235@lunn.ch>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
 <20170605173136.10795-1-paul.burton@imgtec.com>
 <20170605173136.10795-5-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        linux-mips@linux-mips.org, Eric Dumazet <edumazet@google.com>,
        Jarod Wilson <jarod@redhat.com>,
        Tobias Klauser <tklauser@distanz.ch>
To: Paul Burton <paul.burton@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36925 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751170AbdFESyx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 14:54:53 -0400
Content-Disposition: inline
In-Reply-To: <20170605173136.10795-5-paul.burton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static struct pch_gbe_privdata *
> +pch_gbe_get_priv(struct pci_dev *pdev, const struct pci_device_id *pci_id)
> +{
> +	struct pch_gbe_privdata *pdata;
> +	struct gpio_desc *gpio;
> +
> +	if (!IS_ENABLED(CONFIG_OF))
> +		return (struct pch_gbe_privdata *)pci_id->driver_data;

It is possible to enable CONFIG_OF on all architectures, including x86
used by Minnow. If somebody was to do this, i think Minnow breaks. What
i think you really want is:

  	if pci_id->driver_data;
		  return (struct pch_gbe_privdata *)pci_id->driver_data;

> +
> +	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
> +	if (!pdata)
> +		return ERR_PTR(-ENOMEM);
> +
> +	gpio = devm_gpiod_get(&pdev->dev, "phy-reset", GPIOD_ASIS);
> +	if (!IS_ERR(gpio))
> +		pdata->phy_reset_gpio = gpio;
> +	else if (PTR_ERR(gpio) != -ENOENT)
> +		return ERR_CAST(gpio);
> +
> +	return pdata;
> +}

There should not be a need to protect for !CONFIG_OF, and
devm_gpiod_get() knows how to look in ACPI tables, if an intel or
ARM64 platform it using that to list its GPIOs.

      Andrew
