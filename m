From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] kill drivers/net/setup.c
Date: Wed, 4 Jun 2003 20:16:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604181627.GA24733@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The last two drivers are ppc 8xx system devices and Paul (ppc
maintainer) said I should just send this patch along, the 8xx
guys will have to deal with a possible breakage when brining
up their port for 2.5/2.6 again.  (Not that I expect anything
bad to happen..)


--- 1.8/arch/ppc/8260_io/enet.c	Sun Apr 27 13:56:50 2003
+++ edited/arch/ppc/8260_io/enet.c	Tue Jun  3 22:08:59 2003
@@ -608,7 +608,7 @@
 
 /* Initialize the CPM Ethernet on SCC.
  */
-int __init scc_enet_init(void)
+static int __init scc_enet_init(void)
 {
 	struct net_device *dev;
 	struct scc_enet_private *cep;
@@ -860,3 +860,4 @@
 	return 0;
 }
 
+module_init(scc_enet_init);
--- 1.9/arch/ppc/8260_io/fcc_enet.c	Sun Apr 27 13:56:50 2003
+++ edited/arch/ppc/8260_io/fcc_enet.c	Tue Jun  3 22:08:59 2003
@@ -1323,7 +1323,7 @@
 
 /* Initialize the CPM Ethernet on FCC.
  */
-int __init fec_enet_init(void)
+static int __init fec_enet_init(void)
 {
 	struct net_device *dev;
 	struct fcc_enet_private *cep;
@@ -1394,6 +1394,7 @@
 
 	return 0;
 }
+module_init(fec_enet_init);
 
 /* Make sure the device is shut down during initialization.
 */
--- 1.10/arch/ppc/8xx_io/enet.c	Mon Sep 16 06:51:56 2002
+++ edited/arch/ppc/8xx_io/enet.c	Tue Jun  3 22:08:59 2003
@@ -639,7 +639,7 @@
  * transmit and receive to make sure we don't catch the CPM with some
  * inconsistent control information.
  */
-int __init scc_enet_init(void)
+static int __init scc_enet_init(void)
 {
 	struct net_device *dev;
 	struct scc_enet_private *cep;
@@ -964,3 +964,5 @@
 
 	return 0;
 }
+
+module_init(scc_enet_init);
--- 1.13/arch/ppc/8xx_io/fec.c	Tue Dec 31 22:10:48 2002
+++ edited/arch/ppc/8xx_io/fec.c	Tue Jun  3 22:09:00 2003
@@ -1566,7 +1566,7 @@
 
 /* Initialize the FEC Ethernet on 860T.
  */
-int __init fec_enet_init(void)
+static int __init fec_enet_init(void)
 {
 	struct net_device *dev;
 	struct fec_enet_private *fep;
@@ -1782,6 +1782,7 @@
 
 	return 0;
 }
+module_init(fec_enet_init);
 
 /* This function is called to start or restart the FEC during a link
  * change.  This only happens when switching between half and full
--- 1.16/drivers/net/setup.c	Wed Jun  4 07:13:57 2003
+++ edited/drivers/net/setup.c	Tue Jun  3 22:12:10 2003
@@ -1,54 +0,0 @@
-
-/*
- *	New style setup code for the network devices
- */
- 
-#include <linux/config.h>
-#include <linux/netdevice.h>
-#include <linux/errno.h>
-#include <linux/init.h>
-#include <linux/netlink.h>
-
-extern int scc_enet_init(void); 
-extern int fec_enet_init(void); 
-
-/*
- *	Devices in this list must do new style probing. That is they must
- *	allocate their own device objects and do their own bus scans.
- */
-
-struct net_probe
-{
-	int (*probe)(void);
-	int status;	/* non-zero if autoprobe has failed */
-};
- 
-static struct net_probe pci_probes[] __initdata = {
-	/*
-	 *	Early setup devices
-	 */
-#if defined(CONFIG_SCC_ENET)
-        {scc_enet_init, 0},
-#endif
-#if defined(CONFIG_FEC_ENET)
-        {fec_enet_init, 0},
-#endif
-	{NULL, 0},
-};
-
-
-/*
- *	Run the updated device probes. These do not need a device passed
- *	into them.
- */
- 
-void __init net_device_init(void)
-{
-	struct net_probe *p = pci_probes;
-
-	while (p->probe != NULL)
-	{
-		p->status = p->probe();
-		p++;
-	}
-}
--- 1.83/net/core/dev.c	Mon May 26 07:16:23 2003
+++ edited/net/core/dev.c	Tue Jun  3 22:12:01 2003
@@ -2861,15 +2861,8 @@
  *	unhooks any devices that fail to initialise (normally hardware not
  *	present) and leaves us with a valid list of present and active devices.
  *
- */
-
-extern void net_device_init(void);
-extern void ip_auto_config(void);
-
-
-/*
- *       This is called single threaded during boot, so no need
- *       to take the rtnl semaphore.
+ *	This is called single threaded during boot, so no need
+ *	to take the rtnl semaphore.
  */
 static int __init net_dev_init(void)
 {
@@ -3003,7 +2996,6 @@
 	 *	Initialise network devices
 	 */
 
-	net_device_init();
 	rc = 0;
 out:
 	return rc;
