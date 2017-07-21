From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 3/4] net-next: dsa: fix flow dissection
Date: Fri, 21 Jul 2017 10:58:12 +0200
Message-ID: <20170721085813.30789-3-john@phrozen.org>
References: <20170721085813.30789-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721085813.30789-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RPS and probably other kernel features are currently broken on some if not
all DSA devices. The root cause of this is that skb_hash will call the
flow_dissector. At this point the skb still contains the magic switch header
and the skb->protocol field is not set up to the correct 802.3 value yet.
By the time the tag specific code is called, removing the header and
properly setting the protocol an invalid hash is already set. In the case
of the mt7530 this will result in all flows always having the same hash.

This patch makes the flow dissector honour the nh and protocol offset
defined by the dsa tag driver thus fixing dissection, hashing and RPS.

Signed-off-by: John Crispin <john@phrozen.org>
---
 net/core/flow_dissector.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index fc5fc4594c90..1268ae75c3b3 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -4,6 +4,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/if_vlan.h>
+#include <net/dsa.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/gre.h>
@@ -440,6 +441,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			 skb->vlan_proto : skb->protocol;
 		nhoff = skb_network_offset(skb);
 		hlen = skb_headlen(skb);
+
+		if (unlikely(netdev_uses_dsa(skb->dev))) {
+			const struct dsa_device_ops *ops;
+			u8 *p = (u8 *)data;
+
+			ops = skb->dev->dsa_ptr->tag_ops;
+			if (ops->hash_proto_off)
+				proto = (u16)p[ops->hash_proto_off];
+			hlen -= ops->hash_nh_off;
+			nhoff += ops->hash_nh_off;
+		}
 	}
 
 	/* It is ensured by skb_flow_dissector_init() that control key will
-- 
2.11.0
