From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bridge: allow local delivery when port is disabled
Date: Thu, 12 Dec 2013 13:41:59 -0800
Message-ID: <20131212134159.5bc985a9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:63094 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab3LLVmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 16:42:04 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so1256073pbb.37
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 13:42:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an Ethernet device is enslaved to a bridge, and the bridge STP
detects loss of carrier (or operational state down), then normally
packet reception is blocked.

This breaks control applications like WPA which maybe expecting to
receive packets to negotiate to bring link up. The bridge needs to
block forwarding packets from these disabled ports, but there is no
hard requirement to not allow local packet delivery.

In this special case, packets are not forwarded (local delivery only),
and only packet directed at the address of the Ethernet device are
accepted (no promiscuous or other ports in bridge).

The existing code already allowed link-local-address packets in
which is what STP uses to communicate with other bridges.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>

---
 net/bridge/br_input.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

--- a/net/bridge/br_input.c	2013-12-06 16:49:53.663016412 -0800
+++ b/net/bridge/br_input.c	2013-12-08 12:27:04.736572830 -0800
@@ -152,6 +152,16 @@ static int br_handle_local_finish(struct
 	return 0;	 /* process further */
 }
 
+/* Deliver packet to local host only */
+static rx_handler_result_t br_local_only(struct sk_buff *skb)
+{
+	if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+		    NULL, br_handle_local_finish))
+		return RX_HANDLER_CONSUMED; /* consumed by filter */
+	else
+		return RX_HANDLER_PASS;	/* continue processing */
+}
+
 /*
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
@@ -206,14 +216,8 @@ rx_handler_result_t br_handle_frame(stru
 				goto forward;
 		}
 
-		/* Deliver packet to local host only */
-		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-			    NULL, br_handle_local_finish)) {
-			return RX_HANDLER_CONSUMED; /* consumed by filter */
-		} else {
-			*pskb = skb;
-			return RX_HANDLER_PASS;	/* continue processing */
-		}
+		*pskb = skb;
+		return br_local_only(skb);
 	}
 
 forward:
@@ -235,6 +239,13 @@ forward:
 		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 			br_handle_frame_finish);
 		break;
+
+	case BR_STATE_DISABLED:
+		if (skb->pkt_type == PACKET_HOST) {
+			*pskb = skb;
+			return br_local_only(skb);
+		}
+		/* fall through */
 	default:
 drop:
 		kfree_skb(skb);
