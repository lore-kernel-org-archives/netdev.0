From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/18] batman-adv: check batadv_orig_hash_add_if() return code
Date: Thu, 23 Aug 2012 15:10:18 +0200
Message-ID: <1345727427-20805-10-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28751 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933186Ab2HWNK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:57 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

If this call fails, some of the orig_nodes spaces may have been
resized for the increased number of interface, and some may not.
If we would just continue with the larger number of interfaces,
this would lead to access to not allocated memory later.

We better check the return code, and don't add the interface if
no memory is available. OTOH, keeping some of the orig_nodes
with too much memory allocated should hurt no one (except for
a few too many bytes allocated).

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 282bf6e..2c5a247 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -313,7 +313,13 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
 	hard_iface->if_status = BATADV_IF_INACTIVE;
-	batadv_orig_hash_add_if(hard_iface, bat_priv->num_ifaces);
+	ret = batadv_orig_hash_add_if(hard_iface, bat_priv->num_ifaces);
+	if (ret < 0) {
+		bat_priv->bat_algo_ops->bat_iface_disable(hard_iface);
+		bat_priv->num_ifaces--;
+		hard_iface->if_status = BATADV_IF_NOT_IN_USE;
+		goto err_dev;
+	}
 
 	hard_iface->batman_adv_ptype.type = ethertype;
 	hard_iface->batman_adv_ptype.func = batadv_batman_skb_recv;
-- 
1.7.9.4
