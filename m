From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 1/6] X25: Use identifiers for X25 to device interface
Date: Sun, 18 Apr 2010 19:51:50 +1000
Message-ID: <1271584310.6280.425.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:51633 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938Ab0DRJv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 05:51:56 -0400
Received: by pzk42 with SMTP id 42so2814816pzk.4
        for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 02:51:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use identifiers in x25_device.h instead of magic numbers for X25 layer 3 to device interface.
Also fixed checkpatch notes on updated code.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 Documentation/networking/x25-iface.txt |   16 +++++++-------
 include/net/x25device.h                |    8 +++++++
 net/x25/x25_dev.c                      |   36 +++++++++++++++++--------------
 3 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/Documentation/networking/x25-iface.txt b/Documentation/networking/x25-iface.txt
index 975cc87..78f662e 100644
--- a/Documentation/networking/x25-iface.txt
+++ b/Documentation/networking/x25-iface.txt
@@ -20,23 +20,23 @@ the rest of the skbuff, if any more information does exist.
 Packet Layer to Device Driver
 -----------------------------
 
-First Byte = 0x00
+First Byte = 0x00 (X25_IFACE_DATA)
 
 This indicates that the rest of the skbuff contains data to be transmitted
 over the LAPB link. The LAPB link should already exist before any data is
 passed down.
 
-First Byte = 0x01
+First Byte = 0x01 (X25_IFACE_CONNECT)
 
 Establish the LAPB link. If the link is already established then the connect
 confirmation message should be returned as soon as possible.
 
-First Byte = 0x02
+First Byte = 0x02 (X25_IFACE_DISCONNECT)
 
 Terminate the LAPB link. If it is already disconnected then the disconnect
 confirmation message should be returned as soon as possible.
 
-First Byte = 0x03
+First Byte = 0x03 (X25_IFACE_PARAMS)
 
 LAPB parameters. To be defined.
 
@@ -44,22 +44,22 @@ LAPB parameters. To be defined.
 Device Driver to Packet Layer
 -----------------------------
 
-First Byte = 0x00
+First Byte = 0x00 (X25_IFACE_DATA)
 
 This indicates that the rest of the skbuff contains data that has been
 received over the LAPB link.
 
-First Byte = 0x01
+First Byte = 0x01 (X25_IFACE_CONNECT)
 
 LAPB link has been established. The same message is used for both a LAPB
 link connect_confirmation and a connect_indication.
 
-First Byte = 0x02
+First Byte = 0x02 (X25_IFACE_DISCONNECT)
 
 LAPB link has been terminated. This same message is used for both a LAPB
 link disconnect_confirmation and a disconnect_indication.
 
-First Byte = 0x03
+First Byte = 0x03 (X25_IFACE_PARAMS)
 
 LAPB parameters. To be defined.
 
diff --git a/include/net/x25device.h b/include/net/x25device.h
index 1415bcf..51f8902 100644
--- a/include/net/x25device.h
+++ b/include/net/x25device.h
@@ -13,4 +13,12 @@ static inline __be16 x25_type_trans(struct sk_buff *skb, struct net_device *dev)
 	
 	return htons(ETH_P_X25);
 }
+
+enum {
+	X25_IFACE_DATA,
+	X25_IFACE_CONNECT,
+	X25_IFACE_DISCONNECT,
+	X25_IFACE_PARAMS
+};
+
 #endif
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index b9ef682..9005f6d 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -24,6 +24,7 @@
 #include <net/sock.h>
 #include <linux/if_arp.h>
 #include <net/x25.h>
+#include <net/x25device.h>
 
 static int x25_receive_data(struct sk_buff *skb, struct x25_neigh *nb)
 {
@@ -115,19 +116,22 @@ int x25_lapb_receive_frame(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	switch (skb->data[0]) {
-		case 0x00:
-			skb_pull(skb, 1);
-			if (x25_receive_data(skb, nb)) {
-				x25_neigh_put(nb);
-				goto out;
-			}
-			break;
-		case 0x01:
-			x25_link_established(nb);
-			break;
-		case 0x02:
-			x25_link_terminated(nb);
-			break;
+
+	case X25_IFACE_DATA:
+		skb_pull(skb, 1);
+		if (x25_receive_data(skb, nb)) {
+			x25_neigh_put(nb);
+			goto out;
+		}
+		break;
+
+	case X25_IFACE_CONNECT:
+		x25_link_established(nb);
+		break;
+
+	case X25_IFACE_DISCONNECT:
+		x25_link_terminated(nb);
+		break;
 	}
 	x25_neigh_put(nb);
 drop:
@@ -148,7 +152,7 @@ void x25_establish_link(struct x25_neigh *nb)
 				return;
 			}
 			ptr  = skb_put(skb, 1);
-			*ptr = 0x01;
+			*ptr = X25_IFACE_CONNECT;
 			break;
 
 #if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
@@ -184,7 +188,7 @@ void x25_terminate_link(struct x25_neigh *nb)
 	}
 
 	ptr  = skb_put(skb, 1);
-	*ptr = 0x02;
+	*ptr = X25_IFACE_DISCONNECT;
 
 	skb->protocol = htons(ETH_P_X25);
 	skb->dev      = nb->dev;
@@ -200,7 +204,7 @@ void x25_send_frame(struct sk_buff *skb, struct x25_neigh *nb)
 	switch (nb->dev->type) {
 		case ARPHRD_X25:
 			dptr  = skb_push(skb, 1);
-			*dptr = 0x00;
+			*dptr = X25_IFACE_DATA;
 			break;
 
 #if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
-- 
1.5.6.5



