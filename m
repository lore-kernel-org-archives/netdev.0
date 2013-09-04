From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v4] vxlan: Notify drivers for listening UDP port changes
Date: Wed,  4 Sep 2013 02:13:38 -0700
Message-ID: <1378286019-8719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:52149 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756051Ab3IDJNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 05:13:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joseph Gasparakis <joseph.gasparakis@intel.com>

This patch adds two more ndo ops: ndo_add_rx_vxlan_port() and
ndo_del_rx_vxlan_port().

Drivers can get notifications through the above functions about changes
of the UDP listening port of VXLAN. Also, when physical ports come up,
now they can call vxlan_get_rx_port() in order to obtain the port number(s)
of the existing VXLAN interface in case they already up before them.

This information about the listening UDP port would be used for VXLAN
related offloads.

A big thank you to John Fastabend (john.r.fastabend@intel.com) for his
input and his suggestions on this patch set.

CC: John Fastabend <john.r.fastabend@intel.com>
CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/vxlan.c       | 68 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/netdevice.h | 19 +++++++++++++
 include/net/vxlan.h       |  1 +
 3 files changed, 87 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ebda3a1..0b62d82 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -558,6 +558,40 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	return 1;
 }
 
+/* Notify netdevs that UDP port started listening */
+static void vxlan_notify_add_rx_port(struct sock *sk)
+{
+	struct net_device *dev;
+	struct net *net = sock_net(sk);
+	sa_family_t sa_family = sk->sk_family;
+	u16 port = htons(inet_sk(sk)->inet_sport);
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		if (dev->netdev_ops->ndo_add_vxlan_port)
+			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
+							    port);
+	}
+	rcu_read_unlock();
+}
+
+/* Notify netdevs that UDP port is no more listening */
+static void vxlan_notify_del_rx_port(struct sock *sk)
+{
+	struct net_device *dev;
+	struct net *net = sock_net(sk);
+	sa_family_t sa_family = sk->sk_family;
+	u16 port = htons(inet_sk(sk)->inet_sport);
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		if (dev->netdev_ops->ndo_del_vxlan_port)
+			dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
+							    port);
+	}
+	rcu_read_unlock();
+}
+
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, union vxlan_addr *ip,
@@ -909,13 +943,16 @@ static void vxlan_sock_hold(struct vxlan_sock *vs)
 
 void vxlan_sock_release(struct vxlan_sock *vs)
 {
-	struct vxlan_net *vn = net_generic(sock_net(vs->sock->sk), vxlan_net_id);
+	struct sock *sk = vs->sock->sk;
+	struct net *net = sock_net(sk);
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 
 	if (!atomic_dec_and_test(&vs->refcnt))
 		return;
 
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
+	vxlan_notify_del_rx_port(sk);
 	spin_unlock(&vn->sock_lock);
 
 	queue_work(vxlan_wq, &vs->del_work);
@@ -1980,6 +2017,34 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
+/* Calls the ndo_add_vxlan_port of the caller in order to
+ * supply the listening VXLAN udp ports.
+ */
+void vxlan_get_rx_port(struct net_device *dev)
+{
+	struct vxlan_sock *vs;
+	struct net *net = dev_net(dev);
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	sa_family_t sa_family;
+	u16 port;
+	int i;
+
+	if (!dev || !dev->netdev_ops || !dev->netdev_ops->ndo_add_vxlan_port)
+		return;
+
+	spin_lock(&vn->sock_lock);
+	for (i = 0; i < PORT_HASH_SIZE; ++i) {
+		hlist_for_each_entry_rcu(vs, vs_head(net, i), hlist) {
+			port = htons(inet_sk(vs->sock->sk)->inet_sport);
+			sa_family = vs->sock->sk->sk_family;
+			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
+							    port);
+		}
+	}
+	spin_unlock(&vn->sock_lock);
+}
+EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
+
 /* Initialize the device structure. */
 static void vxlan_setup(struct net_device *dev)
 {
@@ -2239,6 +2304,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
+	vxlan_notify_add_rx_port(sk);
 	spin_unlock(&vn->sock_lock);
 
 	/* Mark socket as an encapsulation socket. */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3ad49b8..8ed4ae9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -948,6 +948,19 @@ struct netdev_phys_port_id {
  *	Called to get ID of physical port of this device. If driver does
  *	not implement this, it is assumed that the hw is not able to have
  *	multiple net devices on single physical port.
+ *
+ * void (*ndo_add_vxlan_port)(struct  net_device *dev,
+ *			      sa_family_t sa_family, __u16 port);
+ *	Called by vxlan to notiy a driver about the UDP port and socket
+ *	address family that vxlan is listnening to. It is called only when
+ *	a new port starts listening. The operation is protected by the
+ *	vxlan_net->sock_lock.
+ *
+ * void (*ndo_del_vxlan_port)(struct  net_device *dev,
+ *			      sa_family_t sa_family, __u16 port);
+ *	Called by vxlan to notify the driver about a UDP port and socket
+ *	address family that vxlan is not listening to anymore. The operation
+ *	is protected by the vxlan_net->sock_lock.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1078,6 +1091,12 @@ struct net_device_ops {
 						      bool new_carrier);
 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
 							struct netdev_phys_port_id *ppid);
+	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
+						      sa_family_t sa_family,
+						      __u16 port);
+	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
+						      sa_family_t sa_family,
+						      __u16 port);
 };
 
 /*
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index e09c40b..2d64d3c 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -36,4 +36,5 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 
 __be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb);
 
+void vxlan_get_rx_port(struct net_device *netdev);
 #endif
-- 
1.8.3.1
