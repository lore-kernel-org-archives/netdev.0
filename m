From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/7] i40e: remove open-coded skb_cow_head
Date: Fri, 18 Apr 2014 18:59:21 -0700
Message-ID: <1397872767-4001-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56433 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753797AbaDSB7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2014 21:59:31 -0400
In-Reply-To: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 0f5d96a..1fdc8e9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1713,9 +1713,11 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 				I40E_TX_FLAGS_VLAN_PRIO_SHIFT;
 		if (tx_flags & I40E_TX_FLAGS_SW_VLAN) {
 			struct vlan_ethhdr *vhdr;
-			if (skb_header_cloned(skb) &&
-			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-				return -ENOMEM;
+			int rc;
+
+			rc = skb_cow_head(skb, 0);
+			if (rc < 0)
+				return rc;
 			vhdr = (struct vlan_ethhdr *)skb->data;
 			vhdr->h_vlan_TCI = htons(tx_flags >>
 						 I40E_TX_FLAGS_VLAN_SHIFT);
@@ -1743,20 +1745,18 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		    u64 *cd_type_cmd_tso_mss, u32 *cd_tunneling)
 {
 	u32 cd_cmd, cd_tso_len, cd_mss;
+	struct ipv6hdr *ipv6h;
 	struct tcphdr *tcph;
 	struct iphdr *iph;
 	u32 l4len;
 	int err;
-	struct ipv6hdr *ipv6h;
 
 	if (!skb_is_gso(skb))
 		return 0;
 
-	if (skb_header_cloned(skb)) {
-		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err)
-			return err;
-	}
+	err = skb_cow_head(skb, 0);
+	if (err < 0)
+		return err;
 
 	if (protocol == htons(ETH_P_IP)) {
 		iph = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
-- 
1.9.0
