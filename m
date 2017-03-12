From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 17/27] afnetns: introduce __inet_select_addr
Date: Mon, 13 Mar 2017 00:01:41 +0100
Message-ID: <20170312230151.5185-18-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:32835 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935589AbdCLXCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:16 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 4E66A2060A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:09 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 69E0F2423E
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:08 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/inetdevice.h |  2 ++
 net/ipv4/devinet.c         | 27 ++++++++++++++++++++++++---
 2 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 01cbcfe93383b7..a41bfce099e0a1 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -170,6 +170,8 @@ int inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
 int devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
 void devinet_init(void);
 struct in_device *inetdev_by_index(struct net *, int);
+__be32 __inet_select_addr(const struct net_device *dev, __be32 dst, int scope,
+			  struct afnetns *afnetns);
 __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
 __be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
 			 __be32 local, int scope);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cc15afefa1df0a..0844d917aa8d7d 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1224,7 +1224,17 @@ static int inet_gifconf(struct net_device *dev, char __user *buf, int len)
 	return done;
 }
 
-__be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
+static struct afnetns *ifa_afnetns(struct in_ifaddr *ifa)
+{
+#if IS_ENABLED(CONFIG_AFNETNS)
+	return ifa->afnetns;
+#else
+	return NULL;
+#endif
+}
+
+__be32 __inet_select_addr(const struct net_device *dev, __be32 dst,
+			  int scope, struct afnetns *afnetns)
 {
 	__be32 addr = 0;
 	struct in_device *in_dev;
@@ -1237,6 +1247,8 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 		goto no_in_dev;
 
 	for_primary_ifa(in_dev) {
+		if (afnetns && afnetns != ifa_afnetns(ifa))
+			continue;
 		if (ifa->ifa_scope > scope)
 			continue;
 		if (!dst || inet_ifa_match(dst, ifa)) {
@@ -1262,7 +1274,8 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 	    (in_dev = __in_dev_get_rcu(dev))) {
 		for_primary_ifa(in_dev) {
 			if (ifa->ifa_scope != RT_SCOPE_LINK &&
-			    ifa->ifa_scope <= scope) {
+			    ifa->ifa_scope <= scope &&
+			    (!afnetns || afnetns == ifa_afnetns(ifa))) {
 				addr = ifa->ifa_local;
 				goto out_unlock;
 			}
@@ -1283,7 +1296,8 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 
 		for_primary_ifa(in_dev) {
 			if (ifa->ifa_scope != RT_SCOPE_LINK &&
-			    ifa->ifa_scope <= scope) {
+			    ifa->ifa_scope <= scope &&
+			    (!afnetns || afnetns == ifa_afnetns(ifa))) {
 				addr = ifa->ifa_local;
 				goto out_unlock;
 			}
@@ -1293,6 +1307,13 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 	rcu_read_unlock();
 	return addr;
 }
+EXPORT_SYMBOL(__inet_select_addr);
+
+__be32 inet_select_addr(const struct net_device *dev, __be32 dst,
+			int scope)
+{
+	return __inet_select_addr(dev, dst, scope, NULL);
+}
 EXPORT_SYMBOL(inet_select_addr);
 
 static __be32 confirm_addr_indev(struct in_device *in_dev, __be32 dst,
-- 
2.9.3
