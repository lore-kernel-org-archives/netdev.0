From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/8]  2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:12:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327031219.B31053@electric-eye.fr.zoreil.com>
References: <20040327030853.A30849@electric-eye.fr.zoreil.com> <20040327031131.A31053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040327031131.A31053@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 27, 2004 at 03:11:31AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Balance the call to pci_enable_device() in SiS190_init_one() with a call
to pci_disable_device() in SiS190_remove_one().


 drivers/net/sis190.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff -puN drivers/net/sis190.c~sis190-missing-pci-disable-device drivers/net/sis190.c
--- linux-2.6.5-rc2/drivers/net/sis190.c~sis190-missing-pci-disable-device	2004-03-26 23:16:58.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/sis190.c	2004-03-26 23:16:58.000000000 +0100
@@ -435,6 +435,18 @@ ReadEEprom(void *ioaddr, u32 RegAddr)
 	return data;
 }
 
+static void SiS190_release_board(struct pci_dev *pdev, struct net_device *dev)
+{
+	struct sis190_private *tp = dev->priv;
+
+	assert(tp != NULL);
+
+	iounmap(tp->mmio_addr);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	free_netdev(dev);
+}
+
 static int __devinit
 SiS190_init_board(struct pci_dev *pdev, struct net_device **dev_out,
 		  void **ioaddr_out)
@@ -599,10 +611,7 @@ SiS190_init_one(struct pci_dev *pdev, co
 	spin_lock_init(&tp->lock);
 	rc = register_netdev(dev);
 	if (rc) {
-		iounmap(ioaddr);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		free_netdev(dev);
+		SiS190_release_board(pdev, dev);
 		return rc;
 	}
 
@@ -694,16 +703,13 @@ static void __devexit
 SiS190_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct sis190_private *tp = (struct sis190_private *) (dev->priv);
 
 	assert(dev != NULL);
-	assert(tp != NULL);
 
 	unregister_netdev(dev);
-	iounmap(tp->mmio_addr);
-	pci_release_regions(pdev);
 
-	free_netdev(dev);
+	SiS190_release_board(pdev, dev);
+
 	pci_set_drvdata(pdev, NULL);
 }
 

_
