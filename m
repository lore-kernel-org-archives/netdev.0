From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 2/5] bcma: convert suspend/resume to pm_ops
Date: Fri, 13 Jan 2012 23:58:39 +0100
Message-ID: <1326495522-6024-2-git-send-email-zajec5@gmail.com>
References: <1326495522-6024-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37946 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab2AMW64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 17:58:56 -0500
Received: by mail-ey0-f174.google.com with SMTP id l12so346245eaa.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 14:58:55 -0800 (PST)
In-Reply-To: <1326495522-6024-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus Torvalds <torvalds@linux-foundation.org>

=2E. and avoid doing the unnecessary PCI operations - the PCI layer wil=
l
do them for us.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/bcma/host_pci.c |   42 ++++++++++++++++-----------------------=
---
 1 files changed, 16 insertions(+), 26 deletions(-)

diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index c1ca9e3..86dfeea 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -235,41 +235,32 @@ static void bcma_host_pci_remove(struct pci_dev *=
dev)
 }
=20
 #ifdef CONFIG_PM
-static int bcma_host_pci_suspend(struct pci_dev *dev, pm_message_t sta=
te)
+static int bcma_host_pci_suspend(struct device *dev)
 {
-	struct bcma_bus *bus =3D pci_get_drvdata(dev);
-
-	/* Host specific */
-	pci_save_state(dev);
-	pci_disable_device(dev);
-	pci_set_power_state(dev, pci_choose_state(dev, state));
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct bcma_bus *bus =3D pci_get_drvdata(pdev);
=20
 	bus->mapped_core =3D NULL;
+
 	return 0;
 }
=20
-static int bcma_host_pci_resume(struct pci_dev *dev)
+static int bcma_host_pci_resume(struct device *dev)
 {
-	struct bcma_bus *bus =3D pci_get_drvdata(dev);
-	int err;
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct bcma_bus *bus =3D pci_get_drvdata(pdev);
=20
-	/* Host specific */
-	pci_set_power_state(dev, 0);
-	err =3D pci_enable_device(dev);
-	if (err)
-		return err;
-	pci_restore_state(dev);
+	return bcma_bus_resume(bus);
+}
=20
-	/* Bus specific */
-	err =3D bcma_bus_resume(bus);
-	if (err)
-		return err;
+static SIMPLE_DEV_PM_OPS(bcma_pm_ops, bcma_host_pci_suspend,
+			 bcma_host_pci_resume);
+#define BCMA_PM_OPS	(&bcma_pm_ops)
=20
-	return 0;
-}
 #else /* CONFIG_PM */
-# define bcma_host_pci_suspend	NULL
-# define bcma_host_pci_resume	NULL
+
+#define BCMA_PM_OPS     NULL
+
 #endif /* CONFIG_PM */
=20
 static DEFINE_PCI_DEVICE_TABLE(bcma_pci_bridge_tbl) =3D {
@@ -287,8 +278,7 @@ static struct pci_driver bcma_pci_bridge_driver =3D=
 {
 	.id_table =3D bcma_pci_bridge_tbl,
 	.probe =3D bcma_host_pci_probe,
 	.remove =3D bcma_host_pci_remove,
-	.suspend =3D bcma_host_pci_suspend,
-	.resume =3D bcma_host_pci_resume,
+	.driver.pm =3D BCMA_PM_OPS,
 };
=20
 int __init bcma_host_pci_init(void)
--=20
1.7.7
