From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 12/19] batman-adv: disable sysfs knobs when GW-mode is not implemented
Date: Fri, 12 Aug 2016 10:56:48 +0200
Message-ID: <1470992215-11009-13-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:35023 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbcHLI5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:25 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <a@unstable.cc>

Now that the GW-mode code is algorithm specific, batman-adv expects the
routing algorithm to implement some APIs to make it work.

However, such APIs are not mandatory, therefore we might have algorithms
not providing them. In this case all the sysfs knobs related to GW-mode
should be deactivated to make sure that settings injected by the user
for this feature are rejected.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/sysfs.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index e78bd7f..02d96f2 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -429,6 +429,13 @@ static ssize_t batadv_show_gw_mode(struct kobject *kobj, struct attribute *attr,
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
 	int bytes_written;
 
+	/* GW mode is not available if the routing algorithm in use does not
+	 * implement the GW API
+	 */
+	if (!bat_priv->algo_ops->gw.get_best_gw_node ||
+	    !bat_priv->algo_ops->gw.is_eligible)
+		return -ENOENT;
+
 	switch (atomic_read(&bat_priv->gw.mode)) {
 	case BATADV_GW_MODE_CLIENT:
 		bytes_written = sprintf(buff, "%s\n",
@@ -456,6 +463,13 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 	char *curr_gw_mode_str;
 	int gw_mode_tmp = -1;
 
+	/* toggling GW mode is allowed only if the routing algorithm in use
+	 * provides the GW API
+	 */
+	if (!bat_priv->algo_ops->gw.get_best_gw_node ||
+	    !bat_priv->algo_ops->gw.is_eligible)
+		return -EINVAL;
+
 	if (buff[count - 1] == '\n')
 		buff[count - 1] = '\0';
 
@@ -520,6 +534,13 @@ static ssize_t batadv_show_gw_sel_class(struct kobject *kobj,
 {
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
 
+	/* GW selection class is not available if the routing algorithm in use
+	 * does not implement the GW API
+	 */
+	if (!bat_priv->algo_ops->gw.get_best_gw_node ||
+	    !bat_priv->algo_ops->gw.is_eligible)
+		return -ENOENT;
+
 	if (bat_priv->algo_ops->gw.show_sel_class)
 		return bat_priv->algo_ops->gw.show_sel_class(bat_priv, buff);
 
@@ -532,6 +553,13 @@ static ssize_t batadv_store_gw_sel_class(struct kobject *kobj,
 {
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
 
+	/* setting the GW selection class is allowed only if the routing
+	 * algorithm in use implements the GW API
+	 */
+	if (!bat_priv->algo_ops->gw.get_best_gw_node ||
+	    !bat_priv->algo_ops->gw.is_eligible)
+		return -EINVAL;
+
 	if (buff[count - 1] == '\n')
 		buff[count - 1] = '\0';
 
-- 
2.8.1
