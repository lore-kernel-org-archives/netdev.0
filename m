From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] fm10k: fix incorrect free on skb in ts_tx_enqueue
Date: Tue, 16 Jun 2015 06:47:16 -0700
Message-ID: <1434462448-140563-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8750 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756696AbbFPNrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 09:47:33 -0400
In-Reply-To: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch resolves a bug in the ts_tx_enqueue code responsible for a
NULL pointer dereference and invalid access of the skb list. We
incorrectly freed the actual skb we found instead of our copy. Thus the
skb queue is essentially invalidated. Resolve this by freeing our clone
in the cases where we did not add it to the queue. This also avoids the
skb memory leak caused by failure to free the clone.

[  589.719320] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  589.722344] IP: [<ffffffffa0310e60>] fm10k_ts_tx_subtask+0xb0/0x160 [fm10k]
[  589.723796] PGD 0
[  589.725228] Oops: 0000 [#1] SMP

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
index 39b8328..b4945e8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
@@ -79,7 +79,7 @@ void fm10k_ts_tx_enqueue(struct fm10k_intfc *interface, struct sk_buff *skb)
 
 	/* if list is already has one then we just free the clone */
 	if (skb)
-		kfree_skb(skb);
+		dev_kfree_skb(clone);
 }
 
 void fm10k_ts_tx_hwtstamp(struct fm10k_intfc *interface, __le16 dglort,
-- 
2.4.3
