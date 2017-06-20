From: John Crispin <john@phrozen.org>
Subject: [RFC 1/2] net-next: fix DSA flow_disection
Date: Tue, 20 Jun 2017 10:06:54 +0200
Message-ID: <20170620080655.7251-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:45221 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752112AbdFTIHW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 04:07:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RPS and probably other kernel features are currently broken on some if not
all DSA devices. The root cause of this that skb_hash will call the
flow_disector. At this point the skb still contains the magic switch header
and the skb->protocol field is not set up to the correct 802.3 value yet.
by the time the tag specific code is called, removing the header and
properly setting the protocol an invalid hash is already set. In the case
of the mt7530 this will result in all flows always having the same hash.

The patch adds 2 new fields to the dsa_switch_ops allowing the
flow_disector to use them in order to be able to create the real hash of
the connection.

Signed-off-by: John Crispin <john@phrozen.org>
---
 include/net/dsa.h         |  6 ++++++
 net/core/flow_dissector.c | 12 ++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 58969b9a090c..8b0e8eca3c28 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -442,6 +442,12 @@ struct dsa_switch_ops {
 					 int port, struct net_device *br);
 	void	(*crosschip_bridge_leave)(struct dsa_switch *ds, int sw_index,
 					  int port, struct net_device *br);
+
+	/*
+	 * Network header and 802.3 protocol offsets
+	 */
+	int	hash_nh_off;
+	int	hash_proto_off;
 };
 
 struct dsa_switch_driver {
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index fc5fc4594c90..da45bdf57408 100644
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
+			const struct dsa_switch_ops *ops;
+			u8 *p = (u8 *) data;
+
+			ops = skb->dev->dsa_ptr->ds[0]->ops;
+			if (ops->hash_proto_off)
+				proto = (u16) p[ops->hash_proto_off];
+			hlen -= ops->hash_nh_off;
+			nhoff += ops->hash_nh_off;
+		}
 	}
 
 	/* It is ensured by skb_flow_dissector_init() that control key will
-- 
2.11.0
