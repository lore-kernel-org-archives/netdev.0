From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 11/12] d80211: encryption keys sysfs attributes
Date: Thu,  8 Jun 2006 09:49:15 +0200 (CEST)
Message-ID: <20060608074915.8C1F548397@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51608 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964783AbWFHHsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:48:04 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add /sys/class/ieee80211/phyX/sta/*/key/* and /sys/class/net/X/keys/[0-3]/*
attributes.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c           |   33 ++++++
 net/d80211/ieee80211_i.h         |   11 ++
 net/d80211/ieee80211_ioctl.c     |  101 ++++++++++++-------
 net/d80211/ieee80211_key.h       |    2 
 net/d80211/ieee80211_sysfs.c     |   12 ++
 net/d80211/ieee80211_sysfs_sta.c |  206 ++++++++++++++++++++++++++++++++++++++
 6 files changed, 326 insertions(+), 39 deletions(-)

9b2e2e2cc66e7fb3f1ae07d7e083ffa63dffbde7
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index e4ac701..1a03f07 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -84,15 +84,44 @@ ieee80211_key_data2conf(struct ieee80211
 	return conf;
 }
 
+struct ieee80211_key *ieee80211_key_alloc(struct ieee80211_sub_if_data *sdata,
+					  int idx, size_t key_len, gfp_t flags)
+{
+	struct ieee80211_key *key;
+	int res;
+
+	key = kzalloc(sizeof(struct ieee80211_key) + key_len, flags);
+	if (!key)
+		return NULL;
+	if (sdata)
+		res = kobject_set_name(&key->kobj, "%d", idx);
+	else
+		res = kobject_set_name(&key->kobj, "key");
+	if (res) {
+		kfree(key);
+		return NULL;
+	}
+	ieee80211_key_sysfs_set_kset(key, sdata ? &sdata->key_kset : NULL);
+	kobject_init(&key->kobj);
+	return key;
+}
 
 void ieee80211_key_free(struct ieee80211_key *key)
 {
-	if (key && key->alg == ALG_CCMP)
+	if (key)
+		kobject_put(&key->kobj);
+}
+
+void ieee80211_key_release(struct kobject *kobj)
+{
+	struct ieee80211_key *key;
+
+	key = container_of(kobj, struct ieee80211_key, kobj);
+	if (key->alg == ALG_CCMP)
 		ieee80211_aes_key_free(key->u.ccmp.tfm);
 	kfree(key);
 }
 
-
 static int rate_list_match(int *rate_list, int rate)
 {
 	int i;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 212d12f..c1d7422 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -294,6 +294,7 @@ struct ieee80211_sub_if_data {
 #define NUM_DEFAULT_KEYS 4
         struct ieee80211_key *keys[NUM_DEFAULT_KEYS];
         struct ieee80211_key *default_key;
+	struct kset key_kset;
 
 	struct ieee80211_if_ap *bss; /* BSS that this device belongs to */
 
@@ -527,7 +528,10 @@ int ieee80211_if_config(struct net_devic
 struct ieee80211_key_conf *
 ieee80211_key_data2conf(struct ieee80211_local *local,
 			struct ieee80211_key *data);
+struct ieee80211_key *ieee80211_key_alloc(struct ieee80211_sub_if_data *sdata,
+					  int idx, size_t key_len, gfp_t flags);
 void ieee80211_key_free(struct ieee80211_key *key);
+void ieee80211_key_release(struct kobject *kobj);
 void ieee80211_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 		       struct ieee80211_rx_status *status, u32 msg_type);
 void ieee80211_prepare_rates(struct net_device *dev);
