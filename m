From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] RPS: export internal software RX queues via sysfs
Date: Wed, 14 Apr 2010 15:57:59 +0800
Message-ID: <1271231879-3079-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:64946 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab0DNH5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 03:57:45 -0400
Received: by pwj9 with SMTP id 9so6068133pwj.19
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 00:57:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

export internal software RX queues via sysfs.

The RPS software RX queues are exported as
/sys/class/net/$nic/queues/rx-$/sw-rx-$, and you can specify which CPU handles
a special queue by writing the CPU id to the corresponding file sw-rx-$.
The number of software RX queues can be specified by writing
/sys/class/net/$nic/queues/rx-$/nr-sw-rx. nr-sw-rx is 0 by default.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/net-sysfs.c |  234 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 230 insertions(+), 4 deletions(-)
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 96ed690..4a547b7 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -512,6 +512,167 @@ static struct sysfs_ops rx_queue_sysfs_ops = {
 	.store = rx_queue_attr_store,
 };
 
+static DEFINE_MUTEX(rps_map_lock);
+
+static ssize_t show_sw_rx(struct netdev_rx_queue *queue,
+			     struct rx_queue_attribute *attribute, char *buf)
+{
+	unsigned long id;
+	struct rps_map *map;
+	u16 cpu;
+
+	strict_strtoul(attribute->attr.name + strlen("sw-rx-"), 10, &id);
+	rcu_read_lock();
+	map = rcu_dereference(queue->rps_map);
+	if (map && id < map->len)
+		cpu = map->cpus[id];
+	else
+		cpu = 0;
+	rcu_read_unlock();
+	return sprintf(buf, "%hu\n", cpu);
+}
+
+static ssize_t store_sw_rx(struct netdev_rx_queue *queue,
+			      struct rx_queue_attribute *attribute,
+			      const char *buf, size_t len)
+{
+	unsigned long id, cpu;
+	struct rps_map *map;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (strict_strtoul(buf, 0, &cpu) || cpu >= nr_cpumask_bits)
+		return -EINVAL;
+	strict_strtoul(attribute->attr.name + strlen("sw-rx-"), 10, &id);
+
+	mutex_lock(&rps_map_lock);
+	map = queue->rps_map;
+	if (map && id < map->len)
+		map->cpus[id] = cpu;
+	mutex_unlock(&rps_map_lock);
+
+	return len;
+}
+
+struct sw_rx_attribute {
+	struct rx_queue_attribute	qattr;
+	atomic_t			ref;
+};
+
+static inline void sw_rx_attribute_free(struct sw_rx_attribute *attr)
+{
+	kfree(attr->qattr.attr.name);
+	kfree(attr);
+}
+
+static struct sw_rx_attribute **sw_rx_attr;
+static int sw_rx_attr_size;
+
+#define SW_RX_MAX 65535
+
+static void shrink_sw_rx_attr(void)
+{
+	struct sw_rx_attribute **attrs;
+
+	if (sw_rx_attr_size == 0) {
+		kfree(sw_rx_attr);
+		sw_rx_attr = NULL;
+		return;
+	}
+
+	attrs = kmalloc(sw_rx_attr_size * sizeof(void *), GFP_KERNEL);
+	if (attrs == NULL)
+		return;
+	memcpy(attrs, sw_rx_attr, sw_rx_attr_size * sizeof(void *));
+	swap(attrs, sw_rx_attr);
+	kfree(attrs);
+}
+
+/* must be called with rps_map_lock locked */
+static int update_sw_rx_files(struct kobject *kobj,
+				 struct rps_map *old_map, struct rps_map *map)
+{
+	int i;
+	int old_map_len = old_map ? old_map->len : 0;
+	int map_len = map ? map->len : 0;
+
+	if (old_map_len >= map_len) {
+		bool shrink = false;
+
+		for (i = old_map_len - 1; i >= map_len; i--) {
+			sysfs_remove_file(kobj, &sw_rx_attr[i]->qattr.attr);
+			if (atomic_dec_and_test(&sw_rx_attr[i]->ref)) {
+				sw_rx_attribute_free(sw_rx_attr[i]);
+				sw_rx_attr_size--;
+				shrink = true;
+			}
+
+		}
+
+		if (shrink)
+			shrink_sw_rx_attr();
+
+		return 0;
+	}
+
+	if (map_len > sw_rx_attr_size) {
+		struct sw_rx_attribute **attrs;
+		char name[sizeof("sw-rx-" __stringify(SW_RX_MAX))];
+		char *pname;
+
+		attrs = krealloc(sw_rx_attr, map_len * sizeof(void *),
+				 GFP_KERNEL);
+		if (attrs == NULL)
+			return -ENOMEM;
+		sw_rx_attr = attrs;
+		for (i = sw_rx_attr_size; i < map_len; i++) {
+			sw_rx_attr[i] = kmalloc(sizeof(**attrs), GFP_KERNEL);
+			if (sw_rx_attr[i] == NULL)
+				break;
+			sprintf(name, "sw-rx-%d", i);
+			pname = kstrdup(name, GFP_KERNEL);
+			if (pname == NULL) {
+				kfree(sw_rx_attr[i]);
+				break;
+			}
+			sw_rx_attr[i]->qattr.attr.name = pname;
+			sw_rx_attr[i]->qattr.attr.mode = S_IRUGO | S_IWUSR;
+			sw_rx_attr[i]->qattr.show = show_sw_rx;
+			sw_rx_attr[i]->qattr.store = store_sw_rx;
+			atomic_set(&sw_rx_attr[i]->ref, 0);
+		}
+		if (i != map_len) {
+			while (--i >= sw_rx_attr_size)
+				sw_rx_attribute_free(sw_rx_attr[i]);
+			shrink_sw_rx_attr();
+			return -ENOMEM;
+		}
+	}
+
+	for (i = old_map_len; i < map_len; i++) {
+		atomic_inc(&sw_rx_attr[i]->ref);
+		if (sysfs_create_file(kobj, &sw_rx_attr[i]->qattr.attr) == 0)
+			continue;
+		atomic_dec(&sw_rx_attr[i]->ref);
+		while (--i >= old_map_len) {
+			sysfs_remove_file(kobj, &sw_rx_attr[i]->qattr.attr);
+			atomic_dec(&sw_rx_attr[i]->ref);
+		}
+		if (sw_rx_attr_size < map_len) {
+			for (i = sw_rx_attr_size; i < map_len; i++)
+				sw_rx_attribute_free(sw_rx_attr[i]);
+			shrink_sw_rx_attr();
+		}
+		return -ENOMEM;
+	}
+
+	if (sw_rx_attr_size < map_len)
+		sw_rx_attr_size = map_len;
+
+	return 0;
+}
+
 static ssize_t show_rps_map(struct netdev_rx_queue *queue,
 			    struct rx_queue_attribute *attribute, char *buf)
 {
@@ -556,7 +717,6 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	struct rps_map *old_map, *map;
 	cpumask_var_t mask;
 	int err, cpu, i;
-	static DEFINE_SPINLOCK(rps_map_lock);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -589,10 +749,15 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 		map = NULL;
 	}
 
