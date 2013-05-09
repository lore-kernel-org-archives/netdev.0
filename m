From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 4/4] batman-adv: reorder clean up routine in order to avoid race conditions
Date: Thu,  9 May 2013 12:56:47 +0200
Message-ID: <1368097007-817-5-git-send-email-ordex@autistici.org>
References: <1368097007-817-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:44797 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151Ab3EIK6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 06:58:35 -0400
In-Reply-To: <1368097007-817-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nc_worker accesses the originator table during its periodic
work, but since the originator table is freed before
stopping the worker this leads to a global protection fault.

Fix this by killing the worker (in nc_free) before freeing
the originator table.

Moreover tidy up the entire clean up routine by running all
the subcomponents freeing procedures first and then killing
the TT and the originator tables at the end.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/main.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 9c620cd..1240f07 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -163,14 +163,22 @@ void batadv_mesh_free(struct net_device *soft_iface)
 	batadv_vis_quit(bat_priv);
 
 	batadv_gw_node_purge(bat_priv);
-	batadv_originator_free(bat_priv);
 	batadv_nc_free(bat_priv);
-
-	batadv_tt_free(bat_priv);
-
-	batadv_bla_free(bat_priv);
-
 	batadv_dat_free(bat_priv);
+	batadv_bla_free(bat_priv);
+
+	/* Free the TT and the originator tables only after having terminated
+	 * all the other depending components which may use these structures for
+	 * their purposes.
+	 */
+	batadv_tt_free(bat_priv);
+
+	/* Since the originator table clean up routine is accessing the TT
+	 * tables as well, it has to be invoked after the TT tables have been
+	 * freed and marked as empty. This ensures that no cleanup RCU callbacks
+	 * accessing the TT data are scheduled for later execution.
+	 */
+	batadv_originator_free(bat_priv);
 
 	free_percpu(bat_priv->bat_counters);
 
-- 
1.8.1.5
