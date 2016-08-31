From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 3/4] net: Add xps_dev_flow_table_cnt
Date: Tue, 30 Aug 2016 17:00:33 -0700
Message-ID: <1472601634-531498-4-git-send-email-tom@herbertland.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43741 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752320AbcHaABI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 20:01:08 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7UNvP6Q018843
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:00:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 255kcwgdws-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:00:49 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.101.97) with ESMTP id
 f6dc28906f0d11e681d924be0595f910-198f1a50 for <netdev@vger.kernel.org>;        Tue,
 30 Aug 2016 17:00:45 -0700
In-Reply-To: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add infrastructure and definitions to create XFS flow tables. This
creates the new sys entry /sys/class/net/eth*/xps_dev_flow_table_cnt

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h | 22 ++++++++++++++
 net/core/net-sysfs.c      | 76 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 98 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 487d1df..d30e1bb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -736,8 +736,28 @@ struct xps_dev_maps {
 };
 #define XPS_DEV_MAPS_SIZE (sizeof(struct xps_dev_maps) +		\
     (nr_cpu_ids * sizeof(struct xps_map *)))
+
+struct xps_dev_flow {
+	union {
+		u64	v64;
+		struct {
+			int		queue_index;
+			unsigned int	queue_ptr;
+		};
+	};
+};
+
+struct xps_dev_flow_table {
+	unsigned int mask;
+	struct rcu_head rcu;
+	struct xps_dev_flow flows[0];
+};
+#define XPS_DEV_FLOW_TABLE_SIZE(_num) (sizeof(struct xps_dev_flow_table) + \
+	((_num) * sizeof(struct xps_dev_flow)))
+
 #endif /* CONFIG_XPS */
 
+
 #define TC_MAX_QUEUE	16
 #define TC_BITMASK	15
 /* HW offloaded queuing disciplines txq count and offset maps */
@@ -1810,6 +1830,8 @@ struct net_device {
 
 #ifdef CONFIG_XPS
 	struct xps_dev_maps __rcu *xps_maps;
+	struct xps_dev_flow_table __rcu *xps_flow_table;
+	unsigned int xps_dev_flow_table_cnt;
 #endif
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto __rcu  *egress_cl_list;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5a33f6a..41d0bc9 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -503,6 +503,79 @@ static ssize_t phys_switch_id_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(phys_switch_id);
 
+#ifdef CONFIG_XPS
+static void xps_dev_flow_table_release(struct rcu_head *rcu)
+{
+	struct xps_dev_flow_table *table = container_of(rcu,
+	    struct xps_dev_flow_table, rcu);
+	vfree(table);
+}
+
+static int change_xps_dev_flow_table_cnt(struct net_device *dev,
+					 unsigned long count)
+{
+	unsigned long mask;
+	struct xps_dev_flow_table *table, *old_table;
+	static DEFINE_SPINLOCK(xps_dev_flow_lock);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (count) {
+		mask = count - 1;
+		/* mask = roundup_pow_of_two(count) - 1;
+		 * without overflows...
+		 */
+		while ((mask | (mask >> 1)) != mask)
+			mask |= (mask >> 1);
+		/* On 64 bit arches, must check mask fits in table->mask (u32),
+		 * and on 32bit arches, must check
+		 * XPS_DEV_FLOW_TABLE_SIZE(mask + 1) doesn't overflow.
+		 */
+#if BITS_PER_LONG > 32
+		if (mask > (unsigned long)(u32)mask)
+			return -EINVAL;
+#else
+		if (mask > (ULONG_MAX - XPS_DEV_FLOW_TABLE_SIZE(1))
+				/ sizeof(struct xps_dev_flow)) {
+			/* Enforce a limit to prevent overflow */
+			return -EINVAL;
+		}
+#endif
+		table = vmalloc(XPS_DEV_FLOW_TABLE_SIZE(mask + 1));
+		if (!table)
+			return -ENOMEM;
+
+		table->mask = mask;
+		for (count = 0; count <= mask; count++)
+			table->flows[count].queue_index = -1;
+	} else
+		table = NULL;
+
+	spin_lock(&xps_dev_flow_lock);
+	old_table = rcu_dereference_protected(dev->xps_flow_table,
+					      lockdep_is_held(&xps_dev_flow_lock));
+	rcu_assign_pointer(dev->xps_flow_table, table);
+	dev->xps_dev_flow_table_cnt = count;
+	spin_unlock(&xps_dev_flow_lock);
+
+	if (old_table)
+		call_rcu(&old_table->rcu, xps_dev_flow_table_release);
+
+	return 0;
+}
+
+static ssize_t xps_dev_flow_table_cnt_store(struct device *dev,
+					    struct device_attribute *attr,
+					    const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, change_xps_dev_flow_table_cnt);
+}
+
+NETDEVICE_SHOW_RW(xps_dev_flow_table_cnt, fmt_dec);
+
+#endif
+
 static struct attribute *net_class_attrs[] = {
 	&dev_attr_netdev_group.attr,
 	&dev_attr_type.attr,
@@ -531,6 +604,9 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_phys_port_name.attr,
 	&dev_attr_phys_switch_id.attr,
 	&dev_attr_proto_down.attr,
+#ifdef CONFIG_XPS
+	&dev_attr_xps_dev_flow_table_cnt.attr,
+#endif
 	NULL,
 };
 ATTRIBUTE_GROUPS(net_class);
-- 
2.8.0.rc2
