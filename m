From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 09/12] batman-adv: add wrapper function to throw uevent in userspace
Date: Mon, 20 Jun 2011 12:17:02 +0200
Message-ID: <1308565025-21293-10-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:57190 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967Ab1FTKRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 06:17:35 -0400
In-Reply-To: <1308565025-21293-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

Using throw_uevent() is now possible to trigger uevent signal that can
be recognised in userspace. Uevents will be triggered through the
/devices/virtual/net/{MESH_IFACE} kobject.

A triggered uevent has three properties:
- type: the event class. Who generates the event (only 'gw' is currently
  defined). Corresponds to the BATTYPE uevent variable.
- action: the associated action with the event ('add'/'change'/'del' are
  currently defined). Corresponds to the BATACTION uevent variable.
- data: any useful data for the userspace. Corresponds to the BATDATA
  uevent variable.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/bat_sysfs.c |   71 ++++++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/bat_sysfs.h |    2 +
 net/batman-adv/main.h      |   11 +++++++
 3 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 63738ec..cd15deb 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -40,6 +40,20 @@ static struct bat_priv *kobj_to_batpriv(struct kobject *obj)
 	return netdev_priv(net_dev);
 }
 
+#define UEV_TYPE_VAR	"BATTYPE="
+#define UEV_ACTION_VAR	"BATACTION="
+#define UEV_DATA_VAR	"BATDATA="
+
+static char *uev_action_str[] = {
+	"add",
+	"del",
+	"change"
+};
+
+static char *uev_type_str[] = {
+	"gw"
+};
+
 /* Use this, if you have customized show and store functions */
 #define BAT_ATTR(_name, _mode, _show, _store)	\
 struct bat_attribute bat_attr_##_name = {	\
@@ -601,3 +615,60 @@ void sysfs_del_hardif(struct kobject **hardif_obj)
 	kobject_put(*hardif_obj);
 	*hardif_obj = NULL;
 }
+
+int throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
+		 enum uev_action action, const char *data)
+{
+	int ret = -1;
+	struct hard_iface *primary_if = NULL;
+	struct kobject *bat_kobj;
+	char *uevent_env[4] = { NULL, NULL, NULL, NULL };
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	bat_kobj = &primary_if->soft_iface->dev.kobj;
+
+	uevent_env[0] = kmalloc(strlen(UEV_TYPE_VAR) +
+				strlen(uev_type_str[type]) + 1,
+				GFP_ATOMIC);
+	if (!uevent_env[0])
+		goto out;
+
+	sprintf(uevent_env[0], "%s%s", UEV_TYPE_VAR, uev_type_str[type]);
+
+	uevent_env[1] = kmalloc(strlen(UEV_ACTION_VAR) +
+				strlen(uev_action_str[action]) + 1,
+				GFP_ATOMIC);
+	if (!uevent_env[1])
+		goto out;
+
+	sprintf(uevent_env[1], "%s%s", UEV_ACTION_VAR, uev_action_str[action]);
+
+	/* If the event is DEL, ignore the data field */
+	if (action != UEV_DEL) {
+		uevent_env[2] = kmalloc(strlen(UEV_DATA_VAR) +
+					strlen(data) + 1, GFP_ATOMIC);
+		if (!uevent_env[2])
+			goto out;
+
+		sprintf(uevent_env[2], "%s%s", UEV_DATA_VAR, data);
+	}
+
+	ret = kobject_uevent_env(bat_kobj, KOBJ_CHANGE, uevent_env);
+out:
+	kfree(uevent_env[0]);
+	kfree(uevent_env[1]);
+	kfree(uevent_env[2]);
+
+	if (primary_if)
+		hardif_free_ref(primary_if);
+
+	if (ret)
+		bat_dbg(DBG_BATMAN, bat_priv, "Impossible to send "
+			"uevent for (%s,%s,%s) event (err: %d)\n",
+			uev_type_str[type], uev_action_str[action],
+			(action == UEV_DEL ? "NULL" : data), ret);
+	return ret;
+}
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index 02f1fa7..a3f75a7 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -38,5 +38,7 @@ int sysfs_add_meshif(struct net_device *dev);
 void sysfs_del_meshif(struct net_device *dev);
 int sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev);
 void sysfs_del_hardif(struct kobject **hardif_obj);
+int throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
+		 enum uev_action action, const char *data);
 
 #endif /* _NET_BATMAN_ADV_SYSFS_H_ */
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 8eae05e..f9e0e17 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -91,6 +91,17 @@ enum mesh_state {
 #define BCAST_QUEUE_LEN		256
 #define BATMAN_QUEUE_LEN	256
 
+
+enum uev_action {
+	UEV_ADD = 0,
+	UEV_DEL,
+	UEV_CHANGE
+};
+
+enum uev_type {
+	UEV_GW = 0
+};
+
 /*
  * Debug Messages
  */
-- 
1.7.5.3

