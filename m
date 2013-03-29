From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] atl1e: drop pci-msi support because of packet corruption
Date: Fri, 29 Mar 2013 05:10:50 +0100
Message-ID: <20130329041050.GA29040@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rebelyouth.hacklab@gmail.com, xiong@qca.qualcomm.com,
	christian.suenkenberg@student.kit.edu, sven@svenhartge.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37762 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab3C2EKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 00:10:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usage of pci-msi results in corrupted dma packet transfers to the host.

Reported-by: rebelyouth <rebelyouth.hacklab@gmail.com>
Cc: Huang, Xiong <xiong@qca.qualcomm.com>
Tested-by: Christian S=C3=BCnkenberg <christian.suenkenberg@student.kit=
=2Eedu>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
I think this is material for -stable.

 drivers/net/ethernet/atheros/atl1e/atl1e.h      |  1 -
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 19 ++---------------=
--
 2 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e.h b/drivers/net/e=
thernet/atheros/atl1e/atl1e.h
index 829b5ad..edfdf6b 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e.h
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e.h
@@ -438,7 +438,6 @@ struct atl1e_adapter {
 	struct atl1e_hw        hw;
 	struct atl1e_hw_stats  hw_stats;
=20
-	bool have_msi;
 	u32 wol;
 	u16 link_speed;
 	u16 link_duplex;
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/=
net/ethernet/atheros/atl1e/atl1e_main.c
index e1f1b2a..7e0a822 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1847,34 +1847,19 @@ static void atl1e_free_irq(struct atl1e_adapter=
 *adapter)
 	struct net_device *netdev =3D adapter->netdev;
=20
 	free_irq(adapter->pdev->irq, netdev);
-
-	if (adapter->have_msi)
-		pci_disable_msi(adapter->pdev);
 }
=20
 static int atl1e_request_irq(struct atl1e_adapter *adapter)
 {
 	struct pci_dev    *pdev   =3D adapter->pdev;
 	struct net_device *netdev =3D adapter->netdev;
-	int flags =3D 0;
 	int err =3D 0;
=20
-	adapter->have_msi =3D true;
-	err =3D pci_enable_msi(pdev);
-	if (err) {
-		netdev_dbg(netdev,
-			   "Unable to allocate MSI interrupt Error: %d\n", err);
-		adapter->have_msi =3D false;
-	}
-
-	if (!adapter->have_msi)
-		flags |=3D IRQF_SHARED;
-	err =3D request_irq(pdev->irq, atl1e_intr, flags, netdev->name, netde=
v);
+	err =3D request_irq(pdev->irq, atl1e_intr, IRQF_SHARED, netdev->name,
+			  netdev);
 	if (err) {
 		netdev_dbg(adapter->netdev,
 			   "Unable to allocate interrupt Error: %d\n", err);
-		if (adapter->have_msi)
-			pci_disable_msi(pdev);
 		return err;
 	}
 	netdev_dbg(netdev, "atl1e_request_irq OK\n");
--=20
1.8.1.4
