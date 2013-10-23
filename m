From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 16/16] batman-adv: generalize batman-adv icmp packet handling
Date: Wed, 23 Oct 2013 18:05:03 +0200
Message-ID: <1382544303-2694-17-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:47628 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab3JWQMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:12:24 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Instead of handling icmp packets only up to length of icmp_packet_rr,
the code should handle any icmp length size. Therefore the length
truncating is moved to when the packet is actually sent to userspace
(this does not support lengths longer than icmp_packet_rr yet). Longer
packets are forwarded without truncating.

This patch also cleans up some parts where the icmp header struct could
be used instead of other icmp_packet(_rr) structs to make the code more
readable.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/icmp_socket.c | 128 +++++++++++++++++++++++++++----------------
 net/batman-adv/icmp_socket.h |   2 +-
 net/batman-adv/packet.h      |   2 +
 net/batman-adv/routing.c     | 120 ++++++++++++++++++++++++----------------
 net/batman-adv/types.h       |   2 +-
 5 files changed, 157 insertions(+), 97 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 82ac647..29ae4ef 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -29,7 +29,7 @@
 static struct batadv_socket_client *batadv_socket_client_hash[256];
 
 static void batadv_socket_add_packet(struct batadv_socket_client *socket_client,
-				     struct batadv_icmp_packet_rr *icmp_packet,
+				     struct batadv_icmp_header *icmph,
 				     size_t icmp_len);
 
 void batadv_socket_init(void)
@@ -155,13 +155,13 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 	struct batadv_priv *bat_priv = socket_client->bat_priv;
 	struct batadv_hard_iface *primary_if = NULL;
 	struct sk_buff *skb;
-	struct batadv_icmp_packet_rr *icmp_packet;
-
+	struct batadv_icmp_packet_rr *icmp_packet_rr;
+	struct batadv_icmp_header *icmp_header;
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_neigh_node *neigh_node = NULL;
 	size_t packet_len = sizeof(struct batadv_icmp_packet);
 
-	if (len < sizeof(struct batadv_icmp_packet)) {
+	if (len < sizeof(struct batadv_icmp_header)) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: invalid packet size\n");
 		return -EINVAL;
@@ -174,8 +174,10 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 		goto out;
 	}
 
