From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e100 2.6 3/3] h/w can't do IPv6 checksum offloading
Date: Thu, 25 Sep 2003 18:48:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309251846280.6381-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Driver was advertising HW_CSUM, but hardware is only capable of IP_CSUM.

-----------

diff -Naurp net-drivers-2.5/drivers/net/e100/e100_main.c net-drivers-2.5/drivers/net/e100.mod/e100_main.c
--- net-drivers-2.5/drivers/net/e100/e100_main.c	2003-09-24 20:34:50.000000000 -0700
+++ net-drivers-2.5/drivers/net/e100.mod/e100_main.c	2003-09-24 20:35:14.000000000 -0700
@@ -46,7 +46,13 @@
 
 /* Change Log
  * 
- * 2.3.18       07/08/03
+ * 2.3.30       09/21/03
+ * o Bug fix (Bugzilla 97908): Loading e100 was causing crash on Itanium2
+ *   with HP chipset
+ * o Bug fix (Bugzilla 101583): e100 can't pass traffic with ipv6
+ * o Bug fix (Bugzilla 101360): PRO/10+ can't pass traffic
+ * 
+ * 2.3.27       08/08/03
  * o Bug fix: read skb->len after freeing skb
  *   [Andrew Morton] akpm@zip.com.au
  * o Bug fix: 82557 (with National PHY) timeout during init
@@ -54,24 +60,6 @@
  * o Feature add: allow to change Wake On LAN when EEPROM disabled
  * 
  * 2.3.13       05/08/03
- * o Feature remove: /proc/net/PRO_LAN_Adapters support gone completely
- * o Feature remove: IDIAG support (use ethtool -t instead)
- * o Cleanup: fixed spelling mistakes found by community
- * o Feature add: ethtool cable diag test
- * o Feature add: ethtool parameter support (ring size, xsum, flow ctrl)
- * o Cleanup: move e100_asf_enable under CONFIG_PM to avoid warning
- *   [Stephen Rothwell (sfr@canb.auug.org.au)]
- * o Bug fix: don't call any netif_carrier_* until netdev registered.
- *   [Andrew Morton (akpm@digeo.com)]
- * o Cleanup: replace (skb->len - skb->data_len) with skb_headlen(skb)
- *   [jmorris@intercode.com.au]
- * o Bug fix: cleanup of Tx skbs after running ethtool diags
- * o Bug fix: incorrect reporting of ethtool diag overall results
- * o Bug fix: must hold xmit_lock before stopping queue in ethtool
- *   operations that require reset h/w and driver structures.
- * o Bug fix: statistic command failure would stop statistic collection.
- * 
- * 2.2.21	02/11/03
  */
  
 #include <linux/config.h>
@@ -137,7 +125,7 @@ static void e100_non_tx_background(unsig
 static inline void e100_tx_skb_free(struct e100_private *bdp, tcb_t *tcb);
 /* Global Data structures and variables */
 char e100_copyright[] __devinitdata = "Copyright (c) 2003 Intel Corporation";
-char e100_driver_version[]="2.3.18-k1";
+char e100_driver_version[]="2.3.30-k1";
 const char *e100_full_driver_name = "Intel(R) PRO/100 Network Driver";
 char e100_short_driver_name[] = "e100";
 static int e100nics = 0;
@@ -645,7 +633,7 @@ e100_found1(struct pci_dev *pcid, const 
 	dev->do_ioctl = &e100_ioctl;
 
 	if (bdp->flags & USE_IPCB)
-	dev->features = NETIF_F_SG | NETIF_F_HW_CSUM |
+	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		
 	if ((rc = register_netdev(dev)) != 0) {
