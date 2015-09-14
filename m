From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net] cxgb4vf: support for single-threading access to adapter mailbox registers
Date: Mon, 14 Sep 2015 19:08:34 +0530
Message-ID: <1442237914-9011-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25892 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750944AbbINNiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 09:38:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue is the for the Virtual Function Driver, the only way to get the
Virtual Interface statistics is to issue mailbox commands to ask the
firmware for the VI Stats. And, because the VI Stats command can only
retrieve a smallish number of stats per mailbox command, we have to issue
three mailbox commands in quick succession. What we ran into was irqbalance
coming in every 10 seconds and interrogating every network interface in the
system.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
V2: Updated description and using linux completion API's instead of
    for loop based on review comments by David Miller

 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |  9 +++++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  4 ++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 46 +++++++++++++++++++++-
 3 files changed, 58 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 6049f70..45b2768 100644
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
@@ -381,6 +385,11 @@ struct adapter {
 
 	/* various locks */
 	spinlock_t stats_lock;
+
+	/* support for single-threading access to adapter mailbox registers */
+	spinlock_t mbox_lock;
+	struct mbox_list mlist;
+	struct completion mbox_completion;
 };
 
 enum { /* adapter flags */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index b2b5e5b..bd5799b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2681,6 +2681,10 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 */
 	spin_lock_init(&adapter->stats_lock);
 
+	spin_lock_init(&adapter->mbox_lock);
+	INIT_LIST_HEAD(&adapter->mlist.list);
+	init_completion(&adapter->mbox_completion);
+
 	/*
 	 * Map our I/O registers in BAR0.
 	 */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 63dd5fd..08b730f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -34,6 +34,7 @@
  */
 
 #include <linux/pci.h>
+#include <linux/completion.h>
 
 #include "t4vf_common.h"
 #include "t4vf_defs.h"
@@ -125,6 +126,7 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	const __be64 *p;
 	u32 mbox_data = T4VF_MBDATA_BASE_ADDR;
 	u32 mbox_ctl = T4VF_CIM_BASE_ADDR + CIM_VF_EXT_MAILBOX_CTRL;
+	struct mbox_list entry;
 
 	/*
 	 * Commands must be multiples of 16 bytes in length and may not be
@@ -134,6 +136,37 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
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
+	/* If we're at the head, break out and start the mailbox
+	 * protocol.
+	 */
+	if (list_first_entry(&adapter->mlist.list,
+			     struct mbox_list, list) != &entry) {
+		int ret;
+
+		ret = wait_for_completion_timeout(&adapter->mbox_completion,
+						  4 * FW_CMD_MAX_TIMEOUT);
+		/* If we've waited too long, return a busy indication.  This
+		 * really ought to be based on our initial position in the
+		 * mailbox access list but this is a start.  We very rearely
+		 * contend on access to the mailbox ...
+		 */
+		if (ret) {
+			spin_lock(&adapter->mbox_lock);
+			list_del(&entry.list);
+			spin_unlock(&adapter->mbox_lock);
+			return -EBUSY;
+		}
+	}
+
 	/*
 	 * Loop trying to get ownership of the mailbox.  Return an error
 	 * if we can't gain ownership.
@@ -141,8 +174,12 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
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
@@ -218,6 +255,10 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 			}
 			t4_write_reg(adapter, mbox_ctl,
 				     MBOWNER_V(MBOX_OWNER_NONE));
+			spin_lock(&adapter->mbox_lock);
+			list_del(&entry.list);
+			spin_unlock(&adapter->mbox_lock);
+			complete(&adapter->mbox_completion);
 			return -FW_CMD_RETVAL_G(v);
 		}
 	}
@@ -226,6 +267,9 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
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
