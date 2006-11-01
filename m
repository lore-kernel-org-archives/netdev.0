From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 16/18] e1000: add dynamic itr modes
Date: Wed, 01 Nov 2006 09:52:05 -0800
Message-ID: <20061101175205.2356.39205.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:24336 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946981AbWKARqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:46:19 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add a new dynamic itr algorithm, with 2 modes, and make it the default
operation mode. This greatly reduces latency and increases small packet
performance, at the "cost" of some CPU utilization. Bulk traffic
throughput is unaffected.


The driver can limit the amount of interrupts per second that the
adapter will generate for incoming packets. It does this by writing a
value to the adapter that is based on the maximum amount of interrupts
that the adapter will generate per second.

Setting InterruptThrottleRate to a value greater or equal to 100 will
program the adapter to send out a maximum of that many interrupts per
second, even if more packets have come in. This reduces interrupt
load on the system and can lower CPU utilization under heavy load,
but will increase latency as packets are not processed as quickly.

The default behaviour of the driver previously assumed a static
InterruptThrottleRate value of 8000, providing a good fallback value
for all traffic types,but lacking in small packet performance and
latency. The hardware can handle many more small packets per second
however, and for this reason an adaptive interrupt moderation algorithm
was implemented.

Since 7.3.x, the driver has two adaptive modes (setting 1 or 3) in
which it dynamically adjusts the InterruptThrottleRate value based on
the traffic that it receives. After determining the type of incoming
traffic in the last timeframe, it will adjust the InterruptThrottleRate
to an appropriate value for that traffic.

The algorithm classifies the incoming traffic every interval into
classes.  Once the class is determined, the InterruptThrottleRate
value is adjusted to suit that traffic type the best. There are
three classes defined: "Bulk traffic", for large amounts of packets
of normal size; "Low latency", for small amounts of traffic and/or
a significant percentage of small packets; and "Lowest latency",
for almost completely small packets or minimal traffic.

In dynamic conservative mode, the InterruptThrottleRate value is
set to 4000 for traffic that falls in class "Bulk traffic". If
traffic falls in the "Low latency" or "Lowest latency" class, the
InterruptThrottleRate is increased stepwise to 20000. This default
mode is suitable for most applications.

For situations where low latency is vital such as cluster or
grid computing, the algorithm can reduce latency even more when
InterruptThrottleRate is set to mode 1. In this mode, which operates
the same as mode 3, the InterruptThrottleRate will be increased
stepwise to 70000 for traffic in class "Lowest latency".

