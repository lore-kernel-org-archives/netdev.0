From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 09/17] net: Allow userns root control of the core of the network stack.
Date: Fri, 16 Nov 2012 05:03:04 -0800
Message-ID: <1353070992-5552-9-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
 <1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, Serge Hallyn <serge@hallyn.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59529 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab2KPNEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 08:04:12 -0500
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Allow an unpriviled user who has created a user namespace, and then
created a network namespace to effectively use the new network
namespace, by reducing capable(CAP_NET_ADMIN) and
capable(CAP_NET_RAW) calls to be ns_capable(net->user_ns,
CAP_NET_ADMIN), or capable(net->user_ns, CAP_NET_RAW) calls.

Settings that merely control a single network device are allowed.
Either the network device is a logical network device where
restrictions make no difference or the network device is hardware NIC
that has been explicity moved from the initial network namespace.

In general policy and network stack state changes are allowed
while resource control is left unchanged.

Allow ethtool ioctls.

Allow binding to network devices.
Allow setting the socket mark.
Allow setting the socket priority.

Allow setting the network device alias via sysfs.
Allow setting the mtu via sysfs.
Allow changing the network device flags via sysfs.
Allow setting the network device group via sysfs.

Allow the following network device ioctls.
SIOCGMIIPHY
SIOCGMIIREG
SIOCSIFNAME
SIOCSIFFLAGS
SIOCSIFMETRIC
SIOCSIFMTU
SIOCSIFHWADDR
SIOCSIFSLAVE
SIOCADDMULTI
SIOCDELMULTI
SIOCSIFHWBROADCAST
SIOCSMIIREG
SIOCBONDENSLAVE
SIOCBONDRELEASE
SIOCBONDSETHWADDR
SIOCBONDCHANGEACTIVE
SIOCBRADDIF
SIOCBRDELIF
SIOCSHWTSTAMP

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/dev.c       |   17 +++++++++++++----
 net/core/ethtool.c   |    2 +-
 net/core/net-sysfs.c |   15 ++++++++++-----
 net/core/sock.c      |    7 ++++---
 4 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 09cb3f6..7150ea9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5200,7 +5200,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSIFNAME:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		dev_load(net, ifr.ifr_name);
 		rtnl_lock();
@@ -5221,16 +5221,25 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	 *	- require strict serialization.
 	 *	- do not return a value
 	 */
+	case SIOCSIFMAP:
+	case SIOCSIFTXQLEN:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		/* fall through */
+	/*
+	 *	These ioctl calls:
+	 *	- require local superuser power.
+	 *	- require strict serialization.
+	 *	- do not return a value
+	 */
 	case SIOCSIFFLAGS:
 	case SIOCSIFMETRIC:
 	case SIOCSIFMTU:
-	case SIOCSIFMAP:
 	case SIOCSIFHWADDR:
 	case SIOCSIFSLAVE:
 	case SIOCADDMULTI:
 	case SIOCDELMULTI:
 	case SIOCSIFHWBROADCAST:
-	case SIOCSIFTXQLEN:
 	case SIOCSMIIREG:
 	case SIOCBONDENSLAVE:
 	case SIOCBONDRELEASE:
@@ -5239,7 +5248,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCBRADDIF:
 	case SIOCBRDELIF:
 	case SIOCSHWTSTAMP:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		/* fall through */
 	case SIOCBONDSLAVEINFOQUERY:
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 4d64cc2..a870543 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1460,7 +1460,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GEEE:
 		break;
 	default:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 	}
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index bcf02f6..c66b8c2 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -73,11 +73,12 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 			    const char *buf, size_t len,
 			    int (*set)(struct net_device *, unsigned long))
 {
-	struct net_device *net = to_net_dev(dev);
+	struct net_device *netdev = to_net_dev(dev);
+	struct net *net = dev_net(netdev);
 	unsigned long new;
 	int ret = -EINVAL;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	ret = kstrtoul(buf, 0, &new);
@@ -87,8 +88,8 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	if (dev_isalive(net)) {
-		if ((ret = (*set)(net, new)) == 0)
+	if (dev_isalive(netdev)) {
+		if ((ret = (*set)(netdev, new)) == 0)
 			ret = len;
 	}
 	rtnl_unlock();
@@ -264,6 +265,9 @@ static ssize_t store_tx_queue_len(struct device *dev,
 				  struct device_attribute *attr,
 				  const char *buf, size_t len)
 {
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
 
@@ -271,10 +275,11 @@ static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
 			     const char *buf, size_t len)
 {
 	struct net_device *netdev = to_net_dev(dev);
+	struct net *net = dev_net(netdev);
 	size_t count = len;
 	ssize_t ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	/* ignore trailing newline */
diff --git a/net/core/sock.c b/net/core/sock.c
index 8a146cf..85d75cb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -515,7 +515,7 @@ static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 
 	/* Sorry... */
 	ret = -EPERM;
-	if (!capable(CAP_NET_RAW))
+	if (!ns_capable(net->user_ns, CAP_NET_RAW))
 		goto out;
 
 	ret = -EINVAL;
@@ -696,7 +696,8 @@ set_rcvbuf:
 		break;
 
 	case SO_PRIORITY:
-		if ((val >= 0 && val <= 6) || capable(CAP_NET_ADMIN))
+		if ((val >= 0 && val <= 6) ||
+		    ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 			sk->sk_priority = val;
 		else
 			ret = -EPERM;
@@ -813,7 +814,7 @@ set_rcvbuf:
 			clear_bit(SOCK_PASSSEC, &sock->flags);
 		break;
 	case SO_MARK:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 			ret = -EPERM;
 		else
 			sk->sk_mark = val;
-- 
1.7.5.4
