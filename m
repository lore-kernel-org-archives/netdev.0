From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] net: export physical port id via sysfs
Date: Fri, 19 Jul 2013 15:55:51 +0200
Message-ID: <1374242152-10325-4-git-send-email-jiri@resnulli.us>
References: <1374242152-10325-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:41763 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759542Ab3GSN4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:56:06 -0400
Received: by mail-ea0-f179.google.com with SMTP id b15so2445657eae.10
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 06:56:04 -0700 (PDT)
In-Reply-To: <1374242152-10325-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/net-sysfs.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 981fed3..fb19ede 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -334,6 +334,46 @@ static ssize_t store_group(struct device *dev, struct device_attribute *attr,
 	return netdev_store(dev, attr, buf, len, change_group);
 }
 
+static size_t _format_port_id(char *buf, int buflen,
+			      const unsigned char *id, int len)
+{
+	int i;
+	char *cp = buf;
+
+	for (i = 0; i < len; i++)
+		cp += scnprintf(cp, buflen - (cp - buf), "%02x", id[i]);
+	return cp - buf;
+}
+
+ssize_t sysfs_format_port_id(char *buf, const unsigned char *id, int len)
+{
+	size_t l;
+
+	l = _format_port_id(buf, PAGE_SIZE, id, len);
+	l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
+	return (ssize_t)l;
+}
+static ssize_t show_phys_port_id(struct device *dev,
+				 struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	ssize_t ret = 0;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (dev_isalive(netdev) && netdev->netdev_ops->ndo_get_phys_port_id) {
+		struct netdev_phys_port_id ppid;
+
+		ret = netdev->netdev_ops->ndo_get_phys_port_id(netdev, &ppid);
+		if (!ret)
+			ret = sysfs_format_port_id(buf, ppid.id, ppid.id_len);
+	}
+	rtnl_unlock();
+
+	return ret;
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_assign_type, S_IRUGO, show_addr_assign_type, NULL),
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
@@ -355,6 +395,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
 	__ATTR(netdev_group, S_IRUGO | S_IWUSR, show_group, store_group),
+	__ATTR(phys_port_id, S_IRUGO, show_phys_port_id, NULL),
 	{}
 };
 
-- 
1.8.1.4
