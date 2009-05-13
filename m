From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 5/7] [PATCH 5/8] can: SJA1000 generic platform bus
 driver
Date: Wed, 13 May 2009 16:02:35 -0600
Message-ID: <20090513160235.5d2d281c@bike.lwn.net>
References: <20090512092757.048938233@denx.de>
	<20090512092757.894204198@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vena.lwn.net ([206.168.112.25]:39908 "EHLO vena.lwn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761543AbZEMWCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:02:36 -0400
In-Reply-To: <20090512092757.894204198@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 May 2009 11:28:02 +0200
Wolfgang Grandegger <wg@grandegger.com> wrote:

> This driver adds support for the SJA1000 chips connected to the
> "platform bus", which can be found on various embedded systems.

[...]

> +
> +static u8 sp_read_reg(const struct net_device *dev, int reg)
> +{
> +	return ioread8((void __iomem *)(dev->base_addr + reg));
> +}
> +
> +static void sp_write_reg(const struct net_device *dev, int reg, u8 val)
> +{
> +	iowrite8(val, (void __iomem *)(dev->base_addr + reg));
> +}

So there's no locking around accesses to the hardware at all.  How do you
protect against concurrent access?

[...]

> +static int sp_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev = dev_get_drvdata(&pdev->dev);
> +	struct resource *res;
> +
> +	unregister_sja1000dev(dev);
> +	dev_set_drvdata(&pdev->dev, NULL);
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	release_mem_region(res->start, res->end - res->start + 1);
> +
> +	if (dev->base_addr)
> +		iounmap((void __iomem *)dev->base_addr);

Seems like you should unmap it before releasing it back to the kernel.
Nobody else is ever going to jump in and try to map it, but still...

> +	free_sja1000dev(dev);
> +
> +	return 0;
> +}

jon
