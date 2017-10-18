From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 2/8] cxgb4: add tc flower match support for vlan
Date: Wed, 18 Oct 2017 20:49:08 +0530
Message-ID: <601680fb92270e9ed33e5bfcaf36b1394009ddf7.1508312071.git.rahul.lakkireddy@chelsio.com>
References: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:10622 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdJRPUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:20:34 -0400
In-Reply-To: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
References: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Add support for matching on vlan tci.  Construct vlan tci match param
based on vlan-id and vlan-pcp values supplied by tc.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 35 ++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index 647c86ae343d..f7554b768e9d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -160,6 +160,40 @@ static void cxgb4_process_flow_match(struct net_device *dev,
 		fs->mask.tos = mask->tos;
 	}
 
+	if (dissector_uses_key(cls->dissector, FLOW_DISSECTOR_KEY_VLAN)) {
+		struct flow_dissector_key_vlan *key, *mask;
+		u16 vlan_tci, vlan_tci_mask;
+
+		key = skb_flow_dissector_target(cls->dissector,
+						FLOW_DISSECTOR_KEY_VLAN,
+						cls->key);
+		mask = skb_flow_dissector_target(cls->dissector,
+						 FLOW_DISSECTOR_KEY_VLAN,
+						 cls->mask);
+		vlan_tci = key->vlan_id | (key->vlan_priority <<
+					   VLAN_PRIO_SHIFT);
+		vlan_tci_mask = mask->vlan_id | (mask->vlan_priority <<
+						 VLAN_PRIO_SHIFT);
+		fs->val.ivlan = cpu_to_be16(vlan_tci);
+		fs->mask.ivlan = cpu_to_be16(vlan_tci_mask);
+
+		/* Chelsio adapters use ivlan_vld bit to match vlan packets
+		 * as 802.1Q. Also, when vlan tag is present in packets,
+		 * ethtype match is used then to match on ethtype of inner
+		 * header ie. the header following the vlan header.
+		 * So, set the ivlan_vld based on ethtype info supplied by
+		 * TC for vlan packets if its 802.1Q. And then reset the
+		 * ethtype value else, hw will try to match the supplied
+		 * ethtype value with ethtype of inner header.
+		 */
+		if (fs->val.ethtype == ETH_P_8021Q) {
+			fs->val.ivlan_vld = 1;
+			fs->mask.ivlan_vld = 1;
+			fs->val.ethtype = 0;
+			fs->mask.ethtype = 0;
+		}
+	}
+
 	/* Match only packets coming from the ingress port where this
 	 * filter will be created.
 	 */
@@ -179,6 +213,7 @@ static int cxgb4_validate_flow_match(struct net_device *dev,
 	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
+	      BIT(FLOW_DISSECTOR_KEY_VLAN) |
 	      BIT(FLOW_DISSECTOR_KEY_IP))) {
 		netdev_warn(dev, "Unsupported key used: 0x%x\n",
 			    cls->dissector->used_keys);
-- 
2.14.1
