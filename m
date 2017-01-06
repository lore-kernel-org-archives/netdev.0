From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next] cxgb4: Synchronize access to mailbox
Date: Fri,  6 Jan 2017 08:47:20 +0530
Message-ID: <1483672640-18185-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        ganeshgr@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:58989 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935363AbdAFEDW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 23:03:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue comes when there are multiple threads attempting to use
the mailbox facility at the same time.
When DCB operations and interface up/down is run in a loop for every
0.1 sec, we observed mailbox collisions. And out of the two commands
one would fail with the present code, since we don't queue the second
command.

To overcome the above issue, added a queue to access the mailbox.
Whenever a mailbox command is issued add it to the queue. If its at
the head issue the mailbox command, else wait for the existing command
to complete. Usually command takes less than a milli-second to
complete.

Also timeout from the loop, if the command under execution takes
long time to run.

In reality, the number of mailbox access collisions is going to be
very rare since no one runs such abusive script.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  8 ++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  3 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 59 ++++++++++++++++++++++++-
 3 files changed, 69 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 0bce1bf9ca0f..78a852c72f5d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -782,6 +782,10 @@ struct vf_info {
 	bool pf_set_mac;
 };
 
+struct mbox_list {
+	struct list_head list;
+};
+
 struct adapter {
 	void __iomem *regs;
 	void __iomem *bar2;
@@ -844,6 +848,10 @@ struct adapter {
 	struct work_struct db_drop_task;
 	bool tid_release_task_busy;
 
+	/* lock for mailbox cmd list */
+	spinlock_t mbox_lock;
+	struct mbox_list mlist;
+
 	/* support for mailbox command/reply logging */
 #define T4_OS_LOG_MBOX_CMDS 256
 	struct mbox_cmd_log *mbox_log;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6f951877430b..9d2fe5140b88 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4707,6 +4707,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&adapter->stats_lock);
 	spin_lock_init(&adapter->tid_release_lock);
 	spin_lock_init(&adapter->win0_lock);
+	spin_lock_init(&adapter->mbox_lock);
+
+	INIT_LIST_HEAD(&adapter->mlist.list);
 
 	INIT_WORK(&adapter->tid_release_task, process_tid_release_list);
 	INIT_WORK(&adapter->db_full_task, process_db_full);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index e8139514d32c..7ac6ea531b0f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -284,6 +284,7 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 		1, 1, 3, 5, 10, 10, 20, 50, 100, 200
 	};
 
+	struct mbox_list entry;
 	u16 access = 0;
 	u16 execute = 0;
 	u32 v;
@@ -311,11 +312,61 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 		timeout = -timeout;
 	}
 
+	/* Queue ourselves onto the mailbox access list.  When our entry is at
+	 * the front of the list, we have rights to access the mailbox.  So we
+	 * wait [for a while] till we're at the front [or bail out with an
+	 * EBUSY] ...
+	 */
+	spin_lock(&adap->mbox_lock);
+	list_add_tail(&entry.list, &adap->mlist.list);
+	spin_unlock(&adap->mbox_lock);
+
+	delay_idx = 0;
+	ms = delay[0];
+
+	for (i = 0; ; i += ms) {
+		/* If we've waited too long, return a busy indication.  This
+		 * really ought to be based on our initial position in the
+		 * mailbox access list but this is a start.  We very rearely
+		 * contend on access to the mailbox ...
+		 */
+		if (i > FW_CMD_MAX_TIMEOUT) {
+			spin_lock(&adap->mbox_lock);
+			list_del(&entry.list);
+			spin_unlock(&adap->mbox_lock);
+			ret = -EBUSY;
+			t4_record_mbox(adap, cmd, size, access, ret);
+			return ret;
+		}
+
+		/* If we're at the head, break out and start the mailbox
+		 * protocol.
+		 */
+		if (list_first_entry(&adap->mlist.list, struct mbox_list,
+				     list) == &entry)
+			break;
+
+		/* Delay for a bit before checking again ... */
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
+	/* Loop trying to get ownership of the mailbox.  Return an error
+	 * if we can't gain ownership.
+	 */
 	v = MBOWNER_G(t4_read_reg(adap, ctl_reg));
 	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
 		v = MBOWNER_G(t4_read_reg(adap, ctl_reg));
-
 	if (v != MBOX_OWNER_DRV) {
+		spin_lock(&adap->mbox_lock);
+		list_del(&entry.list);
+		spin_unlock(&adap->mbox_lock);
 		ret = (v == MBOX_OWNER_FW) ? -EBUSY : -ETIMEDOUT;
 		t4_record_mbox(adap, cmd, MBOX_LEN, access, ret);
 		return ret;
@@ -366,6 +417,9 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 			execute = i + ms;
 			t4_record_mbox(adap, cmd_rpl,
 				       MBOX_LEN, access, execute);
+			spin_lock(&adap->mbox_lock);
+			list_del(&entry.list);
+			spin_unlock(&adap->mbox_lock);
 			return -FW_CMD_RETVAL_G((int)res);
 		}
 	}
@@ -375,6 +429,9 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 	dev_err(adap->pdev_dev, "command %#x in mailbox %d timed out\n",
 		*(const u8 *)cmd, mbox);
 	t4_report_fw_error(adap);
+	spin_lock(&adap->mbox_lock);
+	list_del(&entry.list);
+	spin_unlock(&adap->mbox_lock);
 	return ret;
 }
 
-- 
2.3.4
