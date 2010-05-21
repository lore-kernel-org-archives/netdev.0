From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the driver-core tree with the net tree
Date: Fri, 21 May 2010 16:21:34 +1000
Message-ID: <20100521162134.6b6326bd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

Today's linux-next merge of the driver-core tree got a conflict in
net/core/net-sysfs.c between commits
0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Receive Packet Steering")
and fec5e652e58fa6017b2c9e06466cb2a6538de5b4 ("rfs: Receive Flow
Steering") from the net tree and commits
bc28c84244da26bafb0d3bce95ef45212b31c6b8 ("net/sysfs: Fix the bitrot in
network device kobject namespace support") and
83dc0fbf37495691219d019ec16b40d8592d2956 ("net: Expose all network
devices in a namespaces in sysfs") from the driver-core tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/core/net-sysfs.c
index c57c4b2,46add45..0000000
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@@ -14,10 -14,11 +14,12 @@@
  #include <linux/netdevice.h>
  #include <linux/if_arp.h>
  #include <linux/slab.h>
+ #include <linux/nsproxy.h>
  #include <net/sock.h>
+ #include <net/net_namespace.h>
  #include <linux/rtnetlink.h>
  #include <linux/wireless.h>
 +#include <linux/vmalloc.h>
  #include <net/wext.h>
  
  #include "net-sysfs.h"
@@@ -467,307 -468,40 +469,339 @@@ static struct attribute_group wireless_
  	.attrs = wireless_attrs,
  };
  #endif
 +
 +#ifdef CONFIG_RPS
 +/*
 + * RX queue sysfs structures and functions.
 + */
 +struct rx_queue_attribute {
 +	struct attribute attr;
 +	ssize_t (*show)(struct netdev_rx_queue *queue,
 +	    struct rx_queue_attribute *attr, char *buf);
 +	ssize_t (*store)(struct netdev_rx_queue *queue,
 +	    struct rx_queue_attribute *attr, const char *buf, size_t len);
 +};
 +#define to_rx_queue_attr(_attr) container_of(_attr,		\
 +    struct rx_queue_attribute, attr)
 +
 +#define to_rx_queue(obj) container_of(obj, struct netdev_rx_queue, kobj)
 +
 +static ssize_t rx_queue_attr_show(struct kobject *kobj, struct attribute *attr,
 +				  char *buf)
 +{
 +	struct rx_queue_attribute *attribute = to_rx_queue_attr(attr);
 +	struct netdev_rx_queue *queue = to_rx_queue(kobj);
 +
 +	if (!attribute->show)
 +		return -EIO;
 +
 +	return attribute->show(queue, attribute, buf);
 +}
 +
 +static ssize_t rx_queue_attr_store(struct kobject *kobj, struct attribute *attr,
 +				   const char *buf, size_t count)
 +{
 +	struct rx_queue_attribute *attribute = to_rx_queue_attr(attr);
 +	struct netdev_rx_queue *queue = to_rx_queue(kobj);
 +
 +	if (!attribute->store)
 +		return -EIO;
 +
 +	return attribute->store(queue, attribute, buf, count);
 +}
 +
 +static struct sysfs_ops rx_queue_sysfs_ops = {
 +	.show = rx_queue_attr_show,
 +	.store = rx_queue_attr_store,
 +};
 +
 +static ssize_t show_rps_map(struct netdev_rx_queue *queue,
 +			    struct rx_queue_attribute *attribute, char *buf)
 +{
 +	struct rps_map *map;
 +	cpumask_var_t mask;
 +	size_t len = 0;
 +	int i;
 +
 +	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
 +		return -ENOMEM;
 +
 +	rcu_read_lock();
 +	map = rcu_dereference(queue->rps_map);
 +	if (map)
 +		for (i = 0; i < map->len; i++)
 +			cpumask_set_cpu(map->cpus[i], mask);
 +
 +	len += cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
 +	if (PAGE_SIZE - len < 3) {
 +		rcu_read_unlock();
 +		free_cpumask_var(mask);
 +		return -EINVAL;
 +	}
 +	rcu_read_unlock();
 +
 +	free_cpumask_var(mask);
 +	len += sprintf(buf + len, "\n");
 +	return len;
 +}
 +
 +static void rps_map_release(struct rcu_head *rcu)
 +{
 +	struct rps_map *map = container_of(rcu, struct rps_map, rcu);
 +
 +	kfree(map);
 +}
 +
 +static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 +		      struct rx_queue_attribute *attribute,
 +		      const char *buf, size_t len)
 +{
 +	struct rps_map *old_map, *map;
 +	cpumask_var_t mask;
 +	int err, cpu, i;
 +	static DEFINE_SPINLOCK(rps_map_lock);
 +
 +	if (!capable(CAP_NET_ADMIN))
 +		return -EPERM;
 +
 +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
 +		return -ENOMEM;
 +
 +	err = bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits);
 +	if (err) {
 +		free_cpumask_var(mask);
 +		return err;
 +	}
 +
 +	map = kzalloc(max_t(unsigned,
 +	    RPS_MAP_SIZE(cpumask_weight(mask)), L1_CACHE_BYTES),
 +	    GFP_KERNEL);
 +	if (!map) {
 +		free_cpumask_var(mask);
 +		return -ENOMEM;
 +	}
 +
 +	i = 0;
 +	for_each_cpu_and(cpu, mask, cpu_online_mask)
 +		map->cpus[i++] = cpu;
 +
 +	if (i)
 +		map->len = i;
 +	else {
 +		kfree(map);
 +		map = NULL;
 +	}
 +
 +	spin_lock(&rps_map_lock);
 +	old_map = queue->rps_map;
 +	rcu_assign_pointer(queue->rps_map, map);
 +	spin_unlock(&rps_map_lock);
 +
 +	if (old_map)
 +		call_rcu(&old_map->rcu, rps_map_release);
 +
 +	free_cpumask_var(mask);
 +	return len;
 +}
 +
 +static ssize_t show_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 +					   struct rx_queue_attribute *attr,
 +					   char *buf)
 +{
 +	struct rps_dev_flow_table *flow_table;
 +	unsigned int val = 0;
 +
 +	rcu_read_lock();
 +	flow_table = rcu_dereference(queue->rps_flow_table);
 +	if (flow_table)
 +		val = flow_table->mask + 1;
 +	rcu_read_unlock();
 +
 +	return sprintf(buf, "%u\n", val);
 +}
 +
 +static void rps_dev_flow_table_release_work(struct work_struct *work)
 +{
 +	struct rps_dev_flow_table *table = container_of(work,
 +	    struct rps_dev_flow_table, free_work);
 +
 +	vfree(table);
 +}
 +
 +static void rps_dev_flow_table_release(struct rcu_head *rcu)
 +{
 +	struct rps_dev_flow_table *table = container_of(rcu,
 +	    struct rps_dev_flow_table, rcu);
 +
 +	INIT_WORK(&table->free_work, rps_dev_flow_table_release_work);
 +	schedule_work(&table->free_work);
 +}
 +
 +static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 +				     struct rx_queue_attribute *attr,
 +				     const char *buf, size_t len)
 +{
 +	unsigned int count;
 +	char *endp;
 +	struct rps_dev_flow_table *table, *old_table;
 +	static DEFINE_SPINLOCK(rps_dev_flow_lock);
 +
 +	if (!capable(CAP_NET_ADMIN))
 +		return -EPERM;
 +
 +	count = simple_strtoul(buf, &endp, 0);
 +	if (endp == buf)
 +		return -EINVAL;
 +
 +	if (count) {
 +		int i;
 +
 +		if (count > 1<<30) {
 +			/* Enforce a limit to prevent overflow */
 +			return -EINVAL;
 +		}
 +		count = roundup_pow_of_two(count);
 +		table = vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));
 +		if (!table)
 +			return -ENOMEM;
 +
 +		table->mask = count - 1;
 +		for (i = 0; i < count; i++)
 +			table->flows[i].cpu = RPS_NO_CPU;
 +	} else
 +		table = NULL;
 +
 +	spin_lock(&rps_dev_flow_lock);
 +	old_table = queue->rps_flow_table;
 +	rcu_assign_pointer(queue->rps_flow_table, table);
 +	spin_unlock(&rps_dev_flow_lock);
 +
 +	if (old_table)
 +		call_rcu(&old_table->rcu, rps_dev_flow_table_release);
 +
 +	return len;
 +}
 +
 +static struct rx_queue_attribute rps_cpus_attribute =
 +	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
 +
 +
 +static struct rx_queue_attribute rps_dev_flow_table_cnt_attribute =
 +	__ATTR(rps_flow_cnt, S_IRUGO | S_IWUSR,
 +	    show_rps_dev_flow_table_cnt, store_rps_dev_flow_table_cnt);
 +
 +static struct attribute *rx_queue_default_attrs[] = {
 +	&rps_cpus_attribute.attr,
 +	&rps_dev_flow_table_cnt_attribute.attr,
 +	NULL
 +};
 +
 +static void rx_queue_release(struct kobject *kobj)
 +{
 +	struct netdev_rx_queue *queue = to_rx_queue(kobj);
 +	struct netdev_rx_queue *first = queue->first;
 +
 +	if (queue->rps_map)
 +		call_rcu(&queue->rps_map->rcu, rps_map_release);
 +
 +	if (queue->rps_flow_table)
 +		call_rcu(&queue->rps_flow_table->rcu,
 +		    rps_dev_flow_table_release);
 +
 +	if (atomic_dec_and_test(&first->count))
 +		kfree(first);
 +}
 +
 +static struct kobj_type rx_queue_ktype = {
 +	.sysfs_ops = &rx_queue_sysfs_ops,
 +	.release = rx_queue_release,
 +	.default_attrs = rx_queue_default_attrs,
 +};
 +
 +static int rx_queue_add_kobject(struct net_device *net, int index)
 +{
 +	struct netdev_rx_queue *queue = net->_rx + index;
 +	struct kobject *kobj = &queue->kobj;
 +	int error = 0;
 +
 +	kobj->kset = net->queues_kset;
 +	error = kobject_init_and_add(kobj, &rx_queue_ktype, NULL,
 +	    "rx-%u", index);
 +	if (error) {
 +		kobject_put(kobj);
 +		return error;
 +	}
 +
 +	kobject_uevent(kobj, KOBJ_ADD);
 +
 +	return error;
 +}
 +
 +static int rx_queue_register_kobjects(struct net_device *net)
 +{
 +	int i;
 +	int error = 0;
 +
 +	net->queues_kset = kset_create_and_add("queues",
 +	    NULL, &net->dev.kobj);
 +	if (!net->queues_kset)
 +		return -ENOMEM;
 +	for (i = 0; i < net->num_rx_queues; i++) {
 +		error = rx_queue_add_kobject(net, i);
 +		if (error)
 +			break;
 +	}
 +
 +	if (error)
 +		while (--i >= 0)
 +			kobject_put(&net->_rx[i].kobj);
 +
 +	return error;
 +}
 +
 +static void rx_queue_remove_kobjects(struct net_device *net)
 +{
 +	int i;
 +
 +	for (i = 0; i < net->num_rx_queues; i++)
 +		kobject_put(&net->_rx[i].kobj);
 +	kset_unregister(net->queues_kset);
 +}
 +#endif /* CONFIG_RPS */
  #endif /* CONFIG_SYSFS */
  
