From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] rx checksum support for gige nForce ethernet
Date: Sat, 07 Aug 2004 13:22:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4114BB8A.3090205@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080903090006010804060905"
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080903090006010804060905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

With help from nVidia I have added rx checksumming to the forcedeth 
driver. It's only supported by the gigabit version of the chipset.

Please test it - it works for me. Depends on the previous patches to 
2.6.8-rc3-mm1, but rejects against 2.6.8-rc3-mm1 should be trivial.

--
    Manfred

--------------080903090006010804060905
Content-Type: text/plain;
 name="patch-forcedeth-rxcheck"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-rxcheck"

// $Header$
// Kernel Version:
//  VERSION = 2
//  PATCHLEVEL = 6
//  SUBLEVEL = 8
//  EXTRAVERSION =-rc3-mm1
--- 2.6/drivers/net/forcedeth.c	2004-08-07 13:09:21.512115128 +0200
+++ build-2.6/drivers/net/forcedeth.c	2004-08-07 13:15:37.308985320 +0200
@@ -78,6 +78,7 @@
  *	0.29: 28 Jul 2004: Add jumbo frame support. Add reset into nv_close,
  *			   previous code clobbered kfree'd memory.
  *	0.30: 07 Aug 2004: Add backup timer for link change notification.
+ *	0.31: 07 Aug 2004: rx checksum support
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -89,7 +90,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.30"
+#define FORCEDETH_VERSION		"0.31"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -219,6 +220,7 @@ enum {
 #define NVREG_TXRXCTL_BIT2	0x0004
 #define NVREG_TXRXCTL_IDLE	0x0008
 #define NVREG_TXRXCTL_RESET	0x0010
+#define NVREG_TXRXCTL_RXCHECK	0x0400
 	NvRegMIIStatus = 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
@@ -315,6 +317,10 @@ struct ring_desc {
 #define NV_RX_ERROR		(1<<30)
 #define NV_RX_AVAIL		(1<<31)
 
+#define NV_RX2_CHECKSUMMASK	(0x1C000000)
+#define NV_RX2_CHECKSUMOK1	(0x10000000)
+#define NV_RX2_CHECKSUMOK2	(0x14000000)
+#define NV_RX2_CHECKSUMOK3	(0x18000000)
 #define NV_RX2_DESCRIPTORVALID	(1<<29)
 #define NV_RX2_SUBSTRACT1	(1<<25)
 #define NV_RX2_ERROR1		(1<<18)
@@ -377,8 +383,15 @@ struct ring_desc {
 #define POLL_WAIT	(1+HZ/100)
 #define LINK_TIMEOUT	(3*HZ)
 
+/* 
+ * desc_ver values:
+ * This field has two purposes:
+ * - Newer nics uses a different ring layout. The layout is selected by
+ *   comparing np->desc_ver with DESC_VER_xy.
+ * - It contains bits that are forced on when writing to NvRegTxRxControl.
+ */
 #define DESC_VER_1	0x0
-#define DESC_VER_2	0x02100
+#define DESC_VER_2	(0x02100|NVREG_TXRXCTL_RXCHECK)
 
 /* PHY defines */
 #define PHY_OUI_MARVELL	0x5043
@@ -1200,6 +1213,15 @@ static void nv_rx_process(struct net_dev
 					goto next_pkt;
 				}
 			}
+			Flags &= NV_RX2_CHECKSUMMASK;
+			if (Flags == NV_RX2_CHECKSUMOK1 ||
+					Flags == NV_RX2_CHECKSUMOK2 ||
+					Flags == NV_RX2_CHECKSUMOK3) {
+				dprintk(KERN_DEBUG "%s: hw checksum hit!.\n", dev->name);
+				np->rx_skbuff[i]->ip_summed = CHECKSUM_UNNECESSARY;
+			} else {
+				dprintk(KERN_DEBUG "%s: hwchecksum miss!.\n", dev->name);
+			}
 		}
 		/* got a valid packet - forward it to the network core */
 		skb = np->rx_skbuff[i];

--------------080903090006010804060905--
