From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 2/9] batman-adv: Calculate correct size for merged packets
Date: Mon, 31 Jan 2011 16:20:44 +0100
Message-ID: <1296487251-12552-3-git-send-email-sven@narfation.org>
References: <1296487251-12552-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:42649 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997Ab1AaPVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:21:10 -0500
In-Reply-To: <1296487251-12552-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The routing algorithm must be able to decide if a fragment can be merged with
the missing part and still be passed to a forwarding interface. The fragments
can only differ by one byte in case that the original payload had an uneven
length. In that situation the sender has to inform all possible receivers that
the tail is one byte longer using the flag UNI_FRAG_LARGETAIL.

The combination of UNI_FRAG_LARGETAIL and UNI_FRAG_HEAD flag makes it possible
to calculate the correct length for even and uneven sized payloads.

The original formula missed to add the unicast header at all and forgot to
remove the fragment header of the second fragment. This made the results highly
unreliable and only useful for machines with large differences between the
configured MTUs.

Reported-by: Russell Senior <russell@personaltelco.net>
Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/packet.h  |    1 +
 net/batman-adv/routing.c |    2 +-
 net/batman-adv/unicast.c |    8 ++++++--
 net/batman-adv/unicast.h |   23 +++++++++++++++++++++++
 4 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 2284e81..03ce0d3 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -50,6 +50,7 @@
 
 /* fragmentation defines */
 #define UNI_FRAG_HEAD 0x01
+#define UNI_FRAG_LARGETAIL 0x02
 
 struct batman_packet {
 	uint8_t  packet_type;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8828edd..a8cd389 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1193,7 +1193,7 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 				     dstaddr);
 
 	if (unicast_packet->packet_type == BAT_UNICAST_FRAG &&
-	    2 * skb->len - hdr_size <= batman_if->net_dev->mtu) {
+	    frag_can_reassemble(skb, batman_if->net_dev->mtu)) {
 
 		ret = frag_reassemble_skb(skb, bat_priv, &new_skb);
 
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 811f7fc..fc77079 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -225,6 +225,7 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	int uc_hdr_len = sizeof(struct unicast_packet);
 	int ucf_hdr_len = sizeof(struct unicast_frag_packet);
 	int data_len = skb->len - uc_hdr_len;
+	int large_tail = 0;
 
 	if (!bat_priv->primary_if)
 		goto dropped;
@@ -254,8 +255,11 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	memcpy(frag1->orig, bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(frag2, frag1, sizeof(struct unicast_frag_packet));
 
-	frag1->flags |= UNI_FRAG_HEAD;
-	frag2->flags &= ~UNI_FRAG_HEAD;
+	if (data_len & 1)
+		large_tail = UNI_FRAG_LARGETAIL;
+
+	frag1->flags = UNI_FRAG_HEAD | large_tail;
+	frag2->flags = large_tail;
 
 	frag1->seqno = htons((uint16_t)atomic_inc_return(
 			     &batman_if->frag_seqno));
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index e32b786..e7211c2 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -22,6 +22,8 @@
 #ifndef _NET_BATMAN_ADV_UNICAST_H_
 #define _NET_BATMAN_ADV_UNICAST_H_
 
+#include "packet.h"
+
 #define FRAG_TIMEOUT 10000	/* purge frag list entrys after time in ms */
 #define FRAG_BUFFER_SIZE 6	/* number of list elements in buffer */
 
@@ -32,4 +34,25 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv);
 int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 		  struct batman_if *batman_if, uint8_t dstaddr[]);
 
+static inline int frag_can_reassemble(struct sk_buff *skb, int mtu)
+{
+	struct unicast_frag_packet *unicast_packet;
+	int uneven_correction = 0;
+	unsigned int merged_size;
+
+	unicast_packet = (struct unicast_frag_packet *)skb->data;
+
+	if (unicast_packet->flags & UNI_FRAG_LARGETAIL) {
+		if (unicast_packet->flags & UNI_FRAG_HEAD)
+			uneven_correction = 1;
+		else
+			uneven_correction = -1;
+	}
+
+	merged_size = (skb->len - sizeof(struct unicast_frag_packet)) * 2;
+	merged_size += sizeof(struct unicast_packet) + uneven_correction;
+
+	return merged_size <= mtu;
+}
+
 #endif /* _NET_BATMAN_ADV_UNICAST_H_ */
-- 
1.7.2.3

