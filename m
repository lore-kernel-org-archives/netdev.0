From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e100 2.6 2/3] trying to pci_alloc before pci_enable
Date: Thu, 25 Sep 2003 18:46:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309251844360.6381-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Some archs don't like calling pci_alloc_consistent before calling 
pci_enable_device.  (Imagine that).  This corrects that.

-----------------

diff -Naurp net-drivers-2.5/drivers/net/e100/e100_main.c net-drivers-2.5/drivers/net/e100.mod/e100_main.c
--- net-drivers-2.5/drivers/net/e100/e100_main.c	2003-09-24 20:34:20.000000000 -0700
+++ net-drivers-2.5/drivers/net/e100.mod/e100_main.c	2003-09-24 20:34:49.000000000 -0700
@@ -584,10 +584,6 @@ e100_found1(struct pci_dev *pcid, const 
 	pci_set_drvdata(pcid, dev);
 	SET_NETDEV_DEV(dev, &pcid->dev);
 
-	if ((rc = e100_alloc_space(bdp)) != 0) {
-		goto err_dev;
-	}
-
 	bdp->flags = 0;
 	bdp->ifs_state = 0;
 	bdp->ifs_value = 0;
@@ -604,7 +600,11 @@ e100_found1(struct pci_dev *pcid, const 
 	bdp->watchdog_timer.function = (void *) &e100_watchdog;
 
 	if ((rc = e100_pci_setup(pcid, bdp)) != 0) {
-		goto err_dealloc;
+		goto err_dev;
+	}
+
+	if ((rc = e100_alloc_space(bdp)) != 0) {
+		goto err_pci;
 	}
 
 	if (((bdp->pdev->device > 0x1030)
@@ -649,7 +649,7 @@ e100_found1(struct pci_dev *pcid, const 
 			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		
 	if ((rc = register_netdev(dev)) != 0) {
-		goto err_pci;
+		goto err_dealloc;
 	}
 
 	e100_check_options(e100nics, bdp);
@@ -700,12 +700,12 @@ e100_found1(struct pci_dev *pcid, const 
 
 err_unregister_netdev:
 	unregister_netdev(dev);
+err_dealloc:
+	e100_dealloc_space(bdp);
 err_pci:
 	iounmap(bdp->scb);
 	pci_release_regions(pcid);
 	pci_disable_device(pcid);
-err_dealloc:
-	e100_dealloc_space(bdp);
 err_dev:
 	pci_set_drvdata(pcid, NULL);
 	kfree(dev);