@@ -633,5 +637,12 @@ int ieee80211_sta_kset_sysfs_register(st
 void ieee80211_sta_kset_sysfs_unregister(struct ieee80211_local *local);
 int ieee80211_sta_sysfs_add(struct sta_info *sta);
 void ieee80211_sta_sysfs_remove(struct sta_info *sta);
+int ieee80211_key_kset_sysfs_register(struct ieee80211_sub_if_data *sdata);
+void ieee80211_key_kset_sysfs_unregister(struct ieee80211_sub_if_data *sdata);
+void ieee80211_key_sysfs_set_kset(struct ieee80211_key *key, struct kset *kset);
+int ieee80211_key_sysfs_add(struct ieee80211_key *key);
+void ieee80211_key_sysfs_remove(struct ieee80211_key *key);
+int ieee80211_key_sysfs_add_default(struct ieee80211_sub_if_data *sdata);
+void ieee80211_key_sysfs_remove_default(struct ieee80211_sub_if_data *sdata);
 
 #endif /* IEEE80211_I_H */
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 562b9f3..7c2a847 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -470,7 +470,7 @@ static int ieee80211_set_encryption(stru
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int ret = 0;
 	struct sta_info *sta;
-	struct ieee80211_key **key;
+	struct ieee80211_key *key, *old_key;
 	int try_hwaccel = 1;
         struct ieee80211_key_conf *keyconf;
         struct ieee80211_sub_if_data *sdata;
@@ -486,7 +486,7 @@ static int ieee80211_set_encryption(stru
 			       dev->name, idx);
 			return -EINVAL;
 		}
-		key = &sdata->keys[idx];
+		key = sdata->keys[idx];
 
 		/* Disable hwaccel for default keys when the interface is not
 		 * the default one.
@@ -525,7 +525,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 			return -ENOENT;
 		}
 
-		key = &sta->key;
+		key = sta->key;
 	}
 
 	/* FIX:
@@ -571,8 +571,8 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (alg == ALG_NONE) {
 		keyconf = NULL;
-		if (try_hwaccel && *key && local->hw->set_key &&
-		    (keyconf = ieee80211_key_data2conf(local, *key)) != NULL &&
+		if (try_hwaccel && key && local->hw->set_key &&
+		    (keyconf = ieee80211_key_data2conf(local, key)) != NULL &&
 		    local->hw->set_key(dev, DISABLE_KEY, sta_addr,
 				       keyconf, sta ? sta->aid : 0)) {
 			if (err)
@@ -583,68 +583,101 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		}
 		kfree(keyconf);
 
-		if (sdata->default_key == *key)
+		if (key && sdata->default_key == key) {
+			ieee80211_key_sysfs_remove_default(sdata);
 			sdata->default_key = NULL;
-		ieee80211_key_free(*key);
-		*key = NULL;
+		}
+		ieee80211_key_sysfs_remove(key);
+		if (sta)
+			sta->key = NULL;
+		else
+			sdata->keys[idx] = NULL;
+		ieee80211_key_free(key);
+		key = NULL;
 	} else {
-		if (*key == NULL || (*key)->keylen < key_len) {
-			ieee80211_key_free(*key);
-			*key = kmalloc(sizeof(struct ieee80211_key) +
-				       key_len, GFP_ATOMIC);
-			if (*key == NULL) {
-				ret = -ENOMEM;
-				goto done;
-			}
+		old_key = key;
+		key = ieee80211_key_alloc(sta ? NULL : sdata, idx, key_len,
+					  GFP_KERNEL);
+		if (!key) {
+			ret = -ENOMEM;
+			goto err_out;
 		}
-		memset(*key, 0, sizeof(struct ieee80211_key) + key_len);
+
 		/* default to sw encryption; low-level driver sets these if the
 		 * requested encryption is supported */
-		(*key)->hw_key_idx = HW_KEY_IDX_INVALID;
-		(*key)->force_sw_encrypt = 1;
+		key->hw_key_idx = HW_KEY_IDX_INVALID;
+		key->force_sw_encrypt = 1;
 
-		(*key)->alg = alg;
-		(*key)->keyidx = idx;
-		(*key)->keylen = key_len;
-		memcpy((*key)->key, _key, key_len);
+		key->alg = alg;
+		key->keyidx = idx;
+		key->keylen = key_len;
+		memcpy(key->key, _key, key_len);
 		if (set_tx_key)
-			(*key)->default_tx_key = 1;
+			key->default_tx_key = 1;
 
 		if (alg == ALG_CCMP) {
 			/* Initialize AES key state here as an optimization
 			 * so that it does not need to be initialized for every
 			 * packet. */
-			(*key)->u.ccmp.tfm = ieee80211_aes_key_setup_encrypt(
-				(*key)->key);
-			if ((*key)->u.ccmp.tfm == NULL) {
-				kfree(*key);
-				*key = NULL;
+			key->u.ccmp.tfm = ieee80211_aes_key_setup_encrypt(
+				key->key);
+			if (key->u.ccmp.tfm == NULL) {
 				ret = -ENOMEM;
-				goto done;
+				goto err_free;
 			}
 		}
 
+		if (old_key && sdata->default_key == old_key) {
+			ieee80211_key_sysfs_remove_default(sdata);
+			sdata->default_key = NULL;
+		}
+		ieee80211_key_sysfs_remove(old_key);
+		if (sta)
+			sta->key = key;
+		else
+			sdata->keys[idx] = key;
+		ieee80211_key_free(old_key);
+		if (sta)
+			key->kobj.parent = &sta->kobj;
+		ret = ieee80211_key_sysfs_add(key);
+		if (ret)
+			goto err_null;
+
 		if (try_hwaccel &&
 		    (alg == ALG_WEP || alg == ALG_TKIP || alg == ALG_CCMP)) {
 			int e = ieee80211_set_hw_encryption(dev, sta, sta_addr,
-							    *key);
+							    key);
 			if (err)
 				*err = e;
 		}
 	}
 
