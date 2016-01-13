From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 1/2] batman-adv: fix lockdep splat when doing mcast_free
Date: Thu, 14 Jan 2016 01:51:53 +0800
Message-ID: <1452707514-5091-2-git-send-email-a__8893.58735080368$1452707669$gmane$org@unstable.cc>
References: <1452707514-5091-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:10197 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932338AbcAMRyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2016 12:54:02 -0500
In-Reply-To: <1452707514-5091-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

While testing, we got something like this:

WARNING: CPU: 0 PID: 238 at net/batman-adv/multicast.c:142 batadv_mcast_mla_tt_retract+0x94/0x205 [batman_adv]()
[...]
Call Trace:
[<ffffffff815fc597>] dump_stack+0x4b/0x64
[<ffffffff810b34dc>] warn_slowpath_common+0xbc/0x120
[<ffffffffa0024ec5>] ? batadv_mcast_mla_tt_retract+0x94/0x205 [batman_adv]
[<ffffffff810b3705>] warn_slowpath_null+0x15/0x20
[<ffffffffa0024ec5>] batadv_mcast_mla_tt_retract+0x94/0x205 [batman_adv]
[<ffffffffa00273fe>] batadv_mcast_free+0x36/0x39 [batman_adv]
[<ffffffffa0020c77>] batadv_mesh_free+0x7d/0x13f [batman_adv]
[<ffffffffa0036a6b>] batadv_softif_free+0x15/0x25 [batman_adv]
[...]

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/multicast.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index eb76386f8d4b..75fa5013af72 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -802,7 +802,9 @@ void batadv_mcast_free(struct batadv_priv *bat_priv)
 	batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_MCAST, 1);
 	batadv_tvlv_handler_unregister(bat_priv, BATADV_TVLV_MCAST, 1);
 
+	spin_lock_bh(&bat_priv->tt.commit_lock);
 	batadv_mcast_mla_tt_retract(bat_priv, NULL);
+	spin_unlock_bh(&bat_priv->tt.commit_lock);
 }
 
 /**
-- 
2.7.0
