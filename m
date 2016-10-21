From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] flow_dissector: avoid uninitialized variable access
Date: Fri, 21 Oct 2016 17:55:53 +0200
Message-ID: <20161021155626.4020344-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Alexander Duyck <aduyck@mirantis.com>,
        Tom Herbert <tom@herbertland.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>, Eric Garver <e@erig.me>,
        Amir Vadai <amir@vadai.me>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc warns about an uninitialized pointer dereference in the vlan
priority handling:

net/core/flow_dissector.c: In function '__skb_flow_dissect':
net/core/flow_dissector.c:281:61: error: 'vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]

>From all I can tell, this warning is about a real bug, and we
should not attempt look up the vlan header if there was
no vlan tag.

Fixes: f6a66927692e ("flow_dissector: Get vlan priority in addition to vlan id")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I'm not sure about this one, please have a closer look at what
the original code does before applying.
---
 net/core/flow_dissector.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 44e6ba9d3a6b..dd6003bf27e1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -245,7 +245,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	}
 	case htons(ETH_P_8021AD):
 	case htons(ETH_P_8021Q): {
-		const struct vlan_hdr *vlan;
+		const struct vlan_hdr *vlan = NULL;
 
 		if (skb && skb_vlan_tag_present(skb))
 			proto = skb->protocol;
@@ -264,7 +264,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		}
 
 		skip_vlan = true;
-		if (dissector_uses_key(flow_dissector,
+		if (vlan && dissector_uses_key(flow_dissector,
 				       FLOW_DISSECTOR_KEY_VLAN)) {
 			key_vlan = skb_flow_dissector_target(flow_dissector,
 							     FLOW_DISSECTOR_KEY_VLAN,
-- 
2.9.0
