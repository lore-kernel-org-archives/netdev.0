From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 11/17] i40e: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:24 +0100
Message-ID: <de7e007ad0078a6e6eaee0a3a677097b00fa02c3.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60870 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbaC2L0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:51 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index a329aac..75bd010 100644
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
