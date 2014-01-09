From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/13] batman-adv: add isolation_mark sysfs attribute
Date: Thu,  9 Jan 2014 15:52:57 +0100
Message-ID: <1389279182-3256-9-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:18753 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbaAIOyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:54:50 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

This attribute can be used to set and read the value and the
mask of the skb mark which will be used to classify the
source non-mesh client as ISOLATED. In this way a client can
be advertised as such and the mark can potentially be
restored at the receiving node before delivering the skb.

This can be helpful for creating network wide netfilter
policies.

This sysfs file expects a string of the shape "$mark/$mask".
Where $mark has to be a 32-bit number in any base, while
$mask must be a 32bit mask expressed in hex base. Only bits
in $mark covered by the bitmask are really stored.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 Documentation/ABI/testing/sysfs-class-net-mesh |  8 +++
 net/batman-adv/soft-interface.c                |  2 +
 net/batman-adv/sysfs.c                         | 71 ++++++++++++++++++++++++++
 net/batman-adv/types.h                         |  2 +
 4 files changed, 83 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index 0baa657..4793d3d 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -68,6 +68,14 @@ Description:
                 Defines the penalty which will be applied to an
                 originator message's tq-field on every hop.
 
+What:		/sys/class/net/<mesh_iface>/mesh/isolation_mark
+Date:		Nov 2013
+Contact:	Antonio Quartulli <antonio@meshcoding.com>
+Description:
+		Defines the isolation mark (and its bitmask) which
+		is used to classify clients as "isolated" by the
+		Extended Isolation feature.
+
 What:           /sys/class/net/<mesh_iface>/mesh/network_coding
 Date:           Nov 2012
 Contact:        Martin Hundeboll <martin@hundeboll.net>
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b569932..35a82e3 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -701,6 +701,8 @@ static int batadv_softif_init_late(struct net_device *dev)
 #endif
 	bat_priv->tt.last_changeset = NULL;
 	bat_priv->tt.last_changeset_len = 0;
+	bat_priv->isolation_mark = 0;
+	bat_priv->isolation_mark_mask = 0;
 
 	/* randomize initial seqno to avoid collision */
 	get_random_bytes(&random_seqno, sizeof(random_seqno));
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 511e011..b6a4403 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -450,6 +450,74 @@ static ssize_t batadv_store_gw_bwidth(struct kobject *kobj,
 	return batadv_gw_bandwidth_set(net_dev, buff, count);
 }
 
+/**
+ * batadv_show_isolation_mark - print the current isolation mark/mask
+ * @kobj: kobject representing the private mesh sysfs directory
+ * @attr: the batman-adv attribute the user is interacting with
+ * @buff: the buffer that will contain the data to send back to the user
+ *
+ * Returns the number of bytes written into 'buff' on success or a negative
+ * error code in case of failure
+ */
+static ssize_t batadv_show_isolation_mark(struct kobject *kobj,
+					  struct attribute *attr, char *buff)
+{
+	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
+
+	return sprintf(buff, "%#.8x/%#.8x\n", bat_priv->isolation_mark,
+		       bat_priv->isolation_mark_mask);
+}
+
+/**
+ * batadv_store_isolation_mark - parse and store the isolation mark/mask entered
+ *  by the user
+ * @kobj: kobject representing the private mesh sysfs directory
+ * @attr: the batman-adv attribute the user is interacting with
+ * @buff: the buffer containing the user data
+ * @count: number of bytes in the buffer
+ *
+ * Returns 'count' on success or a negative error code in case of failure
+ */
+static ssize_t batadv_store_isolation_mark(struct kobject *kobj,
+					   struct attribute *attr, char *buff,
+					   size_t count)
+{
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
+	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+	uint32_t mark, mask;
+	char *mask_ptr;
+
+	/* parse the mask if it has been specified, otherwise assume the mask is
+	 * the biggest possible
+	 */
+	mask = 0xFFFFFFFF;
+	mask_ptr = strchr(buff, '/');
+	if (mask_ptr) {
+		*mask_ptr = '\0';
+		mask_ptr++;
+
+		/* the mask must be entered in hex base as it is going to be a
+		 * bitmask and not a prefix length
+		 */
+		if (kstrtou32(mask_ptr, 16, &mask) < 0)
+			return -EINVAL;
+	}
+
+	/* the mark can be entered in any base */
+	if (kstrtou32(buff, 0, &mark) < 0)
+		return -EINVAL;
+
+	bat_priv->isolation_mark_mask = mask;
+	/* erase bits not covered by the mask */
+	bat_priv->isolation_mark = mark & bat_priv->isolation_mark_mask;
+
+	batadv_info(net_dev,
+		    "New skb mark for extended isolation: %#.8x/%#.8x\n",
+		    bat_priv->isolation_mark, bat_priv->isolation_mark_mask);
+
+	return count;
+}
+
 BATADV_ATTR_SIF_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
 BATADV_ATTR_SIF_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
 #ifdef CONFIG_BATMAN_ADV_BLA
@@ -478,6 +546,8 @@ BATADV_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, BATADV_DBG_ALL, NULL);
 BATADV_ATTR_SIF_BOOL(network_coding, S_IRUGO | S_IWUSR,
 		     batadv_nc_status_update);
 #endif
+static BATADV_ATTR(isolation_mark, S_IRUGO | S_IWUSR,
+		   batadv_show_isolation_mark, batadv_store_isolation_mark);
 
 static struct batadv_attribute *batadv_mesh_attrs[] = {
 	&batadv_attr_aggregated_ogms,
@@ -501,6 +571,7 @@ static struct batadv_attribute *batadv_mesh_attrs[] = {
 #ifdef CONFIG_BATMAN_ADV_NC
 	&batadv_attr_network_coding,
 #endif
+	&batadv_attr_isolation_mark,
 	NULL,
 };
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 70abb1c..0430a04 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -697,6 +697,8 @@ struct batadv_priv {
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 	atomic_t log_level;
 #endif
+	uint32_t isolation_mark;
+	uint32_t isolation_mark_mask;
 	atomic_t bcast_seqno;
 	atomic_t bcast_queue_left;
 	atomic_t batman_queue_left;
-- 
1.8.5.2
