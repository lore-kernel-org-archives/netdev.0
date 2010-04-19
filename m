From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCHv2 1/7] X25: Add if_x25.h and x25 to device identifiers
Date: Tue, 20 Apr 2010 09:28:37 +1000
Message-ID: <1271719717.2802.77.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42768 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144Ab0DSX2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 19:28:45 -0400
Received: by pwj9 with SMTP id 9so3833392pwj.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 16:28:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


V2 Feedback from John Hughes.
- Add header for userspace implementations such as xot/xoe to use
- Use explicit values for interface stability
- No changes to driver patches

V1
- Use identifiers instead of magic numbers for X25 layer 3 to device interface.
- Also fixed checkpatch notes on updated code.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 include/linux/if_x25.h  |   26 ++++++++++++++++++++++++++
 include/net/x25device.h |    1 +
 net/x25/x25_dev.c       |   36 ++++++++++++++++++++----------------
 3 files changed, 47 insertions(+), 16 deletions(-)
 create mode 100644 include/linux/if_x25.h

diff --git a/include/linux/if_x25.h b/include/linux/if_x25.h
new file mode 100644
index 0000000..897765f
--- /dev/null
+++ b/include/linux/if_x25.h
@@ -0,0 +1,26 @@
+/*
+ *  Linux X.25 packet to device interface
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ *  GNU General Public License for more details.
+ */
+
+#ifndef _IF_X25_H
+#define _IF_X25_H
+
+#include <linux/types.h>
+
+/* Documentation/networking/x25-iface.txt */
+#define X25_IFACE_DATA		0x00
+#define X25_IFACE_CONNECT	0x01
+#define X25_IFACE_DISCONNECT	0x02
+#define X25_IFACE_PARAMS	0x03
+
+#endif /* _IF_X25_H */
diff --git a/include/net/x25device.h b/include/net/x25device.h
index 1415bcf..1fa08b4 100644
--- a/include/net/x25device.h
+++ b/include/net/x25device.h
@@ -3,6 +3,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
+#include <linux/if_x25.h>
 #include <linux/skbuff.h>
 
 static inline __be16 x25_type_trans(struct sk_buff *skb, struct net_device *dev)
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


