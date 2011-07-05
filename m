From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 4/6] batman-adv: broadcast primary OGM on all active hard-interfaces
Date: Tue,  5 Jul 2011 15:43:58 +0200
Message-ID: <1309873440-11704-5-git-send-email-lindner_marek@yahoo.de>
References: <1309873440-11704-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm11.bullet.mail.ukl.yahoo.com ([217.146.183.185]:24526 "HELO
	nm11.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751725Ab1GENoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 09:44:23 -0400
In-Reply-To: <1309873440-11704-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The primary interface OGM has to be broadcasted on all hard-interfaces
even if the primary interface is not the first interface (if_num = 0).
Therefore the code has to compare the originating interface with the
primary interface instead of checking the if_num.

Reported-by: Linus Luessing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/send.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 2f62b2e..4b8e11b 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -163,6 +163,7 @@ static void send_packet(struct forw_packet *forw_packet)
 	struct hard_iface *hard_iface;
 	struct net_device *soft_iface;
 	struct bat_priv *bat_priv;
+	struct hard_iface *primary_if = NULL;
 	struct batman_packet *batman_packet =
 		(struct batman_packet *)(forw_packet->skb->data);
 	int directlink = (batman_packet->flags & DIRECTLINK ? 1 : 0);
@@ -170,19 +171,23 @@ static void send_packet(struct forw_packet *forw_packet)
 	if (!forw_packet->if_incoming) {
 		pr_err("Error - can't forward packet: incoming iface not "
 		       "specified\n");
-		return;
+		goto out;
 	}
 
 	soft_iface = forw_packet->if_incoming->soft_iface;
 	bat_priv = netdev_priv(soft_iface);
 
 	if (forw_packet->if_incoming->if_status != IF_ACTIVE)
-		return;
+		goto out;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
 
 	/* multihomed peer assumed */
 	/* non-primary OGMs are only broadcasted on their interface */
 	if ((directlink && (batman_packet->ttl == 1)) ||
-	    (forw_packet->own && (forw_packet->if_incoming->if_num > 0))) {
+	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
 
 		/* FIXME: what about aggregated packets ? */
 		bat_dbg(DBG_BATMAN, bat_priv,
@@ -199,7 +204,7 @@ static void send_packet(struct forw_packet *forw_packet)
 				broadcast_addr);
 		forw_packet->skb = NULL;
 
-		return;
+		goto out;
 	}
 
 	/* broadcast on every interface */
@@ -211,6 +216,10 @@ static void send_packet(struct forw_packet *forw_packet)
 		send_packet_to_if(forw_packet, hard_iface);
 	}
 	rcu_read_unlock();
+
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 }
 
 static void realloc_packet_buffer(struct hard_iface *hard_iface,
-- 
1.7.5.3

