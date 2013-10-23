From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 11/16] batman-adv: send GW_DEL event in case of soft-iface destruction
Date: Wed, 23 Oct 2013 18:04:58 +0200
Message-ID: <1382544303-2694-12-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:4554 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804Ab3JWQLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:11:52 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

In case of soft_iface destruction send a GW DEL event to
userspace so that applications which are listening for GW
events are informed about the lost of connectivity and can
react accordingly.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/hard-interface.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index c60d3ed..1ba8a55 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -28,6 +28,7 @@
 #include "originator.h"
 #include "hash.h"
 #include "bridge_loop_avoidance.h"
+#include "gateway_client.h"
 
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
@@ -535,8 +536,12 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 	dev_put(hard_iface->soft_iface);
 
 	/* nobody uses this interface anymore */
-	if (!bat_priv->num_ifaces && autodel == BATADV_IF_CLEANUP_AUTO)
-		batadv_softif_destroy_sysfs(hard_iface->soft_iface);
+	if (!bat_priv->num_ifaces) {
+		batadv_gw_check_client_stop(bat_priv);
+
+		if (autodel == BATADV_IF_CLEANUP_AUTO)
+			batadv_softif_destroy_sysfs(hard_iface->soft_iface);
+	}
 
 	netdev_upper_dev_unlink(hard_iface->net_dev, hard_iface->soft_iface);
 	hard_iface->soft_iface = NULL;
-- 
1.8.4
