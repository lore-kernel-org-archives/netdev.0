From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] igb: Fix oops on changing number of rings
Date: Thu,  7 May 2015 05:21:32 -0700
Message-ID: <1431001293-19424-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1431001293-19424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:35176 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbbEGMVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 08:21:36 -0400
In-Reply-To: <1431001293-19424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

When changing the number of rings by ethtool -L, q_vectors are reused,
which causes oops because of uninitialized pointers.

- When an rx is reused as a tx, q_vector->rx.ring is not set to NULL, which
  misleads igb_poll() to determine that it has an rx ring although it
  actually points to the tx ring.
- When a tx is reused as an rx, q_vector->rx.ring->skb
  (q_vector->ring[0].skb) has a value that was used as tx_stats before.

Fix these problems by zeroing it out on reuseing it.

Fixes: 02ef6e1d0b00 ("igb: Fix queue allocation method to accommodate changing during runtime")
Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8457d03..783d60ea 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1207,6 +1207,8 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 	q_vector = adapter->q_vector[v_idx];
 	if (!q_vector)
 		q_vector = kzalloc(size, GFP_KERNEL);
+	else
+		memset(q_vector, 0, size);
 	if (!q_vector)
 		return -ENOMEM;
 
-- 
2.1.0
