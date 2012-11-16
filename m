From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 13/17] net: Allow userns root to control the network bridge code.
Date: Fri, 16 Nov 2012 05:03:08 -0800
Message-ID: <1353070992-5552-13-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
 <1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, Serge Hallyn <serge@hallyn.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:47608 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686Ab2KPNHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 08:07:04 -0500
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Allow an unpriviled user who has created a user namespace, and then
created a network namespace to effectively use the new network
namespace, by reducing capable(CAP_NET_ADMIN) and
capable(CAP_NET_RAW) calls to be ns_capable(net->user_ns,
CAP_NET_ADMIN), or capable(net->user_ns, CAP_NET_RAW) calls.

Allow setting bridge paramters via sysfs.

Allow all of the bridge ioctls:
BRCTL_ADD_IF
BRCTL_DEL_IF
BRCTL_SET_BRDIGE_FORWARD_DELAY
BRCTL_SET_BRIDGE_HELLO_TIME
BRCTL_SET_BRIDGE_MAX_AGE
BRCTL_SET_BRIDGE_AGING_TIME
BRCTL_SET_BRIDGE_STP_STATE
BRCTL_SET_BRIDGE_PRIORITY
BRCTL_SET_PORT_PRIORITY
BRCTL_SET_PATH_COST
BRCTL_ADD_BRIDGE
BRCTL_DEL_BRDIGE

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/br_ioctl.c    |   25 +++++++++++++------------
 net/bridge/br_sysfs_br.c |   10 +++++-----
 net/bridge/br_sysfs_if.c |    2 +-
 3 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 7222fe1..cd8c3a4 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -85,13 +85,14 @@ static int get_fdb_entries(struct net_bridge *br, void __user *userbuf,
 /* called with RTNL */
 static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 {
+	struct net *net = dev_net(br->dev);
 	struct net_device *dev;
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
-	dev = __dev_get_by_index(dev_net(br->dev), ifindex);
+	dev = __dev_get_by_index(net, ifindex);
 	if (dev == NULL)
 		return -EINVAL;
 
@@ -178,25 +179,25 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	}
 
 	case BRCTL_SET_BRIDGE_FORWARD_DELAY:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		return br_set_forward_delay(br, args[1]);
 
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		return br_set_hello_time(br, args[1]);
 
 	case BRCTL_SET_BRIDGE_MAX_AGE:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		return br_set_max_age(br, args[1]);
 
 	case BRCTL_SET_AGEING_TIME:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		br->ageing_time = clock_t_to_jiffies(args[1]);
@@ -236,14 +237,14 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	}
 
 	case BRCTL_SET_BRIDGE_STP_STATE:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		br_stp_set_enabled(br, args[1]);
 		return 0;
 
 	case BRCTL_SET_BRIDGE_PRIORITY:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
@@ -256,7 +257,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		struct net_bridge_port *p;
 		int ret;
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
@@ -273,7 +274,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		struct net_bridge_port *p;
 		int ret;
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
@@ -330,7 +331,7 @@ static int old_deviceless(struct net *net, void __user *uarg)
 	{
 		char buf[IFNAMSIZ];
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		if (copy_from_user(buf, (void __user *)args[1], IFNAMSIZ))
@@ -360,7 +361,7 @@ int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *uar
 	{
 		char buf[IFNAMSIZ];
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		if (copy_from_user(buf, uarg, IFNAMSIZ))
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index c5c0593..53dc9cb 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -36,7 +36,7 @@ static ssize_t store_bridge_parm(struct device *d,
 	unsigned long val;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	val = simple_strtoul(buf, &endp, 0);
@@ -132,7 +132,7 @@ static ssize_t store_stp_state(struct device *d,
 	char *endp;
 	unsigned long val;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	val = simple_strtoul(buf, &endp, 0);
@@ -165,7 +165,7 @@ static ssize_t store_group_fwd_mask(struct device *d,
 	char *endp;
 	unsigned long val;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	val = simple_strtoul(buf, &endp, 0);
@@ -300,7 +300,7 @@ static ssize_t store_group_addr(struct device *d,
 	unsigned int new_addr[6];
 	int i;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (sscanf(buf, "%x:%x:%x:%x:%x:%x",
@@ -337,7 +337,7 @@ static ssize_t store_flush(struct device *d,
 {
 	struct net_bridge *br = to_bridge(d);
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	br_fdb_flush(br);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 13b36bd..7844478 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -209,7 +209,7 @@ static ssize_t brport_store(struct kobject * kobj,
 	char *endp;
 	unsigned long val;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(p->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	val = simple_strtoul(buf, &endp, 0);
-- 
1.7.5.4