-	spin_lock(&rps_map_lock);
+	mutex_lock(&rps_map_lock);
 	old_map = queue->rps_map;
-	rcu_assign_pointer(queue->rps_map, map);
-	spin_unlock(&rps_map_lock);
+	err = update_sw_rx_files(&queue->kobj, old_map, map);
+	if (!err)
+		rcu_assign_pointer(queue->rps_map, map);
+	mutex_unlock(&rps_map_lock);
+
+	if (err)
+		return err;
 
 	if (old_map)
 		call_rcu(&old_map->rcu, rps_map_release);
@@ -604,8 +769,69 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 static struct rx_queue_attribute rps_cpus_attribute =
 	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
 
+static ssize_t show_nr_sw_rx(struct netdev_rx_queue *queue,
+			      struct rx_queue_attribute *attribute, char *buf)
+{
+	struct rps_map *map;
+	unsigned int len;
+
+	rcu_read_lock();
+	map = rcu_dereference(queue->rps_map);
+	len = map ? map->len : 0;
+	rcu_read_unlock();
+	return sprintf(buf, "%u\n", len);
+}
+
+static ssize_t store_nr_sw_rx(struct netdev_rx_queue *queue,
+			      struct rx_queue_attribute *attribute,
+			      const char *buf, size_t len)
+{
+	struct rps_map *old_map, *map;
+	unsigned long nr;
+	int err;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (strict_strtoul(buf, 0, &nr) || nr > SW_RX_MAX + 1)
+		return -EINVAL;
+	if (nr != 0) {
+		map = kzalloc(max_t(unsigned, RPS_MAP_SIZE(nr), L1_CACHE_BYTES),
+			      GFP_KERNEL);
+		if (map == NULL)
+			return -ENOMEM;
+		map->len = nr;
+	} else {
+		map = NULL;
+	}
+
+	mutex_lock(&rps_map_lock);
+	old_map = queue->rps_map;
+	err = update_sw_rx_files(&queue->kobj, old_map, map);
+	if (!err) {
+		if (old_map && map)
+			memcpy(map->cpus, old_map->cpus,
+			       sizeof(map->cpus[0]) *
+			       min_t(unsigned int, nr, old_map->len));
+		rcu_assign_pointer(queue->rps_map, map);
+	}
+	mutex_unlock(&rps_map_lock);
+
+	if (err)
+		return err;
+
+	if (old_map)
+		call_rcu(&old_map->rcu, rps_map_release);
+
+	return len;
+}
+
+static struct rx_queue_attribute nr_sw_rx_attribute =
+	__ATTR(nr-sw-rx, S_IRUGO | S_IWUSR, show_nr_sw_rx, store_nr_sw_rx);
+
 static struct attribute *rx_queue_default_attrs[] = {
 	&rps_cpus_attribute.attr,
+	&nr_sw_rx_attribute.attr,
 	NULL
 };
 
