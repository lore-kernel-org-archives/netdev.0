From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/6] can: add missing initialisations in CAN related skbuffs
Date: Mon,  9 Mar 2015 10:36:16 +0100
Message-ID: <1425893781-10867-2-git-send-email-mkl@pengutronix.de>
References: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50309 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbbCIJgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:36:32 -0400
In-Reply-To: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

When accessing CAN network interfaces with AF_PACKET sockets e.g. by dhclient
this can lead to a skb_under_panic due to missing skb initialisations.

Add the missing initialisations at the CAN skbuff creation times on driver
level (rx path) and in the network layer (tx path).

Reported-by: Austin Schuh <austin@peloton-tech.com>
Reported-by: Daniel Steer <daniel.steer@mclaren.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c | 8 ++++++++
 net/can/af_can.c      | 3 +++
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 3c82e02e3dae..b0f69248cb71 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -579,6 +579,10 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 
@@ -603,6 +607,10 @@ struct sk_buff *alloc_canfd_skb(struct net_device *dev,
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 66e08040ced7..32d710eaf1fc 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -259,6 +259,9 @@ int can_send(struct sk_buff *skb, int loop)
 		goto inval_skb;
 	}
 
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 
-- 
2.1.4
