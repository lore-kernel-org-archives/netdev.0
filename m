From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] vxlan: Fix sparse warnings
Date: Fri, 13 Sep 2013 07:34:13 -0700
Message-ID: <1379082853-28172-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44708 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683Ab3IMOeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 10:34:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joseph Gasparakis <joseph.gasparakis@intel.com>

This patch fixes sparse warnings when incorrectly handling the port number
and using int instead of unsigned int iterating through &vn->sock_list[].
Keeping the port as __be16 also makes things clearer wrt endianess.
Also, it was pointed out that vxlan_get_rx_port() had unnecessary checks
which got removed.

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/vxlan.c       | 18 ++++++++----------
 include/linux/netdevice.h |  8 ++++----
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bf64b41..2400b1b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -564,7 +564,7 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
 	struct net_device *dev;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
-	u16 port = htons(inet_sk(sk)->inet_sport);
+	__be16 port = inet_sk(sk)->inet_sport;
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
@@ -581,7 +581,7 @@ static void vxlan_notify_del_rx_port(struct sock *sk)
 	struct net_device *dev;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
-	u16 port = htons(inet_sk(sk)->inet_sport);
+	__be16 port = inet_sk(sk)->inet_sport;
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
@@ -2021,7 +2021,8 @@ static struct device_type vxlan_type = {
 };
 
 /* Calls the ndo_add_vxlan_port of the caller in order to
- * supply the listening VXLAN udp ports.
+ * supply the listening VXLAN udp ports. Callers are expected
+ * to implement the ndo_add_vxlan_port.
  */
 void vxlan_get_rx_port(struct net_device *dev)
 {
@@ -2029,16 +2030,13 @@ void vxlan_get_rx_port(struct net_device *dev)
 	struct net *net = dev_net(dev);
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	sa_family_t sa_family;
-	u16 port;
-	int i;
-
-	if (!dev || !dev->netdev_ops || !dev->netdev_ops->ndo_add_vxlan_port)
-		return;
+	__be16 port;
+	unsigned int i;
 
 	spin_lock(&vn->sock_lock);
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
-		hlist_for_each_entry_rcu(vs, vs_head(net, i), hlist) {
-			port = htons(inet_sk(vs->sock->sk)->inet_sport);
+		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
+			port = inet_sk(vs->sock->sk)->inet_sport;
 			sa_family = vs->sock->sk->sk_family;
 			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
 							    port);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 041b42a..3de49ac 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -950,14 +950,14 @@ struct netdev_phys_port_id {
  *	multiple net devices on single physical port.
  *
  * void (*ndo_add_vxlan_port)(struct  net_device *dev,
- *			      sa_family_t sa_family, __u16 port);
+ *			      sa_family_t sa_family, __be16 port);
  *	Called by vxlan to notiy a driver about the UDP port and socket
  *	address family that vxlan is listnening to. It is called only when
  *	a new port starts listening. The operation is protected by the
  *	vxlan_net->sock_lock.
  *
  * void (*ndo_del_vxlan_port)(struct  net_device *dev,
- *			      sa_family_t sa_family, __u16 port);
+ *			      sa_family_t sa_family, __be16 port);
  *	Called by vxlan to notify the driver about a UDP port and socket
  *	address family that vxlan is not listening to anymore. The operation
  *	is protected by the vxlan_net->sock_lock.
@@ -1093,10 +1093,10 @@ struct net_device_ops {
 							struct netdev_phys_port_id *ppid);
 	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
-						      __u16 port);
+						      __be16 port);
 	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
-						      __u16 port);
+						      __be16 port);
 };
 
 /*
-- 
1.8.3.1
