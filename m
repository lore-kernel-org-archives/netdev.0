From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/10] batman-adv: don't access unregistered net_device object
Date: Fri, 28 Aug 2015 11:12:34 +0200
Message-ID: <1440753156-7808-9-git-send-email-antonio@meshcoding.com>
References: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:21416 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350AbbH1JN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 05:13:59 -0400
In-Reply-To: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In batadv_hardif_disable_interface() there is a call to
batadv_softif_destroy_sysfs() which in turns invokes
unregister_netdevice() on the soft_iface.
After this point we cannot rely on the soft_iface object
anymore because it might get free'd by the netdev periodic
routine at any time.

For this reason the netdev_upper_dev_unlink(.., soft_iface) call
is moved before the invocation of batadv_softif_destroy_sysfs() so
that we can be sure that the soft_iface object is still valid.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/hard-interface.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index f4a15d2..0565b20 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -528,6 +528,8 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 	batadv_purge_outstanding_packets(bat_priv, hard_iface);
 	dev_put(hard_iface->soft_iface);
 
+	netdev_upper_dev_unlink(hard_iface->net_dev, hard_iface->soft_iface);
+
 	/* nobody uses this interface anymore */
 	if (!bat_priv->num_ifaces) {
 		batadv_gw_check_client_stop(bat_priv);
@@ -536,7 +538,6 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 			batadv_softif_destroy_sysfs(hard_iface->soft_iface);
 	}
 
-	netdev_upper_dev_unlink(hard_iface->net_dev, hard_iface->soft_iface);
 	hard_iface->soft_iface = NULL;
 	batadv_hardif_free_ref(hard_iface);
 
-- 
2.5.0
