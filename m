From: Alexey Charkov <alchark@gmail.com>
Subject: [PATCH] net: via-rhine: Fix compiler warning re: pointer casting on 64bit
Date: Wed, 30 Apr 2014 16:06:29 +0400
Message-ID: <1398859589-22346-1-git-send-email-alchark@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F702D00@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Charkov <alchark@gmail.com>
To: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>,
	Jan Moskyto Matejka <mq@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F702D00@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ixed different size cast warning:

        drivers/net/ethernet/via/via-rhine.c: In function =E2=80=98rhin=
e_init_one_platform=E2=80=99:
        drivers/net/ethernet/via/via-rhine.c:1132:13: warning: cast fro=
m pointer to integer of different size [-Wpointer-to-int-cast]
          revision =3D (u32)match->data;
                     ^

That code was added in commit 2d283862dc62daead9db0dc89cd0d0351e91f765
("net: via-rhine: add OF bus binding").

This patch removes the cast altogether, and instead stores an actual
pointer to u8 in match->data. All instances of 'revision' are also
unified to u8 instead of an assortment of different integer types,
in line with the definition of 'revision' in struct pci_dev.

Tested in platform configuration on a VIA WM8950 APC Rock board.

Reported-by: Jan Moskyto Matejka <mq@suse.cz>
Signed-off-by: Alexey Charkov <alchark@gmail.com>
---
 drivers/net/ethernet/via/via-rhine.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/etherne=
t/via/via-rhine.c
index 4fa9201..80cdc91 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -287,8 +287,9 @@ MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
  * The .data field is currently only used to store chip revision
  * (for quirks etc.)
  */
+static u8 vt8500_revision =3D 0x84;
 static struct of_device_id rhine_of_tbl[] =3D {
-	{ .compatible =3D "via,vt8500-rhine", .data =3D (void *)0x84 },
+	{ .compatible =3D "via,vt8500-rhine", .data =3D &vt8500_revision },
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(of, rhine_of_tbl);
@@ -459,7 +460,7 @@ struct rhine_private {
 	unsigned char *tx_bufs;
 	dma_addr_t tx_bufs_dma;
=20
-	int revision;
+	u8 revision;
 	int irq;
 	long pioaddr;
 	struct net_device *dev;
@@ -882,7 +883,7 @@ static const struct net_device_ops rhine_netdev_ops=
 =3D {
 #endif
 };
=20
-static int rhine_init_one_common(struct device *hwdev, int revision,
+static int rhine_init_one_common(struct device *hwdev, u8 revision,
 				 long pioaddr, void __iomem *ioaddr, int irq)
 {
 	struct net_device *dev;
@@ -1111,7 +1112,7 @@ err_out:
 static int rhine_init_one_platform(struct platform_device *pdev)
 {
 	const struct of_device_id *match;
-	u32 revision;
+	const u8 *revision;
 	int irq;
 	struct resource *res;
 	void __iomem *ioaddr;
@@ -1129,11 +1130,11 @@ static int rhine_init_one_platform(struct platf=
orm_device *pdev)
 	if (!irq)
 		return -EINVAL;
=20
-	revision =3D (u32)match->data;
+	revision =3D match->data;
 	if (!revision)
 		return -EINVAL;
=20
-	return rhine_init_one_common(&pdev->dev, revision,
+	return rhine_init_one_common(&pdev->dev, *revision,
 				     (long)ioaddr, ioaddr, irq);
 }
=20
--=20
1.9.1
