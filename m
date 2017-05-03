From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/16] bridge: ebtables: fix reception of frames DNAT-ed to bridge device/port
Date: Wed,  3 May 2017 11:32:05 +0200
Message-ID: <1493803931-2837-11-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Lüssing <linus.luessing@c0d3.blue>

When trying to redirect bridged frames to the bridge device itself or
a bridge port (brouting) via the dnat target then this currently fails:

The ethernet destination of the frame is dnat'ed to the MAC address of
the bridge device or port just fine. However, the IP code drops it in
the beginning of ip_input.c/ip_rcv() as the dnat target left
the skb->pkt_type as PACKET_OTHERHOST.

Fixing this by resetting skb->pkt_type to an appropriate type after
dnat'ing.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_dnat.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 4e0b0c359325..e0bb624c3845 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -9,6 +9,7 @@
  */
 #include <linux/module.h>
 #include <net/sock.h>
+#include "../br_private.h"
 #include <linux/netfilter.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_bridge/ebtables.h>
@@ -18,11 +19,30 @@ static unsigned int
 ebt_dnat_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_nat_info *info = par->targinfo;
+	struct net_device *dev;
 
 	if (!skb_make_writable(skb, 0))
 		return EBT_DROP;
 
 	ether_addr_copy(eth_hdr(skb)->h_dest, info->mac);
+
+	if (is_multicast_ether_addr(info->mac)) {
+		if (is_broadcast_ether_addr(info->mac))
+			skb->pkt_type = PACKET_BROADCAST;
+		else
+			skb->pkt_type = PACKET_MULTICAST;
+	} else {
+		if (xt_hooknum(par) != NF_BR_BROUTING)
+			dev = br_port_get_rcu(xt_in(par))->br->dev;
+		else
+			dev = xt_in(par);
+
+		if (ether_addr_equal(info->mac, dev->dev_addr))
+			skb->pkt_type = PACKET_HOST;
+		else
+			skb->pkt_type = PACKET_OTHERHOST;
+	}
+
 	return info->target;
 }
 
-- 
2.1.4

