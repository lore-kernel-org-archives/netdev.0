From: Timur Tabi <timur@freescale.com>
Subject: Broken ioremap usage in fsl_pq_mdio.c?
Date: Fri, 6 Jan 2012 15:11:22 -0600
Message-ID: <4F07637A.901@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Andrew Fleming-AFLEMING <AFLEMING@freescale.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:13486 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1030484Ab2AFVLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 16:11:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see some odd code in fsl_pq_mdio.c, so I'm hoping someone can clear this up for me.  In fsl_pq_mdio_probe(), I see this code:

	/* Set the PHY base address */
	addr = of_translate_address(np, addrp);
	if (addr == OF_BAD_ADDR) {
		err = -EINVAL;
		goto err_free_bus;
	}

	map = ioremap(addr, size);
	if (!map) {
		err = -ENOMEM;
		goto err_free_bus;
	}
	priv->map = map;

	if (of_device_is_compatible(np, "fsl,gianfar-mdio") ||
			of_device_is_compatible(np, "fsl,gianfar-tbi") ||
			of_device_is_compatible(np, "fsl,ucc-mdio") ||
			of_device_is_compatible(np, "ucc_geth_phy"))
		map -= offsetof(struct fsl_pq_mdio, miimcfg);
	regs = map;
	priv->regs = regs;

I don't see how the "map -= offsetof(struct fsl_pq_mdio, miimcfg)" is valid.  'map' initially points to the beginning of an ioremap'd buffer.  Subtracting from it will cause it to point to invalid memory area.

I presume this works because ioremap() maps whole pages, and "map - offsetof(struct fsl_pq_mdio, miimcfg)" is still inside that page.  However, this is not documented as an assumption, so I don't know if this is really what's intended.  Regardless, it seems very fragile.  At the very least, there should be another ioremap for priv->regs, but that's still a hack.

-- 
Timur Tabi
Linux kernel developer at Freescale
