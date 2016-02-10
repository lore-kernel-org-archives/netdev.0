From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 12/21] batman-adv: Convert batadv_tvlv_container to kref
Date: Wed, 10 Feb 2016 23:57:18 +0800
Message-ID: <1455119847-5862-13-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:7944 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753016AbcBJQSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:18:43 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batman-adv uses a self-written reference implementation which is just based
on atomic_t. This is less obvious when reading the code than kref and
therefore increases the change that the reference counting will be missed.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.c  | 22 +++++++++++++++++-----
 net/batman-adv/types.h |  2 +-
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index a9b4f75db874..4b6c2589fa34 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -29,6 +29,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/module.h>
@@ -670,14 +671,25 @@ static struct batadv_tvlv_handler
 }
 
 /**
+ * batadv_tvlv_container_release - release tvlv from lists and free
+ * @ref: kref pointer of the tvlv
+ */
+static void batadv_tvlv_container_release(struct kref *ref)
+{
+	struct batadv_tvlv_container *tvlv;
+
+	tvlv = container_of(ref, struct batadv_tvlv_container, refcount);
+	kfree(tvlv);
+}
+
+/**
  * batadv_tvlv_container_free_ref - decrement the tvlv container refcounter and
- *  possibly free it
+ *  possibly release it
  * @tvlv: the tvlv container to free
  */
 static void batadv_tvlv_container_free_ref(struct batadv_tvlv_container *tvlv)
 {
-	if (atomic_dec_and_test(&tvlv->refcount))
-		kfree(tvlv);
+	kref_put(&tvlv->refcount, batadv_tvlv_container_release);
 }
 
 /**
@@ -706,7 +718,7 @@ static struct batadv_tvlv_container
 		if (tvlv_tmp->tvlv_hdr.version != version)
 			continue;
 
-		if (!atomic_inc_not_zero(&tvlv_tmp->refcount))
+		if (!kref_get_unless_zero(&tvlv_tmp->refcount))
 			continue;
 
 		tvlv = tvlv_tmp;
@@ -814,7 +826,7 @@ void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
 
 	memcpy(tvlv_new + 1, tvlv_value, ntohs(tvlv_new->tvlv_hdr.len));
 	INIT_HLIST_NODE(&tvlv_new->list);
-	atomic_set(&tvlv_new->refcount, 1);
+	kref_init(&tvlv_new->refcount);
 
 	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
 	tvlv_old = batadv_tvlv_container_get(bat_priv, type, version);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9df8f39e4785..c55925bb34af 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1266,7 +1266,7 @@ struct batadv_dat_candidate {
 struct batadv_tvlv_container {
 	struct hlist_node list;
 	struct batadv_tvlv_hdr tvlv_hdr;
-	atomic_t refcount;
+	struct kref refcount;
 };
 
 /**
-- 
2.7.1
