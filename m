From: Manfred Spraul <manfred@colorfullife.com>
Subject: [patch] forcedeth: add support for interrupt mitigation
Date: Fri, 21 Oct 2005 20:13:57 +0200
Message-ID: <43592FE5.20106@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090502010808050204090705"
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090502010808050204090705
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

The current forcedeth driver doesn't support interrupt mitigation, this 
can result in an incredible number of interrupts/sec for gigabit links. 
The attached patch adds a throughput mode that enables an interrupt 
mitigation scheme.


--
    Manfred

--------------090502010808050204090705
Content-Type: text/plain;
 name="patch-forcedeth-046-optimization-mode"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-046-optimization-mode"

--- 2.6/drivers/net/forcedeth.c	2005-10-20 23:17:24.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-10-19 21:01:55.000000000 +0200
@@ -98,6 +98,7 @@
  *	0.43: 10 Aug 2005: Add support for tx checksum.
  *	0.44: 20 Aug 2005: Add support for scatter gather and segmentation.
  *	0.45: 18 Sep 2005: Remove nv_stop/start_rx from every link check
+ *	0.46: 20 Aug 2005: Add irq optimization modes.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -109,7 +110,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.45"
+#define FORCEDETH_VERSION		"0.46"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -164,7 +165,8 @@
 #define NVREG_IRQ_LINK			0x0040
 #define NVREG_IRQ_TX_ERROR		0x0080
 #define NVREG_IRQ_TX1			0x0100
-#define NVREG_IRQMASK_WANTED		0x00df
+#define NVREG_IRQMASK_THROUGHPUT	0x00df
+#define NVREG_IRQMASK_CPU		0x0040
 
 #define NVREG_IRQ_UNKNOWN	(~(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR| \
 					NVREG_IRQ_TX_OK|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_TX_ERROR| \
@@ -178,7 +180,8 @@
  * NVREG_POLL_DEFAULT=97 would result in an interval length of 1 ms
  */
 	NvRegPollingInterval = 0x00c,
-#define NVREG_POLL_DEFAULT	970
+#define NVREG_POLL_DEFAULT_THROUGHPUT	970
+#define NVREG_POLL_DEFAULT_CPU	13
 	NvRegMisc1 = 0x080,
 #define NVREG_MISC1_HD		0x02
 #define NVREG_MISC1_FORCE	0x3b0f3c
@@ -539,6 +542,18 @@
  */
 static int max_interrupt_work = 5;
 
