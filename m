From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [RFC PATCH v2 1/4] geneve: Add geneve udp port offload for ethernet devices
Date: Fri,  4 Dec 2015 00:19:01 -0800
Message-ID: <1449217144-18756-2-git-send-email-anjali.singhai@intel.com>
References: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:45409 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755003AbbLDIBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 03:01:52 -0500
In-Reply-To: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ndo_ops to add/del UDP ports to a device that supports geneve
offload.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
---
 drivers/net/geneve.c      | 23 +++++++++++++++++++++++
 include/linux/netdevice.h | 20 +++++++++++++++++++-
 2 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index de5c30c..b43fd56 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -371,8 +371,11 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 
 static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 {
+	struct net_device *dev;
 	struct sock *sk = gs->sock->sk;
+	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
+	__be16 port = inet_sk(sk)->inet_sport;
 	int err;
 
 	if (sa_family == AF_INET) {
@@ -381,6 +384,14 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 			pr_warn("geneve: udp_add_offload failed with status %d\n",
 				err);
 	}
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		if (dev->netdev_ops->ndo_add_geneve_port)
+			dev->netdev_ops->ndo_add_geneve_port(dev, sa_family,
+							     port);
+	}
+	rcu_read_unlock();
 }
 
 static int geneve_hlen(struct genevehdr *gh)
@@ -521,8 +532,20 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 
 static void geneve_notify_del_rx_port(struct geneve_sock *gs)
 {
+	struct net_device *dev;
 	struct sock *sk = gs->sock->sk;
+	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
+	__be16 port = inet_sk(sk)->inet_sport;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		if (dev->netdev_ops->ndo_del_geneve_port)
+			dev->netdev_ops->ndo_del_geneve_port(dev, sa_family,
+							     port);
+	}
+
+	rcu_read_unlock();
 
 	if (sa_family == AF_INET)
 		udp_del_offload(&gs->udp_offloads);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa84b59..4b395a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1013,6 +1013,19 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	a new port starts listening. The operation is protected by the
  *	vxlan_net->sock_lock.
  *
+ * void (*ndo_add_geneve_port)(struct net_device *dev,
+ *			      sa_family_t sa_family, __be16 port);
+ *	Called by geneve to notiy a driver about the UDP port and socket
+ *	address family that geneve is listnening to. It is called only when
+ *	a new port starts listening. The operation is protected by the
+ *	geneve_net->sock_lock.
+ *
+ * void (*ndo_del_geneve_port)(struct net_device *dev,
+ *			      sa_family_t sa_family, __be16 port);
+ *	Called by geneve to notify the driver about a UDP port and socket
+ *	address family that geneve is not listening to anymore. The operation
+ *	is protected by the geneve_net->sock_lock.
+ *
  * void (*ndo_del_vxlan_port)(struct  net_device *dev,
  *			      sa_family_t sa_family, __be16 port);
  *	Called by vxlan to notify the driver about a UDP port and socket
@@ -1217,7 +1230,12 @@ struct net_device_ops {
 	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
 						      __be16 port);
-
+	void			(*ndo_add_geneve_port)(struct  net_device *dev,
+						       sa_family_t sa_family,
+						       __be16 port);
+	void			(*ndo_del_geneve_port)(struct  net_device *dev,
+						       sa_family_t sa_family,
+						       __be16 port);
 	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
 							struct net_device *dev);
 	void			(*ndo_dfwd_del_station)(struct net_device *pdev,
-- 
1.8.1.4
