From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 6/6] bridge: a netlink notification should be sent when those attributes are changed by ioctl
Date: Tue,  5 Apr 2016 11:32:41 +0800
Message-ID: <39a9cc4a663ed22b442a1424b4de21d21c4438cb.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
 <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1459827115.git.lucien.xin@gmail.com>
 <6197a35a2eb6df2caf90edcbf1b49da12077f659.1459827115.git.lucien.xin@gmail.com>
 <baf4788b6ac529a2132ace735fc1caf4989307da.1459827115.git.lucien.xin@gmail.com>
 <9bf0874c74438a287968ef5190599214333b52be.1459827115.git.lucien.xin@gmail.com>
 <d6f49fd173d183b78c4dd4e18e67d394438f5d7d.1459827115.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34275 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbcDEDdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 23:33:16 -0400
Received: by mail-pf0-f194.google.com with SMTP id d184so147872pfc.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 20:33:15 -0700 (PDT)
In-Reply-To: <d6f49fd173d183b78c4dd4e18e67d394438f5d7d.1459827115.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
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
