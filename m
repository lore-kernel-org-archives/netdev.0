From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/3] ipv6: fail early when creating netdev named all or default
Date: Wed, 23 Jul 2014 15:17:31 -0700
Message-ID: <1406153852-22511-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stephane.chazelas@gmail.com, davem@davemloft.net,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:55370 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933635AbaGWWRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 18:17:55 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so2416096pde.9
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 15:17:55 -0700 (PDT)
In-Reply-To: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same for ipv6.

Reported-by: Stephane Chazelas <stephane.chazelas@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/addrconf.c | 67 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 44 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4c03c28..cd9cfd3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -108,11 +108,12 @@ static inline u32 cstamp_delta(unsigned long cstamp)
 }
 
 #ifdef CONFIG_SYSCTL
-static void addrconf_sysctl_register(struct inet6_dev *idev);
+static int addrconf_sysctl_register(struct inet6_dev *idev);
 static void addrconf_sysctl_unregister(struct inet6_dev *idev);
 #else
-static inline void addrconf_sysctl_register(struct inet6_dev *idev)
+static inline int addrconf_sysctl_register(struct inet6_dev *idev)
 {
+	return 0;
 }
 
 static inline void addrconf_sysctl_unregister(struct inet6_dev *idev)
@@ -310,16 +311,16 @@ err_ip:
 static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *ndev;
+	int err = -ENOMEM;
 
 	ASSERT_RTNL();
 
 	if (dev->mtu < IPV6_MIN_MTU)
-		return NULL;
+		return ERR_PTR(-EINVAL);
 
 	ndev = kzalloc(sizeof(struct inet6_dev), GFP_KERNEL);
-
 	if (ndev == NULL)
-		return NULL;
+		return ERR_PTR(err);
 
 	rwlock_init(&ndev->lock);
 	ndev->dev = dev;
@@ -332,7 +333,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
 	if (ndev->nd_parms == NULL) {
 		kfree(ndev);
-		return NULL;
+		return ERR_PTR(err);
 	}
 	if (ndev->cnf.forwarding)
 		dev_disable_lro(dev);
@@ -346,17 +347,14 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		dev_put(dev);
 		kfree(ndev);
-		return NULL;
+		return ERR_PTR(err);
 	}
 
 	if (snmp6_register_dev(ndev) < 0) {
 		ADBG(KERN_WARNING
 			"%s: cannot create /proc/net/dev_snmp6/%s\n",
 			__func__, dev->name);
-		neigh_parms_release(&nd_tbl, ndev->nd_parms);
-		ndev->dead = 1;
-		in6_dev_finish_destroy(ndev);
-		return NULL;
+		goto err_release;
 	}
 
 	/* One reference from device.  We must do this before
@@ -394,7 +392,12 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 
 	ipv6_mc_init_dev(ndev);
 	ndev->tstamp = jiffies;
-	addrconf_sysctl_register(ndev);
+	err = addrconf_sysctl_register(ndev);
+	if (err) {
+		ipv6_mc_destroy_dev(ndev);
+		del_timer(&ndev->regen_timer);
+		goto err_release;
+	}
 	/* protected by rtnl_lock */
 	rcu_assign_pointer(dev->ip6_ptr, ndev);
 
@@ -409,6 +412,12 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
 
 	return ndev;
+
+err_release:
+	neigh_parms_release(&nd_tbl, ndev->nd_parms);
+	ndev->dead = 1;
+	in6_dev_finish_destroy(ndev);
+	return ERR_PTR(err);
 }
 
 static struct inet6_dev *ipv6_find_idev(struct net_device *dev)
@@ -420,7 +429,7 @@ static struct inet6_dev *ipv6_find_idev(struct net_device *dev)
 	idev = __in6_dev_get(dev);
 	if (!idev) {
 		idev = ipv6_add_dev(dev);
-		if (!idev)
+		if (IS_ERR(idev))
 			return NULL;
 	}
 
@@ -2830,8 +2839,8 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 	case NETDEV_REGISTER:
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
 			idev = ipv6_add_dev(dev);
-			if (!idev)
-				return notifier_from_errno(-ENOMEM);
+			if (IS_ERR(idev))
+				return notifier_from_errno(PTR_ERR(idev));
 		}
 		break;
 
@@ -2851,7 +2860,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			if (!idev && dev->mtu >= IPV6_MIN_MTU)
 				idev = ipv6_add_dev(dev);
 
-			if (idev) {
+			if (!IS_ERR_OR_NULL(idev)) {
 				idev->if_flags |= IF_READY;
 				run_pending = 1;
 			}
@@ -2894,7 +2903,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			break;
 		}
 
-		if (idev) {
+		if (!IS_ERR_OR_NULL(idev)) {
 			if (run_pending)
 				addrconf_dad_run(idev);
 
@@ -2929,7 +2938,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
 			idev = ipv6_add_dev(dev);
-			if (idev)
+			if (!IS_ERR(idev))
 				break;
 		}
 
@@ -5248,12 +5257,24 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 	kfree(t);
 }
 
-static void addrconf_sysctl_register(struct inet6_dev *idev)
+static int addrconf_sysctl_register(struct inet6_dev *idev)
 {
-	neigh_sysctl_register(idev->dev, idev->nd_parms,
-			      &ndisc_ifinfo_sysctl_change);
-	__addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
-					idev, &idev->cnf);
+	int err;
+
+	if (!strcmp(idev->dev->name, "default") ||
+	    !strcmp(idev->dev->name, "all"))
+		return -EINVAL;
+
+	err = neigh_sysctl_register(idev->dev, idev->nd_parms,
+				    &ndisc_ifinfo_sysctl_change);
+	if (err)
+		return err;
+	err = __addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
+					 idev, &idev->cnf);
+	if (err)
+		neigh_sysctl_unregister(idev->nd_parms);
+
+	return err;
 }
 
 static void addrconf_sysctl_unregister(struct inet6_dev *idev)
-- 
1.8.3.1
