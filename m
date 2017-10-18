From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 1/8] cxgb4: add tc flower match support for TOS
Date: Wed, 18 Oct 2017 20:49:07 +0530
Message-ID: <e80bab531e4cc5f5161050dd65d1078d925f221e.1508312071.git.rahul.lakkireddy@chelsio.com>
References: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:64481 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdJRPUc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:20:32 -0400
In-Reply-To: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
References: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Add support for matching on IP TOS.  Also check on ethtype value
to be either IPv4 or IPv6.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 51 +++++++++++++++++++++-
 1 file changed, 50 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index 92a311767381..647c86ae343d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -147,6 +147,19 @@ static void cxgb4_process_flow_match(struct net_device *dev,
 		fs->mask.fport = cpu_to_be16(mask->src);
 	}
 
+	if (dissector_uses_key(cls->dissector, FLOW_DISSECTOR_KEY_IP)) {
+		struct flow_dissector_key_ip *key, *mask;
+
+		key = skb_flow_dissector_target(cls->dissector,
+						FLOW_DISSECTOR_KEY_IP,
+						cls->key);
+		mask = skb_flow_dissector_target(cls->dissector,
+						 FLOW_DISSECTOR_KEY_IP,
+						 cls->mask);
+		fs->val.tos = key->tos;
+		fs->mask.tos = mask->tos;
+	}
+
 	/* Match only packets coming from the ingress port where this
 	 * filter will be created.
 	 */
@@ -157,16 +170,52 @@ static void cxgb4_process_flow_match(struct net_device *dev,
 static int cxgb4_validate_flow_match(struct net_device *dev,
 				     struct tc_cls_flower_offload *cls)
 {
+	u16 ethtype_mask = 0;
+	u16 ethtype_key = 0;
+
 	if (cls->dissector->used_keys &
 	    ~(BIT(FLOW_DISSECTOR_KEY_CONTROL) |
 	      BIT(FLOW_DISSECTOR_KEY_BASIC) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
-	      BIT(FLOW_DISSECTOR_KEY_PORTS))) {
+	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
+	      BIT(FLOW_DISSECTOR_KEY_IP))) {
 		netdev_warn(dev, "Unsupported key used: 0x%x\n",
 			    cls->dissector->used_keys);
 		return -EOPNOTSUPP;
 	}
+
+	if (dissector_uses_key(cls->dissector, FLOW_DISSECTOR_KEY_BASIC)) {
+		struct flow_dissector_key_basic *key =
+			skb_flow_dissector_target(cls->dissector,
+						  FLOW_DISSECTOR_KEY_BASIC,
+						  cls->key);
+		struct flow_dissector_key_basic *mask =
+			skb_flow_dissector_target(cls->dissector,
+						  FLOW_DISSECTOR_KEY_BASIC,
+						  cls->mask);
+		ethtype_key = ntohs(key->n_proto);
+		ethtype_mask = ntohs(mask->n_proto);
+	}
+
+	if (dissector_uses_key(cls->dissector, FLOW_DISSECTOR_KEY_IP)) {
+		u16 eth_ip_type = ethtype_key & ethtype_mask;
+		struct flow_dissector_key_ip *mask;
+
+		if (eth_ip_type != ETH_P_IP && eth_ip_type != ETH_P_IPV6) {
+			netdev_err(dev, "IP Key supported only with IPv4/v6");
+			return -EINVAL;
+		}
+
+		mask = skb_flow_dissector_target(cls->dissector,
+						 FLOW_DISSECTOR_KEY_IP,
+						 cls->mask);
+		if (mask->ttl) {
+			netdev_warn(dev, "ttl match unsupported for offload");
+			return -EOPNOTSUPP;
+		}
+	}
+
 	return 0;
 }
 
-- 
2.14.1
