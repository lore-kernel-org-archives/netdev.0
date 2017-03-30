From: Yi-Hung Wei <yihung.wei@gmail.com>
Subject: [PATCH net v2] openvswitch: Fix ovs_flow_key_update()
Date: Thu, 30 Mar 2017 12:36:03 -0700
Message-ID: <1490902563-19288-1-git-send-email-yihung.wei@gmail.com>
Cc: Yi-Hung Wei <yihung.wei@gmail.com>, linux-kernel@vger.kernel.org
To: jbenc@redhat.com, joe@ovn.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ovs_flow_key_update() is called when the flow key is invalid, and it is
used to update and revalidate the flow key. Commit 329f45bc4f19
("openvswitch: add mac_proto field to the flow key") introduces mac_proto
field to flow key and use it to determine whether the flow key is valid.
However, the commit does not update the code path in ovs_flow_key_update()
to revalidate the flow key which may cause BUG_ON() on execute_recirc().
This patch addresses the aforementioned issue.

Fixes: 329f45bc4f19 ("openvswitch: add mac_proto field to the flow key")
Signed-off-by: Yi-Hung Wei <yihung.wei@gmail.com>
---
 net/openvswitch/flow.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 9d4bb8eb63f2..3f76cb765e5b 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -527,7 +527,7 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 	/* Link layer. */
 	clear_vlan(key);
-	if (key->mac_proto == MAC_PROTO_NONE) {
+	if (ovs_key_mac_proto(key) == MAC_PROTO_NONE) {
 		if (unlikely(eth_type_vlan(skb->protocol)))
 			return -EINVAL;
 
@@ -745,7 +745,13 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 {
-	return key_extract(skb, key);
+	int res;
+
+	res = key_extract(skb, key);
+	if (!res)
+		key->mac_proto &= ~SW_FLOW_KEY_INVALID;
+
+	return res;
 }
 
 static int key_extract_mac_proto(struct sk_buff *skb)
-- 
2.7.4
