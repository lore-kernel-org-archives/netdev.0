From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 4/7] batman-adv: Remove slave interfaces before removing master interface
Date: Sat, 24 Nov 2012 01:02:09 +0100
Message-ID: <1353715332-4284-4-git-send-email-sven@narfation.org>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Sven Eckelmann <sven@narfation.org>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40433 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932338Ab2KXACV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 19:02:21 -0500
In-Reply-To: <1353715332-4284-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The master (soft-interface) should remove the references to its soft-interfaces
before it gets destroyed. Otherwise the usage count of the interface will not be
zero and therefore the net_device cannot be removed. This leads to an endless
hang of the unregister call.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/soft-interface.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 8467b9f..5fd0560 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -546,6 +546,14 @@ struct net_device *batadv_softif_create(const char *name)
 
 void batadv_softif_destroy(struct net_device *soft_iface)
 {
+	struct batadv_hard_iface *hard_iface;
+
+	list_for_each_entry(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->soft_iface == soft_iface)
+			batadv_hardif_disable_interface(hard_iface,
+							BATADV_IF_CLEANUP_KEEP);
+	}
+
 	batadv_sysfs_del_meshif(soft_iface);
 	unregister_netdevice(soft_iface);
 }
-- 
1.7.10.4
