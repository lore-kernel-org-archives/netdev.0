From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 1/8 2.5] e1000 - use pci_device_name for syslog messages till
 registering netdevice
Date: Fri, 17 Sep 2004 02:57:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170227530.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000.h linux-2.5/drivers/net/e1000.new/e1000.h
--- linux-2.5/drivers/net/e1000/e1000.h	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000.h	2004-09-09 11:17:12.000000000 -0700
@@ -53,7 +53,6 @@
 #include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/pagemap.h>
-#include <linux/dma-mapping.h>
 #include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -64,7 +63,6 @@
 #include <linux/udp.h>
 #include <net/pkt_sched.h>
 #include <linux/list.h>
-#include <linux/rtnetlink.h>
 #include <linux/reboot.h>
 #ifdef NETIF_F_TSO
 #include <net/checksum.h>
diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-09-09 11:17:12.000000000 -0700
@@ -422,11 +422,6 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->hw.back = adapter;
 	adapter->msg_enable = (1 << debug) - 1;
 
-	rtnl_lock();
-	/* we need to set the name early for the DPRINTK macro */
-	if(dev_alloc_name(netdev, netdev->name) < 0)
-		goto err_free_unlock;
-
 	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
 
@@ -466,6 +461,7 @@ e1000_probe(struct pci_dev *pdev,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e1000_netpoll;
 #endif
+	strcpy(netdev->name, pci_name(pdev));
 
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
@@ -553,7 +543,6 @@ e1000_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
 	e1000_check_options(adapter);
 
 	/* Initial Wake on LAN setting
@@ -586,12 +581,13 @@ e1000_probe(struct pci_dev *pdev,
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
 
-	/* We're already holding the rtnl lock; call the no-lock version */
-	if((err = register_netdevice(netdev)))
+	strcpy(netdev->name, "eth%d");
+	if((err = register_netdev(netdev)))
 		goto err_register;
 
+	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
+
 	cards_found++;
-	rtnl_unlock();
 	return 0;
 
 err_register:
@@ -599,8 +595,6 @@ err_sw_init:
 err_eeprom:
 	iounmap(adapter->hw.hw_addr);
 err_ioremap:
-err_free_unlock:
-	rtnl_unlock();
 	free_netdev(netdev);
 err_alloc_etherdev:
 	pci_release_regions(pdev);
