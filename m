From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 01/10] sfc: Reorder struct efx_nic to separate
 fields by volatility
Date: Fri, 10 Dec 2010 17:38:07 +0000
Message-ID: <1292002687.11673.15.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26814 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499Ab0LJRiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:38:10 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Place the regularly updated fields (locks, MAC stats, etc.) on a
separate cache-line from fields which are mostly constant.  This
should reduce cache misses for access to the latter on the data path.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |   41 +++++++++++++++++++++++------------------
 1 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 0d19fbf..60d6371 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -625,10 +625,8 @@ struct efx_filter_state;
  *	Work items do not hold and must not acquire RTNL.
  * @workqueue_name: Name of workqueue
  * @reset_work: Scheduled reset workitem
- * @monitor_work: Hardware monitor workitem
  * @membase_phys: Memory BAR value as physical address
  * @membase: Memory BAR value
- * @biu_lock: BIU (bus interface unit) lock
  * @interrupt_mode: Interrupt mode
  * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
  * @irq_rx_moderation: IRQ moderation time for RX event queues
@@ -652,14 +650,9 @@ struct efx_filter_state;
  * @int_error_count: Number of internal errors seen recently
  * @int_error_expire: Time at which error count will be expired
  * @irq_status: Interrupt status buffer
- * @last_irq_cpu: Last CPU to handle interrupt.
- *	This register is written with the SMP processor ID whenever an
- *	interrupt is handled.  It is used by efx_nic_test_interrupt()
- *	to verify that an interrupt has occurred.
  * @irq_zero_count: Number of legacy IRQs seen with queue flags == 0
  * @fatal_irq_level: IRQ level (bit number) used for serious errors
  * @mtd_list: List of MTDs attached to the NIC
- * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
  * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
  *	@port_inhibited, efx_monitor() and efx_reconfigure_port()
@@ -672,11 +665,7 @@ struct efx_filter_state;
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtnl lock
  * @rx_checksum_enabled: RX checksumming enabled
- * @mac_stats: MAC statistics. These include all statistics the MACs
- *	can provide.  Generic code converts these into a standard
- *	&struct net_device_stats.
  * @stats_buffer: DMA buffer for statistics
- * @stats_lock: Statistics update lock. Serialises statistics fetches
  * @mac_op: MAC interface
  * @phy_type: PHY type
  * @phy_op: PHY interface
@@ -694,10 +683,23 @@ struct efx_filter_state;
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
  * @loopback_selftest: Offline self-test private state
+ * @monitor_work: Hardware monitor workitem
+ * @biu_lock: BIU (bus interface unit) lock
+ * @last_irq_cpu: Last CPU to handle interrupt.
+ *	This register is written with the SMP processor ID whenever an
+ *	interrupt is handled.  It is used by efx_nic_test_interrupt()
+ *	to verify that an interrupt has occurred.
+ * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
+ * @mac_stats: MAC statistics. These include all statistics the MACs
+ *	can provide.  Generic code converts these into a standard
+ *	&struct net_device_stats.
+ * @stats_lock: Statistics update lock. Serialises statistics fetches
  *
  * This is stored in the private area of the &struct net_device.
  */
 struct efx_nic {
+	/* The following fields should be written very rarely */
+
 	char name[IFNAMSIZ];
 	struct pci_dev *pci_dev;
 	const struct efx_nic_type *type;
@@ -705,10 +707,9 @@ struct efx_nic {
 	struct workqueue_struct *workqueue;
 	char workqueue_name[16];
 	struct work_struct reset_work;
-	struct delayed_work monitor_work;
 	resource_size_t membase_phys;
 	void __iomem *membase;
-	spinlock_t biu_lock;
+
 	enum efx_int_mode interrupt_mode;
 	bool irq_rx_adaptive;
 	unsigned int irq_rx_moderation;
@@ -735,7 +736,6 @@ struct efx_nic {
 	unsigned long int_error_expire;
 
 	struct efx_buffer irq_status;
-	volatile signed int last_irq_cpu;
 	unsigned irq_zero_count;
 	unsigned fatal_irq_level;
 
@@ -743,8 +743,6 @@ struct efx_nic {
 	struct list_head mtd_list;
 #endif
 
-	unsigned n_rx_nodesc_drop_cnt;
-
 	void *nic_data;
 
 	struct mutex mac_lock;
@@ -756,9 +754,7 @@ struct efx_nic {
 	struct net_device *net_dev;
 	bool rx_checksum_enabled;
 
-	struct efx_mac_stats mac_stats;
 	struct efx_buffer stats_buffer;
-	spinlock_t stats_lock;
 
 	struct efx_mac_operations *mac_op;
 
@@ -784,6 +780,15 @@ struct efx_nic {
 	void *loopback_selftest;
 
 	struct efx_filter_state *filter_state;
+
+	/* The following fields may be written more often */
+
+	struct delayed_work monitor_work ____cacheline_aligned_in_smp;
+	spinlock_t biu_lock;
+	volatile signed int last_irq_cpu;
+	unsigned n_rx_nodesc_drop_cnt;
+	struct efx_mac_stats mac_stats;
+	spinlock_t stats_lock;
 };
 
 static inline int efx_dev_registered(struct efx_nic *efx)
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

