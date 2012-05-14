From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/8] batman-adv: improve unicast packet (re)routing
Date: Mon, 14 May 2012 09:17:32 +0200
Message-ID: <1336979858-13928-3-git-send-email-ordex@autistici.org>
References: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:51710 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610Ab2ENHRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:17:09 -0400
In-Reply-To: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of a client X roaming from a generic node A to another node B, it is
possible that a third node C gets A's OGM but not B's. At this point in time, if
C wants to send data to X it will send a unicast packet destined to A. The
packet header will contain A's last ttvn (C got A's OGM and so it knows it).

The packet will travel towards A without being intercepted because the ttvn
contained in its header is the newest for A.

Once A will receive the packet, A's state will not report to be in a "roaming
phase" (because, after a roaming, once A sends out its OGM, all the changes are
committed and the node is considered not to be in the roaming state anymore)
and it will match the ttvn carried by the packet. Therefore there is no reason
for A to try to alter the packet's route, thus dropping the packet because the
destination client is not there anymore.

However, C is well aware that it's routing information towards the client X is
outdated as it received an OGM from A saying that the client roamed away.
Thanks to this detail, this patch introduces a small change in behaviour: as
long as C is in the state of not knowing the new location of client X it will
forward the traffic to its last known location using ttvn-1 of the destination.
By using an older ttvn node A will be forced to re-route the packet.
Intermediate nodes are also allowed to update the packet's destination as long
as they have the information about the client's new location.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c           |    7 +++++++
 net/batman-adv/translation-table.c |   19 +++++++++++++++++++
 net/batman-adv/translation-table.h |    2 ++
 net/batman-adv/unicast.c           |    8 ++++++++
 4 files changed, 36 insertions(+)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4c6467d..b1824bb 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -923,6 +923,13 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 
 		ethhdr = (struct ethhdr *)(skb->data +
 			sizeof(struct unicast_packet));
+
+		/* we don't have an updated route for this client, so we should
+		 * not try to reroute the packet!!
+		 */
+		if (tt_global_client_is_roaming(bat_priv, ethhdr->h_dest))
+			return 1;
+
 		orig_node = transtable_search(bat_priv, NULL, ethhdr->h_dest);
 
 		if (!orig_node) {
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 2cb46f0..b3fb597 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2117,3 +2117,22 @@ request_table:
 		}
 	}
 }
+
+/* returns true whether we know that the client has moved from its old
+ * originator to another one. This entry is kept is still kept for consistency
+ * purposes
+ */
+bool tt_global_client_is_roaming(struct bat_priv *bat_priv, uint8_t *addr)
+{
+	struct tt_global_entry *tt_global_entry;
+	bool ret = false;
+
+	tt_global_entry = tt_global_hash_find(bat_priv, addr);
+	if (!tt_global_entry)
+		goto out;
+
+	ret = tt_global_entry->common.flags & TT_CLIENT_ROAM;
+	tt_global_entry_free_ref(tt_global_entry);
+out:
+	return ret;
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 593d1b3..c43374d 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -53,5 +53,7 @@ bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst);
 void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		    const unsigned char *tt_buff, uint8_t tt_num_changes,
 		    uint8_t ttvn, uint16_t tt_crc);
+bool tt_global_client_is_roaming(struct bat_priv *bat_priv, uint8_t *addr);
+
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 676f6a6..74175c2 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -331,6 +331,14 @@ find_router:
 	unicast_packet->ttvn =
 		(uint8_t)atomic_read(&orig_node->last_ttvn);
 
+	/* inform the destination node that we are still missing a correct route
+	 * for this client. The destination will receive this packet and will
+	 * try to reroute it because the ttvn contained in the header is less
+	 * than the current one
+	 */
+	if (tt_global_client_is_roaming(bat_priv, ethhdr->h_dest))
+		unicast_packet->ttvn = unicast_packet->ttvn - 1;
+
 	if (atomic_read(&bat_priv->fragmentation) &&
 	    data_len + sizeof(*unicast_packet) >
 				neigh_node->if_incoming->net_dev->mtu) {
-- 
1.7.9.4