-	if (len >= sizeof(struct batadv_icmp_packet_rr))
-		packet_len = sizeof(struct batadv_icmp_packet_rr);
+	if (len >= BATADV_ICMP_MAX_PACKET_SIZE)
+		packet_len = BATADV_ICMP_MAX_PACKET_SIZE;
+	else
+		packet_len = len;
 
 	skb = netdev_alloc_skb_ip_align(NULL, packet_len + ETH_HLEN);
 	if (!skb) {
@@ -185,67 +187,78 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 
 	skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(skb, ETH_HLEN);
-	icmp_packet = (struct batadv_icmp_packet_rr *)skb_put(skb, packet_len);
+	icmp_header = (struct batadv_icmp_header *)skb_put(skb, packet_len);
 
-	if (copy_from_user(icmp_packet, buff, packet_len)) {
+	if (copy_from_user(icmp_header, buff, packet_len)) {
 		len = -EFAULT;
 		goto free_skb;
 	}
 
-	if (icmp_packet->icmph.header.packet_type != BATADV_ICMP) {
+	if (icmp_header->header.packet_type != BATADV_ICMP) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: got bogus packet type (expected: BAT_ICMP)\n");
 		len = -EINVAL;
 		goto free_skb;
 	}
 
-	if (icmp_packet->icmph.msg_type != BATADV_ECHO_REQUEST) {
+	switch (icmp_header->msg_type) {
+	case BATADV_ECHO_REQUEST:
+		if (len < sizeof(struct batadv_icmp_packet)) {
+			batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+				   "Error - can't send packet from char device: invalid packet size\n");
+			len = -EINVAL;
+			goto free_skb;
+		}
+
+		if (atomic_read(&bat_priv->mesh_state) != BATADV_MESH_ACTIVE)
+			goto dst_unreach;
+
+		orig_node = batadv_orig_hash_find(bat_priv, icmp_header->dst);
+		if (!orig_node)
+			goto dst_unreach;
+
+		neigh_node = batadv_orig_node_get_router(orig_node);
+		if (!neigh_node)
+			goto dst_unreach;
+
+		if (!neigh_node->if_incoming)
+			goto dst_unreach;
+
+		if (neigh_node->if_incoming->if_status != BATADV_IF_ACTIVE)
+			goto dst_unreach;
+
+		icmp_packet_rr = (struct batadv_icmp_packet_rr *)icmp_header;
+		if (packet_len == sizeof(*icmp_packet_rr))
+			memcpy(icmp_packet_rr->rr,
+			       neigh_node->if_incoming->net_dev->dev_addr,
+			       ETH_ALEN);
+
+		break;
+	default:
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Error - can't send packet from char device: got bogus message type (expected: ECHO_REQUEST)\n");
+			   "Error - can't send packet from char device: got unknown message type\n");
 		len = -EINVAL;
 		goto free_skb;
 	}
 
-	icmp_packet->icmph.uid = socket_client->index;
+	icmp_header->uid = socket_client->index;
 
-	if (icmp_packet->icmph.header.version != BATADV_COMPAT_VERSION) {
-		icmp_packet->icmph.msg_type = BATADV_PARAMETER_PROBLEM;
-		icmp_packet->icmph.header.version = BATADV_COMPAT_VERSION;
-		batadv_socket_add_packet(socket_client, icmp_packet,
+	if (icmp_header->header.version != BATADV_COMPAT_VERSION) {
+		icmp_header->msg_type = BATADV_PARAMETER_PROBLEM;
+		icmp_header->header.version = BATADV_COMPAT_VERSION;
+		batadv_socket_add_packet(socket_client, icmp_header,
 					 packet_len);
 		goto free_skb;
 	}
 
-	if (atomic_read(&bat_priv->mesh_state) != BATADV_MESH_ACTIVE)
-		goto dst_unreach;
-
-	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->icmph.dst);
-	if (!orig_node)
-		goto dst_unreach;
-
-	neigh_node = batadv_orig_node_get_router(orig_node);
-	if (!neigh_node)
-		goto dst_unreach;
-
-	if (!neigh_node->if_incoming)
-		goto dst_unreach;
-
-	if (neigh_node->if_incoming->if_status != BATADV_IF_ACTIVE)
-		goto dst_unreach;
-
-	memcpy(icmp_packet->icmph.orig,
-	       primary_if->net_dev->dev_addr, ETH_ALEN);
-
-	if (packet_len == sizeof(struct batadv_icmp_packet_rr))
-		memcpy(icmp_packet->rr,
-		       neigh_node->if_incoming->net_dev->dev_addr, ETH_ALEN);
+	memcpy(icmp_header->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 
 	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	goto out;
 
 dst_unreach:
-	icmp_packet->icmph.msg_type = BATADV_DESTINATION_UNREACHABLE;
-	batadv_socket_add_packet(socket_client, icmp_packet, packet_len);
+	icmp_header->msg_type = BATADV_DESTINATION_UNREACHABLE;
+	batadv_socket_add_packet(socket_client, icmp_header, packet_len);
 free_skb:
 	kfree_skb(skb);
 out:
@@ -298,27 +311,40 @@ err:
 	return -ENOMEM;
 }
 
+/**
+ * batadv_socket_receive_packet - schedule an icmp packet to be sent to userspace
+ *  on an icmp socket.
+ * @socket_client: the socket this packet belongs to
+ * @icmph: pointer to the header of the icmp packet
+ * @icmp_len: total length of the icmp packet
+ */
 static void batadv_socket_add_packet(struct batadv_socket_client *socket_client,
-				     struct batadv_icmp_packet_rr *icmp_packet,
+				     struct batadv_icmp_header *icmph,
 				     size_t icmp_len)
 {
 	struct batadv_socket_packet *socket_packet;
+	size_t len;
 
 	socket_packet = kmalloc(sizeof(*socket_packet), GFP_ATOMIC);
 
 	if (!socket_packet)
 		return;
 
+	len = icmp_len;
+	/* check the maximum length before filling the buffer */
+	if (len > sizeof(socket_packet->icmp_packet))
+		len = sizeof(socket_packet->icmp_packet);
+
 	INIT_LIST_HEAD(&socket_packet->list);
-	memcpy(&socket_packet->icmp_packet, icmp_packet, icmp_len);
-	socket_packet->icmp_len = icmp_len;
+	memcpy(&socket_packet->icmp_packet, icmph, len);
+	socket_packet->icmp_len = len;
 
 	spin_lock_bh(&socket_client->lock);
 
 	/* while waiting for the lock the socket_client could have been
 	 * deleted
 	 */
-	if (!batadv_socket_client_hash[icmp_packet->icmph.uid]) {
+	if (!batadv_socket_client_hash[icmph->uid]) {
 		spin_unlock_bh(&socket_client->lock);
 		kfree(socket_packet);
 		return;
@@ -342,12 +368,18 @@ static void batadv_socket_add_packet(struct batadv_socket_client *socket_client,
 	wake_up(&socket_client->queue_wait);
 }
 
-void batadv_socket_receive_packet(struct batadv_icmp_packet_rr *icmp_packet,
+/**
+ * batadv_socket_receive_packet - schedule an icmp packet to be received
+ *  locally and sent to userspace.
+ * @icmph: pointer to the header of the icmp packet
+ * @icmp_len: total length of the icmp packet
+ */
+void batadv_socket_receive_packet(struct batadv_icmp_header *icmph,
 				  size_t icmp_len)
 {
 	struct batadv_socket_client *hash;
 
-	hash = batadv_socket_client_hash[icmp_packet->icmph.uid];
+	hash = batadv_socket_client_hash[icmph->uid];
 	if (hash)
-		batadv_socket_add_packet(hash, icmp_packet, icmp_len);
+		batadv_socket_add_packet(hash, icmph, icmp_len);
 }
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 1fcca37..6665080 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -24,7 +24,7 @@
 
 void batadv_socket_init(void);
 int batadv_socket_setup(struct batadv_priv *bat_priv);
-void batadv_socket_receive_packet(struct batadv_icmp_packet_rr *icmp_packet,
+void batadv_socket_receive_packet(struct batadv_icmp_header *icmph,
 				  size_t icmp_len);
 
 #endif /* _NET_BATMAN_ADV_ICMP_SOCKET_H_ */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 843b96a..207459b 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -239,6 +239,8 @@ struct batadv_icmp_packet_rr {
 	uint8_t  rr[BATADV_RR_LEN][ETH_ALEN];
 };
 
+#define BATADV_ICMP_MAX_PACKET_SIZE	sizeof(struct batadv_icmp_packet_rr)
+
 /* All packet headers in front of an ethernet header have to be completely
  * divisible by 2 but not by 4 to make the payload after the ethernet
  * header again 4 bytes boundary aligned.
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 71fba14..d4114d7 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -260,47 +260,65 @@ bool batadv_check_management_packet(struct sk_buff *skb,
 	return true;
 }
 
+/**
+ * batadv_recv_my_icmp_packet - receive an icmp packet locally
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: icmp packet to process
+ *
+ * Returns NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
+ * otherwise.
+ */
 static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
-				      struct sk_buff *skb, size_t icmp_len)
+				      struct sk_buff *skb)
 {
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_orig_node *orig_node = NULL;
-	struct batadv_icmp_packet_rr *icmp_packet;
-	int ret = NET_RX_DROP;
+	struct batadv_icmp_header *icmph;
+	int res, ret = NET_RX_DROP;
 
-	icmp_packet = (struct batadv_icmp_packet_rr *)skb->data;
+	icmph = (struct batadv_icmp_header *)skb->data;
 
-	/* add data to device queue */
-	if (icmp_packet->icmph.msg_type != BATADV_ECHO_REQUEST) {
-		batadv_socket_receive_packet(icmp_packet, icmp_len);
-		goto out;
-	}
+	switch (icmph->msg_type) {
+	case BATADV_ECHO_REPLY:
+	case BATADV_DESTINATION_UNREACHABLE:
+	case BATADV_TTL_EXCEEDED:
+		/* receive the packet */
+		if (skb_linearize(skb) < 0)
+			break;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
+		batadv_socket_receive_packet(icmph, skb->len);
+		break;
+	case BATADV_ECHO_REQUEST:
+		/* answer echo request (ping) */
+		primary_if = batadv_primary_if_get_selected(bat_priv);
+		if (!primary_if)
+			goto out;
 
-	/* answer echo request (ping) */
-	/* get routing information */
-	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->icmph.orig);
-	if (!orig_node)
-		goto out;
+		/* get routing information */
+		orig_node = batadv_orig_hash_find(bat_priv, icmph->orig);
+		if (!orig_node)
+			goto out;
 
-	/* create a copy of the skb, if needed, to modify it. */
-	if (skb_cow(skb, ETH_HLEN) < 0)
-		goto out;
+		/* create a copy of the skb, if needed, to modify it. */
+		if (skb_cow(skb, ETH_HLEN) < 0)
+			goto out;
 
-	icmp_packet = (struct batadv_icmp_packet_rr *)skb->data;
+		icmph = (struct batadv_icmp_header *)skb->data;
 
-	memcpy(icmp_packet->icmph.dst, icmp_packet->icmph.orig, ETH_ALEN);
-	memcpy(icmp_packet->icmph.orig, primary_if->net_dev->dev_addr,
-	       ETH_ALEN);
-	icmp_packet->icmph.msg_type = BATADV_ECHO_REPLY;
-	icmp_packet->icmph.header.ttl = BATADV_TTL;
+		memcpy(icmph->dst, icmph->orig, ETH_ALEN);
+		memcpy(icmph->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
+		icmph->msg_type = BATADV_ECHO_REPLY;
+		icmph->header.ttl = BATADV_TTL;
 
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
-		ret = NET_RX_SUCCESS;
+		res = batadv_send_skb_to_orig(skb, orig_node, NULL);
+		if (res != NET_XMIT_DROP)
+			ret = NET_RX_SUCCESS;
 
+		break;
+	default:
+		/* drop unknown type */
+		goto out;
+	}
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
@@ -363,16 +381,13 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 			    struct batadv_hard_iface *recv_if)
 {
 	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
-	struct batadv_icmp_packet_rr *icmp_packet;
+	struct batadv_icmp_header *icmph;
+	struct batadv_icmp_packet_rr *icmp_packet_rr;
 	struct ethhdr *ethhdr;
 	struct batadv_orig_node *orig_node = NULL;
-	int hdr_size = sizeof(struct batadv_icmp_packet);
+	int hdr_size = sizeof(struct batadv_icmp_header);
 	int ret = NET_RX_DROP;
 
-	/* we truncate all incoming icmp packets if they don't match our size */
-	if (skb->len >= sizeof(struct batadv_icmp_packet_rr))
-		hdr_size = sizeof(struct batadv_icmp_packet_rr);
-
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
 		goto out;
@@ -391,28 +406,39 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	if (!batadv_is_my_mac(bat_priv, ethhdr->h_dest))
 		goto out;
 
-	icmp_packet = (struct batadv_icmp_packet_rr *)skb->data;
+	icmph = (struct batadv_icmp_header *)skb->data;
 
 	/* add record route information if not full */
-	if ((icmp_packet->icmph.msg_type == BATADV_ECHO_REPLY ||
-	     icmp_packet->icmph.msg_type == BATADV_ECHO_REQUEST) &&
-	    (hdr_size == sizeof(struct batadv_icmp_packet_rr)) &&
-	    (icmp_packet->rr_cur < BATADV_RR_LEN)) {
-		memcpy(&(icmp_packet->rr[icmp_packet->rr_cur]),
+	if ((icmph->msg_type == BATADV_ECHO_REPLY ||
+	     icmph->msg_type == BATADV_ECHO_REQUEST) &&
+	    (skb->len >= sizeof(struct batadv_icmp_packet_rr))) {
+		if (skb_linearize(skb) < 0)
+			goto out;
+
+		/* create a copy of the skb, if needed, to modify it. */
+		if (skb_cow(skb, ETH_HLEN) < 0)
+			goto out;
+
+		icmph = (struct batadv_icmp_header *)skb->data;
+		icmp_packet_rr = (struct batadv_icmp_packet_rr *)icmph;
+		if (icmp_packet_rr->rr_cur >= BATADV_RR_LEN)
+			goto out;
+
+		memcpy(&(icmp_packet_rr->rr[icmp_packet_rr->rr_cur]),
 		       ethhdr->h_dest, ETH_ALEN);
-		icmp_packet->rr_cur++;
+		icmp_packet_rr->rr_cur++;
 	}
 
 	/* packet for me */
-	if (batadv_is_my_mac(bat_priv, icmp_packet->icmph.dst))
-		return batadv_recv_my_icmp_packet(bat_priv, skb, hdr_size);
+	if (batadv_is_my_mac(bat_priv, icmph->dst))
+		return batadv_recv_my_icmp_packet(bat_priv, skb);
 
 	/* TTL exceeded */
-	if (icmp_packet->icmph.header.ttl < 2)
+	if (icmph->header.ttl < 2)
 		return batadv_recv_icmp_ttl_exceeded(bat_priv, skb);
 
 	/* get routing information */
-	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->icmph.dst);
+	orig_node = batadv_orig_hash_find(bat_priv, icmph->dst);
 	if (!orig_node)
 		goto out;
 
@@ -420,10 +446,10 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
 
-	icmp_packet = (struct batadv_icmp_packet_rr *)skb->data;
+	icmph = (struct batadv_icmp_header *)skb->data;
 
 	/* decrement ttl */
-	icmp_packet->icmph.header.ttl--;
+	icmph->header.ttl--;
 
 	/* route it */
 	if (batadv_send_skb_to_orig(skb, orig_node, recv_if) != NET_XMIT_DROP)
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 3c21162..91dd369 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -749,7 +749,7 @@ struct batadv_socket_client {
 struct batadv_socket_packet {
 	struct list_head list;
 	size_t icmp_len;
-	struct batadv_icmp_packet_rr icmp_packet;
+	uint8_t icmp_packet[BATADV_ICMP_MAX_PACKET_SIZE];
 };
 
 /**
-- 
1.8.4
