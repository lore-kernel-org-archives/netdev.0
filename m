From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Fix IXP4xx coherent allocations
Date: Sat, 30 Mar 2013 15:22:46 +0100
Message-ID: <m3d2uhdl1l.fsf@intrepid.localdomain>
References: <m3obe9lxil.fsf@intrepid.localdomain>
	<20130323.195740.2108147521543354261.davem@davemloft.net>
	<1364152267.3620.31.camel@deadeye.wl.decadent.org.uk>
	<m3r4j4sdmv.fsf@intrepid.localdomain>
	<20130330132915.GB17995@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, c.aeschlimann@acn-group.ch
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130330132915.GB17995@n2100.arm.linux.org.uk> (Russell King's
	message of "Sat, 30 Mar 2013 13:29:15 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell King - ARM Linux <linux@arm.linux.org.uk> writes:

> I'm having a hard time understanding what is an ARM issue here, what is
> an ARM bug, and what the DMA API requires.  The DMA API documentation
> is extremely sparse in describing what's required of the DMA masks,
> what these functions are supposed to do, and what determines whether
> a mask is "possible" or not.
>
> Moreover, I'm also having a hard time understanding what broke in 3.7,
> and why this fixes it.
>
> In other words, I'm completely failing to understand everything about
> this patch.

The ARM issue here is that the coherent DMA mask, by default, is zero
(i.e. coherent allocations are impossible by default UNLESS the device
pointer supplied is NULL - since DMA masks are bound to devices).
On most other platforms, the default DMA mask is 0xFFFFFFFF = (u32)-1
and this is also required by the DMA API.

In v3.7 (between v3.7-rc6 and v3.7-rc7), Xi Wang noticed that IXP4xx net
drivers call dma_pool_create() with NULL dev argument, and changed them
to use &port->netdev->dev. This broke coherent allocations since now the
device supplied to dma_pool_create() is not NULL and the (zero) mask
prevents coherent allocations. This means the Ethernet and HSS drivers
are since then unusable.


The first part of my patch makes dma_set_coherent_mask (IXP4xx-only
code) actually set the mask. This is needed as on IXP4xx we have (at
least) two different situations:

- PCI devices want "DMA zone" memory (26 bits = 64 MiB)
- built-in devices can use any RAM (32 bits = 4 GiB).

Without the patch, dma_set_coherent_mask only returns 0 or -EIO, it
doesn't change the actual coherent DMA mask and it's then impossible for
coherent allocators to differentiate between the above two cases.

+++ b/arch/arm/mach-ixp4xx/common-pci.c
@@ -454,10 +454,15 @@ int ixp4xx_setup(int nr, struct pci_sys_data *sys)
 
 int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
-	if (mask >= SZ_64M - 1)
-		return 0;
+	if ((mask & DMA_BIT_MASK(26)) != DMA_BIT_MASK(26))
+		return -EIO;
+
+	/* PCI devices are limited to 64 MiB */
+	if (dev_is_pci(dev))
+		mask &= DMA_BIT_MASK(26); /* Use DMA region */
 
-	return -EIO;
+	dev->coherent_dma_mask = mask;
+	return 0;
 }


The second part of my patch sets the coherent DMA masks of the Ethernet
and HSS devices to 4 GiB (the value which should already be the
default). This also seems to be a recommended action.

+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1423,7 +1423,7 @@ static int eth_init_one(struct platform_device *pdev)
 	dev->ethtool_ops = &ixp4xx_ethtool_ops;
 	dev->tx_queue_len = 100;
-
+	dma_set_coherent_mask(&dev->dev, DMA_BIT_MASK(32));
 	netif_napi_add(dev, &port->napi, eth_poll, NAPI_WEIGHT);
 
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1367,6 +1367,7 @@ static int hss_init_one(struct platform_device *pdev)
 	port->dev = &pdev->dev;
 	port->plat = pdev->dev.platform_data;
+	dma_set_coherent_mask(&dev->dev, DMA_BIT_MASK(32));
 	netif_napi_add(dev, &port->napi, hss_hdlc_poll, NAPI_WEIGHT);

-- 
Krzysztof Halasa
