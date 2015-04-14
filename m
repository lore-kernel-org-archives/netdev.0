From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4vf: Implement mailbox access locking and list management
Date: Tue, 14 Apr 2015 18:00:45 +0530
Message-ID: <1429014645-20361-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23192 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751559AbbDNHSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 03:18:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement queue mechanism using list for avoiding concurrent access to mailbox
and provide fair access to mailbox for all commands being executed

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |  8 ++++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  3 ++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 56 +++++++++++++++++++++-
 3 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 6049f70..15d9440 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -348,6 +348,10 @@ struct sge {
 #define for_each_ethrxq(sge, iter) \
 	for (iter = 0; iter < (sge)->ethqsets; iter++)
 
+struct mbox_list {
+	struct list_head list;
+};
+
 /*
  * Per-"adapter" (Virtual Function) information.
  */
@@ -381,6 +385,10 @@ struct adapter {
 
 	/* various locks */
 	spinlock_t stats_lock;
+
+	/* support for single-threading access to adapter mailbox registers */
+	spinlock_t mbox_lock;
+	struct mbox_list mlist;
 };
 
 enum { /* adapter flags */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 122e296..6ca1540 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2680,6 +2680,9 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 */
 	spin_lock_init(&adapter->stats_lock);
 
+	spin_lock_init(&adapter->mbox_lock);
+	INIT_LIST_HEAD(&adapter->mlist.list);
+
 	/*
 	 * Map our I/O registers in BAR0.
 	 */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 280b4a2..fb4c135 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -125,6 +125,7 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	const __be64 *p;
 	u32 mbox_data = T4VF_MBDATA_BASE_ADDR;
 	u32 mbox_ctl = T4VF_CIM_BASE_ADDR + CIM_VF_EXT_MAILBOX_CTRL;
+	struct mbox_list entry;
 
 	/*
 	 * Commands must be multiples of 16 bytes in length and may not be
@@ -134,6 +135,49 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	    size > NUM_CIM_VF_MAILBOX_DATA_INSTANCES * 4)
 		return -EINVAL;
 
+	/* Queue ourselves onto the mailbox access list.  When our entry is at
+	 * the front of the list, we have rights to access the mailbox.  So we
+	 * wait [for a while] till we're at the front [or bail out with an
+	 * EBUSY] ...
+	 */
+	spin_lock(&adapter->mbox_lock);
+	list_add_tail(&entry.list, &adapter->mlist.list);
+	spin_unlock(&adapter->mbox_lock);
+
+	delay_idx = 0;
+	ms = delay[0];
+
+	for (i = 0; ; i += ms) {
+		/* If we've waited too long, return a busy indication.  This
+		 * really ought to be based on our initial position in the
+		 * mailbox access list but this is a start.  We very rarely
+		 * contend on access to the mailbox ...
+		 */
+		if (i > 4 * FW_CMD_MAX_TIMEOUT) {
+			spin_lock(&adapter->mbox_lock);
+			list_del(&entry.list);
+			spin_unlock(&adapter->mbox_lock);
+			return -EBUSY;
+		}
+
+		/* If we're at the head, break out and start the mailbox
+		 * protocol.
+		 */
+		if (list_first_entry(&adapter->mlist.list,
+				     struct mbox_list, list) == &entry)
+			break;
+
+		/* Delay for a bit before checking again ...*/
+		if (sleep_ok) {
+			ms = delay[delay_idx];  /* last element may repeat */
+			if (delay_idx < ARRAY_SIZE(delay) - 1)
+				delay_idx++;
+			msleep(ms);
+		} else {
+			mdelay(ms);
+		}
+	}
+
 	/*
 	 * Loop trying to get ownership of the mailbox.  Return an error
 	 * if we can't gain ownership.
@@ -141,8 +185,12 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	v = MBOWNER_G(t4_read_reg(adapter, mbox_ctl));
 	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
 		v = MBOWNER_G(t4_read_reg(adapter, mbox_ctl));
-	if (v != MBOX_OWNER_DRV)
+	if (v != MBOX_OWNER_DRV) {
+		spin_lock(&adapter->mbox_lock);
+		list_del(&entry.list);
+		spin_unlock(&adapter->mbox_lock);
 		return v == MBOX_OWNER_FW ? -EBUSY : -ETIMEDOUT;
+	}
 
 	/*
 	 * Write the command array into the Mailbox Data register array and
@@ -218,6 +266,9 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 			}
 			t4_write_reg(adapter, mbox_ctl,
 				     MBOWNER_V(MBOX_OWNER_NONE));
+			spin_lock(&adapter->mbox_lock);
+			list_del(&entry.list);
+			spin_unlock(&adapter->mbox_lock);
 			return -FW_CMD_RETVAL_G(v);
 		}
 	}
@@ -226,6 +277,9 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	 * We timed out.  Return the error ...
 	 */
 	dump_mbox(adapter, "FW Timeout", mbox_data);
+	spin_lock(&adapter->mbox_lock);
+	list_del(&entry.list);
+	spin_unlock(&adapter->mbox_lock);
 	return -ETIMEDOUT;
 }
 
-- 
2.3.4
