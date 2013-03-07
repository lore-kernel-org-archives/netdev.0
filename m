From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] bridge: add missing vid to br_mdb_get()
Date: Thu,  7 Mar 2013 21:05:33 +0800
Message-ID: <1362661533-29192-1-git-send-email-amwang@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752867Ab3CGNFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 08:05:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Obviously, vid should be considered when searching for multicast
group.

Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index d5f1d3f..314c73e 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -66,7 +66,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto out;
 		}
 
-		mdst = br_mdb_get(br, skb);
+		mdst = br_mdb_get(br, skb, vid);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
 			br_multicast_deliver(mdst, skb);
 		else
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 4803301..828e2bc 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -97,7 +97,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (is_broadcast_ether_addr(dest))
 		skb2 = skb;
 	else if (is_multicast_ether_addr(dest)) {
-		mdst = br_mdb_get(br, skb);
+		mdst = br_mdb_get(br, skb, vid);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
 			if ((mdst && mdst->mglist) ||
 			    br_multicast_is_router(br))
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 10e6fce..923fbea 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -132,7 +132,7 @@ static struct net_bridge_mdb_entry *br_mdb_ip6_get(
 #endif
 
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
-					struct sk_buff *skb)
+					struct sk_buff *skb, u16 vid)
 {
 	struct net_bridge_mdb_htable *mdb = rcu_dereference(br->mdb);
 	struct br_ip ip;
@@ -144,6 +144,7 @@ struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 		return NULL;
 
 	ip.proto = skb->protocol;
+	ip.vid = vid;
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6d314c4..3cbf5be 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -442,7 +442,7 @@ extern int br_multicast_rcv(struct net_bridge *br,
 			    struct net_bridge_port *port,
 			    struct sk_buff *skb);
 extern struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
-					       struct sk_buff *skb);
+					       struct sk_buff *skb, u16 vid);
 extern void br_multicast_add_port(struct net_bridge_port *port);
 extern void br_multicast_del_port(struct net_bridge_port *port);
 extern void br_multicast_enable_port(struct net_bridge_port *port);
@@ -504,7 +504,7 @@ static inline int br_multicast_rcv(struct net_bridge *br,
 }
 
 static inline struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
-						      struct sk_buff *skb)
+						      struct sk_buff *skb, u16 vid)
 {
 	return NULL;
 }
