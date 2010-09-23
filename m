From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] e1000: use work queues
Date: Wed, 22 Sep 2010 21:22:17 -0700
Message-ID: <20100923042126.11798.49675.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:39000
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751340Ab0IWEWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:22:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

E1000 is using several timers that in a follow on patch
will need to acquire the rtnl_lock in order to be safe.

This patch moves the timer bodies into work queues which
will allow the next patch to add rtnl_lock.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h      |    3 +++
 drivers/net/e1000/e1000_main.c |   25 ++++++++++++++++++++++++-
 2 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 99288b9..a881dd0 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -310,6 +310,9 @@ struct e1000_adapter {
 	int need_ioport;
 
 	bool discarding;
+
+	struct work_struct fifo_stall_task;
+	struct work_struct phy_info_task;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index a1dacea..5b4c6c0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -123,8 +123,10 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
                                 struct e1000_rx_ring *rx_ring);
 static void e1000_set_rx_mode(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
+static void e1000_update_phy_info_task(struct work_struct *work);
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
+static void e1000_82547_tx_fifo_stall_task(struct work_struct *work);
 static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
@@ -1047,7 +1049,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->phy_info_timer.function = e1000_update_phy_info;
 	adapter->phy_info_timer.data = (unsigned long)adapter;
 
+	INIT_WORK(&adapter->fifo_stall_task, e1000_82547_tx_fifo_stall_task);
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
+	INIT_WORK(&adapter->phy_info_task, e1000_update_phy_info_task);
 
 	e1000_check_options(adapter);
 
@@ -2234,6 +2238,14 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 static void e1000_update_phy_info(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
+	schedule_work(&adapter->phy_info_task);
+}
+
+static void e1000_update_phy_info_task(struct work_struct *work)
+{
+	struct e1000_adapter *adapter = container_of(work,
+	                                             struct e1000_adapter,
+	                                             phy_info_task);
 	struct e1000_hw *hw = &adapter->hw;
 	e1000_phy_get_info(hw, &adapter->phy_info);
 }
@@ -2242,10 +2254,21 @@ static void e1000_update_phy_info(unsigned long data)
  * e1000_82547_tx_fifo_stall - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
-
 static void e1000_82547_tx_fifo_stall(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
+	schedule_work(&adapter->fifo_stall_task);
+}
+
+/**
+ * e1000_82547_tx_fifo_stall_task - task to complete work
+ * @work: work struct contained inside adapter struct
+ **/
+static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
+{
+	struct e1000_adapter *adapter = container_of(work,
+	                                             struct e1000_adapter,
+	                                             fifo_stall_task);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	u32 tctl;

