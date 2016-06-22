From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: Synchronize access to mailbox
Date: Wed, 22 Jun 2016 09:39:29 +0530
Message-ID: <1466568569-19120-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:44938 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750943AbcFVEGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 00:06:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue comes when there are multiple threads attempting to use the
mailbox facility at the same time. The issue is the for the Virtual
Function Driver, the only way to get the Virtual Interface statistics
is to issue mailbox commands to ask the firmware for the VI Stats.
And, because the VI Stats command can only retrieve a smallish number of
stats per mailbox command, we have to issue three mailbox commands in quick
succession. When ethtool or netstat command to get interface stats and
interface up/down is run in a loop for every 0.1 sec, we observed
mailbox collisions. And out of the two commands one would fail with
the present code, since we don't queue the second command.

To overcome the above issue, added a queue to access the mailbox.
Whenever a mailbox command is issued add it to the queue. If its at the
head issue the mailbox command, else wait for the existing command to
complete. Usually command takes less than a milli-second to complete.
Also timeout from the loop, if the command under execution takes
long time to run.

In reality, the number of mailbox access collisions is going to be very
rare since no one runs such abusive script.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |  8 ++++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  2 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 55 ++++++++++++++++++++++
 3 files changed, 65 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 734dd776c22f..109bc630408b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -353,6 +353,10 @@ struct hash_mac_addr {
 	u8 addr[ETH_ALEN];
 };
 
+struct mbox_list {
+	struct list_head list;
+};
+
 /*
  * Per-"adapter" (Virtual Function) information.
  */
@@ -387,6 +391,10 @@ struct adapter {
 	/* various locks */
 	spinlock_t stats_lock;
 
+	/* lock for mailbox cmd list */
+	spinlock_t mbox_lock;
+	struct mbox_list mlist;
+
 	/* support for mailbox command/reply logging */
 #define T4VF_OS_LOG_MBOX_CMDS 256
 	struct mbox_cmd_log *mbox_log;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 8d9b2cb74aa2..9f5526478d2f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2774,6 +2774,8 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 * Initialize SMP data synchronization resources.
 	 */
 	spin_lock_init(&adapter->stats_lock);
+	spin_lock_init(&adapter->mbox_lock);
+	INIT_LIST_HEAD(&adapter->mlist.list);
 
 	/*
 	 * Map our I/O registers in BAR0.
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 955ff7c61f1b..61bfe86da86d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -139,6 +139,7 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	u32 mbox_ctl = T4VF_CIM_BASE_ADDR + CIM_VF_EXT_MAILBOX_CTRL;
 	u32 cmd_op = FW_CMD_OP_G(be32_to_cpu(((struct fw_cmd_hdr *)cmd)->hi));
 	__be64 cmd_rpl[MBOX_LEN / 8];
+	struct mbox_list entry;
 
 	/* In T6, mailbox size is changed to 128 bytes to avoid
 	 * invalidating the entire prefetch buffer.
@@ -156,6 +157,51 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
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
+		 * mailbox access list but this is a start.  We very rearely
+		 * contend on access to the mailbox ...
+		 */
+		if (i > FW_CMD_MAX_TIMEOUT) {
+			spin_lock(&adapter->mbox_lock);
+			list_del(&entry.list);
+			spin_unlock(&adapter->mbox_lock);
+			ret = -EBUSY;
+			t4vf_record_mbox(adapter, cmd, size, access, ret);
+			return ret;
+		}
+
+		/* If we're at the head, break out and start the mailbox
+		 * protocol.
+		 */
+		if (list_first_entry(&adapter->mlist.list, struct mbox_list,
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
 	/*
 	 * Loop trying to get ownership of the mailbox.  Return an error
 	 * if we can't gain ownership.
@@ -164,6 +210,9 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
 		v = MBOWNER_G(t4_read_reg(adapter, mbox_ctl));
 	if (v != MBOX_OWNER_DRV) {
+		spin_lock(&adapter->mbox_lock);
+		list_del(&entry.list);
+		spin_unlock(&adapter->mbox_lock);
 		ret = (v == MBOX_OWNER_FW) ? -EBUSY : -ETIMEDOUT;
 		t4vf_record_mbox(adapter, cmd, size, access, ret);
 		return ret;
@@ -248,6 +297,9 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 			if (cmd_op != FW_VI_STATS_CMD)
 				t4vf_record_mbox(adapter, cmd_rpl, size, access,
 						 execute);
+			spin_lock(&adapter->mbox_lock);
+			list_del(&entry.list);
+			spin_unlock(&adapter->mbox_lock);
 			return -FW_CMD_RETVAL_G(v);
 		}
 	}
@@ -255,6 +307,9 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	/* We timed out.  Return the error ... */
 	ret = -ETIMEDOUT;
 	t4vf_record_mbox(adapter, cmd, size, access, ret);
+	spin_lock(&adapter->mbox_lock);
+	list_del(&entry.list);
+	spin_unlock(&adapter->mbox_lock);
 	return ret;
 }
 
-- 
2.3.4
