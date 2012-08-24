From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH] [v3] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 13:51:31 -0600
Message-ID: <5037DB43.60704@wwwdotorg.org>
References: <1345835453-8611-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, ddaney.cavm@gmail.com,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:53860 "EHLO
	avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758130Ab2HXTvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:51:35 -0400
In-Reply-To: <1345835453-8611-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2012 01:10 PM, Timur Tabi wrote:
> Add support for an MDIO bus multiplexer controlled by a simple memory-mapped
> device, like an FPGA.  The device must be memory-mapped and contain only
> 8-bit registers (which keeps things simple).
> 
> Tested on a Freescale P5020DS board which uses the "PIXIS" FPGA attached
> to the localbus.

> +++ b/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt

> +Properties for an MDIO bus multiplexer controlled by a memory-mapped device
> +
> +This is a special case of a MDIO bus multiplexer.  A memory-mapped device,
> +like an FPGA, is used to control which child bus is connected.  The mdio-mux
> +node must be a child of the memory-mapped device.  The driver currently only
> +supports devices with eight-bit registers.

That last sentence seems like a property of the driver, not the binding;
I could easily anticipate allowing the size to be 1 or 2 or 4, and a
driver adapter to that in the future.

Otherwise, this binding looks great now.

> +++ b/drivers/net/phy/mdio-mux-mmioreg.c

> +static int mdio_mux_mmioreg_switch_fn(int current_child, int desired_child,
> +				      void *data)
> +{
> +	struct mdio_mux_mmioreg_state *s = data;
> +
> +	if (current_child ^ desired_child) {
> +		void *p = ioremap(s->phys, 1);
> +		uint8_t x, y;
> +
> +		if (!p)
> +			return -ENOMEM;

Why not map it during probe?

> +		x = ioread8(p);
> +		y = (x & ~s->mask) | desired_child;
> +		if (x != y) {

Isn't that always true, given if (current_child ^ desired_child) above?

> +			iowrite8((x & ~s->mask) | desired_child, p);
> +			pr_debug("%s: %02x -> %02x\n", __func__, x, y);
> +		}
> +
> +		iounmap(p);
> +	}
> +
> +	return 0;
> +}
