From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 3/5] net: Add xps_dev_flow_table_cnt
Date: Wed, 28 Sep 2016 20:54:26 -0700
Message-ID: <20160929035428.204355-4-tom@herbertland.com>
References: <20160929035428.204355-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <rick.jones2@hpe.com>,
        <alexander.duyck@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55781 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752213AbcI2Dys (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 23:54:48 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T3o2x9025916
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 20:54:47 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25rpgyj6tc-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 20:54:47 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 75e1e43085f811e6a7270002c99331b0-179f9a50 for <netdev@vger.kernel.org>;        Wed,
 28 Sep 2016 20:54:45 -0700
In-Reply-To: <20160929035428.204355-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add infrastructure and definitions to create XFS flow tables. This
creates the new sys entry /sys/class/net/eth*/xps_dev_flow_table_cnt

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h | 24 +++++++++++++
 net/core/net-sysfs.c      | 89 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 113 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9567107..60063b3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -736,6 +736,27 @@ struct xps_dev_maps {
     (nr_cpu_ids * sizeof(struct xps_map *)))
 #endif /* CONFIG_XPS */
 
+#ifdef CONFIG_XPS_FLOWS
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
+#endif /* CONFIG_XPS_FLOWS */
+
 #define TC_MAX_QUEUE	16
 #define TC_BITMASK	15
 /* HW offloaded queuing disciplines txq count and offset maps */
@@ -1825,6 +1846,9 @@ struct net_device {
 #ifdef CONFIG_XPS
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
+#ifdef CONFIG_XPS_FLOWS
+	struct xps_dev_flow_table __rcu *xps_flow_table;
+#endif
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto __rcu  *egress_cl_list;
 #endif
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index ab7b0b6..0d00b9c 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -503,6 +503,92 @@ static ssize_t phys_switch_id_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(phys_switch_id);
 
+#ifdef CONFIG_XPS_FLOWS
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
+static ssize_t xps_dev_flow_table_cnt_show(struct device *dev,
+			    struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	struct xps_dev_flow_table *table;
+	unsigned int cnt = 0;
+
+	rcu_read_lock();
+	table = rcu_dereference(netdev->xps_flow_table);
+	if (table)
+		cnt = table->mask + 1;
+	rcu_read_unlock();
+
+	return sprintf(buf, fmt_dec, cnt);
+}
+DEVICE_ATTR_RW(xps_dev_flow_table_cnt);
+#endif /* CONFIG_XPS_FLOWS */
+
 static struct attribute *net_class_attrs[] = {
 	&dev_attr_netdev_group.attr,
 	&dev_attr_type.attr,
@@ -531,6 +617,9 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_phys_port_name.attr,
 	&dev_attr_phys_switch_id.attr,
 	&dev_attr_proto_down.attr,
+#ifdef CONFIG_XPS_FLOWS
+	&dev_attr_xps_dev_flow_table_cnt.attr,
+#endif
 	NULL,
 };
 ATTRIBUTE_GROUPS(net_class);
-- 
2.9.3
