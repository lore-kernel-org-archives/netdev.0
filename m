From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH] net: emaclite: Use platform resource table
Date: Tue,  4 Jun 2013 12:03:27 +0200
Message-ID: <6ece0a9ee777b987ca777a338cc146ed67897529.1370340196.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-1278-1370340207-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:56675 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210Ab3FDKDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 06:03:43 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so5476wgh.30
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 03:03:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-1278-1370340207-0001

Read data directly from platform recource table
and do not use of_irq_to_resource().
Also use devm_request_and_ioremap() for probe
functions simplification.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Based on my discussion with Arnd
"[PATCH] net: emaclite: include linux/of_irq.h"

---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 67 +++++++++------------------
 1 file changed, 22 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index aa14d8a..f87d11c 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1074,13 +1074,14 @@ static int xemaclite_send(struct sk_buff *orig_skb, struct net_device *dev)
  * This function un maps the IO region of the Emaclite device and frees the net
  * device.
  */
-static void xemaclite_remove_ndev(struct net_device *ndev)
+static void xemaclite_remove_ndev(struct net_device *ndev,
+				  struct platform_device *pdev)
 {
 	if (ndev) {
 		struct net_local *lp = netdev_priv(ndev);

 		if (lp->base_addr)
-			iounmap((void __iomem __force *) (lp->base_addr));
+			devm_iounmap(&pdev->dev, lp->base_addr);
 		free_netdev(ndev);
 	}
 }
@@ -1126,8 +1127,7 @@ static struct net_device_ops xemaclite_netdev_ops;
  */
 static int xemaclite_of_probe(struct platform_device *ofdev)
 {
-	struct resource r_irq; /* Interrupt resources */
-	struct resource r_mem; /* IO mem resources */
+	struct resource *res;
 	struct net_device *ndev = NULL;
 	struct net_local *lp = NULL;
 	struct device *dev = &ofdev->dev;
@@ -1137,20 +1137,6 @@ static int xemaclite_of_probe(struct platform_device *ofdev)

 	dev_info(dev, "Device Tree Probing\n");

-	/* Get iospace for the device */
-	rc = of_address_to_resource(ofdev->dev.of_node, 0, &r_mem);
-	if (rc) {
-		dev_err(dev, "invalid address\n");
-		return rc;
-	}
-
-	/* Get IRQ for the device */
-	rc = of_irq_to_resource(ofdev->dev.of_node, 0, &r_irq);
-	if (!rc) {
-		dev_err(dev, "no IRQ found\n");
-		return rc;
-	}
-
 	/* Create an ethernet device instance */
 	ndev = alloc_etherdev(sizeof(struct net_local));
 	if (!ndev)
@@ -1159,29 +1145,25 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 	dev_set_drvdata(dev, ndev);
 	SET_NETDEV_DEV(ndev, &ofdev->dev);

-	ndev->irq = r_irq.start;
-	ndev->mem_start = r_mem.start;
-	ndev->mem_end = r_mem.end;
-
 	lp = netdev_priv(ndev);
 	lp->ndev = ndev;

-	if (!request_mem_region(ndev->mem_start,
-				ndev->mem_end - ndev->mem_start + 1,
-				DRIVER_NAME)) {
-		dev_err(dev, "Couldn't lock memory region at %p\n",
-			(void *)ndev->mem_start);
-		rc = -EBUSY;
-		goto error2;
+	/* Get IRQ for the device */
+	res = platform_get_resource(ofdev, IORESOURCE_IRQ, 0);
+	if (!res) {
+		dev_err(dev, "no IRQ found\n");
+		goto error;
 	}

-	/* Get the virtual base address for the device */
-	lp->base_addr = ioremap(r_mem.start, resource_size(&r_mem));
-	if (NULL == lp->base_addr) {
-		dev_err(dev, "EmacLite: Could not allocate iomem\n");
-		rc = -EIO;
-		goto error1;
-	}
+	ndev->irq = res->start;
+
+	res = platform_get_resource(ofdev, IORESOURCE_MEM, 0);
+	lp->base_addr = devm_request_and_ioremap(&ofdev->dev, res);
+	if (!lp->base_addr)
+		goto error;
+
+	ndev->mem_start = res->start;
+	ndev->mem_end = res->end;

 	spin_lock_init(&lp->reset_lock);
 	lp->next_tx_buf_to_use = 0x0;
@@ -1219,7 +1201,7 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 	if (rc) {
 		dev_err(dev,
 			"Cannot register network device, aborting\n");
-		goto error1;
+		goto error;
 	}

 	dev_info(dev,
@@ -1228,11 +1210,8 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 		 (unsigned int __force)lp->base_addr, ndev->irq);
 	return 0;

-error1:
-	release_mem_region(ndev->mem_start, resource_size(&r_mem));
-
-error2:
-	xemaclite_remove_ndev(ndev);
+error:
+	xemaclite_remove_ndev(ndev, ofdev);
 	return rc;
 }

@@ -1267,9 +1246,7 @@ static int xemaclite_of_remove(struct platform_device *of_dev)
 		of_node_put(lp->phy_node);
 	lp->phy_node = NULL;

-	release_mem_region(ndev->mem_start, ndev->mem_end-ndev->mem_start + 1);
-
-	xemaclite_remove_ndev(ndev);
+	xemaclite_remove_ndev(ndev, of_dev);
 	dev_set_drvdata(dev, NULL);

 	return 0;
--
1.8.2.3


--=_mimegpg-monstr-desktop-1278-1370340207-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGtu28ACgkQykllyylKDCGkZgCeMwrc6Xt4Br8Wc1MXwJ1Itgix
BVwAn0MvjvKvtDqU9wUQUAalPYt8FA8P
=BTIY
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-1278-1370340207-0001--