Setting InterruptThrottleRate to 0 turns off any interrupt moderation
and may improve small packet latency, but is generally not suitable
for bulk throughput traffic.


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Rick Jones <rick.jones2@hp.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h       |   13 ++
 drivers/net/e1000/e1000_main.c  |  226 ++++++++++++++++++++++++++++++++++-----
 drivers/net/e1000/e1000_param.c |   28 +++--
 3 files changed, 228 insertions(+), 39 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 896ea8a..f091042 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -257,6 +257,17 @@ struct e1000_adapter {
 	spinlock_t tx_queue_lock;
 #endif
 	atomic_t irq_sem;
+	unsigned int detect_link;
+	unsigned int total_tx_bytes;
+	unsigned int total_tx_packets;
+	unsigned int total_rx_bytes;
+	unsigned int total_rx_packets;
+	/* Interrupt Throttle Rate */
+	uint32_t itr;
+	uint32_t itr_setting;
+	uint16_t tx_itr;
+	uint16_t rx_itr;
+
 	struct work_struct reset_task;
 	uint8_t fc_autoneg;
 
@@ -314,8 +325,6 @@ struct e1000_adapter {
 	uint64_t gorcl_old;
 	uint16_t rx_ps_bsize0;
 
-	/* Interrupt Throttle Rate */
-	uint32_t itr;
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b05871a..71524b1 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1897,7 +1897,7 @@ e1000_configure_rx(struct e1000_adapter 
 
 	if (hw->mac_type >= e1000_82540) {
 		E1000_WRITE_REG(hw, RADV, adapter->rx_abs_int_delay);
-		if (adapter->itr > 1)
+		if (adapter->itr_setting != 0)
 			E1000_WRITE_REG(hw, ITR,
 				1000000000 / (adapter->itr * 256));
 	}
@@ -1907,11 +1907,11 @@ e1000_configure_rx(struct e1000_adapter 
 		/* Reset delay timers after every interrupt */
 		ctrl_ext |= E1000_CTRL_EXT_INT_TIMER_CLR;
 #ifdef CONFIG_E1000_NAPI
-		/* Auto-Mask interrupts upon ICR read. */
+		/* Auto-Mask interrupts upon ICR access */
 		ctrl_ext |= E1000_CTRL_EXT_IAME;
+		E1000_WRITE_REG(hw, IAM, 0xffffffff);
 #endif
 		E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
-		E1000_WRITE_REG(hw, IAM, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
 
@@ -2576,19 +2576,6 @@ e1000_watchdog(unsigned long data)
 		}
 	}
 
-	/* Dynamic mode for Interrupt Throttle Rate (ITR) */
-	if (adapter->hw.mac_type >= e1000_82540 && adapter->itr == 1) {
-		/* Symmetric Tx/Rx gets a reduced ITR=2000; Total
-		 * asymmetrical Tx or Rx gets ITR=8000; everyone
-		 * else is between 2000-8000. */
-		uint32_t goc = (adapter->gotcl + adapter->gorcl) / 10000;
-		uint32_t dif = (adapter->gotcl > adapter->gorcl ?
-			adapter->gotcl - adapter->gorcl :
-			adapter->gorcl - adapter->gotcl) / 10000;
-		uint32_t itr = goc > 0 ? (dif * 6000 / goc + 2000) : 8000;
-		E1000_WRITE_REG(&adapter->hw, ITR, 1000000000 / (itr * 256));
-	}
-
 	/* Cause software interrupt to ensure rx ring is cleaned */
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);
 
@@ -2604,6 +2591,135 @@ e1000_watchdog(unsigned long data)
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
+enum latency_range {
+	lowest_latency = 0,
+	low_latency = 1,
+	bulk_latency = 2,
+	latency_invalid = 255
+};
+
+/**
+ * e1000_update_itr - update the dynamic ITR value based on statistics
+ *      Stores a new ITR value based on packets and byte
+ *      counts during the last interrupt.  The advantage of per interrupt
+ *      computation is faster updates and more accurate ITR for the current
+ *      traffic pattern.  Constants in this function were computed
+ *      based on theoretical maximum wire speed and thresholds were set based
+ *      on testing data as well as attempting to minimize response time
+ *      while increasing bulk throughput.
+ *      this functionality is controlled by the InterruptThrottleRate module
+ *      parameter (see e1000_param.c)
+ * @adapter: pointer to adapter
+ * @itr_setting: current adapter->itr
+ * @packets: the number of packets during this measurement interval
+ * @bytes: the number of bytes during this measurement interval
+ **/
+static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
+                                   uint16_t itr_setting,
+                                   int packets,
+                                   int bytes)
+{
+	unsigned int retval = itr_setting;
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (unlikely(hw->mac_type < e1000_82540))
+		goto update_itr_done;
+
+	if (packets == 0)
+		goto update_itr_done;
+
+
+	switch (itr_setting) {
+	case lowest_latency:
+		if ((packets < 5) && (bytes > 512))
+			retval = low_latency;
+		break;
+	case low_latency:  /* 50 usec aka 20000 ints/s */
+		if (bytes > 10000) {
+			if ((packets < 10) ||
+			     ((bytes/packets) > 1200))
+				retval = bulk_latency;
+			else if ((packets > 35))
+				retval = lowest_latency;
+		} else if (packets <= 2 && bytes < 512)
+			retval = lowest_latency;
+		break;
+	case bulk_latency: /* 250 usec aka 4000 ints/s */
+		if (bytes > 25000) {
+			if (packets > 35)
+				retval = low_latency;
+		} else {
+			if (bytes < 6000)
+				retval = low_latency;
+		}
+		break;
+	}
+
+update_itr_done:
+	return retval;
+}
+
+static void e1000_set_itr(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	uint16_t current_itr;
+	uint32_t new_itr = adapter->itr;
+
+	if (unlikely(hw->mac_type < e1000_82540))
+		return;
+
+	/* for non-gigabit speeds, just fix the interrupt rate at 4000 */
+	if (unlikely(adapter->link_speed != SPEED_1000)) {
+		current_itr = 0;
+		new_itr = 4000;
+		goto set_itr_now;
+	}
+
+	adapter->tx_itr = e1000_update_itr(adapter,
+	                            adapter->tx_itr,
+	                            adapter->total_tx_packets,
+	                            adapter->total_tx_bytes);
+	adapter->rx_itr = e1000_update_itr(adapter,
+	                            adapter->rx_itr,
+	                            adapter->total_rx_packets,
+	                            adapter->total_rx_bytes);
+
+	current_itr = max(adapter->rx_itr, adapter->tx_itr);
+
+	/* conservative mode eliminates the lowest_latency setting */
+	if (current_itr == lowest_latency && (adapter->itr_setting == 3))
+		current_itr = low_latency;
+
+	switch (current_itr) {
+	/* counts and packets in update_itr are dependent on these numbers */
+	case lowest_latency:
+		new_itr = 70000;
+		break;
+	case low_latency:
+		new_itr = 20000; /* aka hwitr = ~200 */
+		break;
+	case bulk_latency:
+		new_itr = 4000;
+		break;
+	default:
+		break;
+	}
+
+set_itr_now:
+	if (new_itr != adapter->itr) {
+		/* this attempts to bias the interrupt rate towards Bulk
+		 * by adding intermediate steps when interrupt rate is
+		 * increasing */
+		new_itr = new_itr > adapter->itr ?
+		             min(adapter->itr + (new_itr >> 2), new_itr) :
+		             new_itr;
+		adapter->itr = new_itr;
+		E1000_WRITE_REG(hw, ITR, 1000000000 / (new_itr * 256));
+	}
+
+	return;
+}
+
 #define E1000_TX_FLAGS_CSUM		0x00000001
 #define E1000_TX_FLAGS_VLAN		0x00000002
 #define E1000_TX_FLAGS_TSO		0x00000004
@@ -3538,15 +3654,27 @@ irqreturn_t e1000_intr_msi(int irq, void
 	}
 
 #ifdef CONFIG_E1000_NAPI
-	if (likely(netif_rx_schedule_prep(netdev)))
+	if (likely(netif_rx_schedule_prep(netdev))) {
+		adapter->total_tx_bytes = 0;
+		adapter->total_tx_packets = 0;
+		adapter->total_rx_bytes = 0;
+		adapter->total_rx_packets = 0;
 		__netif_rx_schedule(netdev);
-	else
+	} else
 		e1000_irq_enable(adapter);
 #else
+	adapter->total_tx_bytes = 0;
+	adapter->total_rx_bytes = 0;
+	adapter->total_tx_packets = 0;
+	adapter->total_rx_packets = 0;
+
 	for (i = 0; i < E1000_MAX_INTR; i++)
 		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
 		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
 			break;
+
+	if (likely(adapter->itr_setting & 3))
+		e1000_set_itr(adapter);
 #endif
 
 	return IRQ_HANDLED;
@@ -3568,7 +3696,17 @@ e1000_intr(int irq, void *data)
 	uint32_t rctl, icr = E1000_READ_REG(hw, ICR);
 #ifndef CONFIG_E1000_NAPI
 	int i;
-#else
+#endif
+	if (unlikely(!icr))
+		return IRQ_NONE;  /* Not our interrupt */
+
+#ifdef CONFIG_E1000_NAPI
+	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
+	 * not set, then the adapter didn't send an interrupt */
+	if (unlikely(hw->mac_type >= e1000_82571 &&
+	             !(icr & E1000_ICR_INT_ASSERTED)))
+		return IRQ_NONE;
+
 	/* Interrupt Auto-Mask...upon reading ICR,
 	 * interrupts are masked.  No need for the
 	 * IMC write, but it does mean we should
@@ -3577,14 +3715,6 @@ e1000_intr(int irq, void *data)
 		atomic_inc(&adapter->irq_sem);
 #endif
 
-	if (unlikely(!icr)) {
-#ifdef CONFIG_E1000_NAPI
-		if (hw->mac_type >= e1000_82571)
-			e1000_irq_enable(adapter);
-#endif
-		return IRQ_NONE;  /* Not our interrupt */
-	}
-
 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
 		hw->get_link_status = 1;
 		/* 80003ES2LAN workaround--
@@ -3605,13 +3735,18 @@ e1000_intr(int irq, void *data)
 
 #ifdef CONFIG_E1000_NAPI
 	if (unlikely(hw->mac_type < e1000_82571)) {
+		/* disable interrupts, without the synchronize_irq bit */
 		atomic_inc(&adapter->irq_sem);
 		E1000_WRITE_REG(hw, IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
-	if (likely(netif_rx_schedule_prep(netdev)))
+	if (likely(netif_rx_schedule_prep(netdev))) {
+		adapter->total_tx_bytes = 0;
+		adapter->total_tx_packets = 0;
+		adapter->total_rx_bytes = 0;
+		adapter->total_rx_packets = 0;
 		__netif_rx_schedule(netdev);
-	else
+	} else
 		/* this really should not happen! if it does it is basically a
 		 * bug, but not a hard error, so enable ints and continue */
 		e1000_irq_enable(adapter);
@@ -3631,11 +3766,19 @@ e1000_intr(int irq, void *data)
 		E1000_WRITE_REG(hw, IMC, ~0);
 	}
 
