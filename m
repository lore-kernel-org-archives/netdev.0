From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Subject: [RFC RESEND] iwlwifi: pcie: transmit queue auto-sizing
Date: Thu,  4 Feb 2016 22:16:12 +0200
Message-ID: <1454616972-21709-1-git-send-email-emmanuel.grumbach@intel.com>
References: <1454616764-19841-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: netdev@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Dave Taht <dave.taht@gmail.com>,
	Jonathan Corbet <corbet@lwn.net>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49312 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015AbcBDUQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 15:16:17 -0500
In-Reply-To: <1454616764-19841-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As many (all?) WiFi devices, Intel WiFi devices have
transmit queues which have 256 transmit descriptors
each and each descriptor corresponds to an MPDU.
This means that when it is full, the queue contains
256 * ~1500 bytes to be transmitted (if we don't have
A-MSDUs). The purpose of those queues is to have enough
packets to be ready for transmission so that when the device
gets an opportunity to transmit (TxOP), it can take as many
packets as the spec allows and aggregate them into one
A-MPDU or even several A-MPDUs if we are using bursts.

The problem is that the packets that are in these queues are
already out of control of the Qdisc and can stay in those
queues for a fairly long time when the link condition is
not good. This leads to the well known bufferbloat problem.

This patch adds a way to tune the size of the transmit queue
so that it won't cause excessive latency. When the link
condition is good, the packets will flow smoothly and the
transmit queue will grow quickly allowing A-MPDUs and
maximal throughput. When the link is not optimal, we will
have retransmissions, lower transmit rates or signal
detection (CCA) which will cause a delay in the packet
transmission. The driver will sense this higher latency
and will reduce the size of the transmit queue.
This means that the packets that continue to arrive
will pile up in the Qdisc rather than in the device
queues. The major advantage of this approach is that
codel can now do its work.

The algorithm is really (too?) simple:
every 5 seconds, starts from a short queue again.
If a packet has been in the queue for less than 10ms,
allow 10 more MPDUs in.
If a packet has been in the queue for more than 20ms,
reduce by 10 the size of the transmit queue.

The implementation is really naive and way too simple:
 * reading jiffies for every Tx / Tx status is not a
   good idead.
 * jiffies are not fine-grained enough on all platforms
 * the constants chosen are really arbitrary and can't be
   tuned.
 * This may be implemented in mac80211 probably and help
   other drivers.
 * etc...

But already this gives nice results. I ran a very simple
experiment: I put the device in a controlled environment
and ran traffic while running default sized ping in the
background. In this configuration, our device quickly
raises its transmission rate to the best rate.
Then, I force the device to use the lowest rate (6Mbps).
Of course, the throughput collapses, but the ping RTT
shoots up.
Using codel helps, but the latency is still high. Codel
with this patch gives much better results:

pfifo_fast:
rtt min/avg/max/mdev = 1932.616/2393.284/2833.407/315.941 ms, pipe 3, ipg/ewma 2215.707/2446.884 ms

fq_codel + Tx queue auto-sizing:
rtt min/avg/max/mdev = 13.541/32.396/54.791/9.610 ms, ipg/ewma 200.685/32.202 ms

fq_codel without Tx queue auto-sizing:
rtt min/avg/max/mdev = 140.821/257.303/331.889/31.074 ms, pipe 2, ipg/ewma 258.147/252.847 ms

Clearly, there is more work to do to be able to merge this,
but it seems that the wireless problems mentioned in
https://lwn.net/Articles/616241/ may have a solution.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Dave Taht <dave.taht@gmail.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
---
Fix Dave's email address
---
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |  6 ++++
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       | 32 ++++++++++++++++++++--
 2 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/internal.h b/drivers/net/wireless/intel/iwlwifi/pcie/internal.h
index 2f95916..d83eb56 100644
--- a/drivers/net/wireless/intel/iwlwifi/pcie/internal.h
+++ b/drivers/net/wireless/intel/iwlwifi/pcie/internal.h
@@ -192,6 +192,11 @@ struct iwl_cmd_meta {
 	u32 flags;
 };
 