-	if (set_tx_key || (sta == NULL && sdata->default_key == NULL)) {
-                sdata->default_key = *key;
+	if (set_tx_key || (sta == NULL && sdata->default_key == NULL && key)) {
+		sdata->default_key = key;
+		if (ieee80211_key_sysfs_add_default(sdata))
+			printk(KERN_WARNING "%s: cannot create symlink to "
+			       "default key\n", dev->name);
 		if (local->hw->set_key_idx &&
 		    local->hw->set_key_idx(dev, idx))
 			printk(KERN_DEBUG "%s: failed to set TX key idx for "
 			       "low-level driver\n", dev->name);
 	}
 
- done:
 	if (sta)
 		sta_info_put(sta);
 
+	return 0;
+
+err_null:
+	if (sta)
+		sta->key = NULL;
+	else
+		sdata->keys[idx] = NULL;
+err_free:
+	ieee80211_key_free(key);
+err_out:
+	if (sta)
+		sta_info_put(sta);
 	return ret;
 }
 
diff --git a/net/d80211/ieee80211_key.h b/net/d80211/ieee80211_key.h
index 4c688cd..64f2363 100644
--- a/net/d80211/ieee80211_key.h
+++ b/net/d80211/ieee80211_key.h
@@ -40,6 +40,8 @@ #define CCMP_PN_LEN 6
 #define NUM_RX_DATA_QUEUES 17
 
 struct ieee80211_key {
+	struct kobject kobj;
+
 	int hw_key_idx; /* filled and used by low-level driver */
 	ieee80211_key_alg alg;
 	union {
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 12d16fd..10bf45c 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -709,16 +709,22 @@ int ieee80211_sysfs_add_netdevice(struct
 	res = sysfs_create_link(&dev->class_dev.kobj, &local->class_dev.kobj,
 				"wiphy");
 	if (res)
-		goto out;
+		goto err_out;
 	res = ieee80211_add_if_group(&dev->class_dev.kobj, dev);
 	if (res)
-		sysfs_remove_link(&dev->class_dev.kobj, "wiphy");
-out:
+		goto err_link;
+	res = ieee80211_key_kset_sysfs_register(IEEE80211_DEV_TO_SUB_IF(dev));
+	return res;
+
+err_link:
+	sysfs_remove_link(&dev->class_dev.kobj, "wiphy");
+err_out:
 	return res;
 }
 
 void ieee80211_sysfs_remove_netdevice(struct net_device *dev)
 {
+	ieee80211_key_kset_sysfs_unregister(IEEE80211_DEV_TO_SUB_IF(dev));
 	ieee80211_remove_if_group(&dev->class_dev.kobj, dev);
 	sysfs_remove_link(&dev->class_dev.kobj, "wiphy");
 }
diff --git a/net/d80211/ieee80211_sysfs_sta.c b/net/d80211/ieee80211_sysfs_sta.c
index 07de564..94c6dd8 100644
--- a/net/d80211/ieee80211_sysfs_sta.c
+++ b/net/d80211/ieee80211_sysfs_sta.c
@@ -10,14 +10,22 @@
 #include <linux/kobject.h>
 #include <linux/sysfs.h>
 #include "ieee80211_i.h"
+#include "ieee80211_key.h"
 #include "sta_info.h"
 
 static ssize_t sta_sysfs_show(struct kobject *, struct attribute *, char *);
+static ssize_t key_sysfs_show(struct kobject *, struct attribute *, char *);
 
 static struct sysfs_ops sta_ktype_ops = {
 	.show = sta_sysfs_show,
 };
 
+static struct sysfs_ops key_ktype_ops = {
+	.show = key_sysfs_show,
+};
+
+/* sta attributtes */
+
 #define STA_SHOW(name, field, format_string)				\
 static ssize_t show_sta_##name(const struct sta_info *sta, char *buf)	\
 {									\
@@ -183,12 +191,153 @@ #endif
 	NULL
 };
 
+/* keys attributtes */
+
+struct key_attribute {
+	struct attribute attr;
+	ssize_t (*show)(const struct ieee80211_key *, char *buf);
+	ssize_t (*store)(struct ieee80211_key *, const char *buf,
+			 size_t count);
+};
+
+#define KEY_SHOW(name, field, format_string)				\
+static ssize_t show_key_##name(const struct ieee80211_key *key, char *buf)\
+{									\
+	return sprintf(buf, format_string, key->field);			\
+}
+#define KEY_SHOW_D(name, field) KEY_SHOW(name, field, "%d\n")
+
+#define __KEY_ATTR(name)						\
+static struct key_attribute key_attr_##name =				\
+	__ATTR(name, S_IRUSR, show_key_##name, NULL)
+
+#define KEY_ATTR(name, field, format)					\
+		KEY_SHOW_##format(name, field)				\
+		__KEY_ATTR(name)
+
+KEY_ATTR(length, keylen, D);
+KEY_ATTR(sw_encrypt, force_sw_encrypt, D);
+KEY_ATTR(index, keyidx, D);
+KEY_ATTR(hw_index, hw_key_idx, D);
+KEY_ATTR(tx_rx_count, tx_rx_count, D);
+
+static ssize_t show_key_algorithm(const struct ieee80211_key *key, char *buf)
+{
+	char *alg;
+
+	switch (key->alg) {
+	case ALG_WEP:
+		alg = "WEP";
+		break;
+	case ALG_TKIP:
+		alg = "TKIP";
+		break;
+	case ALG_CCMP:
+		alg = "CCMP";
+		break;
+	default:
+		return 0;
+	}
+	return sprintf(buf, "%s\n", alg);
+}
+__KEY_ATTR(algorithm);
+
+static ssize_t show_key_tx_spec(const struct ieee80211_key *key, char *buf)
+{
+	const u8 *tpn;
+
+	switch (key->alg) {
+	case ALG_WEP:
+		return sprintf(buf, "\n");
+	case ALG_TKIP:
+		return sprintf(buf, "%08x %04x\n", key->u.tkip.iv32,
+			       key->u.tkip.iv16);
+	case ALG_CCMP:
+		tpn = key->u.ccmp.tx_pn;
+		return sprintf(buf, "%02x%02x%02x%02x%02x%02x\n", tpn[0],
+			       tpn[1], tpn[2], tpn[3], tpn[4], tpn[5]);
+	default:
+		return 0;
+	}
+}
+__KEY_ATTR(tx_spec);
+
+static ssize_t show_key_rx_spec(const struct ieee80211_key *key, char *buf)
+{
+	int i;
+	const u8 *rpn;
+	char *p = buf;
+
+	switch (key->alg) {
+	case ALG_WEP:
+		return sprintf(buf, "\n");
+	case ALG_TKIP:
+		for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+			p += sprintf(p, "%08x %04x\n",
+				     key->u.tkip.iv32_rx[i],
+				     key->u.tkip.iv16_rx[i]);
+		return (p - buf);
+	case ALG_CCMP:
+		for (i = 0; i < NUM_RX_DATA_QUEUES; i++) {
+			rpn = key->u.ccmp.rx_pn[i];
+			p += sprintf(p, "%02x%02x%02x%02x%02x%02x\n", rpn[0],
+				     rpn[1], rpn[2], rpn[3], rpn[4], rpn[5]);
+		}
+		return (p - buf);
+	default:
+		return 0;
+	}
+}
+__KEY_ATTR(rx_spec);
+
+static ssize_t show_key_replays(const struct ieee80211_key *key, char *buf)
+{
+	if (key->alg != ALG_CCMP)
+		return 0;
+	return sprintf(buf, "%u\n", key->u.ccmp.replays);
+}
+__KEY_ATTR(replays);
+
+static ssize_t show_key_key(const struct ieee80211_key *key, char *buf)
+{
+	int i;
+	char *p = buf;
+
+	for (i = 0; i < key->keylen; i++)
+		p += sprintf(p, "%02x", key->key[i]);
+	p += sprintf(p, "\n");
+	return (p - buf);
+}
+__KEY_ATTR(key);
+
+static struct attribute *key_ktype_attrs[] = {
+	&key_attr_length.attr,
+	&key_attr_sw_encrypt.attr,
+	&key_attr_index.attr,
+	&key_attr_hw_index.attr,
+	&key_attr_tx_rx_count.attr,
+	&key_attr_algorithm.attr,
+	&key_attr_tx_spec.attr,
+	&key_attr_rx_spec.attr,
+	&key_attr_replays.attr,
+	&key_attr_key.attr,
+	NULL
+};
+
+/* structures and functions */
+
 static struct kobj_type sta_ktype = {
 	.release = sta_info_release,
 	.sysfs_ops = &sta_ktype_ops,
 	.default_attrs = sta_ktype_attrs,
 };
 
+static struct kobj_type key_ktype = {
+	.release = ieee80211_key_release,
+	.sysfs_ops = &key_ktype_ops,
+	.default_attrs = key_ktype_attrs,
+};
+
 static ssize_t sta_sysfs_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
@@ -200,6 +349,17 @@ static ssize_t sta_sysfs_show(struct kob
 	return sta_attr->show(sta, buf);
 }
 
+static ssize_t key_sysfs_show(struct kobject *kobj, struct attribute *attr,
+			      char *buf)
+{
+	struct key_attribute *key_attr;
+	struct ieee80211_key *key;
+
+	key_attr = container_of(attr, struct key_attribute, attr);
+	key = container_of(kobj, struct ieee80211_key, kobj);
+	return key_attr->show(key, buf);
+}
+
 int ieee80211_sta_kset_sysfs_register(struct ieee80211_local *local)
 {
 	int res;
@@ -217,6 +377,23 @@ void ieee80211_sta_kset_sysfs_unregister
 	kset_unregister(&local->sta_kset);
 }
 
+int ieee80211_key_kset_sysfs_register(struct ieee80211_sub_if_data *sdata)
+{
+	int res;
+
+	res = kobject_set_name(&sdata->key_kset.kobj, "keys");
+	if (res)
+		return res;
+	sdata->key_kset.kobj.parent = &sdata->dev->class_dev.kobj;
+	sdata->key_kset.ktype = &key_ktype;
+	return kset_register(&sdata->key_kset);
+}
+
+void ieee80211_key_kset_sysfs_unregister(struct ieee80211_sub_if_data *sdata)
+{
+	kset_unregister(&sdata->key_kset);
+}
+
 int ieee80211_sta_sysfs_add(struct sta_info *sta)
 {
 	return kobject_add(&sta->kobj);
@@ -226,3 +403,32 @@ void ieee80211_sta_sysfs_remove(struct s
 {
 	kobject_del(&sta->kobj);
 }
+
+void ieee80211_key_sysfs_set_kset(struct ieee80211_key *key, struct kset *kset)
+{
+	key->kobj.kset = kset;
+	if (!kset)
+		key->kobj.ktype = &key_ktype;
+}
+
+int ieee80211_key_sysfs_add(struct ieee80211_key *key)
+{
+	return kobject_add(&key->kobj);
+}
+
+void ieee80211_key_sysfs_remove(struct ieee80211_key *key)
+{
+	if (key)
+		kobject_del(&key->kobj);
+}
+
+int ieee80211_key_sysfs_add_default(struct ieee80211_sub_if_data *sdata)
+{
+	return sysfs_create_link(&sdata->key_kset.kobj,
+				 &sdata->default_key->kobj, "default");
+}
+
+void ieee80211_key_sysfs_remove_default(struct ieee80211_sub_if_data *sdata)
+{
+	sysfs_remove_link(&sdata->key_kset.kobj, "default");
+}
-- 
1.3.0