+	adapter->total_tx_bytes = 0;
+	adapter->total_rx_bytes = 0;
+	adapter->total_tx_packets = 0;
+	adapter->total_rx_packets = 0;
+
 	for (i = 0; i < E1000_MAX_INTR; i++)
 		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
 		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
 			break;
 
+	if (likely(adapter->itr_setting & 3))
+		e1000_set_itr(adapter);
+
 	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
 		e1000_irq_enable(adapter);
 
@@ -3683,6 +3826,8 @@ e1000_clean(struct net_device *poll_dev,
 	if ((!tx_cleaned && (work_done == 0)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
+		if (likely(adapter->itr_setting & 3))
+			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev);
 		e1000_irq_enable(adapter);
 		return 0;
@@ -3709,6 +3854,7 @@ e1000_clean_tx_irq(struct e1000_adapter 
 	unsigned int count = 0;
 #endif
 	boolean_t cleaned = FALSE;
+	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
@@ -3720,6 +3866,13 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
 
+			if (cleaned) {
+				/* this packet count is wrong for TSO but has a
+				 * tendency to make dynamic ITR change more
+				 * towards bulk */
+				total_tx_packets++;
+				total_tx_bytes += buffer_info->skb->len;
+			}
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->upper.data = 0;
 
@@ -3785,6 +3938,8 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			netif_stop_queue(netdev);
 		}
 	}
+	adapter->total_tx_bytes += total_tx_bytes;
+	adapter->total_tx_packets += total_tx_packets;
 	return cleaned;
 }
 