+/*
+ * Optimization can be either throuput mode or cpu mode
+ */
+#define NV_OPTIMIZATION_MODE_THROUGHPUT 0
+#define NV_OPTIMIZATION_MODE_CPU        1
+static int optimization_mode = NV_OPTIMIZATION_MODE_THROUGHPUT;
+
+/*
+ * Poll interval for timer irq
+ */
+static int poll_interval = -1;
+
 static inline struct fe_priv *get_nvpriv(struct net_device *dev)
 {
 	return netdev_priv(dev);
@@ -1330,67 +1345,71 @@
 			if (!(Flags & NV_RX_DESCRIPTORVALID))
 				goto next_pkt;
 
-			if (Flags & NV_RX_MISSEDFRAME) {
-				np->stats.rx_missed_errors++;
-				np->stats.rx_errors++;
-				goto next_pkt;
-			}
-			if (Flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3)) {
-				np->stats.rx_errors++;
-				goto next_pkt;
-			}
-			if (Flags & NV_RX_CRCERR) {
-				np->stats.rx_crc_errors++;
-				np->stats.rx_errors++;
-				goto next_pkt;
-			}
-			if (Flags & NV_RX_OVERFLOW) {
-				np->stats.rx_over_errors++;
-				np->stats.rx_errors++;
-				goto next_pkt;
-			}
-			if (Flags & NV_RX_ERROR4) {
-				len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
-				if (len < 0) {
+			if (Flags & NV_RX_ERROR) {
+				if (Flags & NV_RX_MISSEDFRAME) {
+					np->stats.rx_missed_errors++;
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-			}
-			/* framing errors are soft errors. */
-			if (Flags & NV_RX_FRAMINGERR) {
-				if (Flags & NV_RX_SUBSTRACT1) {
-					len--;
+				if (Flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3)) {
+					np->stats.rx_errors++;
+					goto next_pkt;
+				}
+				if (Flags & NV_RX_CRCERR) {
+					np->stats.rx_crc_errors++;
+					np->stats.rx_errors++;
+					goto next_pkt;
+				}
+				if (Flags & NV_RX_OVERFLOW) {
+					np->stats.rx_over_errors++;
+					np->stats.rx_errors++;
+					goto next_pkt;
+				}
+				if (Flags & NV_RX_ERROR4) {
+					len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
+					if (len < 0) {
+						np->stats.rx_errors++;
+						goto next_pkt;
+					}
+				}
+				/* framing errors are soft errors. */
+				if (Flags & NV_RX_FRAMINGERR) {
+					if (Flags & NV_RX_SUBSTRACT1) {
+						len--;
+					}
 				}
 			}
 		} else {
 			if (!(Flags & NV_RX2_DESCRIPTORVALID))
 				goto next_pkt;
 
-			if (Flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
-				np->stats.rx_errors++;
-				goto next_pkt;
-			}
-			if (Flags & NV_RX2_CRCERR) {
-				np->stats.rx_crc_errors++;
-				np->stats.rx_errors++;
-				goto next_pkt;
-			}
-			if (Flags & NV_RX2_OVERFLOW) {
-				np->stats.rx_over_errors++;
-				np->stats.rx_errors++;
-				goto next_pkt;
-			}
-			if (Flags & NV_RX2_ERROR4) {
-				len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
-				if (len < 0) {
+			if (Flags & NV_RX2_ERROR) {
+				if (Flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-			}
-			/* framing errors are soft errors */
-			if (Flags & NV_RX2_FRAMINGERR) {
-				if (Flags & NV_RX2_SUBSTRACT1) {
-					len--;
+				if (Flags & NV_RX2_CRCERR) {
+					np->stats.rx_crc_errors++;
+					np->stats.rx_errors++;
+					goto next_pkt;
+				}
+				if (Flags & NV_RX2_OVERFLOW) {
+					np->stats.rx_over_errors++;
+					np->stats.rx_errors++;
+					goto next_pkt;
+				}
+				if (Flags & NV_RX2_ERROR4) {
+					len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
+					if (len < 0) {
+						np->stats.rx_errors++;
+						goto next_pkt;
+					}
+				}
+				/* framing errors are soft errors */
+				if (Flags & NV_RX2_FRAMINGERR) {
+					if (Flags & NV_RX2_SUBSTRACT1) {
+						len--;
+					}
 				}
 			}
 			Flags &= NV_RX2_CHECKSUMMASK;
@@ -1810,22 +1829,18 @@
 		if (!(events & np->irqmask))
 			break;
 
-		if (events & (NVREG_IRQ_TX1|NVREG_IRQ_TX_OK|NVREG_IRQ_TX_ERROR|NVREG_IRQ_TX_ERR)) {
+		spin_lock(&np->lock);
+		nv_tx_done(dev);
+		spin_unlock(&np->lock);
+		
+		nv_rx_process(dev);
+		if (nv_alloc_rx(dev)) {
 			spin_lock(&np->lock);
-			nv_tx_done(dev);
+			if (!np->in_shutdown)
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 			spin_unlock(&np->lock);
 		}
-
-		if (events & (NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF)) {
-			nv_rx_process(dev);
-			if (nv_alloc_rx(dev)) {
-				spin_lock(&np->lock);
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
-			}
-		}
-
+		
 		if (events & NVREG_IRQ_LINK) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
@@ -2226,7 +2241,14 @@
 	writel(NVREG_RNDSEED_FORCE | (i&NVREG_RNDSEED_MASK), base + NvRegRandomSeed);
 	writel(NVREG_UNKSETUP1_VAL, base + NvRegUnknownSetupReg1);
 	writel(NVREG_UNKSETUP2_VAL, base + NvRegUnknownSetupReg2);
-	writel(NVREG_POLL_DEFAULT, base + NvRegPollingInterval);
+	if (poll_interval == -1) {
+		if (optimization_mode == NV_OPTIMIZATION_MODE_THROUGHPUT)
+			writel(NVREG_POLL_DEFAULT_THROUGHPUT, base + NvRegPollingInterval);
+		else
+			writel(NVREG_POLL_DEFAULT_CPU, base + NvRegPollingInterval);
+	}
+	else
+		writel(poll_interval, base + NvRegPollingInterval);
 	writel(NVREG_UNKSETUP6_VAL, base + NvRegUnknownSetupReg6);
 	writel((np->phyaddr << NVREG_ADAPTCTL_PHYSHIFT)|NVREG_ADAPTCTL_PHYVALID|NVREG_ADAPTCTL_RUNNING,
 			base + NvRegAdapterControl);
@@ -2510,7 +2532,11 @@
 	} else {
 		np->tx_flags = NV_TX2_VALID;
 	}
-	np->irqmask = NVREG_IRQMASK_WANTED;
+	if (optimization_mode == NV_OPTIMIZATION_MODE_THROUGHPUT)
+		np->irqmask = NVREG_IRQMASK_THROUGHPUT;
+	else
+		np->irqmask = NVREG_IRQMASK_CPU;
+
 	if (id->driver_data & DEV_NEED_TIMERIRQ)
 		np->irqmask |= NVREG_IRQ_TIMER;
 	if (id->driver_data & DEV_NEED_LINKTIMER) {
@@ -2698,6 +2724,10 @@
 
 module_param(max_interrupt_work, int, 0);
 MODULE_PARM_DESC(max_interrupt_work, "forcedeth maximum events handled per interrupt");
+module_param(optimization_mode, int, 0);
+MODULE_PARM_DESC(optimization_mode, "forcedeth optimization for througput (0) or cpu (1) mode");
+module_param(poll_interval, int, 0);
+MODULE_PARM_DESC(poll_interval, "forcedeth polling interval for timer irq");
 
 MODULE_AUTHOR("Manfred Spraul <manfred@colorfullife.com>");
 MODULE_DESCRIPTION("Reverse Engineered nForce ethernet driver");

--------------090502010808050204090705--
