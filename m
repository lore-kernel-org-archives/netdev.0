From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next 3/4] bridge: Prepare for forwarding another bridge group addresses
Date: Tue, 10 Jun 2014 20:59:24 +0900
Message-ID: <1402401565-15423-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1402401565-15423-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:47065 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbaFJMAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 08:00:19 -0400
In-Reply-To: <1402401565-15423-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a bridge is an 802.1ad bridge, it must forward another bridge group
addresses (the Nearest Customer Bridge group addresses).
(For details, see IEEE 802.1Q-2011 8.6.3.)

As user might not want group_fwd_mask to be modified by enabling 802.1ad,
introduce a new mask, group_fwd_mask_required, which indicates addresses
the bridge wants to forward. This will be set by enabling 802.1ad.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_device.c  | 1 +
 net/bridge/br_input.c   | 8 ++++++--
 net/bridge/br_private.h | 3 +++
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 1b797c4..568cccd 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -378,6 +378,7 @@ void br_dev_setup(struct net_device *dev)
 
 	br->stp_enabled = BR_NO_STP;
 	br->group_fwd_mask = BR_GROUPFWD_DEFAULT;
+	br->group_fwd_mask_required = BR_GROUPFWD_DEFAULT;
 
 	br->designated_root = br->bridge_id;
 	br->bridge_max_age = br->max_age = 20 * HZ;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 04d6348..366c436 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -177,6 +177,8 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	p = br_port_get_rcu(skb->dev);
 
 	if (unlikely(is_link_local_ether_addr(dest))) {
+		u16 fwd_mask = p->br->group_fwd_mask_required;
+
 		/*
 		 * See IEEE 802.1D Table 7-10 Reserved addresses
 		 *
@@ -194,7 +196,8 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		case 0x00:	/* Bridge Group Address */
 			/* If STP is turned off,
 			   then must forward to keep loop detection */
-			if (p->br->stp_enabled == BR_NO_STP)
+			if (p->br->stp_enabled == BR_NO_STP ||
+			    fwd_mask & (1u << dest[5]))
 				goto forward;
 			break;
 
@@ -203,7 +206,8 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 
 		default:
 			/* Allow selective forwarding for most other protocols */
-			if (p->br->group_fwd_mask & (1u << dest[5]))
+			fwd_mask |= p->br->group_fwd_mask;
+			if (fwd_mask & (1u << dest[5]))
 				goto forward;
 		}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b65fee9..ba59880 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -35,6 +35,8 @@
 #define BR_GROUPFWD_DEFAULT	0
 /* Don't allow forwarding control protocols like STP and LLDP */
 #define BR_GROUPFWD_RESTRICTED	0x4007u
+/* The Nearest Customer Bridge Group Address, 01-80-C2-00-00-[00,0B,0C,0D,0F] */
+#define BR_GROUPFWD_8021AD	0xB801u
 
 /* Path to usermode spanning tree program */
 #define BR_STP_PROG	"/sbin/bridge-stp"
@@ -232,6 +234,7 @@ struct net_bridge
 	bool				nf_call_arptables;
 #endif
 	u16				group_fwd_mask;
+	u16				group_fwd_mask_required;
 
 	/* STP */
 	bridge_id			designated_root;
-- 
1.8.1.2
