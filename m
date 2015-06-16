From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] fm10k: move setting shinfo inside ts_tx_enqueue
Date: Tue, 16 Jun 2015 06:47:15 -0700
Message-ID: <1434462448-140563-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:24718 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756695AbbFPNrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 09:47:33 -0400
In-Reply-To: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch simplifies the code flow for setting the IN_PROGRESS bit of
the shinfo for an skb we will be timestamping.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
index 95f1d62..39b8328 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
@@ -70,16 +70,16 @@ void fm10k_ts_tx_enqueue(struct fm10k_intfc *interface, struct sk_buff *skb)
 	 * if none are present then insert skb in tail of list
 	 */
 	skb = fm10k_ts_tx_skb(interface, FM10K_CB(clone)->fi.w.dglort);
-	if (!skb)
+	if (!skb) {
+		skb_shinfo(clone)->tx_flags |= SKBTX_IN_PROGRESS;
 		__skb_queue_tail(list, clone);
+	}
 
 	spin_unlock_irqrestore(&list->lock, flags);
 
 	/* if list is already has one then we just free the clone */
 	if (skb)
 		kfree_skb(skb);
-	else
-		skb_shinfo(clone)->tx_flags |= SKBTX_IN_PROGRESS;
 }
 
 void fm10k_ts_tx_hwtstamp(struct fm10k_intfc *interface, __le16 dglort,
-- 
2.4.3
