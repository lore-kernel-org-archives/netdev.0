From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: insert missing iounmap(), add error handling
Date: Fri, 3 Oct 2003 21:29:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003212904.34d4ca01.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test6-current.

Thanks,
--
~Randy



From: Leann Ogasawara <ogasawara@osdl.org>
Subject: Re: [Kernel-janitors] [PATCH] insert missing iounmap()

> > Patch inserts a missing iounmap().  Implements a cleanup path
> > for error handling as well.  Feedback is much appreciated.  Thanks :)



===== drivers/net/natsemi.c 1.55 vs edited =====


 linux-260-test6-kj1-rddunlap/drivers/net/natsemi.c |   39 ++++++++++-----------
 1 files changed, 20 insertions(+), 19 deletions(-)

diff -puN drivers/net/natsemi.c~net_natsemi_iounmap drivers/net/natsemi.c
--- linux-260-test6-kj1/drivers/net/natsemi.c~net_natsemi_iounmap	2003-09-29 17:37:59.000000000 -0700
+++ linux-260-test6-kj1-rddunlap/drivers/net/natsemi.c	2003-09-29 17:37:59.000000000 -0700
@@ -765,19 +765,13 @@ static int __devinit natsemi_probe1 (str
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	i = pci_request_regions(pdev, dev->name);
-	if (i) {
-		free_netdev(dev);
-		return i;
-	}
+	if (i)
+		goto err_pci_request_regions;
 
-	{
-		void *mmio = ioremap (ioaddr, iosize);
-		if (!mmio) {
-			pci_release_regions(pdev);
-			free_netdev(dev);
-			return -ENOMEM;
-		}
-		ioaddr = (unsigned long) mmio;
+	ioaddr = (unsigned long) ioremap (ioaddr, iosize);
+	if (!ioaddr) {
+		i = -ENOMEM;
+		goto err_ioremap;
 	}
 
 	/* Work around the dropped serial bit. */
@@ -835,13 +829,9 @@ static int __devinit natsemi_probe1 (str
 		dev->mtu = mtu;
 
 	i = register_netdev(dev);
-	if (i) {
-		pci_release_regions(pdev);
-		unregister_netdev(dev);
-		free_netdev(dev);
-		pci_set_drvdata(pdev, NULL);
-		return i;
-	}
+	if (i)
+		goto err_register_netdev;
+
 	netif_carrier_off(dev);
 
 	if (netif_msg_drv(np)) {
@@ -878,6 +868,17 @@ static int __devinit natsemi_probe1 (str
 
 
 	return 0;
+
+ err_register_netdev:
+	iounmap ((void *) dev->base_addr);
+
+ err_ioremap:
+	pci_release_regions(pdev);
+	pci_set_drvdata(pdev, NULL);
+
+ err_pci_request_regions:
+	free_netdev(dev);
+	return i;
 }
 
 

_
