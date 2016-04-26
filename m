From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 3/5] batman-adv: Deactivate TO_BE_ACTIVATED hardif on shutdown
Date: Tue, 26 Apr 2016 11:27:17 +0800
Message-ID: <1461641239-7097-4-git-send-email-a@unstable.cc>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:35125 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbcDZD2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 23:28:07 -0400
In-Reply-To: <1461641239-7097-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The shutdown of an batman-adv interface can happen with one of its slave
interfaces still being in the BATADV_IF_TO_BE_ACTIVATED state. A possible
reason for it is that the routing algorithm BATMAN_V was selected and
batadv_schedule_bat_ogm was not yet called for this interface. This slave
interface still has to be set to BATADV_IF_INACTIVE or the batman-adv
interface will never reduce its usage counter and thus never gets shutdown.

This problem can be simulated via:

    $ modprobe dummy
    $ modprobe batman-adv routing_algo=BATMAN_V
    $ ip link add bat0 type batadv
    $ ip link set dummy0 master bat0
    $ ip link set dummy0 up
    $ ip link del bat0
    unregister_netdevice: waiting for bat0 to become free. Usage count = 3

Reported-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/hard-interface.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index b22b2775a0a5..c61d5b0b24d2 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -572,8 +572,7 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct batadv_hard_iface *primary_if = NULL;
 
-	if (hard_iface->if_status == BATADV_IF_ACTIVE)
-		batadv_hardif_deactivate_interface(hard_iface);
+	batadv_hardif_deactivate_interface(hard_iface);
 
 	if (hard_iface->if_status != BATADV_IF_INACTIVE)
 		goto out;
-- 
2.8.1
