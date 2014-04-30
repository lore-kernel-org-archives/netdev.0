From: Alexey Charkov <alchark@gmail.com>
Subject: [PATCH] net: via-rhine: Drop revision property, use quirks instead
Date: Wed, 30 Apr 2014 22:21:09 +0400
Message-ID: <1398882069-28872-1-git-send-email-alchark@gmail.com>
References: <1398859589-22346-1-git-send-email-alchark@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Charkov <alchark@gmail.com>
To: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>,
	Jan Moskyto Matejka <mq@suse.cz>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398859589-22346-1-git-send-email-alchark@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds two new flags to quirks and thus removes the need to carry
revision in rhine_private. As a result, the init logic is simplified
a bit.

This also fixes a compiler warning in OF code on 64bit due to pointer
casting:

        drivers/net/ethernet/via/via-rhine.c: In function =E2=80=98rhin=
e_init_one_platform=E2=80=99:
        drivers/net/ethernet/via/via-rhine.c:1132:13: warning: cast fro=
m pointer to integer of different size [-Wpointer-to-int-cast]
          revision =3D (u32)match->data;
                     ^

That code was added in commit 2d283862dc62daead9db0dc89cd0d0351e91f765
("net: via-rhine: add OF bus binding").

Tested in platform configuration on a VIA WM8950 APC Rock board.

Reported-by: Jan Moskyto Matejka <mq@suse.cz>
Signed-off-by: Alexey Charkov <alchark@gmail.com>
---

This supercedes a previously submitted patch titled:

net: via-rhine: Fix compiler warning re: pointer casting on 64bit

I thought it would be a good idea to also streamline the common code so=
mewhat
while at it, and storing quirks directly in the match table sounded mor=
e
appropriate than storing an abstract revision that doesn't come from th=
e
hardware.

This also further reduces the rhine_private structure and makes runtime=
 checks
more uniform throughout the driver.

 drivers/net/ethernet/via/via-rhine.c | 77 ++++++++++++++++++++--------=
--------
 1 file changed, 42 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/etherne=
t/via/via-rhine.c
index 4fa9201..13cfcce 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -264,6 +264,8 @@ enum rhine_quirks {
 	rq6patterns	=3D 0x0040,	/* 6 instead of 4 patterns for WOL */
 	rqStatusWBRace	=3D 0x0080,	/* Tx Status Writeback Error possible */
 	rqRhineI	=3D 0x0100,	/* See comment below */
+	rqIntPHY	=3D 0x0200,	/* Integrated PHY */
+	rqMgmt		=3D 0x0400,	/* Management adapter */
 };
 /*
  * rqRhineI: VT86C100A (aka Rhine-I) uses different bits to enable
@@ -284,11 +286,11 @@ static DEFINE_PCI_DEVICE_TABLE(rhine_pci_tbl) =3D=
 {
 MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
=20
 /* OpenFirmware identifiers for platform-bus devices
- * The .data field is currently only used to store chip revision
- * (for quirks etc.)
+ * The .data field is currently only used to store quirks
  */
