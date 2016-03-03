From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] bridge: a netlink notification should be sent whenever those attributes change
Date: Thu,  3 Mar 2016 20:16:58 +0800
Message-ID: <2e80304ba6a0021637e362c83f931dc596f72d89.1457007418.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33373 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693AbcCCMRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 07:17:04 -0500
Received: by mail-pf0-f194.google.com with SMTP id 63so1222804pfe.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 04:17:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when we change the attributes of bridge or br_port by netlink,
a relevant netlink notification will be sent, but if we change them
by ioctl or sysfs, no notification will be sent.

we should ensure that whenever those attributes change internally or from
sysfs/ioctl, that a netlink notification is sent out to listeners.

Also, NetworkManager will use this in the future to listen for out-of-band
bridge master attribute updates and incorporate them into the runtime
configuration.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_ioctl.c    | 40 ++++++++++++++++++++++++----------------
 net/bridge/br_sysfs_br.c |  2 ++
 net/bridge/br_sysfs_if.c |  4 +++-
 3 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 263b4de..f8fc624 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -112,7 +112,9 @@ static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p = NULL;
 	unsigned long args[4];
+	int ret = -EOPNOTSUPP;
 
 	if (copy_from_user(args, rq->ifr_data, sizeof(args)))
 		return -EFAULT;
@@ -182,25 +184,29 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
-		return br_set_forward_delay(br, args[1]);
+		ret = br_set_forward_delay(br, args[1]);
+		break;
 
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
-		return br_set_hello_time(br, args[1]);
+		ret = br_set_hello_time(br, args[1]);
+		break;
 
 	case BRCTL_SET_BRIDGE_MAX_AGE:
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
-		return br_set_max_age(br, args[1]);
+		ret = br_set_max_age(br, args[1]);
+		break;
 
 	case BRCTL_SET_AGEING_TIME:
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
-		return br_set_ageing_time(br, args[1]);
+		ret = br_set_ageing_time(br, args[1]);
+		break;
 
 	case BRCTL_GET_PORT_INFO:
 	{
@@ -240,20 +246,19 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 			return -EPERM;
 
 		br_stp_set_enabled(br, args[1]);
-		return 0;
+		ret = 0;
+		break;
 
 	case BRCTL_SET_BRIDGE_PRIORITY:
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		br_stp_set_bridge_priority(br, args[1]);
-		return 0;
+		ret = 0;
+		break;
 
 	case BRCTL_SET_PORT_PRIORITY:
 	{
-		struct net_bridge_port *p;
-		int ret;
-
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
@@ -263,14 +268,11 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		else
 			ret = br_stp_set_port_priority(p, args[2]);
 		spin_unlock_bh(&br->lock);
-		return ret;
+		break;
 	}
 
 	case BRCTL_SET_PATH_COST:
 	{
-		struct net_bridge_port *p;
-		int ret;
-
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
@@ -280,8 +282,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		else
 			ret = br_stp_set_path_cost(p, args[2]);
 		spin_unlock_bh(&br->lock);
-
-		return ret;
+		break;
 	}
 
 	case BRCTL_GET_FDB_ENTRIES:
@@ -289,7 +290,14 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 				       args[2], args[3]);
 	}
 
-	return -EOPNOTSUPP;
+	if (!ret) {
+		if (p)
+			br_ifinfo_notify(RTM_NEWLINK, p);
+		else
+			netdev_state_change(br->dev);
+	}
+
+	return ret;
 }
 
 static int old_deviceless(struct net *net, void __user *uarg)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 6b80914..231e093 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -44,6 +44,8 @@ static ssize_t store_bridge_parm(struct device *d,
 		return -EINVAL;
 
 	err = (*set)(br, val);
+	if (!err)
+		netdev_state_change(br->dev);
 	return err ? err : len;
 }
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index efe415a..0ad8592 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -253,8 +253,10 @@ static ssize_t brport_store(struct kobject *kobj,
 			spin_lock_bh(&p->br->lock);
 			ret = brport_attr->store(p, val);
 			spin_unlock_bh(&p->br->lock);
-			if (ret == 0)
+			if (ret == 0) {
+				br_ifinfo_notify(RTM_NEWLINK, p);
 				ret = count;
+			}
 		}
 		rtnl_unlock();
 	}
-- 
2.1.0
