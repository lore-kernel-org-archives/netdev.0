From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/3] ipv4: fail early when creating netdev named all or default
Date: Wed, 23 Jul 2014 15:17:30 -0700
Message-ID: <1406153852-22511-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stephane.chazelas@gmail.com, davem@davemloft.net,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:50140 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933386AbaGWWRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 18:17:54 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2559694pab.30
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 15:17:54 -0700 (PDT)
In-Reply-To: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We create a proc dir for each network device, this will cause
conflicts when the devices have name "all" or "default".

Rather than emitting an ugly kernel warning, we could just
fail earlier by checking the device name.

Reported-by: Stephane Chazelas <stephane.chazelas@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/devinet.c | 37 ++++++++++++++++++++++++++++---------
 1 file changed, 28 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e944937..fbd8b04 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -180,11 +180,12 @@ static BLOCKING_NOTIFIER_HEAD(inetaddr_chain);
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			 int destroy);
 #ifdef CONFIG_SYSCTL
-static void devinet_sysctl_register(struct in_device *idev);
+static int devinet_sysctl_register(struct in_device *idev);
 static void devinet_sysctl_unregister(struct in_device *idev);
 #else
-static void devinet_sysctl_register(struct in_device *idev)
+static int devinet_sysctl_register(struct in_device *idev)
 {
+	return 0;
 }
 static void devinet_sysctl_unregister(struct in_device *idev)
 {
@@ -232,6 +233,7 @@ EXPORT_SYMBOL(in_dev_finish_destroy);
 static struct in_device *inetdev_init(struct net_device *dev)
 {
 	struct in_device *in_dev;
+	int err = -ENOMEM;
 
 	ASSERT_RTNL();
 
@@ -252,7 +254,13 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	/* Account for reference dev->ip_ptr (below) */
 	in_dev_hold(in_dev);
 
-	devinet_sysctl_register(in_dev);
+	err = devinet_sysctl_register(in_dev);
+	if (err) {
+		in_dev->dead = 1;
+		in_dev_put(in_dev);
+		in_dev = NULL;
+		goto out;
+	}
 	ip_mc_init_dev(in_dev);
 	if (dev->flags & IFF_UP)
 		ip_mc_up(in_dev);
@@ -260,7 +268,7 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	/* we can receive as soon as ip_ptr is set -- do this last */
 	rcu_assign_pointer(dev->ip_ptr, in_dev);
 out:
-	return in_dev;
+	return in_dev ?: ERR_PTR(err);
 out_kfree:
 	kfree(in_dev);
 	in_dev = NULL;
@@ -1347,8 +1355,8 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	if (!in_dev) {
 		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
-			if (!in_dev)
-				return notifier_from_errno(-ENOMEM);
+			if (IS_ERR(in_dev))
+				return notifier_from_errno(PTR_ERR(in_dev));
 			if (dev->flags & IFF_LOOPBACK) {
 				IN_DEV_CONF_SET(in_dev, NOXFRM, 1);
 				IN_DEV_CONF_SET(in_dev, NOPOLICY, 1);
@@ -2182,11 +2190,22 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 	kfree(t);
 }
 
-static void devinet_sysctl_register(struct in_device *idev)
+static int devinet_sysctl_register(struct in_device *idev)
 {
-	neigh_sysctl_register(idev->dev, idev->arp_parms, NULL);
-	__devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
+	int err;
+
+	if (!strcmp(idev->dev->name, "default") ||
+	    !strcmp(idev->dev->name, "all"))
+		return -EINVAL;
+
+	err = neigh_sysctl_register(idev->dev, idev->arp_parms, NULL);
+	if (err)
+		return err;
+	err = __devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
 					&idev->cnf);
+	if (err)
+		neigh_sysctl_unregister(idev->arp_parms);
+	return err;
 }
 
 static void devinet_sysctl_unregister(struct in_device *idev)
-- 
1.8.3.1
