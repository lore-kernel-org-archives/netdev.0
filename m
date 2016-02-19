From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40e/i40evf: Move Tx checksum closer to TSO
Date: Fri, 19 Feb 2016 01:53:58 -0800
Message-ID: <1455875651-21696-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35306 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427404AbcBSJyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:16 -0500
In-Reply-To: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

On all of the other Intel drivers we place checksum close to TSO as they
have a significant amount in common and it can help to reduce the decision
tree for how to handle the frame as the first check in TSO is to see if
checksumming is offloaded, and if it is not we can skip _BOTH_ TSO and Tx
checksum offload based on a single check.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 12 ++++++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 10 +++++-----
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5123646..cb52f39 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2929,6 +2929,12 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (tso)
 		tx_flags |= I40E_TX_FLAGS_TSO;
 
+	/* Always offload the checksum, since it's in the data descriptor */
+	tso = i40e_tx_enable_csum(skb, &tx_flags, &td_cmd, &td_offset,
+				  tx_ring, &cd_tunneling);
+	if (tso < 0)
+		goto out_drop;
+
 	tsyn = i40e_tsyn(tx_ring, skb, tx_flags, &cd_type_cmd_tso_mss);
 
 	if (tsyn)
@@ -2939,12 +2945,6 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	/* always enable CRC insertion offload */
 	td_cmd |= I40E_TX_DESC_CMD_ICRC;
 
-	/* Always offload the checksum, since it's in the data descriptor */
-	tso = i40e_tx_enable_csum(skb, &tx_flags, &td_cmd, &td_offset,
-				  tx_ring, &cd_tunneling);
-	if (tso < 0)
-		goto out_drop;
-
 	i40e_create_tx_ctx(tx_ring, cd_type_cmd_tso_mss,
 			   cd_tunneling, cd_l2tag2);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 2369db5..ebcc25c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -2148,17 +2148,17 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (tso)
 		tx_flags |= I40E_TX_FLAGS_TSO;
 
-	skb_tx_timestamp(skb);
-
-	/* always enable CRC insertion offload */
-	td_cmd |= I40E_TX_DESC_CMD_ICRC;
-
 	/* Always offload the checksum, since it's in the data descriptor */
 	tso = i40e_tx_enable_csum(skb, &tx_flags, &td_cmd, &td_offset,
 				  tx_ring, &cd_tunneling);
 	if (tso < 0)
 		goto out_drop;
 
+	skb_tx_timestamp(skb);
+
+	/* always enable CRC insertion offload */
+	td_cmd |= I40E_TX_DESC_CMD_ICRC;
+
 	i40e_create_tx_ctx(tx_ring, cd_type_cmd_tso_mss,
 			   cd_tunneling, cd_l2tag2);
 
-- 
2.5.0
