From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.7] e1000 sparse cleanup
Date: Wed, 16 Jun 2004 15:21:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616152151.0723c468@dell_ss3.pdx.osdl.net>
References: <468F3FDA28AA87429AD807992E22D07E0158A1CD@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "cramerj" <cramerj@intel.com>, "Ronciak, John" <john.ronciak@intel.com>,
        "Jeff Garzik" <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0158A1CD@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following gets rid of warnings from sparse checking tool.
It doesn't like
	"#if X"  when "#ifdef X" is intended
	declaring inline functions before they are used.
--------
diff -Nru a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
--- a/drivers/net/e1000/e1000.h	2004-06-16 15:18:09 -07:00
+++ b/drivers/net/e1000/e1000.h	2004-06-16 15:18:09 -07:00
@@ -82,7 +82,7 @@
 
 #include "e1000_hw.h"
 
-#if DBG
+#ifdef DBG
 #define E1000_DBG(args...) printk(KERN_DEBUG "e1000: " args)
 #else
 #define E1000_DBG(args...)
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	2004-06-16 15:18:09 -07:00
+++ b/drivers/net/e1000/e1000_main.c	2004-06-16 15:18:09 -07:00
@@ -132,8 +132,6 @@
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
-static inline void e1000_irq_disable(struct e1000_adapter *adapter);
-static inline void e1000_irq_enable(struct e1000_adapter *adapter);
 static irqreturn_t e1000_intr(int irq, void *data, struct pt_regs *regs);
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter);
 #ifdef CONFIG_E1000_NAPI
@@ -150,9 +148,6 @@
 void set_ethtool_ops(struct net_device *netdev);
 static void e1000_enter_82542_rst(struct e1000_adapter *adapter);
 static void e1000_leave_82542_rst(struct e1000_adapter *adapter);
-static inline void e1000_rx_checksum(struct e1000_adapter *adapter,
-                                     struct e1000_rx_desc *rx_desc,
-                                     struct sk_buff *skb);
 static void e1000_tx_timeout(struct net_device *dev);
 static void e1000_tx_timeout_task(struct net_device *dev);
 static void e1000_smartspeed(struct e1000_adapter *adapter);
@@ -206,6 +201,35 @@
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
+
+/**
+ * e1000_irq_disable - Mask off interrupt generation on the NIC
+ * @adapter: board private structure
+ **/
+
+static inline void
+e1000_irq_disable(struct e1000_adapter *adapter)
+{
+	atomic_inc(&adapter->irq_sem);
+	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
+	E1000_WRITE_FLUSH(&adapter->hw);
+	synchronize_irq(adapter->pdev->irq);
+}
+
+/**
+ * e1000_irq_enable - Enable default interrupt generation settings
+ * @adapter: board private structure
+ **/
+
+static inline void
+e1000_irq_enable(struct e1000_adapter *adapter)
+{
+	if(atomic_dec_and_test(&adapter->irq_sem)) {
+		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
+		E1000_WRITE_FLUSH(&adapter->hw);
+	}
+}
+
 /**
  * e1000_init_module - Driver Registration Routine
  *
@@ -2047,34 +2071,6 @@
 }
 
 /**
- * e1000_irq_disable - Mask off interrupt generation on the NIC
- * @adapter: board private structure
- **/
-
-static inline void
-e1000_irq_disable(struct e1000_adapter *adapter)
-{
-	atomic_inc(&adapter->irq_sem);
-	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
-	E1000_WRITE_FLUSH(&adapter->hw);
-	synchronize_irq(adapter->pdev->irq);
-}
-
-/**
- * e1000_irq_enable - Enable default interrupt generation settings
- * @adapter: board private structure
- **/
-
-static inline void
-e1000_irq_enable(struct e1000_adapter *adapter)
-{
-	if(atomic_dec_and_test(&adapter->irq_sem)) {
-		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
-		E1000_WRITE_FLUSH(&adapter->hw);
-	}
-}
-
-/**
  * e1000_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
@@ -2219,6 +2215,41 @@
 }
 
 /**
+ * e1000_rx_checksum - Receive Checksum Offload for 82543
+ * @adapter: board private structure
+ * @rx_desc: receive descriptor
+ * @sk_buff: socket buffer with received data
+ **/
+
+static inline void
+e1000_rx_checksum(struct e1000_adapter *adapter,
+                  struct e1000_rx_desc *rx_desc,
+                  struct sk_buff *skb)
+{
+	/* 82543 or newer only */
+	if((adapter->hw.mac_type < e1000_82543) ||
+	/* Ignore Checksum bit is set */
+	(rx_desc->status & E1000_RXD_STAT_IXSM) ||
+	/* TCP Checksum has not been calculated */
+	(!(rx_desc->status & E1000_RXD_STAT_TCPCS))) {
+		skb->ip_summed = CHECKSUM_NONE;
+		return;
+	}
+
+	/* At this point we know the hardware did the TCP checksum */
+	/* now look at the TCP checksum error bit */
+	if(rx_desc->errors & E1000_RXD_ERR_TCPE) {
+		/* let the stack verify checksum errors */
+		skb->ip_summed = CHECKSUM_NONE;
+		adapter->hw_csum_err++;
+	} else {
+	/* TCP checksum is good */
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		adapter->hw_csum_good++;
+	}
+}
+
+/**
  * e1000_clean_rx_irq - Send received data up the network stack,
  * @adapter: board private structure
  **/
@@ -2573,40 +2604,6 @@
 	return E1000_SUCCESS;
 }
 
-/**
- * e1000_rx_checksum - Receive Checksum Offload for 82543
- * @adapter: board private structure
- * @rx_desc: receive descriptor
- * @sk_buff: socket buffer with received data
- **/
-
-static inline void
-e1000_rx_checksum(struct e1000_adapter *adapter,
-                  struct e1000_rx_desc *rx_desc,
-                  struct sk_buff *skb)
-{
-	/* 82543 or newer only */
-	if((adapter->hw.mac_type < e1000_82543) ||
-	/* Ignore Checksum bit is set */
-	(rx_desc->status & E1000_RXD_STAT_IXSM) ||
-	/* TCP Checksum has not been calculated */
-	(!(rx_desc->status & E1000_RXD_STAT_TCPCS))) {
-		skb->ip_summed = CHECKSUM_NONE;
-		return;
-	}
-
-	/* At this point we know the hardware did the TCP checksum */
-	/* now look at the TCP checksum error bit */
-	if(rx_desc->errors & E1000_RXD_ERR_TCPE) {
-		/* let the stack verify checksum errors */
-		skb->ip_summed = CHECKSUM_NONE;
-		adapter->hw_csum_err++;
-	} else {
-	/* TCP checksum is good */
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		adapter->hw_csum_good++;
-	}
-}
 
 void
 e1000_pci_set_mwi(struct e1000_hw *hw)
diff -Nru a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
--- a/drivers/net/e1000/e1000_osdep.h	2004-06-16 15:18:09 -07:00
+++ b/drivers/net/e1000/e1000_osdep.h	2004-06-16 15:18:09 -07:00
@@ -63,7 +63,7 @@
 
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
 
-#if DBG
+#ifdef DBG
 #define DEBUGOUT(S)		printk(KERN_DEBUG S "\n")
 #define DEBUGOUT1(S, A...)	printk(KERN_DEBUG S "\n", A)
 #else
