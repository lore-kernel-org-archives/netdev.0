From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 1/10][CORE]: The dev->get_stats pointer is not NULL
 nowadays.
Date: Tue, 20 May 2008 20:29:13 +0400
Message-ID: <4832FC59.4010707@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37077 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933317AbYETQbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:31:40 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And so does the pointer is returns, but sysfs and netlinks still 
check for both cases.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/core/net-sysfs.c |    9 ++++-----
 net/core/rtnetlink.c |   20 ++++++++------------
 2 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 90e2177..dccd737 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -242,11 +242,11 @@ static ssize_t netstat_show(const struct device *d,
 			offset % sizeof(unsigned long) != 0);
 
 	read_lock(&dev_base_lock);
-	if (dev_isalive(dev) && dev->get_stats &&
-	    (stats = (*dev->get_stats)(dev)))
+	if (dev_isalive(dev)) {
+		stats = dev->get_stats(dev);
 		ret = sprintf(buf, fmt_ulong,
 			      *(unsigned long *)(((u8 *) stats) + offset));
-
+	}
 	read_unlock(&dev_base_lock);
 	return ret;
 }
@@ -457,8 +457,7 @@ int netdev_register_kobject(struct net_device *net)
 	strlcpy(dev->bus_id, net->name, BUS_ID_SIZE);
 
 #ifdef CONFIG_SYSFS
-	if (net->get_stats)
-		*groups++ = &netstat_group;
+	*groups++ = &netstat_group;
 
 #ifdef CONFIG_WIRELESS_EXT
 	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index cf857c4..ca32ddb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -606,6 +606,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
+	struct net_device_stats *stats;
+	struct nlattr *attr;
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
 	if (nlh == NULL)
@@ -652,19 +654,13 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		NLA_PUT(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast);
 	}
 
-	if (dev->get_stats) {
-		struct net_device_stats *stats = dev->get_stats(dev);
-		if (stats) {
-			struct nlattr *attr;
+	attr = nla_reserve(skb, IFLA_STATS,
+			sizeof(struct rtnl_link_stats));
+	if (attr == NULL)
+		goto nla_put_failure;
 
-			attr = nla_reserve(skb, IFLA_STATS,
-					   sizeof(struct rtnl_link_stats));
-			if (attr == NULL)
-				goto nla_put_failure;
-
-			copy_rtnl_link_stats(nla_data(attr), stats);
-		}
-	}
+	stats = dev->get_stats(dev);
+	copy_rtnl_link_stats(nla_data(attr), stats);
 
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
-- 
1.5.3.4