@@ -3864,6 +4019,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 	unsigned int i;
 	int cleaned_count = 0;
 	boolean_t cleaned = FALSE;
+	unsigned int total_rx_bytes=0, total_rx_packets=0;
 
 	i = rx_ring->next_to_clean;
 	rx_desc = E1000_RX_DESC(*rx_ring, i);
@@ -3930,6 +4086,10 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		 * done after the TBI_ACCEPT workaround above */
 		length -= 4;
 
+		/* probably a little skewed due to removing CRC */
+		total_rx_bytes += length;
+		total_rx_packets++;
+
 		/* code added for copybreak, this should improve
 		 * performance for small packets with large amounts
 		 * of reassembly being done in the stack */
@@ -3998,6 +4158,8 @@ next_desc:
 	if (cleaned_count)
 		adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
 
+	adapter->total_rx_packets += total_rx_packets;
+	adapter->total_rx_bytes += total_rx_bytes;
 	return cleaned;
 }
 
@@ -4027,6 +4189,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 	uint32_t length, staterr;
 	int cleaned_count = 0;
 	boolean_t cleaned = FALSE;
+	unsigned int total_rx_bytes=0, total_rx_packets=0;
 
 	i = rx_ring->next_to_clean;
 	rx_desc = E1000_RX_DESC_PS(*rx_ring, i);
