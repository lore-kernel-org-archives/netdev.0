From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 3/4] bridge: Consider the Nearest Customer Bridge group addresses
Date: Mon,  9 Jun 2014 20:34:46 +0900
Message-ID: <1402313687-28067-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:37859 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753750AbaFILfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 07:35:10 -0400
In-Reply-To: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An 802.1ad bridge must forward the Nearest Customer Bridge group addresses.
 01-80-C2-00-00-00
 01-80-C2-00-00-0B
 01-80-C2-00-00-0C
 01-80-C2-00-00-0D
 01-80-C2-00-00-0F
(For details, see IEEE 802.1Q-2011 8.6.3.)

An exception is the br->group_addr, which needs to be passed to the higher
layer entity so that STP works.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_input.c   | 15 ++++++++++++++-
 net/bridge/br_private.h | 10 ++++++++++
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 04d6348..b05d419 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -194,13 +194,26 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		case 0x00:	/* Bridge Group Address */
 			/* If STP is turned off,
 			   then must forward to keep loop detection */
-			if (p->br->stp_enabled == BR_NO_STP)
+			if (p->br->stp_enabled == BR_NO_STP ||
+			    (br_vlan_enabled(p->br) &&
+			     br_vlan_get_proto(p->br) == htons(ETH_P_8021AD) &&
+			     p->br->group_addr[5] != dest[5]))
 				goto forward;
 			break;
 
 		case 0x01:	/* IEEE MAC (Pause) */
 			goto drop;
 
+		case 0x0B:
+		case 0x0C:
+		case 0x0D:
+		case 0x0F:
+			/* The Nearest Customer Bridge group address */
+			if (br_vlan_enabled(p->br) &&
+			    br_vlan_get_proto(p->br) == htons(ETH_P_8021AD) &&
+			    p->br->group_addr[5] != dest[5])
+				goto forward;
+			/* fall through */
 		default:
 			/* Allow selective forwarding for most other protocols */
 			if (p->br->group_fwd_mask & (1u << dest[5]))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b65fee9..65204c2 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -647,6 +647,11 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return br->vlan_enabled;
 }
+
+static inline __be16 br_vlan_get_proto(struct net_bridge *br)
+{
+	return br->vlan_proto;
+}
 #else
 static inline bool br_allowed_ingress(struct net_bridge *br,
 				      struct net_port_vlans *v,
@@ -742,6 +747,11 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return 0;
 }
+
+static inline __be16 br_vlan_get_proto(struct net_bridge *br)
+{
+	return 0;
+}
 #endif
 
 /* br_netfilter.c */
-- 
1.8.1.2