+ static const void *net_current_ns(void)
+ {
+ 	return current->nsproxy->net_ns;
+ }
+ 
+ static const void *net_initial_ns(void)
+ {
+ 	return &init_net;
+ }
+ 
+ static const void *net_netlink_ns(struct sock *sk)
+ {
+ 	return sock_net(sk);
+ }
+ 
+ static struct kobj_ns_type_operations net_ns_type_operations = {
+ 	.type = KOBJ_NS_TYPE_NET,
+ 	.current_ns = net_current_ns,
+ 	.netlink_ns = net_netlink_ns,
+ 	.initial_ns = net_initial_ns,
+ };
+ 
+ static void net_kobj_ns_exit(struct net *net)
+ {
+ 	kobj_ns_exit(KOBJ_NS_TYPE_NET, net);
+ }
+ 
+ static struct pernet_operations kobj_net_ops = {
+ 	.exit = net_kobj_ns_exit,
+ };
+ 
+ 
  #ifdef CONFIG_HOTPLUG
  static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
  {
@@@ -826,13 -566,6 +866,10 @@@ void netdev_unregister_kobject(struct n
  
  	kobject_get(&dev->kobj);
  
- 	if (!net_eq(dev_net(net), &init_net))
- 		return;
- 
 +#ifdef CONFIG_RPS
 +	rx_queue_remove_kobjects(net);
 +#endif
 +
  	device_del(dev);
  }
  
@@@ -841,8 -574,8 +878,9 @@@ int netdev_register_kobject(struct net_
  {
  	struct device *dev = &(net->dev);
  	const struct attribute_group **groups = net->sysfs_groups;
 +	int error = 0;
  
+ 	device_initialize(dev);
  	dev->class = &net_class;
  	dev->platform_data = net;
  	dev->groups = groups;
@@@ -865,22 -598,7 +903,19 @@@
  #endif
  #endif /* CONFIG_SYSFS */
  
- 	if (!net_eq(dev_net(net), &init_net))
- 		return 0;
- 
 -	return device_add(dev);
 +	error = device_add(dev);
 +	if (error)
 +		return error;
 +
 +#ifdef CONFIG_RPS
 +	error = rx_queue_register_kobjects(net);
 +	if (error) {
 +		device_del(dev);
 +		return error;
 +	}
 +#endif
 +
 +	return error;
  }
  
  int netdev_class_create_file(struct class_attribute *class_attr)
