From: prasanna.panchamukhi@riverbed.com
Subject: [PATCH] e1000e:  MSI interrupt test failed,
	using legacy interrupt
Date: Thu, 26 Apr 2012 17:05:50 -0700
Message-ID: <1335485150-2765-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	prasanna.panchamukhi@riverbed.com
To: bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	jeffrey.e.pieper@intel.com, bhutchings@solarflare.com, gospo@redhat.com,
	sassmann@redhat.com, jesse.brandeburg@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Prasanna S. Panchamukhi <ppanchamukhi@riverbed.com>

Following logs where seen on Systems with multiple NICs & ports,
while using MSI interrupts as shown below:

Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0d.0: lan0_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: wan0_1: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: lan0_1: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:32 (none) user.warn kernel: 0000:40:0e.0: wan4_0: MSI interrupt
test failed, using legacy interrupt.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0e.0: wan1_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0e.0: lan1_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: wan2_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: lan2_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: wan3_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: lan3_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0e.0: lan4_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: wan5_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: lan5_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX

This patch changes the IRQ tests to use polling loops starting with a
delay of 1 tick and doubling that if necessary up to a maximum total
delay of approximately 1 second.

Signed-off-by: Prasanna S. Panchamukhi <ppanchamukhi@riverbed.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 19ab215..8ff0fff 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -98,6 +98,16 @@ struct e1000_reg_info {
 #define E1000_TDFTS	0x03428	/* Tx Data FIFO Tail Saved - RW */
 #define E1000_TDFPC	0x03430	/* Tx Data FIFO Packet Count - RW */
 
+/* IRQ latency can be enormous because:
+ * - All IRQs may be disabled on a CPU for a *long* time by e.g. a
+ *   slow serial console or an old IDE driver doing error recovery
+ * - The PREEMPT_RT patches mostly deal with this, but also allow a
+ *   tasklet or normal task to be given higher priority than our IRQ
+ *   threads
+ * Try to avoid blaming the hardware for this.
+ */
+#define IRQ_TIMEOUT HZ
+
 static const struct e1000_reg_info e1000_reg_info_tbl[] = {
 
 	/* General Registers */
@@ -3767,6 +3777,7 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
+	unsigned long timeout, wait;
 	int err;
 
 	/* poll_enable hasn't been called yet, so don't need disable */
@@ -3799,12 +3810,20 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 	/* fire an unusual interrupt on the test handler */
 	ew32(ICS, E1000_ICS_RXSEQ);
 	e1e_flush();
-	msleep(50);
-
+	timeout = jiffies + IRQ_TIMEOUT;
+	wait = 1;
+	e_dbg("Waiting for MSI interrupt!\n");
+	do {
+		schedule_timeout_uninterruptible(wait);
+		rmb();
+		if (!(adapter->flags & FLAG_MSI_TEST_FAILED))
+			goto success;
+		wait *= 2;
+	} while (time_before(jiffies, timeout));
+
+success:
 	e1000_irq_disable(adapter);
 
-	rmb();
-
 	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
 		adapter->int_mode = E1000E_INT_MODE_LEGACY;
 		e_info("MSI interrupt test failed, using legacy interrupt.\n");
-- 
1.7.0.4


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
