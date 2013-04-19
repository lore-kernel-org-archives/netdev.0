From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH next 2/2] batman-adv: fix global protection fault during soft_iface destruction
Date: Fri, 19 Apr 2013 11:04:52 +0200
Message-ID: <1366362292-22961-3-git-send-email-ordex@autistici.org>
References: <1366362292-22961-1-git-send-email-ordex@autistici.org>
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:40180 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757030Ab3DSJG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 05:06:26 -0400
In-Reply-To: <1366362292-22961-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batadv_mesh_free() schedules some RCU callbacks which need the bat_priv struct
to do their jobs, while free_netdev(), which is called immediately after, is
destroying the private data.

Put an rcu_barrier() in the middle so that free_netdev() is invoked only after
all the callbacks returned.

This bug has been introduced by ab8f433dd39be94e8617cff2dfe9f7eca162eb15
("batman-adv: Move deinitialization of soft-interface to destructor")

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/soft-interface.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 403b8c4..6f20d33 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -582,6 +582,13 @@ static void batadv_softif_free(struct net_device *dev)
 {
 	batadv_debugfs_del_meshif(dev);
 	batadv_mesh_free(dev);
+
+	/* some scheduled RCU callbacks need the bat_priv struct to accomplish
+	 * their tasks. Wait for them all to be finished before freeing the
+	 * netdev and its private data (bat_priv)
+	 */
+	rcu_barrier();
+
 	free_netdev(dev);
 }
 
-- 
1.8.1.5
