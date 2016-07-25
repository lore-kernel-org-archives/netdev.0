From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 1/3] bnxt_en: Improve ntuple filters by checking destination MAC address.
Date: Mon, 25 Jul 2016 12:33:35 -0400
Message-ID: <1469464417-786-2-git-send-email-michael.chan@broadcom.com>
References: <1469464417-786-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36699 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbcGYQdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 12:33:54 -0400
Received: by mail-pa0-f48.google.com with SMTP id pp5so62756755pac.3
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 09:33:54 -0700 (PDT)
In-Reply-To: <1469464417-786-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include the destination MAC address in the ntuple filter structure.  The
current code assumes that the destination MAC address is always the MAC
address of the NIC.  This may not be true if there are macvlans, for
example.  Add destination MAC address checking and configure the filter
correctly using the correct index for the destination MAC address.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 25 ++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  2 ++
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8a0165b..7de7d7a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3240,7 +3240,7 @@ static int bnxt_hwrm_cfa_ntuple_filter_alloc(struct bnxt *bp,
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[fltr->rxq + 1];
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_CFA_NTUPLE_FILTER_ALLOC, -1, -1);
-	req.l2_filter_id = bp->vnic_info[0].fw_l2_filter_id[0];
+	req.l2_filter_id = bp->vnic_info[0].fw_l2_filter_id[fltr->l2_fltr_idx];
 
 	req.enables = cpu_to_le32(BNXT_NTP_FLTR_FLAGS);
 
@@ -6299,7 +6299,8 @@ static bool bnxt_fltr_match(struct bnxt_ntuple_filter *f1,
 	    keys1->ports.ports == keys2->ports.ports &&
 	    keys1->basic.ip_proto == keys2->basic.ip_proto &&
 	    keys1->basic.n_proto == keys2->basic.n_proto &&
-	    ether_addr_equal(f1->src_mac_addr, f2->src_mac_addr))
+	    ether_addr_equal(f1->src_mac_addr, f2->src_mac_addr) &&
+	    ether_addr_equal(f1->dst_mac_addr, f2->dst_mac_addr))
 		return true;
 
 	return false;
@@ -6312,12 +6313,28 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 	struct bnxt_ntuple_filter *fltr, *new_fltr;
 	struct flow_keys *fkeys;
 	struct ethhdr *eth = (struct ethhdr *)skb_mac_header(skb);
-	int rc = 0, idx, bit_id;
+	int rc = 0, idx, bit_id, l2_idx = 0;
 	struct hlist_head *head;
 
 	if (skb->encapsulation)
 		return -EPROTONOSUPPORT;
 
+	if (!ether_addr_equal(dev->dev_addr, eth->h_dest)) {
+		struct bnxt_vnic_info *vnic = &bp->vnic_info[0];
+		int off = 0, j;
+
+		netif_addr_lock_bh(dev);
+		for (j = 0; j < vnic->uc_filter_count; j++, off += ETH_ALEN) {
+			if (ether_addr_equal(eth->h_dest,
+					     vnic->uc_list + off)) {
+				l2_idx = j + 1;
+				break;
+			}
+		}
+		netif_addr_unlock_bh(dev);
+		if (!l2_idx)
+			return -EINVAL;
+	}
 	new_fltr = kzalloc(sizeof(*new_fltr), GFP_ATOMIC);
 	if (!new_fltr)
 		return -ENOMEM;
@@ -6335,6 +6352,7 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 		goto err_free;
 	}
 
+	memcpy(new_fltr->dst_mac_addr, eth->h_dest, ETH_ALEN);
 	memcpy(new_fltr->src_mac_addr, eth->h_source, ETH_ALEN);
 
 	idx = skb_get_hash_raw(skb) & BNXT_NTP_FLTR_HASH_MASK;
@@ -6360,6 +6378,7 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 
 	new_fltr->sw_id = (u16)bit_id;
 	new_fltr->flow_id = flow_id;
+	new_fltr->l2_fltr_idx = l2_idx;
 	new_fltr->rxq = rxq_index;
 	hlist_add_head_rcu(&new_fltr->hash, head);
 	bp->ntp_fltr_count++;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 5307a2e..23e04a6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -785,10 +785,12 @@ struct bnxt_pf_info {
 
 struct bnxt_ntuple_filter {
 	struct hlist_node	hash;
+	u8			dst_mac_addr[ETH_ALEN];
 	u8			src_mac_addr[ETH_ALEN];
 	struct flow_keys	fkeys;
 	__le64			filter_id;
 	u16			sw_id;
+	u8			l2_fltr_idx;
 	u16			rxq;
 	u32			flow_id;
 	unsigned long		state;
-- 
1.8.3.1
