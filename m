From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 6/6] bridge: a netlink notification should be sent when those attributes are changed by ioctl
Date: Wed, 16 Mar 2016 21:34:49 +0800
Message-ID: <9cadf4925a11b60a5420406b4eb164e9a2d13b50.1458134414.git.lucien.xin@gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
 <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
 <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
 <45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
 <38a10eecc6347a3c47b55c86b4783c49b6dbbc99.1458134414.git.lucien.xin@gmail.com>
 <7c788b65786582209a3ba4bc4d4ed279f6f77568.1458134414.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34339 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966410AbcCPNfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:35:22 -0400
Received: by mail-pf0-f196.google.com with SMTP id n5so6721626pfn.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:35:21 -0700 (PDT)
In-Reply-To: <7c788b65786582209a3ba4bc4d4ed279f6f77568.1458134414.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1458134414.git.lucien.xin@gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when we change the attributes of bridge or br_port by netlink,
a relevant netlink notification will be sent, but if we change them
by ioctl or sysfs, no notification will be sent.

We should ensure that whenever those attributes change internally or from
sysfs/ioctl, that a netlink notification is sent out to listeners.

Also, NetworkManager will use this in the future to listen for out-of-band
bridge master attribute updates and incorporate them into the runtime
configuration.

This patch is used for ioctl.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_ioctl.c | 40 ++++++++++++++++++++++++----------------
 1 file changed, 24 insertions(+), 16 deletions(-)

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
-- 
2.1.0
