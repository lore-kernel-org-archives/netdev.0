From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 1 2.6.7-rc3-bk6] pcnet32: discard oversize rx packets
Date: Tue, 15 Jun 2004 11:52:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406151852.i5FIqOh20749@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch will discard received frames that are larger than one buffer.
This has been tested on ia32 and ppc64 systems.

Please also apply to 2.4.7 (with offset of -3), tested ia32.

Signed-off by: brazilnut@us.ibm.com

--- linux-2.6.7-rc3-bk6/drivers/net/orig.pcnet32.c	Mon Jun 14 12:19:09 2004
+++ linux-2.6.7-rc3-bk6/drivers/net/pcnet32.c	Tue Jun 15 09:36:43 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30c"
-#define DRV_RELDATE	"05.25.2004"
+#define DRV_VERSION	"1.30d"
+#define DRV_RELDATE	"06.01.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -245,6 +245,7 @@ static int full_duplex[MAX_UNITS];
  * v1.30b  24 May 2004 Don Fry fix bogus tx carrier errors with 79c973,
  *	   assisted by Bruce Penrod <bmpenrod@endruntechnologies.com>.
  * v1.30c  25 May 2004 Don Fry added netif_wake_queue after pcnet32_restart.
+ * v1.30d  01 Jun 2004 Don Fry discard oversize rx packets.
  */
 
 
@@ -1907,7 +1908,13 @@ pcnet32_rx(struct net_device *dev)
 	    short pkt_len = (le32_to_cpu(lp->rx_ring[entry].msg_length) & 0xfff)-4;
 	    struct sk_buff *skb;
 
-	    if (pkt_len < 60) {
+	    /* Discard oversize frames. */
+	    if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
+		if (netif_msg_drv(lp))
+		    printk(KERN_ERR "%s: Impossible packet size %d!\n",
+			    dev->name, pkt_len);
+		lp->stats.rx_errors++;
+	    } else if (pkt_len < 60) {
 		if (netif_msg_rx_err(lp))
 		    printk(KERN_ERR "%s: Runt packet!\n", dev->name);
 		lp->stats.rx_errors++;

-- 
Don Fry
brazilnut@us.ibm.com
