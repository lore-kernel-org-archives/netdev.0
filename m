From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/11] batman-adv: skip the window protection test when the originator has no neighbours
Date: Tue, 17 Apr 2012 13:58:27 +0200
Message-ID: <1334663907-22725-12-git-send-email-ordex@autistici.org>
References: <1334663907-22725-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:22438 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756046Ab2DQL5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 07:57:45 -0400
In-Reply-To: <1334663907-22725-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we receive an OGM from from a node for the first time, the last_real_seqno
field of the orig_node structure has not been initialised yet. The value of this
field is used to compute the current ogm-seqno window and therefore the
protection mechanism will probably drop the packet due to an out-of-window error.
To avoid this situation this patch adds a check to skip the window protection
mechanism if no neighbour nodes have already been added. When the first
neighbour node is added, the last_real_seqno field is initialised too.

Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f36b54c..873ea40 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -861,7 +861,8 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	seq_diff = batman_ogm_packet->seqno - orig_node->last_real_seqno;
 
 	/* signalize caller that the packet is to be dropped. */
-	if (window_protected(bat_priv, seq_diff,
+	if (!hlist_empty(&orig_node->neigh_list) &&
+	    window_protected(bat_priv, seq_diff,
 			     &orig_node->batman_seqno_reset))
 		goto out;
 
-- 
1.7.9.4
