From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/16] batman-adv: Check total_size when queueing fragments
Date: Fri, 29 May 2015 11:05:15 +0200
Message-ID: <1432890328-8247-4-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:14791 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030207AbbE2Jcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:32:42 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

The fragmentation code was replaced in
610bfc6bc99bc83680d190ebc69359a05fc7f605 ("batman-adv: Receive fragment=
ed
packets and merge") by an implementation which handles the queueing+mer=
ging
of fragments based on their size and the total_size of the non-fragment=
ed
packet. This total_size is announced by each fragment. The new
implementation doesn't check if the the total_size information of the
packets inside one chain is consistent.

This is consistency check is recommended to allow using any of the pack=
ets
in the queue to decide whether all fragments of a packet are received o=
r
not.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/fragmentation.c | 7 +++++--
 net/batman-adv/types.h         | 2 ++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index af495cc..a9fc653 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -161,6 +161,7 @@ static bool batadv_frag_insert_packet(struct batadv=
_orig_node *orig_node,
 		hlist_add_head(&frag_entry_new->list, &chain->head);
 		chain->size =3D skb->len - hdr_size;
 		chain->timestamp =3D jiffies;
+		chain->total_size =3D ntohs(frag_packet->total_size);
 		ret =3D true;
 		goto out;
 	}
@@ -195,9 +196,11 @@ static bool batadv_frag_insert_packet(struct batad=
v_orig_node *orig_node,
=20
 out:
 	if (chain->size > batadv_frag_size_limit() ||
-	    ntohs(frag_packet->total_size) > batadv_frag_size_limit()) {
+	    chain->total_size !=3D ntohs(frag_packet->total_size) ||
+	    chain->total_size > batadv_frag_size_limit()) {
 		/* Clear chain if total size of either the list or the packet
-		 * exceeds the maximum size of one merged packet.
+		 * exceeds the maximum size of one merged packet. Don't allow
+		 * packets to have different total_size.
 		 */
 		batadv_frag_clear_chain(&chain->head);
 		chain->size =3D 0;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 28f2461..e95db42 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -132,6 +132,7 @@ struct batadv_orig_ifinfo {
  * @timestamp: time (jiffie) of last received fragment
  * @seqno: sequence number of the fragments in the list
  * @size: accumulated size of packets in list
+ * @total_size: expected size of the assembled packet
  */
 struct batadv_frag_table_entry {
 	struct hlist_head head;
@@ -139,6 +140,7 @@ struct batadv_frag_table_entry {
 	unsigned long timestamp;
 	uint16_t seqno;
 	uint16_t size;
+	uint16_t total_size;
 };
=20
 /**
--=20
2.4.2
