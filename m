From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipvlan: fix leak in ipvlan_rcv_frame
Date: Mon, 16 Nov 2015 22:34:26 +0100
Message-ID: <d903709e25790603ab7ba0f43c79171da8485af6.1447705694.git.sd@queasysnail.net>
Cc: maheshb@google.com, Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752460AbbKPVf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 16:35:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass a **skb to ipvlan_rcv_frame so that if skb_share_check returns a
new skb, we actually use it during further processing.

It's safe to ignore the new skb in the ipvlan_xmit_* functions, because
they call ipvlan_rcv_frame with local == true, so that dev_forward_skb
is called and always takes ownership of the skb.

Fixes: 2ad7bf363841 ("ipvlan: Initial check-in of the IPVLAN driver.")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ipvlan/ipvlan_core.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index d50887e3df6d..a9148e46dad0 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -254,7 +254,7 @@ acct:
 	}
 }
 
-static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff *skb,
+static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff **pskb,
 			    bool local)
 {
 	struct ipvl_dev *ipvlan = addr->master;
@@ -262,6 +262,7 @@ static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff *skb,
 	unsigned int len;
 	rx_handler_result_t ret = RX_HANDLER_CONSUMED;
 	bool success = false;
+	struct sk_buff *skb = *pskb;
 
 	len = skb->len + ETH_HLEN;
 	if (unlikely(!(dev->flags & IFF_UP))) {
@@ -273,6 +274,7 @@ static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff *skb,
 	if (!skb)
 		goto out;
 
+	*pskb = skb;
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 
@@ -486,7 +488,7 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 
 	addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
 	if (addr)
-		return ipvlan_rcv_frame(addr, skb, true);
+		return ipvlan_rcv_frame(addr, &skb, true);
 
 out:
 	skb->dev = ipvlan->phy_dev;
@@ -506,7 +508,7 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		if (lyr3h) {
 			addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
 			if (addr)
-				return ipvlan_rcv_frame(addr, skb, true);
+				return ipvlan_rcv_frame(addr, &skb, true);
 		}
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (!skb)
@@ -589,7 +591,7 @@ static rx_handler_result_t ipvlan_handle_mode_l3(struct sk_buff **pskb,
 
 	addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
 	if (addr)
-		ret = ipvlan_rcv_frame(addr, skb, false);
+		ret = ipvlan_rcv_frame(addr, pskb, false);
 
 out:
 	return ret;
@@ -626,7 +628,7 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 
 		addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
 		if (addr)
-			ret = ipvlan_rcv_frame(addr, skb, false);
+			ret = ipvlan_rcv_frame(addr, pskb, false);
 	}
 
 	return ret;
-- 
2.6.2
