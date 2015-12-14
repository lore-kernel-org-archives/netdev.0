From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH v5 1/5] geneve: Add geneve udp port offload for ethernet devices
Date: Mon, 14 Dec 2015 12:21:17 -0800
Message-ID: <1450124481-206978-2-git-send-email-anjali.singhai@intel.com>
References: <1450124481-206978-1-git-send-email-anjali.singhai@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	jeffrey.t.kirsher@intel.com, Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:35429 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbbLNUD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 15:03:56 -0500
In-Reply-To: <1450124481-206978-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ndo_ops to add/del UDP ports to a device that supports geneve
offload.

v2: Comment fix.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
---
 drivers/net/geneve.c      | 23 +++++++++++++++++++++++
 include/linux/netdevice.h | 20 +++++++++++++++++++-
 2 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 0750d7a..89325e4 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -380,8 +380,11 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 
 static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 {
+	struct net_device *dev;
 	struct sock *sk = gs->sock->sk;
+	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
+	__be16 port = inet_sk(sk)->inet_sport;
 	int err;
 
 	if (sa_family == AF_INET) {
@@ -390,6 +393,14 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
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
@@ -530,8 +541,20 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 
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
index 1bb21ff..82065a7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1013,6 +1013,19 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	a new port starts listening. The operation is protected by the
  *	vxlan_net->sock_lock.
  *
+ * void (*ndo_add_geneve_port)(struct net_device *dev,
+ *			      sa_family_t sa_family, __be16 port);
+ *	Called by geneve to notify a driver about the UDP port and socket
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
