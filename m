From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH] net: bridge: fix for bridging 802.1Q without REORDER_HDR
Date: Fri, 11 Sep 2015 21:22:03 +0200
Message-ID: <1441999323-29381-1-git-send-email-phil@nwl.cc>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:55179 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890AbbIKTWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2015 15:22:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When forwarding packets from an 802.1Q interface with REORDER_HDR set to
zero, the VLAN header previously inserted by vlan_do_receive() needs to
be stripped from the packet and the mac_header adjustment undone,
otherwise a tagged frame with first four bytes missing will be
transmitted.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/bridge/br_input.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f921a5d..e4e3fc7 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -288,6 +288,16 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	}
 
 forward:
+	if (is_vlan_dev(skb->dev) &&
+	    !(vlan_dev_priv(skb->dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+		unsigned int offset = skb->data - skb_mac_header(skb);
+
+		skb_push(skb, offset);
+		memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
+		skb->mac_header += VLAN_HLEN;
+		skb_pull(skb, offset);
+		skb_reset_mac_len(skb);
+	}
 	switch (p->state) {
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
-- 
2.1.2
