From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.6-bk8] pcnet32: limit frames received during interrupt.
Date: Sat, 22 May 2004 15:22:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405222222.i4MMMJ512917@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The current code will allow an infinite number of frames to be received
during one interrupt.  Tested ia32 and ppc64.

--- linux-2.6.6-bk8/drivers/net/ltint.pcnet32.c	Fri May 21 15:09:56 2004
+++ linux-2.6.6-bk8/drivers/net/pcnet32.c	Sat May 22 13:23:24 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30"
-#define DRV_RELDATE	"05.18.2004"
+#define DRV_VERSION	"1.30a"
+#define DRV_RELDATE	"05.22.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -86,7 +86,7 @@
 
 static struct net_device *pcnet32_dev;
 
-static int max_interrupt_work = 80;
+static int max_interrupt_work = 2;
 static int rx_copybreak = 200;
 
 #define PCNET32_PORT_AUI      0x00
@@ -241,6 +241,7 @@
  *	   forever.
  * v1.30   18 May 2004 Don Fry removed timer and Last Transmit Interrupt
  *	   (ltint) as they added complexity and didn't give good throughput.
+ * v1.30a  22 May 2004 Don Fry limit frames received during interrupt.
  */
 
 
@@ -1860,6 +1861,7 @@
 {
     struct pcnet32_private *lp = dev->priv;
     int entry = lp->cur_rx & RX_RING_MOD_MASK;
+    int boguscnt = RX_RING_SIZE / 2;
 
     /* If we own the next entry, it's a new packet. Send it up. */
     while ((short)le16_to_cpu(lp->rx_ring[entry].status) >= 0) {
@@ -1962,6 +1964,7 @@
 	wmb(); /* Make sure owner changes after all others are visible */
 	lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
 	entry = (++lp->cur_rx) & RX_RING_MOD_MASK;
+	if (--boguscnt <= 0) break;	/* don't stay in loop forever */
     }
 
     return 0;
-- 
Don Fry
brazilnut@us.ibm.com
