From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 6/6] bridge: a netlink notification should be sent when those attributes are changed by ioctl
Date: Sat,  9 Apr 2016 00:03:33 +0800
Message-ID: <412ca1bb5690dfd7a73a37d7e821784f24edd059.1460131308.git.lucien.xin@gmail.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
 <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1460131308.git.lucien.xin@gmail.com>
 <6197a35a2eb6df2caf90edcbf1b49da12077f659.1460131308.git.lucien.xin@gmail.com>
 <8c14a891d0a8bcea071d4e5305776a5c5cd9fd17.1460131308.git.lucien.xin@gmail.com>
 <1dd5e14c7f042753a4d70b585de407a4e388262a.1460131308.git.lucien.xin@gmail.com>
 <8c87a70b3c214f90b7345edb68536429fdaad096.1460131308.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:34933 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932742AbcDHQEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:04:05 -0400
Received: by mail-ig0-f196.google.com with SMTP id fn8so2997422igb.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 09:04:04 -0700 (PDT)
In-Reply-To: <8c87a70b3c214f90b7345edb68536429fdaad096.1460131308.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460131308.git.lucien.xin@gmail.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
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
