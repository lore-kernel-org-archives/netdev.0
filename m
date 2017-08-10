From: John Crispin <john@phrozen.org>
Subject: [PATCH net-next] net: core: fix compile error inside flow_dissector due to new dsa callback
Date: Thu, 10 Aug 2017 10:09:03 +0200
Message-ID: <20170810080903.32231-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Jiri Pirko <jiri@mellanox.com>, Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following error was introduced by
commit 43e665287f93 ("net-next: dsa: fix flow dissection")
due to a missing #if guard

net/core/flow_dissector.c: In function '__skb_flow_dissect':
net/core/flow_dissector.c:448:18: error: 'struct net_device' has no member named 'dsa_ptr'
ops = skb->dev->dsa_ptr->tag_ops;
                ^
make[3]: *** [net/core/flow_dissector.o] Error 1

Signed-off-by: John Crispin <john@phrozen.org>
---
 net/core/flow_dissector.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 5b5be9577257..79b9c06c83ad 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -441,6 +441,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			 skb->vlan_proto : skb->protocol;
 		nhoff = skb_network_offset(skb);
 		hlen = skb_headlen(skb);
+#if IS_ENABLED(CONFIG_NET_DSA)
 		if (unlikely(netdev_uses_dsa(skb->dev))) {
 			const struct dsa_device_ops *ops;
 			int offset;
@@ -452,6 +453,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 				nhoff += offset;
 			}
 		}
+#endif
 	}
 
 	/* It is ensured by skb_flow_dissector_init() that control key will
-- 
2.11.0