+static u32 vt8500_quirks =3D rqWOL | rqForceReset | rq6patterns;
 static struct of_device_id rhine_of_tbl[] =3D {
-	{ .compatible =3D "via,vt8500-rhine", .data =3D (void *)0x84 },
+	{ .compatible =3D "via,vt8500-rhine", .data =3D &vt8500_quirks },
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(of, rhine_of_tbl);
@@ -459,7 +461,6 @@ struct rhine_private {
 	unsigned char *tx_bufs;
 	dma_addr_t tx_bufs_dma;
=20
-	int revision;
 	int irq;
 	long pioaddr;
 	struct net_device *dev;
@@ -882,7 +883,7 @@ static const struct net_device_ops rhine_netdev_ops=
 =3D {
 #endif
 };
=20
-static int rhine_init_one_common(struct device *hwdev, int revision,
+static int rhine_init_one_common(struct device *hwdev, u32 quirks,
 				 long pioaddr, void __iomem *ioaddr, int irq)
 {
 	struct net_device *dev;
@@ -906,31 +907,13 @@ static int rhine_init_one_common(struct device *h=
wdev, int revision,
=20
 	rp =3D netdev_priv(dev);
 	rp->dev =3D dev;
-	rp->revision =3D revision;
+	rp->quirks =3D quirks;
 	rp->pioaddr =3D pioaddr;
 	rp->base =3D ioaddr;
 	rp->irq =3D irq;
 	rp->msg_enable =3D netif_msg_init(debug, RHINE_MSG_DEFAULT);
=20
-	phy_id =3D 0;
-	name =3D "Rhine";
-	if (revision < VTunknown0) {
-		rp->quirks =3D rqRhineI;
-	} else if (revision >=3D VT6102) {
-		rp->quirks =3D rqWOL | rqForceReset;
-		if (revision < VT6105) {
-			name =3D "Rhine II";
-			rp->quirks |=3D rqStatusWBRace;	/* Rhine-II exclusive */
-		} else {
-			phy_id =3D 1;	/* Integrated PHY, phy_id fixed to 1 */
-			if (revision >=3D VT6105_B0)
-				rp->quirks |=3D rq6patterns;
-			if (revision < VT6105M)
-				name =3D "Rhine III";
-			else
-				name =3D "Rhine III (Management Adapter)";
-		}
-	}
+	phy_id =3D rp->quirks & rqIntPHY ? 1 : 0;
=20
 	u64_stats_init(&rp->tx_stats.syncp);
 	u64_stats_init(&rp->rx_stats.syncp);
@@ -975,7 +958,7 @@ static int rhine_init_one_common(struct device *hwd=
ev, int revision,
 	if (rp->quirks & rqRhineI)
 		dev->features |=3D NETIF_F_SG|NETIF_F_HW_CSUM;
=20
-	if (rp->revision >=3D VT6105M)
+	if (rp->quirks & rqMgmt)
 		dev->features |=3D NETIF_F_HW_VLAN_CTAG_TX |
 				 NETIF_F_HW_VLAN_CTAG_RX |
 				 NETIF_F_HW_VLAN_CTAG_FILTER;
@@ -985,6 +968,15 @@ static int rhine_init_one_common(struct device *hw=
dev, int revision,
 	if (rc)
 		goto err_out_free_netdev;
=20
+	if (rp->quirks & rqRhineI)
+		name =3D "Rhine";
+	else if (rp->quirks & rqStatusWBRace)
+		name =3D "Rhine II";
+	else if (rp->quirks & rqMgmt)
+		name =3D "Rhine III (Management Adapter)";
+	else
+		name =3D "Rhine III";
+
 	netdev_info(dev, "VIA %s at 0x%lx, %pM, IRQ %d\n",
 		    name, (long)ioaddr, dev->dev_addr, rp->irq);
=20
@@ -1031,7 +1023,7 @@ static int rhine_init_one_pci(struct pci_dev *pde=
v,
 	long pioaddr, memaddr;
 	void __iomem *ioaddr;
 	int io_size =3D pdev->revision < VTunknown0 ? 128 : 256;
-	u32 quirks =3D pdev->revision < VTunknown0 ? rqRhineI : 0;
+	u32 quirks;
 #ifdef USE_MMIO
 	int bar =3D 1;
 #else
@@ -1047,6 +1039,21 @@ static int rhine_init_one_pci(struct pci_dev *pd=
ev,
 	if (rc)
 		goto err_out;
=20
+	if (pdev->revision < VTunknown0) {
+		quirks =3D rqRhineI;
+	} else if (pdev->revision >=3D VT6102) {
+		quirks =3D rqWOL | rqForceReset;
+		if (pdev->revision < VT6105) {
+			quirks |=3D rqStatusWBRace;
+		} else {
+			quirks |=3D rqIntPHY;
+			if (pdev->revision >=3D VT6105_B0)
+				quirks |=3D rq6patterns;
+			if (pdev->revision >=3D VT6105M)
+				quirks |=3D rqMgmt;
+		}
+	}
+
 	/* sanity check */
 	if ((pci_resource_len(pdev, 0) < io_size) ||
 	    (pci_resource_len(pdev, 1) < io_size)) {
@@ -1093,7 +1100,7 @@ static int rhine_init_one_pci(struct pci_dev *pde=
v,
 	}
 #endif /* USE_MMIO */
=20
-	rc =3D rhine_init_one_common(&pdev->dev, pdev->revision,
+	rc =3D rhine_init_one_common(&pdev->dev, quirks,
 				   pioaddr, ioaddr, pdev->irq);
 	if (!rc)
 		return 0;
@@ -1111,7 +1118,7 @@ err_out:
 static int rhine_init_one_platform(struct platform_device *pdev)
 {
 	const struct of_device_id *match;
-	u32 revision;
+	const u32 *quirks;
 	int irq;
 	struct resource *res;
 	void __iomem *ioaddr;
@@ -1129,11 +1136,11 @@ static int rhine_init_one_platform(struct platf=
orm_device *pdev)
 	if (!irq)
 		return -EINVAL;
=20
-	revision =3D (u32)match->data;
-	if (!revision)
+	quirks =3D match->data;
+	if (!quirks)
 		return -EINVAL;
=20
-	return rhine_init_one_common(&pdev->dev, revision,
+	return rhine_init_one_common(&pdev->dev, *quirks,
 				     (long)ioaddr, ioaddr, irq);
 }
=20
@@ -1523,7 +1530,7 @@ static void init_registers(struct net_device *dev=
)
=20
 	rhine_set_rx_mode(dev);
=20
-	if (rp->revision >=3D VT6105M)
+	if (rp->quirks & rqMgmt)
 		rhine_init_cam_filter(dev);
=20
 	napi_enable(&rp->napi);
@@ -2160,7 +2167,7 @@ static void rhine_set_rx_mode(struct net_device *=
dev)
 		/* Too many to match, or accept all multicasts. */
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
-	} else if (rp->revision >=3D VT6105M) {
+	} else if (rp->quirks & rqMgmt) {
 		int i =3D 0;
 		u32 mCAMmask =3D 0;	/* 32 mCAMs (6105M and better) */
 		netdev_for_each_mc_addr(ha, dev) {
@@ -2182,7 +2189,7 @@ static void rhine_set_rx_mode(struct net_device *=
dev)
 		iowrite32(mc_filter[1], ioaddr + MulticastFilter1);
 	}
 	/* enable/disable VLAN receive filtering */
-	if (rp->revision >=3D VT6105M) {
+	if (rp->quirks & rqMgmt) {
 		if (dev->flags & IFF_PROMISC)
 			BYTE_REG_BITS_OFF(BCR1_VIDFR, ioaddr + PCIBusConfig1);
 		else
--=20
1.9.1
