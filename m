From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 1/6] on-demand stats support
Date: Mon, 2 Feb 2004 14:01:26 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402021334560.6288-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Provide updated stats when requested via ->get_stats or ethtool.
  Previously, driver would only update stats every 2 seconds,
  which would cause some monitoring apps to show zero change
  from one second to the next.

----------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_ethtool.c netdev-2.6/drivers/net/e1000.mod/e1000_ethtool.c
--- netdev-2.6/drivers/net/e1000/e1000_ethtool.c	2004-02-02 12:05:14.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_ethtool.c	2004-02-02 12:05:31.000000000 -0800
@@ -43,6 +43,7 @@ extern int e1000_setup_rx_resources(stru
 extern int e1000_setup_tx_resources(struct e1000_adapter *adapter);
 extern void e1000_free_rx_resources(struct e1000_adapter *adapter);
 extern void e1000_free_tx_resources(struct e1000_adapter *adapter);
+extern void e1000_update_stats(struct e1000_adapter *adapter);
 
 struct e1000_stats {
 	char stat_string[ETH_GSTRING_LEN];
@@ -1604,6 +1605,7 @@ err_geeprom_ioctl:
 		} stats = { {ETHTOOL_GSTATS, E1000_STATS_LEN} };
 		int i;
 
+		e1000_update_stats(adapter);
 		for(i = 0; i < E1000_STATS_LEN; i++)
 			stats.data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
 					sizeof(uint64_t)) ?
diff -Naurp netdev-2.6/drivers/net/e1000/e1000.h netdev-2.6/drivers/net/e1000.mod/e1000.h
--- netdev-2.6/drivers/net/e1000/e1000.h	2004-02-02 12:05:14.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000.h	2004-02-02 12:05:38.000000000 -0800
@@ -206,6 +206,9 @@ struct e1000_adapter {
 	uint32_t tx_int_delay;
 	uint32_t tx_abs_int_delay;
 	uint32_t gotcl;
+	uint64_t gotcl_old;
+	uint64_t tpt_old;
+	uint64_t colc_old;
 	uint32_t tx_fifo_head;
 	uint32_t tx_head_addr;
 	uint32_t tx_fifo_size;
@@ -220,6 +223,7 @@ struct e1000_adapter {
 	uint32_t rx_abs_int_delay;
 	boolean_t rx_csum;
 	uint32_t gorcl;
+	uint64_t gorcl_old;
 
 	/* Interrupt Throttle Rate */
 	uint32_t itr;
diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-02 12:05:14.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-02 12:06:46.000000000 -0800
@@ -119,6 +119,7 @@ int e1000_setup_tx_resources(struct e100
 int e1000_setup_rx_resources(struct e1000_adapter *adapter);
 void e1000_free_tx_resources(struct e1000_adapter *adapter);
 void e1000_free_rx_resources(struct e1000_adapter *adapter);
+void e1000_update_stats(struct e1000_adapter *adapter);
 
 /* Local Function Prototypes */
 
@@ -142,7 +143,6 @@ static int e1000_xmit_frame(struct sk_bu
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
-static void e1000_update_stats(struct e1000_adapter *adapter);
 static inline void e1000_irq_disable(struct e1000_adapter *adapter);
 static inline void e1000_irq_enable(struct e1000_adapter *adapter);
 static irqreturn_t e1000_intr(int irq, void *data, struct pt_regs *regs);
@@ -1392,6 +1392,17 @@ e1000_watchdog(unsigned long data)
 	}
 
 	e1000_update_stats(adapter);
+
+	adapter->hw.tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
+	adapter->tpt_old = adapter->stats.tpt;
+	adapter->hw.collision_delta = adapter->stats.colc - adapter->colc_old;
+	adapter->colc_old = adapter->stats.colc;
+	
+	adapter->gorcl = adapter->stats.gorcl - adapter->gorcl_old;
+	adapter->gorcl_old = adapter->stats.gorcl;
+	adapter->gotcl = adapter->stats.gotcl - adapter->gotcl_old;
+	adapter->gotcl_old = adapter->stats.gotcl;
+
 	e1000_update_adaptive(&adapter->hw);
 
 	if(!netif_carrier_ok(netdev)) {
@@ -1838,6 +1849,7 @@ e1000_get_stats(struct net_device *netde
 {
 	struct e1000_adapter *adapter = netdev->priv;
 
+	e1000_update_stats(adapter);
 	return &adapter->net_stats;
 }
 
@@ -1896,7 +1908,7 @@ e1000_change_mtu(struct net_device *netd
  * @adapter: board private structure
  **/
 
-static void
+void
 e1000_update_stats(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
@@ -1914,8 +1926,7 @@ e1000_update_stats(struct e1000_adapter 
 
 	adapter->stats.crcerrs += E1000_READ_REG(hw, CRCERRS);
 	adapter->stats.gprc += E1000_READ_REG(hw, GPRC);
-	adapter->gorcl = E1000_READ_REG(hw, GORCL);
-	adapter->stats.gorcl += adapter->gorcl;
+	adapter->stats.gorcl += E1000_READ_REG(hw, GORCL);
 	adapter->stats.gorch += E1000_READ_REG(hw, GORCH);
 	adapter->stats.bprc += E1000_READ_REG(hw, BPRC);
 	adapter->stats.mprc += E1000_READ_REG(hw, MPRC);
@@ -1927,8 +1938,6 @@ e1000_update_stats(struct e1000_adapter 
 	adapter->stats.prc1023 += E1000_READ_REG(hw, PRC1023);
 	adapter->stats.prc1522 += E1000_READ_REG(hw, PRC1522);
 
-	spin_unlock_irqrestore(&adapter->stats_lock, flags);
-
 	/* the rest of the counters are only modified here */
 
 	adapter->stats.symerrs += E1000_READ_REG(hw, SYMERRS);
@@ -1946,8 +1955,7 @@ e1000_update_stats(struct e1000_adapter 
 	adapter->stats.xofftxc += E1000_READ_REG(hw, XOFFTXC);
 	adapter->stats.fcruc += E1000_READ_REG(hw, FCRUC);
 	adapter->stats.gptc += E1000_READ_REG(hw, GPTC);
-	adapter->gotcl = E1000_READ_REG(hw, GOTCL);
-	adapter->stats.gotcl += adapter->gotcl;
+	adapter->stats.gotcl += E1000_READ_REG(hw, GOTCL);
 	adapter->stats.gotch += E1000_READ_REG(hw, GOTCH);
 	adapter->stats.rnbc += E1000_READ_REG(hw, RNBC);
 	adapter->stats.ruc += E1000_READ_REG(hw, RUC);
@@ -2029,6 +2037,8 @@ e1000_update_stats(struct e1000_adapter 
 		   !e1000_read_phy_reg(hw, M88E1000_RX_ERR_CNTR, &phy_tmp))
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
+
+	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 
 /**
