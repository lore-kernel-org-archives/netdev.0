From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] i40e/i40evf: Fix mixed size frags and linearization
Date: Thu,  4 Jun 2015 20:27:02 -0700
Message-ID: <1433474824-5414-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433474824-5414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47765 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450AbbFED1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 23:27:10 -0400
In-Reply-To: <1433474824-5414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch fixes a bug where the i40e Tx queue will hang if this
skb is passed to the driver.

With mixed size fragments while using TSO there was a corner case
where we needed to linearize but we were not. This was seen with
iSCSI traffic and could be reproduced with a frag list that looks
like this:

num_frags = 17, gso_segs = 17, hdr_len = 66,
skb_shinfo(skb)->gso_size = 1448
size = 3002, j = 1, frag_size = 2936, num_frags = 17
size = 4268, j = 1, frag_size = 4096, num_frags = 16
size = 5534, j = 1, frag_size = 4096, num_frags = 15
size = 5352, j = 1, frag_size = 4096, num_frags = 14
size = 5170, j = 1, frag_size = 4096, num_frags = 13
size = 3468, j = 1, frag_size = 2576, num_frags = 12
size = 750, j = 1, frag_size = 112, num_frags = 11
size = 862, j = 2, frag_size = 112, num_frags = 10
size = 974, j = 3, frag_size = 112, num_frags = 9
size = 1126, j = 4, frag_size = 152, num_frags = 8
size = 1330, j = 5, frag_size = 204, num_frags = 7
size = 1534, j = 6, frag_size = 204, num_frags = 6
size = 356, j = 1, frag_size = 204, num_frags = 5
size = 560, j = 2, frag_size = 204, num_frags = 4
size = 764, j = 3, frag_size = 204, num_frags = 3
size = 968, j = 4, frag_size = 204, num_frags = 2
size = 1140, j = 5, frag_size = 172, num_frags = 1
result: linearize = 0, j = 6

Change-ID: I79bb1aeab0af255fe2ce28e93672a85d85bf47e8
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 25 ++++++++++---------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 25 ++++++++++---------------
 2 files changed, 20 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 4bd3a80..9d95042d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2410,14 +2410,12 @@ static int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
  * i40e_chk_linearize - Check if there are more than 8 fragments per packet
  * @skb:      send buffer
  * @tx_flags: collected send information
- * @hdr_len:  size of the packet header
  *
  * Note: Our HW can't scatter-gather more than 8 fragments to build
  * a packet on the wire and so we need to figure out the cases where we
  * need to linearize the skb.
  **/
-static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags,
-			       const u8 hdr_len)
+static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags)
 {
 	struct skb_frag_struct *frag;
 	bool linearize = false;
@@ -2429,7 +2427,7 @@ static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags,
 	gso_segs = skb_shinfo(skb)->gso_segs;
 
 	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO)) {
-		u16 j = 1;
+		u16 j = 0;
 
 		if (num_frags < (I40E_MAX_BUFFER_TXD))
 			goto linearize_chk_done;
@@ -2440,21 +2438,18 @@ static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags,
 			goto linearize_chk_done;
 		}
 		frag = &skb_shinfo(skb)->frags[0];
-		size = hdr_len;
 		/* we might still have more fragments per segment */
 		do {
 			size += skb_frag_size(frag);
 			frag++; j++;
+			if ((size >= skb_shinfo(skb)->gso_size) &&
+			    (j < I40E_MAX_BUFFER_TXD)) {
+				size = (size % skb_shinfo(skb)->gso_size);
+				j = (size) ? 1 : 0;
+			}
 			if (j == I40E_MAX_BUFFER_TXD) {
-				if (size < skb_shinfo(skb)->gso_size) {
-					linearize = true;
-					break;
-				}
-				j = 1;
-				size -= skb_shinfo(skb)->gso_size;
-				if (size)
-					j++;
-				size += hdr_len;
+				linearize = true;
+				break;
 			}
 			num_frags--;
 		} while (num_frags);
@@ -2724,7 +2719,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	if (tsyn)
 		tx_flags |= I40E_TX_FLAGS_TSYN;
 
-	if (i40e_chk_linearize(skb, tx_flags, hdr_len))
+	if (i40e_chk_linearize(skb, tx_flags))
 		if (skb_linearize(skb))
 			goto out_drop;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index b077e02..458fbb4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1619,14 +1619,12 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
  * i40e_chk_linearize - Check if there are more than 8 fragments per packet
  * @skb:      send buffer
  * @tx_flags: collected send information
- * @hdr_len:  size of the packet header
  *
  * Note: Our HW can't scatter-gather more than 8 fragments to build
  * a packet on the wire and so we need to figure out the cases where we
  * need to linearize the skb.
  **/
-static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags,
-			       const u8 hdr_len)
+static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags)
 {
 	struct skb_frag_struct *frag;
 	bool linearize = false;
@@ -1638,7 +1636,7 @@ static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags,
 	gso_segs = skb_shinfo(skb)->gso_segs;
 
 	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO)) {
-		u16 j = 1;
+		u16 j = 0;
 
 		if (num_frags < (I40E_MAX_BUFFER_TXD))
 			goto linearize_chk_done;
@@ -1649,21 +1647,18 @@ static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags,
 			goto linearize_chk_done;
 		}
 		frag = &skb_shinfo(skb)->frags[0];
-		size = hdr_len;
 		/* we might still have more fragments per segment */
 		do {
 			size += skb_frag_size(frag);
 			frag++; j++;
+			if ((size >= skb_shinfo(skb)->gso_size) &&
+			    (j < I40E_MAX_BUFFER_TXD)) {
+				size = (size % skb_shinfo(skb)->gso_size);
+				j = (size) ? 1 : 0;
+			}
 			if (j == I40E_MAX_BUFFER_TXD) {
-				if (size < skb_shinfo(skb)->gso_size) {
-					linearize = true;
-					break;
-				}
-				j = 1;
-				size -= skb_shinfo(skb)->gso_size;
-				if (size)
-					j++;
-				size += hdr_len;
+				linearize = true;
+				break;
 			}
 			num_frags--;
 		} while (num_frags);
@@ -1950,7 +1945,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (tso)
 		tx_flags |= I40E_TX_FLAGS_TSO;
 
-	if (i40e_chk_linearize(skb, tx_flags, hdr_len))
+	if (i40e_chk_linearize(skb, tx_flags))
 		if (skb_linearize(skb))
 			goto out_drop;
 
-- 
2.1.0
