From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 01/21] batman-adv: Drop reference to netdevice on last reference
Date: Wed, 10 Feb 2016 23:57:07 +0800
Message-ID: <1455119847-5862-2-git-send-email-a__23883.598476141$1455120008$gmane$org@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:31877 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751546AbcBJP74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 10:59:56 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The references to the network device should be dropped inside the release
function for batadv_hard_iface similar to what is done with the batman-adv
internal datastructures.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/hard-interface.c | 13 ++++++++-----
 net/batman-adv/hard-interface.h |  6 +++---
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index db90022c00a4..b17e272b5cb3 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -47,13 +47,16 @@
 #include "sysfs.h"
 #include "translation-table.h"
 
-void batadv_hardif_free_rcu(struct rcu_head *rcu)
+/**
+ * batadv_hardif_release - release hard interface from lists and queue for
+ *  free after rcu grace period
+ * @hard_iface: the hard interface to free
+ */
+void batadv_hardif_release(struct batadv_hard_iface *hard_iface)
 {
-	struct batadv_hard_iface *hard_iface;
-
-	hard_iface = container_of(rcu, struct batadv_hard_iface, rcu);
 	dev_put(hard_iface->net_dev);
-	kfree(hard_iface);
+
+	kfree_rcu(hard_iface, rcu);
 }
 
 struct batadv_hard_iface *
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 4d6b5e12331f..9eb08ad6032d 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -61,18 +61,18 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 void batadv_hardif_remove_interfaces(void);
 int batadv_hardif_min_mtu(struct net_device *soft_iface);
 void batadv_update_min_mtu(struct net_device *soft_iface);
-void batadv_hardif_free_rcu(struct rcu_head *rcu);
+void batadv_hardif_release(struct batadv_hard_iface *hard_iface);
 
 /**
  * batadv_hardif_free_ref - decrement the hard interface refcounter and
- *  possibly free it
+ *  possibly release it
  * @hard_iface: the hard interface to free
  */
 static inline void
 batadv_hardif_free_ref(struct batadv_hard_iface *hard_iface)
 {
 	if (atomic_dec_and_test(&hard_iface->refcount))
-		call_rcu(&hard_iface->rcu, batadv_hardif_free_rcu);
+		batadv_hardif_release(hard_iface);
 }
 
 static inline struct batadv_hard_iface *
-- 
2.7.1