+struct iwl_txq_auto_size {
+	int min_space;
+	unsigned long reset_ts;
+};
+
 /*
  * Generic queue structure
  *
@@ -293,6 +298,7 @@ struct iwl_txq {
 	bool block;
 	unsigned long wd_timeout;
 	struct sk_buff_head overflow_q;
+	struct iwl_txq_auto_size auto_sz;
 };
 
 static inline dma_addr_t
diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/tx.c b/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
index 837a7d5..4d1dee6 100644
--- a/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
@@ -572,6 +572,8 @@ static int iwl_pcie_txq_init(struct iwl_trans *trans, struct iwl_txq *txq,
 
 	spin_lock_init(&txq->lock);
 	__skb_queue_head_init(&txq->overflow_q);
+	txq->auto_sz.min_space = 240;
+	txq->auto_sz.reset_ts = jiffies;
 
 	/*
 	 * Tell nic where to find circular buffer of Tx Frame Descriptors for
@@ -1043,10 +1045,14 @@ void iwl_trans_pcie_reclaim(struct iwl_trans *trans, int txq_id, int ssn,
 	     q->read_ptr != tfd_num;
 	     q->read_ptr = iwl_queue_inc_wrap(q->read_ptr)) {
 		struct sk_buff *skb = txq->entries[txq->q.read_ptr].skb;
+		struct ieee80211_tx_info *info;
+		unsigned long tx_time;
 
 		if (WARN_ON_ONCE(!skb))
 			continue;
 
+		info = IEEE80211_SKB_CB(skb);
+
 		iwl_pcie_free_tso_page(skb);
 
 		__skb_queue_tail(skbs, skb);
@@ -1056,6 +1062,18 @@ void iwl_trans_pcie_reclaim(struct iwl_trans *trans, int txq_id, int ssn,
 		iwl_pcie_txq_inval_byte_cnt_tbl(trans, txq);
 
 		iwl_pcie_txq_free_tfd(trans, txq);
+
+		tx_time = (uintptr_t)info->driver_data[IWL_TRANS_FIRST_DRIVER_DATA + 2];
+		if (time_before(jiffies, tx_time + msecs_to_jiffies(10))) {
+			txq->auto_sz.min_space -= 10;
+			txq->auto_sz.min_space =
+				max(txq->auto_sz.min_space, txq->q.high_mark);
+		} else if (time_after(jiffies,
+				      tx_time + msecs_to_jiffies(20))) {
+			txq->auto_sz.min_space += 10;
+			txq->auto_sz.min_space =
+				min(txq->auto_sz.min_space, 252);
+		}
 	}
 
 	iwl_pcie_txq_progress(txq);
@@ -2185,6 +2203,7 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
 		      struct iwl_device_cmd *dev_cmd, int txq_id)
 {
 	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_hdr *hdr;
 	struct iwl_tx_cmd *tx_cmd = (struct iwl_tx_cmd *)dev_cmd->payload;
 	struct iwl_cmd_meta *out_meta;
@@ -2234,13 +2253,20 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
 
 	spin_lock(&txq->lock);
 
-	if (iwl_queue_space(q) < q->high_mark) {
+	info->driver_data[IWL_TRANS_FIRST_DRIVER_DATA + 2] =
+		(void *)(uintptr_t)jiffies;
+
+	if (time_after(jiffies,
+		       txq->auto_sz.reset_ts + msecs_to_jiffies(5000))) {
+		txq->auto_sz.min_space = 240;
+		txq->auto_sz.reset_ts = jiffies;
+	}
+
+	if (iwl_queue_space(q) < txq->auto_sz.min_space) {
 		iwl_stop_queue(trans, txq);
 
 		/* don't put the packet on the ring, if there is no room */
 		if (unlikely(iwl_queue_space(q) < 3)) {
-			struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
-
 			info->driver_data[IWL_TRANS_FIRST_DRIVER_DATA + 1] =
 				dev_cmd;
 			__skb_queue_tail(&txq->overflow_q, skb);
-- 
2.5.0
