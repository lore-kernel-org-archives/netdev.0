From: therbert@google.com (Tom Herbert)
Subject: RFC [PATCH net-2.6 6/6] net: softRSS net-sysfs
Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
Message-ID: <20080305205116.63E16412794@localhost>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:9580 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295AbYCEUvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 15:51:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements per device sys-fs variables to set the CPU mask used for software RSS.

Signed-off-by: Tom Herbert <therbert@google.com>

---

diff -uprN -X /tmp/donts/rss_3 net-2.6/net/core/net-sysfs.c net-2.6.patch/net/core/net-sysfs.c
--- net-2.6/net/core/net-sysfs.c	2008-03-05 09:03:28.210553000 -0800
+++ net-2.6.patch/net/core/net-sysfs.c	2008-03-05 09:25:33.622754000 -0800
@@ -208,6 +208,81 @@ static ssize_t store_tx_queue_len(struct
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
 
+
+#if defined(CONFIG_NET_NAPI_RSS) || defined(CONFIG_NET_SOFTRSS)
+static ssize_t netdev_store_cpumask(struct net_device *net, const char *buf,
+    size_t len, cpumask_t *maskp)
+{
+	cpumask_t new_value;
+	int err;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	err = cpumask_parse(buf, len, new_value);
+	if (err)
+		return err;
+
+	rtnl_lock();
+	if (dev_isalive(net)) 
+		*maskp = new_value;
+	rtnl_unlock();
+
+	return len;
+}
+
+static ssize_t netdev_show_cpumask(struct net_device *net, char *buf,
+    cpumask_t *maskp)
+{
+	size_t len;
+	cpumask_t tmp;
+
+	read_lock(&dev_base_lock);
+	if (dev_isalive(net))
+		cpus_and(tmp, *maskp, cpu_online_map);
+	else
+		cpus_clear(tmp);
+	read_unlock(&dev_base_lock);
+
+	len = cpumask_scnprintf(buf, PAGE_SIZE, tmp);
+	if (PAGE_SIZE - len < 2)
+		return -EINVAL;
+
+	len += sprintf(buf + len, "\n");
+	return len;
+}
+#endif
+
+#ifdef CONFIG_NET_NAPI_RSS
+static ssize_t show_napi_rss_cpus(struct class_device *dev, char *buf)
+{
+	const struct net_device *net = to_net_dev(dev);
+	return (netdev_show_cpumask(net, buf, &net->napi_rss_cpus));
+}
+
+static ssize_t store_napi_rss_cpus(struct class_device *dev, const char *buf,
+    size_t len)
+{
+	const struct net_device *net = to_net_dev(dev);
+	return (netdev_store_cpumask(net, buf, len, &net->napi_rss_cpus));
+}
+#endif
+
+#ifdef CONFIG_NET_SOFTRSS
+static ssize_t show_soft_rss_cpus(struct class_device *dev, char *buf)
+{
+	const struct net_device *net = to_net_dev(dev);
+	return (netdev_show_cpumask(net, buf, &net->soft_rss_cpus));
+}
+
+static ssize_t store_soft_rss_cpus(struct class_device *dev, const char *buf,
+    size_t len)
+{
+	const struct net_device *net = to_net_dev(dev);
+	return (netdev_store_cpumask(net, buf, len, &net->soft_rss_cpus));
+}
+#endif
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
@@ -224,6 +299,14 @@ static struct device_attribute net_class
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+#ifdef CONFIG_NET_NAPI_RSS
+	__ATTR(napi_rss_cpus, S_IRUGO | S_IWUSR, show_napi_rss_cpus,
+	       store_napi_rss_cpus),
+#endif
+#ifdef CONFIG_NET_SOFTRSS
+	__ATTR(soft_rss_cpus, S_IRUGO | S_IWUSR, show_soft_rss_cpus,
+	       store_soft_rss_cpus),
+#endif
 	{}
 };
 
