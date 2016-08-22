From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 17/20] batman-adv: Place kref_get for tvlv_container near use
Date: Mon, 22 Aug 2016 15:56:17 +0200
Message-ID: <20160822135620.15337-18-sw@simonwunderlich.de>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38996 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755276AbcHVN56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:57:58 -0400
In-Reply-To: <20160822135620.15337-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

It is hard to understand why the refcnt is increased when it isn't done
near the actual place the new reference is used. So using kref_get right
before the place which requires the reference and in the same function
helps to avoid accidental problems caused by incorrect reference counting.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/tvlv.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/batman-adv/tvlv.c b/net/batman-adv/tvlv.c
index 3d1cf0f..3533867 100644
--- a/net/batman-adv/tvlv.c
+++ b/net/batman-adv/tvlv.c
@@ -257,8 +257,13 @@ void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
 	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
 	tvlv_old = batadv_tvlv_container_get(bat_priv, type, version);
 	batadv_tvlv_container_remove(bat_priv, tvlv_old);
+
+	kref_get(&tvlv_new->refcount);
 	hlist_add_head(&tvlv_new->list, &bat_priv->tvlv.container_list);
 	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
+
+	/* don't return reference to new tvlv_container */
+	batadv_tvlv_container_put(tvlv_new);
 }
 
 /**
-- 
2.9.3
