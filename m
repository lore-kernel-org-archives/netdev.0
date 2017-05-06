From: David Ahern <dsahern@gmail.com>
Subject: [PATCH RFC net-next 5/6] net: Delay initializations for lightweight devices
Date: Sat,  6 May 2017 10:07:33 -0600
Message-ID: <20170506160734.47084-6-dsahern@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34512 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752131AbdEFQHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 12:07:51 -0400
Received: by mail-pf0-f193.google.com with SMTP id d1so4395345pfe.1
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 09:07:50 -0700 (PDT)
In-Reply-To: <20170506160734.47084-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delay ipv4 and ipv6 initializations on lightweight netdevices until an
address is added to the device.

Skip sysctl initialization for neighbor path as well.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h |  5 +++++
 net/core/neighbour.c      |  3 +++
 net/ipv4/devinet.c        | 18 ++++++++++++++++--
 net/ipv6/addrconf.c       |  9 +++++++++
 net/mpls/af_mpls.c        |  6 ++++++
 5 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4ddd0ac7e1cb..32d155be777a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4144,6 +4144,11 @@ static inline bool netif_is_lwd(struct net_device *dev)
 	return !!(dev->priv_flags & IFF_LWT_NETDEV);
 }
 
+static inline bool netif_has_sysctl(struct net_device *dev)
+{
+	return !netif_is_lwd(dev);
+}
+
 static inline bool netif_is_macsec(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_MACSEC;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 58b0bcc125b5..10104a7135e2 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -3123,6 +3123,9 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	char neigh_path[ sizeof("net//neigh/") + IFNAMSIZ + IFNAMSIZ ];
 	char *p_name;
 
+	if (dev && !netif_has_sysctl(dev))
+		return 0;
+
 	t = kmemdup(&neigh_sysctl_template, sizeof(*t), GFP_KERNEL);
 	if (!t)
 		goto err;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index df14815a3b8c..c5ffd3ed4b2c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -771,8 +771,15 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 
 	in_dev = __in_dev_get_rtnl(dev);
 	err = -ENOBUFS;
-	if (!in_dev)
-		goto errout;
+	if (!in_dev) {
+		if (netif_is_lwd(dev)) {
+			in_dev = inetdev_init(dev);
+			if (IS_ERR(in_dev))
+				in_dev = NULL;
+		}
+		if (!in_dev)
+			goto errout;
+	}
 
 	ifa = inet_alloc_ifa();
 	if (!ifa)
@@ -1417,6 +1424,10 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 
 	if (!in_dev) {
 		if (event == NETDEV_REGISTER) {
+			/* inet init is deferred for lightweight devices */
+			if (netif_is_lwd(dev))
+				goto out;
+
 			in_dev = inetdev_init(dev);
 			if (IS_ERR(in_dev))
 				return notifier_from_errno(PTR_ERR(in_dev));
@@ -2303,6 +2314,9 @@ static int devinet_sysctl_register(struct in_device *idev)
 {
 	int err;
 
+	if (!netif_has_sysctl(idev->dev))
+		return 0;
+
 	if (!sysctl_dev_name_is_allowed(idev->dev->name))
 		return -EINVAL;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8d297a79b568..9814df6b7017 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3371,6 +3371,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 
 	switch (event) {
 	case NETDEV_REGISTER:
+		/* inet6 init is deferred for lightweight devices */
+		if (netif_is_lwd(dev))
+			return NOTIFY_OK;
+
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
 			idev = ipv6_add_dev(dev);
 			if (IS_ERR(idev))
@@ -6368,6 +6372,11 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 	struct ctl_table *table;
 	char path[sizeof("net/ipv6/conf/") + IFNAMSIZ];
 
+	if (idev && idev->dev && !netif_has_sysctl(idev->dev)) {
+		p->sysctl_header = NULL;
+		return 0;
+	}
+
 	table = kmemdup(addrconf_sysctl, sizeof(addrconf_sysctl), GFP_KERNEL);
 	if (!table)
 		goto out;
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 088e2b459d0f..7503d68da2ea 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1251,6 +1251,9 @@ static int mpls_dev_sysctl_register(struct net_device *dev,
 	struct ctl_table *table;
 	int i;
 
+	if (!netif_has_sysctl(dev))
+		return 0;
+
 	table = kmemdup(&mpls_dev_table, sizeof(mpls_dev_table), GFP_KERNEL);
 	if (!table)
 		goto out;
@@ -1285,6 +1288,9 @@ static void mpls_dev_sysctl_unregister(struct net_device *dev,
 	struct net *net = dev_net(dev);
 	struct ctl_table *table;
 
+	if (!mdev->sysctl)
+		return;
+
 	table = mdev->sysctl->ctl_table_arg;
 	unregister_net_sysctl_table(mdev->sysctl);
 	kfree(table);
-- 
2.11.0 (Apple Git-81)
