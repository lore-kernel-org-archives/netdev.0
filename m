From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH net 1/5] batman-adv: replace WARN with rate limited output on non-existing VLAN
Date: Sun, 26 Jun 2016 11:16:09 +0200
Message-ID: <1466932573-23105-1-git-send-email-sven@narfation.org>
References: <10049349.EHEiaYmtBd@sven-edge>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Sven Eckelmann <sven@narfation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40186 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731AbcFZJQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jun 2016 05:16:26 -0400
In-Reply-To: <10049349.EHEiaYmtBd@sven-edge>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

If a VLAN tagged frame is received and the corresponding VLAN is not
configured on the soft interface, it will splat a WARN on every packet
received. This is a quite annoying behaviour for some scenarios, e.g. if
bat0 is bridged with eth0, and there are arbitrary VLAN tagged frames
from Ethernet coming in without having any VLAN configuration on bat0.

The code should probably create vlan objects on the fly and
transparently transport these VLAN-tagged Ethernet frames, but until
this is done, at least the WARN splat should be replaced by a rate
limited output.

Fixes: 354136bcc3c4 ("batman-adv: fix kernel crash due to missing NULL checks")
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/translation-table.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index feaf492b..72abab7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -650,8 +650,10 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 
 	/* increase the refcounter of the related vlan */
 	vlan = batadv_softif_vlan_get(bat_priv, vid);
-	if (WARN(!vlan, "adding TT local entry %pM to non-existent VLAN %d",
-		 addr, BATADV_PRINT_VID(vid))) {
+	if (!vlan) {
+		net_ratelimited_function(batadv_info, soft_iface,
+					 "adding TT local entry %pM to non-existent VLAN %d\n",
+					 addr, BATADV_PRINT_VID(vid));
 		kfree(tt_local);
 		tt_local = NULL;
 		goto out;
-- 
2.8.1
