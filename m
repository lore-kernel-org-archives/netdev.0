From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-next-2.6 2/4] be2net: don't rearm mcc cq when device is
 not open
Date: Wed, 17 Feb 2010 17:05:11 +0530
Message-ID: <20100217113511.GA19873@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:23294 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754593Ab0BQLfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:35:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an MCC cmd is issued (via a netdev/ethtool op)
while the device is not open, the MCC CQ gets processed but the EQ
is not processed (as isr is not registered.) This can cause the EQ
to become full. So, while the device is not open, CQ must not be re-armed
to prevent EQ entries.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |   20 ++++++++++++++++++--
 drivers/net/benet/be_cmds.h |    2 ++
 drivers/net/benet/be_main.c |    5 +++++
 4 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 5038c16..2734a41 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -151,6 +151,7 @@ struct be_eq_obj {
 struct be_mcc_obj {
 	struct be_queue_info q;
 	struct be_queue_info cq;
+	bool rearm_cq;
 };
 
 struct be_drvr_stats {
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 477f82b..d7546b4 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -104,10 +104,26 @@ static struct be_mcc_compl *be_mcc_compl_get(struct be_adapter *adapter)
 	return NULL;
 }
 
+void be_async_mcc_enable(struct be_adapter *adapter)
+{
+	spin_lock_bh(&adapter->mcc_cq_lock);
+
+	be_cq_notify(adapter, adapter->mcc_obj.cq.id, true, 0);
+	adapter->mcc_obj.rearm_cq = true;
+
+	spin_unlock_bh(&adapter->mcc_cq_lock);
+}
+
+void be_async_mcc_disable(struct be_adapter *adapter)
+{
+	adapter->mcc_obj.rearm_cq = false;
+}
+
 int be_process_mcc(struct be_adapter *adapter)
 {
 	struct be_mcc_compl *compl;
 	int num = 0, status = 0;
+	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 
 	spin_lock_bh(&adapter->mcc_cq_lock);
 	while ((compl = be_mcc_compl_get(adapter))) {
@@ -120,14 +136,14 @@ int be_process_mcc(struct be_adapter *adapter)
 				(struct be_async_event_link_state *) compl);
 		} else if (compl->flags & CQE_FLAGS_COMPLETED_MASK) {
 				status = be_mcc_compl_process(adapter, compl);
-				atomic_dec(&adapter->mcc_obj.q.used);
+				atomic_dec(&mcc_obj->q.used);
 		}
 		be_mcc_compl_use(compl);
 		num++;
 	}
 
 	if (num)
-		be_cq_notify(adapter, adapter->mcc_obj.cq.id, true, num);
+		be_cq_notify(adapter, mcc_obj->cq.id, mcc_obj->rearm_cq, num);
 
 	spin_unlock_bh(&adapter->mcc_cq_lock);
 	return status;
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 7297b5a..01501db 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -937,6 +937,8 @@ extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 				struct be_dma_mem *nonemb_cmd);
 extern int be_cmd_fw_init(struct be_adapter *adapter);
 extern int be_cmd_fw_clean(struct be_adapter *adapter);
+extern void be_async_mcc_enable(struct be_adapter *adapter);
+extern void be_async_mcc_disable(struct be_adapter *adapter);
 extern int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 				u32 loopback_type, u32 pkt_size,
 				u32 num_pkts, u64 pattern);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7bf1900..43dbe28 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1655,6 +1655,9 @@ static int be_open(struct net_device *netdev)
 	/* Rx compl queue may be in unarmed state; rearm it */
 	be_cq_notify(adapter, adapter->rx_obj.cq.id, true, 0);
 
+	/* Now that interrupts are on we can process async mcc */
+	be_async_mcc_enable(adapter);
+
 	status = be_cmd_link_status_query(adapter, &link_up, &mac_speed,
 			&link_speed);
 	if (status)
@@ -1780,6 +1783,8 @@ static int be_close(struct net_device *netdev)
 
 	cancel_delayed_work_sync(&adapter->work);
 
+	be_async_mcc_disable(adapter);
+
 	netif_stop_queue(netdev);
 	netif_carrier_off(netdev);
 	adapter->link_up = false;
-- 
1.6.3.3

