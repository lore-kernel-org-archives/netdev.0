From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] Fix IXP4xx coherent allocations
Date: Sat, 23 Mar 2013 20:35:46 +0100
Message-ID: <m3obe9lxil.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Christophe Aeschlimann <c.aeschlimann@acn-group.ch>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARM core code currently requires coherent DMA mask to be set. Make sure
we limit PCI devices to 64 MiB while allowing on-chip devices to access
the whole 4 GiB address space.

This fixes a v3.7+ regression which broke IXP4xx built-in network devic=
es.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
Cc: <stable@vger.kernel.org>

diff --git a/arch/arm/mach-ixp4xx/common-pci.c b/arch/arm/mach-ixp4xx/c=
ommon-pci.c
index ea1933d..8629fc9 100644
--- a/arch/arm/mach-ixp4xx/common-pci.c
+++ b/arch/arm/mach-ixp4xx/common-pci.c
@@ -454,10 +454,15 @@ int ixp4xx_setup(int nr, struct pci_sys_data *sys=
)
=20
 int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
-	if (mask >=3D SZ_64M - 1)
-		return 0;
+	if ((mask & DMA_BIT_MASK(26)) !=3D DMA_BIT_MASK(26))
+		return -EIO;
+
+	/* PCI devices are limited to 64 MiB */
+	if (dev_is_pci(dev))
+		mask &=3D DMA_BIT_MASK(26); /* Use DMA region */
=20
-	return -EIO;
+	dev->coherent_dma_mask =3D mask;
+	return 0;
 }
=20
 EXPORT_SYMBOL(ixp4xx_pci_read);
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/eth=
ernet/xscale/ixp4xx_eth.c
index 6958a5e..7c08269 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1423,7 +1423,7 @@ static int eth_init_one(struct platform_device *p=
dev)
 	dev->netdev_ops =3D &ixp4xx_netdev_ops;
 	dev->ethtool_ops =3D &ixp4xx_ethtool_ops;
 	dev->tx_queue_len =3D 100;
-
+	dma_set_coherent_mask(&dev->dev, DMA_BIT_MASK(32));
 	netif_napi_add(dev, &port->napi, eth_poll, NAPI_WEIGHT);
=20
 	if (!(port->npe =3D npe_request(NPE_ID(port->id)))) {
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.=
c
index 95d0451..83b4597 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1367,6 +1367,7 @@ static int hss_init_one(struct platform_device *p=
dev)
 	port->id =3D pdev->id;
 	port->dev =3D &pdev->dev;
 	port->plat =3D pdev->dev.platform_data;
+	dma_set_coherent_mask(&dev->dev, DMA_BIT_MASK(32));
 	netif_napi_add(dev, &port->napi, hss_hdlc_poll, NAPI_WEIGHT);
=20
 	if ((err =3D register_hdlc_device(dev)))
