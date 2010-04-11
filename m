From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] rps: add flow director support
Date: Mon, 12 Apr 2010 05:42:20 +0800
Message-ID: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:50442 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab0DKNm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 09:42:58 -0400
Received: by pva18 with SMTP id 18so2730510pva.19
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 06:42:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add rps flow director support

with rps flow director, users can do weighted packet dispatching among CPUs.
For example, CPU0:CPU1 is 1:3 for eth0's rx-0:

 localhost linux # echo 4 > /sys/class/net/eth0/queues/rx-0/rps_flows  
 localhost linux # echo 0 > /sys/class/net/eth0/queues/rx-0/rps_flow_0
 localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flow_1
 localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flow_2
 localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flow_3

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/net-sysfs.c |  176 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 172 insertions(+), 4 deletions(-)
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1e7fdd6..d904610 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -511,6 +511,109 @@ static struct sysfs_ops rx_queue_sysfs_ops = {
 	.store = rx_queue_attr_store,
 };
 
+static DEFINE_MUTEX(rps_map_lock);
+
+static ssize_t show_rps_flow(struct netdev_rx_queue *queue,
+			     struct rx_queue_attribute *attribute, char *buf)
+{
+	unsigned long flowid;
+	struct rps_map *map;
+	u16 cpu;
+
+	strict_strtoul(attribute->attr.name + strlen("rps_flow_"), 10, &flowid);
+	rcu_read_lock();
+	map = rcu_dereference(queue->rps_map);
+	if (map && flowid < map->len)
+		cpu = map->cpus[flowid];
+	else
+		cpu = 0;
+	rcu_read_unlock();
+	return sprintf(buf, "%hu\n", cpu);
+}
+
+static ssize_t store_rps_flow(struct netdev_rx_queue *queue,
+			      struct rx_queue_attribute *attribute,
+			      const char *buf, size_t len)
+{
+	unsigned long flowid, cpu;
+	struct rps_map *map;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (strict_strtoul(buf, 0, &cpu))
+		return -EINVAL;
+	strict_strtoul(attribute->attr.name + strlen("rps_flow_"), 10, &flowid);
+
+	mutex_lock(&rps_map_lock);
+	map = queue->rps_map;
+	if (map && flowid < map->len)
+		map->cpus[flowid] = cpu;
+	mutex_unlock(&rps_map_lock);
+
+	return len;
+}
+
+static struct rx_queue_attribute **rps_flow_attribute;
+static int rps_flow_attribute_size;
+
+/* must be called with rps_map_lock locked */
+static int update_rps_flow_files(struct kobject *kobj,
+				 struct rps_map *old_map, struct rps_map *map)
+{
+	int i;
+	int old_map_len = old_map ? old_map->len : 0;
+	int map_len = map ? map->len : 0;
+
+	if (old_map_len >= map_len) {
+		for (i = map_len; i < old_map_len; i++)
+			sysfs_remove_file(kobj, &rps_flow_attribute[i]->attr);
+		return 0;
+	}
+
+	if (map_len > rps_flow_attribute_size) {
+		struct rx_queue_attribute **attrs;
+		char name[sizeof("rps_flow_4294967295")];
+		char *pname;
+
+		attrs = krealloc(rps_flow_attribute, map_len * sizeof(void *),
+				 GFP_KERNEL);
+		if (attrs == NULL)
+			return -ENOMEM;
+		rps_flow_attribute = attrs;
+		for (i = rps_flow_attribute_size; i < map_len; i++) {
+			rps_flow_attribute[i] = kmalloc(sizeof(**attrs),
+							GFP_KERNEL);
+			if (rps_flow_attribute[i] == NULL)
+				break;
+			sprintf(name, "rps_flow_%d", i);
+			pname = kstrdup(name, GFP_KERNEL);
+			if (pname == NULL) {
+				kfree(rps_flow_attribute[i]);
+				break;
+			}
+			rps_flow_attribute[i]->attr.name = pname;
+			rps_flow_attribute[i]->attr.mode = S_IRUGO | S_IWUSR;
+			rps_flow_attribute[i]->show = show_rps_flow;
+			rps_flow_attribute[i]->store = store_rps_flow;
+		}
+		rps_flow_attribute_size = i;
+		if (i != map_len)
+			return -ENOMEM;
+	}
+
+	for (i = old_map_len; i < map_len; i++) {
+		if (sysfs_create_file(kobj, &rps_flow_attribute[i]->attr)) {
+			while (--i >= old_map_len)
+				sysfs_remove_file(kobj,
+						  &rps_flow_attribute[i]->attr);
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
 static ssize_t show_rps_map(struct netdev_rx_queue *queue,
 			    struct rx_queue_attribute *attribute, char *buf)
 {
@@ -555,7 +658,6 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	struct rps_map *old_map, *map;
 	cpumask_var_t mask;
 	int err, cpu, i;
-	static DEFINE_SPINLOCK(rps_map_lock);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -588,10 +690,15 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 		map = NULL;
 	}
 
-	spin_lock(&rps_map_lock);
+	mutex_lock(&rps_map_lock);
 	old_map = queue->rps_map;
-	rcu_assign_pointer(queue->rps_map, map);
-	spin_unlock(&rps_map_lock);
+	err = update_rps_flow_files(&queue->kobj, old_map, map);
+	if (!err)
+		rcu_assign_pointer(queue->rps_map, map);
+	mutex_unlock(&rps_map_lock);
+
+	if (err)
+		return err;
 
 	if (old_map)
 		call_rcu(&old_map->rcu, rps_map_release);
@@ -603,8 +710,69 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 static struct rx_queue_attribute rps_cpus_attribute =
 	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
 
+static ssize_t show_rps_flows(struct netdev_rx_queue *queue,
+		struct rx_queue_attribute *attribute, char *buf)
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
+static ssize_t store_rps_flows(struct netdev_rx_queue *queue,
+			       struct rx_queue_attribute *attribute,
+			       const char *buf, size_t len)
+{
+	struct rps_map *old_map, *map;
+	unsigned long flows;
+	int err;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (strict_strtoul(buf, 0, &flows))
+		return -EINVAL;
+	if (flows != 0) {
+		map = kzalloc(max_t(unsigned, RPS_MAP_SIZE(flows),
+				    L1_CACHE_BYTES), GFP_KERNEL);
+		if (map == NULL)
+			return -ENOMEM;
+		map->len = flows;
+	} else {
+		map = NULL;
+	}
+
+	mutex_lock(&rps_map_lock);
+	old_map = queue->rps_map;
+	err = update_rps_flow_files(&queue->kobj, old_map, map);
+	if (!err) {
+		if (old_map && map)
+			memcpy(map->cpus, old_map->cpus,
+			       sizeof(map->cpus[0]) *
+			       min_t(unsigned int, flows, old_map->len));
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
+static struct rx_queue_attribute rps_flows_attribute =
+	__ATTR(rps_flows, S_IRUGO | S_IWUSR, show_rps_flows, store_rps_flows);
+
 static struct attribute *rx_queue_default_attrs[] = {
 	&rps_cpus_attribute.attr,
+	&rps_flows_attribute.attr,
 	NULL
 };
 
