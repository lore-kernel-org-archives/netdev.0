From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 18/20] batman-adv: Place kref_get for tvlv_handler near use
Date: Mon, 22 Aug 2016 15:56:18 +0200
Message-ID: <20160822135620.15337-19-sw@simonwunderlich.de>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:39005 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755501AbcHVN57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:57:59 -0400
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
 net/batman-adv/tvlv.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/batman-adv/tvlv.c b/net/batman-adv/tvlv.c
index 3533867..77654f0 100644
--- a/net/batman-adv/tvlv.c
+++ b/net/batman-adv/tvlv.c
@@ -547,8 +547,12 @@ void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
 	INIT_HLIST_NODE(&tvlv_handler->list);
 
 	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
+	kref_get(&tvlv_handler->refcount);
 	hlist_add_head_rcu(&tvlv_handler->list, &bat_priv->tvlv.handler_list);
 	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
+
+	/* don't return reference to new tvlv_handler */
+	batadv_tvlv_handler_put(tvlv_handler);
 }
 
 /**
-- 
2.9.3
