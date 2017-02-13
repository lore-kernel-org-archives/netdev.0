From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 5/9] bnxt_en: Add hardware NTUPLE filter for encapsulated packets.
Date: Sun, 12 Feb 2017 19:18:14 -0500
Message-ID: <1486945098-4086-6-git-send-email-michael.chan@broadcom.com>
References: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:35465 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdBMATE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:19:04 -0500
Received: by mail-it0-f50.google.com with SMTP id 203so170032261ith.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:18:59 -0800 (PST)
In-Reply-To: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb_flow_dissect_flow_keys() returns with the encapsulation flag
set, pass the information to the firmware to setup the NTUPLE filter
accordingly.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 516c5d7..f3d829f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3456,6 +3456,9 @@ static int bnxt_hwrm_cfa_ntuple_filter_free(struct bnxt *bp,
 	 CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_PORT_MASK |	\
 	 CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_DST_ID)
 
+#define BNXT_NTP_TUNNEL_FLTR_FLAG				\
+		CFA_NTUPLE_FILTER_ALLOC_REQ_ENABLES_TUNNEL_TYPE
+
 static int bnxt_hwrm_cfa_ntuple_filter_alloc(struct bnxt *bp,
 					     struct bnxt_ntuple_filter *fltr)
 {
@@ -3496,6 +3499,11 @@ static int bnxt_hwrm_cfa_ntuple_filter_alloc(struct bnxt *bp,
 		req.dst_ipaddr[0] = keys->addrs.v4addrs.dst;
 		req.dst_ipaddr_mask[0] = cpu_to_be32(0xffffffff);
 	}
+	if (keys->control.flags & FLOW_DIS_ENCAPSULATION) {
+		req.enables |= cpu_to_le32(BNXT_NTP_TUNNEL_FLTR_FLAG);
+		req.tunnel_type =
+			CFA_NTUPLE_FILTER_ALLOC_REQ_TUNNEL_TYPE_ANYTUNNEL;
+	}
 
 	req.src_port = keys->ports.src;
 	req.src_port_mask = cpu_to_be16(0xffff);
@@ -6869,6 +6877,7 @@ static bool bnxt_fltr_match(struct bnxt_ntuple_filter *f1,
 	    keys1->ports.ports == keys2->ports.ports &&
 	    keys1->basic.ip_proto == keys2->basic.ip_proto &&
 	    keys1->basic.n_proto == keys2->basic.n_proto &&
+	    keys1->control.flags == keys2->control.flags &&
 	    ether_addr_equal(f1->src_mac_addr, f2->src_mac_addr) &&
 	    ether_addr_equal(f1->dst_mac_addr, f2->dst_mac_addr))
 		return true;
@@ -6886,9 +6895,6 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 	int rc = 0, idx, bit_id, l2_idx = 0;
 	struct hlist_head *head;
 
-	if (skb->encapsulation)
-		return -EPROTONOSUPPORT;
-
 	if (!ether_addr_equal(dev->dev_addr, eth->h_dest)) {
 		struct bnxt_vnic_info *vnic = &bp->vnic_info[0];
 		int off = 0, j;
@@ -6927,6 +6933,11 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 		rc = -EPROTONOSUPPORT;
 		goto err_free;
 	}
+	if ((fkeys->control.flags & FLOW_DIS_ENCAPSULATION) &&
+	    bp->hwrm_spec_code < 0x10601) {
+		rc = -EPROTONOSUPPORT;
+		goto err_free;
+	}
 
 	memcpy(new_fltr->dst_mac_addr, eth->h_dest, ETH_ALEN);
 	memcpy(new_fltr->src_mac_addr, eth->h_source, ETH_ALEN);
-- 
1.8.3.1
