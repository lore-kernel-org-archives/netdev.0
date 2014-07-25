From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 2/3] ipv6: fail early when creating netdev named all or default
Date: Fri, 25 Jul 2014 15:25:09 -0700
Message-ID: <1406327110-17227-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1406327110-17227-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stephane.chazelas@gmail.com, f.fainelli@gmail.com,
	davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:42814 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761089AbaGYWZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 18:25:31 -0400
Received: by mail-pd0-f180.google.com with SMTP id y13so6400376pdi.39
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 15:25:31 -0700 (PDT)
In-Reply-To: <1406327110-17227-1-git-send-email-xiyou.wangcong@gmail.com>
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
 net/ipv6/addrconf.c | 82 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 54 insertions(+), 28 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4c03c28..0b239fc 100644
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
 
@@ -2950,10 +2959,14 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		if (idev) {
 			snmp6_unregister_dev(idev);
 			addrconf_sysctl_unregister(idev);
-			addrconf_sysctl_register(idev);
-			err = snmp6_register_dev(idev);
+			err = addrconf_sysctl_register(idev);
 			if (err)
 				return notifier_from_errno(err);
+			err = snmp6_register_dev(idev);
+			if (err) {
+				addrconf_sysctl_unregister(idev);
+				return notifier_from_errno(err);
+			}
 		}
 		break;
 
@@ -5248,12 +5261,23 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
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
+	if (!sysctl_dev_name_is_allowed(idev->dev->name))
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
@@ -5338,6 +5362,7 @@ static struct rtnl_af_ops inet6_ops = {
 
 int __init addrconf_init(void)
 {
+	struct inet6_dev *idev;
 	int i, err;
 
 	err = ipv6_addr_label_init();
@@ -5376,11 +5401,12 @@ int __init addrconf_init(void)
 	 * device and it being up should be removed.
 	 */
 	rtnl_lock();
-	if (!ipv6_add_dev(init_net.loopback_dev))
-		err = -ENOMEM;
+	idev = ipv6_add_dev(init_net.loopback_dev);
 	rtnl_unlock();
-	if (err)
+	if (IS_ERR(idev)) {
+		err = PTR_ERR(idev);
 		goto errlo;
+	}
 
 	for (i = 0; i < IN6_ADDR_HSIZE; i++)
 		INIT_HLIST_HEAD(&inet6_addr_lst[i]);
-- 
1.8.3.1