@@ -4131,6 +4294,9 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 		pskb_trim(skb, skb->len - 4);
 
 copydone:
+		total_rx_bytes += skb->len;
+		total_rx_packets++;
+
 		e1000_rx_checksum(adapter, staterr,
 				  le16_to_cpu(rx_desc->wb.lower.hi_dword.csum_ip.csum), skb);
 		skb->protocol = eth_type_trans(skb, netdev);
@@ -4179,6 +4345,8 @@ next_desc:
 	if (cleaned_count)
 		adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
 
+	adapter->total_rx_packets += total_rx_packets;
+	adapter->total_rx_bytes += total_rx_bytes;
 	return cleaned;
 }
 
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index e4f8892..cbfcd7f 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -139,7 +139,7 @@ E1000_PARAM(XsumRX, "Disable or enable R
  * Valid Range: 0-65535
  */
 E1000_PARAM(TxIntDelay, "Transmit Interrupt Delay");
-#define DEFAULT_TIDV                  64
+#define DEFAULT_TIDV                   8
 #define MAX_TXDELAY               0xFFFF
 #define MIN_TXDELAY                    0
 
@@ -148,7 +148,7 @@ E1000_PARAM(TxIntDelay, "Transmit Interr
  * Valid Range: 0-65535
  */
 E1000_PARAM(TxAbsIntDelay, "Transmit Absolute Interrupt Delay");
-#define DEFAULT_TADV                  64
+#define DEFAULT_TADV                  32
 #define MAX_TXABSDELAY            0xFFFF
 #define MIN_TXABSDELAY                 0
 
@@ -167,16 +167,16 @@ E1000_PARAM(RxIntDelay, "Receive Interru
  * Valid Range: 0-65535
  */
 E1000_PARAM(RxAbsIntDelay, "Receive Absolute Interrupt Delay");
-#define DEFAULT_RADV                 128
+#define DEFAULT_RADV                   8
 #define MAX_RXABSDELAY            0xFFFF
 #define MIN_RXABSDELAY                 0
 
 /* Interrupt Throttle Rate (interrupts/sec)
  *
- * Valid Range: 100-100000 (0=off, 1=dynamic)
+ * Valid Range: 100-100000 (0=off, 1=dynamic, 3=dynamic conservative)
  */
 E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
-#define DEFAULT_ITR                 8000
+#define DEFAULT_ITR                    3
 #define MAX_ITR                   100000
 #define MIN_ITR                      100
 
@@ -472,15 +472,27 @@ e1000_check_options(struct e1000_adapter
 				break;
 			case 1:
 				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
-				        opt.name);
+					opt.name);
+				adapter->itr_setting = adapter->itr;
+				adapter->itr = 20000;
+				break;
+			case 3:
+				DPRINTK(PROBE, INFO,
+				        "%s set to dynamic conservative mode\n",
+					opt.name);
+				adapter->itr_setting = adapter->itr;
+				adapter->itr = 20000;
 				break;
 			default:
 				e1000_validate_option(&adapter->itr, &opt,
-				                      adapter);
+				        adapter);
+				/* save the setting, because the dynamic bits change itr */
+				adapter->itr_setting = adapter->itr;
 				break;
 			}
 		} else {
-			adapter->itr = opt.def;
+			adapter->itr_setting = opt.def;
+			adapter->itr = 20000;
 		}
 	}
 	{ /* Smart Power Down */



---
Auke Kok <auke-jan.h.kok@intel.com>
