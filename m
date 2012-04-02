From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 45/51] vlan: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:35 -0400
Message-ID: <1333335521-1348-46-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592Ab2DBDAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:39 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/8021q/vlan_netlink.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 5071136..708c80e 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -166,11 +166,13 @@ static int vlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct nlattr *nest;
 	unsigned int i;
 
-	NLA_PUT_U16(skb, IFLA_VLAN_ID, vlan_dev_priv(dev)->vlan_id);
+	if (nla_put_u16(skb, IFLA_VLAN_ID, vlan_dev_priv(dev)->vlan_id))
+		goto nla_put_failure;
 	if (vlan->flags) {
 		f.flags = vlan->flags;
 		f.mask  = ~0;
-		NLA_PUT(skb, IFLA_VLAN_FLAGS, sizeof(f), &f);
+		if (nla_put(skb, IFLA_VLAN_FLAGS, sizeof(f), &f))
+			goto nla_put_failure;
 	}
 	if (vlan->nr_ingress_mappings) {
 		nest = nla_nest_start(skb, IFLA_VLAN_INGRESS_QOS);
@@ -183,8 +185,9 @@ static int vlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 			m.from = i;
 			m.to   = vlan->ingress_priority_map[i];
-			NLA_PUT(skb, IFLA_VLAN_QOS_MAPPING,
-				sizeof(m), &m);
+			if (nla_put(skb, IFLA_VLAN_QOS_MAPPING,
+				    sizeof(m), &m))
+				goto nla_put_failure;
 		}
 		nla_nest_end(skb, nest);
 	}
@@ -202,8 +205,9 @@ static int vlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 				m.from = pm->priority;
 				m.to   = (pm->vlan_qos >> 13) & 0x7;
-				NLA_PUT(skb, IFLA_VLAN_QOS_MAPPING,
-					sizeof(m), &m);
+				if (nla_put(skb, IFLA_VLAN_QOS_MAPPING,
+					    sizeof(m), &m))
+					goto nla_put_failure;
 			}
 		}
 		nla_nest_end(skb, nest);
-- 
1.7.7.6
