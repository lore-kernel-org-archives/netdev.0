From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 5/7] batman-adv: Allow to postpone softif unregistration
Date: Sat, 24 Nov 2012 01:02:10 +0100
Message-ID: <1353715332-4284-5-git-send-email-sven@narfation.org>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Sven Eckelmann <sven@narfation.org>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40441 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932348Ab2KXACW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 19:02:22 -0500
In-Reply-To: <1353715332-4284-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The caller of batadv_softif_destroy may want to postpone the unregistration of
the soft-interface. This is necessary when the rtnl_link configuration hooks
are used.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/hard-interface.c |    2 +-
 net/batman-adv/soft-interface.c |    5 +++--
 net/batman-adv/soft-interface.h |    3 ++-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index daeb632..5e2655d 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -447,7 +447,7 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 
 	/* nobody uses this interface anymore */
 	if (!bat_priv->num_ifaces && autodel == BATADV_IF_CLEANUP_AUTO)
-		batadv_softif_destroy(hard_iface->soft_iface);
+		batadv_softif_destroy(hard_iface->soft_iface, NULL);
 
 	hard_iface->soft_iface = NULL;
 	batadv_hardif_free_ref(hard_iface);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 5fd0560..68832f5 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -544,7 +544,8 @@ struct net_device *batadv_softif_create(const char *name)
 	return soft_iface;
 }
 
-void batadv_softif_destroy(struct net_device *soft_iface)
+void batadv_softif_destroy(struct net_device *soft_iface,
+			   struct list_head *head)
 {
 	struct batadv_hard_iface *hard_iface;
 
@@ -555,7 +556,7 @@ void batadv_softif_destroy(struct net_device *soft_iface)
 	}
 
 	batadv_sysfs_del_meshif(soft_iface);
-	unregister_netdevice(soft_iface);
+	unregister_netdevice_queue(soft_iface, head);
 }
 
 int batadv_softif_is_valid(const struct net_device *net_dev)
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 07a08fe..fe9b0f7 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -25,7 +25,8 @@ void batadv_interface_rx(struct net_device *soft_iface,
 			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
 			 int hdr_size, struct batadv_orig_node *orig_node);
 struct net_device *batadv_softif_create(const char *name);
-void batadv_softif_destroy(struct net_device *soft_iface);
+void batadv_softif_destroy(struct net_device *soft_iface,
+			   struct list_head *head);
 int batadv_softif_is_valid(const struct net_device *net_dev);
 
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
-- 
1.7.10.4
