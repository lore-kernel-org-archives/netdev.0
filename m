From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net] sunvnet: only use connected ports when sending
Date: Fri, 25 Jul 2014 10:30:11 -0400
Message-ID: <1406298611.17119.5.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37131 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbaGYOaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 10:30:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The sunvnet driver doesn't check whether or not a port is connected when
transmitting packets, which results in failures if a port fails to connect
(e.g., due to a version mismatch). The original code also assumes
unnecessarily that the first port is up and a switch, even though there is
a flag for switch ports.

This patch only matches a port if it is connected, and otherwise uses the
switch_port flag to send the packet to a switch port that is up.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index fd411d6..d813bfb 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -610,6 +610,13 @@ static int __vnet_tx_trigger(struct vnet_port *port)
 	return err;
 }
 
+static inline bool port_is_up(struct vnet_port *vnet)
+{
+	struct vio_driver_state *vio = &vnet->vio;
+
+	return !!(vio->hs_state & VIO_HS_COMPLETE);
+}
+
 struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
 {
 	unsigned int hash = vnet_hashfn(skb->data);
@@ -617,14 +624,19 @@ struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
 	struct vnet_port *port;
 
 	hlist_for_each_entry(port, hp, hash) {
+		if (!port_is_up(port))
+			continue;
 		if (ether_addr_equal(port->raddr, skb->data))
 			return port;
 	}
-	port = NULL;
-	if (!list_empty(&vp->port_list))
-		port = list_entry(vp->port_list.next, struct vnet_port, list);
-
-	return port;
+	list_for_each_entry(port, &vp->port_list, list) {
+		if (!port->switch_port)
+			continue;
+		if (!port_is_up(port))
+			continue;
+		return port;
+	}
+	return NULL;
 }
 
 struct vnet_port *tx_port_find(struct vnet *vp, struct sk_buff *skb)
-- 
1.7.1
