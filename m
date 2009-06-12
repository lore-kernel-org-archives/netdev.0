From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network drivers ndo_start_xmit() return values (part 4)
Date: Fri, 12 Jun 2009 16:37:34 +0200
Message-ID: <4A32682E.5030402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040002080600080201040205"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46403 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763514AbZFLOhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 10:37:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040002080600080201040205
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Only a single driver handled by this patch, drivers/net/wan
initially appeared to need more fixups.


--------------040002080600080201040205
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

commit 0ede7036a67cd605c3717824f76518f5913ca3af
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 16:36:18 2009 +0200

    net: fix network drivers ndo_start_xmit() return values (part 4)
    
    Fix up WAN drivers that return an errno value to qdisc_restart(), causing
    qdisc_restart() to print a warning an requeue/retransmit the skb.
    
    - cycx_x25: intention appears to be to requeue the skb
    
    Does not compile cleanly for me even without this patch, so untested.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index 35dea3b..f525f9f 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -615,7 +615,7 @@ static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 		case WAN_DISCONNECTED:
 			if (cycx_x25_chan_connect(dev)) {
 				netif_stop_queue(dev);
-				return -EBUSY;
+				return NETDEV_TX_BUSY;
 			}
 			/* fall thru */
 		case WAN_CONNECTED:
@@ -624,7 +624,7 @@ static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 			netif_stop_queue(dev);
 
 			if (cycx_x25_chan_send(dev, skb))
-				return -EBUSY;
+				return NETDEV_TX_BUSY;
 
 			break;
 		default:
@@ -656,7 +656,7 @@ static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 		if (cycx_x25_chan_send(dev, skb)) {
 			/* prepare for future retransmissions */
 			skb_push(skb, 1);
-			return -EBUSY;
+			return NETDEV_TX_BUSY;
 		}
 	}
 

--------------040002080600080201040205--
