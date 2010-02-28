From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 12/13] bridge: Add hash elasticity/max sysfs entries
Date: Sun, 28 Feb 2010 13:41:51 +0800
Message-ID: <E1NlbuZ-000224-H9@gondolin.me.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42766 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752660Ab0B1Fl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 00:41:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add hash elasticity/max sysfs entries

This patch allows the user to control the hash elasticity/max
parameters.  The elasticity setting does not take effect until
the next new multicast group is added.  At which point it is
checked and if after rehashing it still can't be satisfied then
snooping will be disabled.

The max setting on the other hand takes effect immediately.  It
must be a power of two and cannot be set to a value less than the
current number of multicast group entries.  This is the only way
to shrink the multicast hash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_multicast.c |   41 +++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h   |    1 +
 net/bridge/br_sysfs_br.c  |   39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 81 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c7a1095..2559fb5 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -15,6 +15,7 @@
 #include <linux/igmp.h>
 #include <linux/jhash.h>
 #include <linux/kernel.h>
+#include <linux/log2.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter_bridge.h>
 #include <linux/random.h>
@@ -1261,3 +1262,43 @@ unlock:
 
 	return err;
 }
+
+int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val)
+{
+	int err = -ENOENT;
+	u32 old;
+
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev))
+		goto unlock;
+
+	err = -EINVAL;
+	if (!is_power_of_2(val))
+		goto unlock;
+	if (br->mdb && val < br->mdb->size)
+		goto unlock;
+
+	err = 0;
+
+	old = br->hash_max;
+	br->hash_max = val;
+
+	if (br->mdb) {
+		if (br->mdb->old) {
+			err = -EEXIST;
+rollback:
+			br->hash_max = old;
+			goto unlock;
+		}
+
+		err = br_mdb_rehash(&br->mdb, br->hash_max,
+				    br->hash_elasticity);
+		if (err)
+			goto rollback;
+	}
+
+unlock:
+	spin_unlock(&br->multicast_lock);
+
+	return err;
+}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4467904..0f12a8f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -302,6 +302,7 @@ extern int br_multicast_set_router(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_port_router(struct net_bridge_port *p,
 					unsigned long val);
 extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
+extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
 				   struct net_bridge_port *port,
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 0ab2883..d2ee53b 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -378,6 +378,43 @@ static ssize_t store_multicast_snooping(struct device *d,
 }
 static DEVICE_ATTR(multicast_snooping, S_IRUGO | S_IWUSR,
 		   show_multicast_snooping, store_multicast_snooping);
+
+static ssize_t show_hash_elasticity(struct device *d,
+				    struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->hash_elasticity);
+}
+
+static int set_elasticity(struct net_bridge *br, unsigned long val)
+{
+	br->hash_elasticity = val;
+	return 0;
+}
+
+static ssize_t store_hash_elasticity(struct device *d,
+				     struct device_attribute *attr,
+				     const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_elasticity);
+}
+static DEVICE_ATTR(hash_elasticity, S_IRUGO | S_IWUSR, show_hash_elasticity,
+		   store_hash_elasticity);
+
+static ssize_t show_hash_max(struct device *d, struct device_attribute *attr,
+			     char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->hash_max);
+}
+
+static ssize_t store_hash_max(struct device *d, struct device_attribute *attr,
+			      const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_multicast_set_hash_max);
+}
+static DEVICE_ATTR(hash_max, S_IRUGO | S_IWUSR, show_hash_max,
+		   store_hash_max);
 #endif
 
 static struct attribute *bridge_attrs[] = {
@@ -402,6 +439,8 @@ static struct attribute *bridge_attrs[] = {
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
+	&dev_attr_hash_elasticity.attr,
+	&dev_attr_hash_max.attr,
 #endif
 	NULL
 };
