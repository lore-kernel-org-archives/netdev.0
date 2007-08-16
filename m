From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] net: add dev_get_stats
Date: Thu, 16 Aug 2007 09:25:26 -0400
Message-ID: <20070816132622.371812650@linux-foundation.org>
References: <20070816132523.201766718@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43313 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755072AbXHPNes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 09:34:48 -0400
Content-Disposition: inline; filename=dev_get_stats.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we now have internal stats, it cleans up code to have a
dev_get_stats() interface.  This allows for future patches where
'network device ops' patch where get_stats is immutable.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/linux/netdevice.h	2007-08-16 06:34:25.000000000 -0400
+++ b/include/linux/netdevice.h	2007-08-16 06:38:33.000000000 -0400
@@ -809,6 +809,7 @@ extern int		dev_set_mac_address(struct n
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
+extern struct net_device_stats	*dev_get_stats(struct net_device *dev);
 
 extern int		netdev_budget;
 
--- a/net/core/dev.c	2007-08-16 06:34:25.000000000 -0400
+++ b/net/core/dev.c	2007-08-16 08:26:04.000000000 -0400
@@ -2304,7 +2304,7 @@ void dev_seq_stop(struct seq_file *seq, 
 
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
 {
-	struct net_device_stats *stats = dev->get_stats(dev);
+	struct net_device_stats *stats = dev_get_stats(dev);
 
 	seq_printf(seq, "%6s:%8lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
 		   "%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
@@ -3682,10 +3682,21 @@ out:
 	mutex_unlock(&net_todo_run_mutex);
 }
 
-static struct net_device_stats *internal_stats(struct net_device *dev)
+/**
+ *	dev_get_stats - get network device statistics
+ *	@dev:	network device
+ *
+ *	Get standard network device statistics.
+ * 	Use internal stastics unless device overides
+ */
+struct net_device_stats *dev_get_stats(struct net_device *dev)
 {
-	return &dev->stats;
+	if (!dev->get_stats)
+		return &dev->stats;
+
+	return dev->get_stats(dev);
 }
+EXPORT_SYMBOL(dev_get_stats);
 
 /**
  *	alloc_netdev_mq - allocate network device
@@ -3733,7 +3744,6 @@ struct net_device *alloc_netdev_mq(int s
 
 	dev->egress_subqueue_count = queue_count;
 
-	dev->get_stats = internal_stats;
 	setup(dev);
 	strcpy(dev->name, name);
 	return dev;
--- a/net/core/net-sysfs.c	2007-08-16 06:34:25.000000000 -0400
+++ b/net/core/net-sysfs.c	2007-08-16 09:23:13.000000000 -0400
@@ -264,8 +264,7 @@ static ssize_t netstat_show(const struct
 		WARN_ON(1);
 
 	read_lock(&dev_base_lock);
-	if (dev_isalive(dev) && dev->get_stats &&
-	    (stats = (*dev->get_stats)(dev)))
+	if (dev_isalive(dev) && (stats = dev_get_stats(dev)))
 		ret = sprintf(buf, fmt_ulong,
 			      *(unsigned long *)(((u8 *) stats) + offset));
 
@@ -481,8 +480,7 @@ int netdev_register_sysfs(struct net_dev
 	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
 	strlcpy(dev->bus_id, net->name, BUS_ID_SIZE);
 
-	if (net->get_stats)
-		*groups++ = &netstat_group;
+	*groups++ = &netstat_group;
 
 #ifdef CONFIG_WIRELESS_EXT
 	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
--- a/net/core/rtnetlink.c	2007-08-16 06:34:25.000000000 -0400
+++ b/net/core/rtnetlink.c	2007-08-16 08:26:13.000000000 -0400
@@ -619,6 +619,7 @@ static int rtnl_fill_ifinfo(struct sk_bu
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
+	struct net_device_stats *stats;
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
 	if (nlh == NULL)
@@ -666,18 +667,13 @@ static int rtnl_fill_ifinfo(struct sk_bu
 		NLA_PUT(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast);
 	}
 
-	if (dev->get_stats) {
-		struct net_device_stats *stats = dev->get_stats(dev);
-		if (stats) {
-			struct nlattr *attr;
-
-			attr = nla_reserve(skb, IFLA_STATS,
-					   sizeof(struct rtnl_link_stats));
-			if (attr == NULL)
-				goto nla_put_failure;
+	if ((stats = dev_get_stats(dev))) {
+		struct nlattr *attr = nla_reserve(skb, IFLA_STATS,
+						  sizeof(struct rtnl_link_stats));
+		if (attr == NULL)
+			goto nla_put_failure;
 
-			copy_rtnl_link_stats(nla_data(attr), stats);
-		}
+		copy_rtnl_link_stats(nla_data(attr), stats);
 	}
 
 	if (dev->rtnl_link_ops) {

-- 

