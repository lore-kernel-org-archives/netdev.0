From: akpm@osdl.org
Subject: [patch 07/13] fix pci_disable_device in 8139too
Date: Tue, 15 Mar 2005 14:22:44 -0800
Message-ID: <200503152222.j2FMMdgg016811@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, dilinger@debian.org
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Andres Salomon <dilinger@debian.org>

http://linux.bkbits.net:8080/linux-2.6/cset@418391928THbmFKdJ5UCOhnFPMYbOA
added an unconditional pci_disable_device() to __rtl8139_cleanup_dev().

That's fine for rtl8139_remove_one and rtl8139_init_one; however, for
rtl8139_init_board, it ends up being called in the error path.  That is, if
pci_enable_device or pci_request_regions fails, err_out calls
__rtl8139_cleanup_dev, which calls pci_disable_device.

I've attached a patch that should fix it.  Not the cleanest thing, but it
should work until we have a higher level pci api in place.

Andres Salomon <dilinger@debian.org>

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/8139too.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff -puN drivers/net/8139too.c~fix-pci_disable_device-in-8139too drivers/net/8139too.c
--- 25/drivers/net/8139too.c~fix-pci_disable_device-in-8139too	Tue Mar 15 14:19:53 2005
+++ 25-akpm/drivers/net/8139too.c	Tue Mar 15 14:19:53 2005
@@ -749,7 +749,6 @@ static void __rtl8139_cleanup_dev (struc
 	pci_release_regions (pdev);
 
 	free_netdev(dev);
-	pci_disable_device(pdev);
 	pci_set_drvdata (pdev, NULL);
 }
 
@@ -778,7 +777,7 @@ static int __devinit rtl8139_init_board 
 	struct net_device *dev;
 	struct rtl8139_private *tp;
 	u8 tmp8;
-	int rc;
+	int rc, disable_dev_on_err = 0;
 	unsigned int i;
 	unsigned long pio_start, pio_end, pio_flags, pio_len;
 	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
@@ -850,6 +849,7 @@ static int __devinit rtl8139_init_board 
 	rc = pci_request_regions (pdev, "8139too");
 	if (rc)
 		goto err_out;
+	disable_dev_on_err = 1;
 
 	/* enable PCI bus-mastering */
 	pci_set_master (pdev);
@@ -935,6 +935,8 @@ match:
 
 err_out:
 	__rtl8139_cleanup_dev (dev);
+	if (disable_dev_on_err)
+		pci_disable_device (pdev);
 	return rc;
 }
 
@@ -1112,6 +1114,7 @@ static int __devinit rtl8139_init_one (s
 
 err_out:
 	__rtl8139_cleanup_dev (dev);
+	pci_disable_device (pdev);
 	return i;
 }
 
@@ -1125,6 +1128,7 @@ static void __devexit rtl8139_remove_one
 	unregister_netdev (dev);
 
 	__rtl8139_cleanup_dev (dev);
+	pci_disable_device (pdev);
 }
 
 
_
