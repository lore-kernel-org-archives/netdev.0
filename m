From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next v2 1/2] vxlan: Notify drivers for listening UDP port
 changes
Date: Thu, 29 Aug 2013 16:19:04 +0200
Message-ID: <20130829141904.GB1450@minipsycho.brq.redhat.com>
References: <1377780878-32384-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:51069 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754284Ab3H2OTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 10:19:08 -0400
Received: by mail-ee0-f47.google.com with SMTP id d49so275548eek.6
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 07:19:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1377780878-32384-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 29, 2013 at 02:54:37PM CEST, jeffrey.t.kirsher@intel.com wrote:
>From: Joseph Gasparakis <joseph.gasparakis@intel.com>
>
>This patch adds two more ndo ops: ndo_add_rx_vxlan_port() and
>ndo_del_rx_vxlan_port().
>
>Drivers can get notifications through the above functions about changes
>of the UDP listening port of VXLAN. Also, when physical ports come up,
>now they can call vxlan_get_rx_port() in order to obtain the port number(s)
>of the existing VXLAN interface in case they already up before them.
>
>This information about the listening UDP port would be used for VXLAN
>related offloads.
>
>A big thank you to John Fastabend (john.r.fastabend@intel.com) for his input
>and his suggestions on this patch set.
>
>CC: John Fastabend <john.r.fastabend@intel.com>
>CC: Stephen Hemminger <stephen@networkplumber.org>
>Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>---
>v2: Now locking on sock_lock around vxlan_get_rx_port() in order to avoid
>    races with vxlan removing ports and drivers still keeping resources for
>    them.
>---
> drivers/net/vxlan.c       | 56 ++++++++++++++++++++++++++++++++++++++++++++++-
> include/linux/netdevice.h | 16 ++++++++++++++
> include/net/vxlan.h       |  1 +
> 3 files changed, 72 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>index 3b21aca..65d1df5 100644
>--- a/drivers/net/vxlan.c
>+++ b/drivers/net/vxlan.c
>@@ -456,6 +456,32 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
> 	return 1;
> }
> 
>+/* Notify netdevs that UDP port started listening */
>+static void vxlan_notify_add_rx_port(struct net *net, __be16 port)
>+{
>+	struct net_device *dev;
>+
>+	rcu_read_lock();
>+	for_each_netdev_rcu(net, dev) {
>+		if (dev->netdev_ops->ndo_add_vxlan_port)
>+			dev->netdev_ops->ndo_add_vxlan_port(dev, htons(port));
>+	}


Is it really desirable to notify *all* devices? Even those who are not
involved in vxlan traffic? I think that only affected devices should be
notified. Lower device list being currently introduced by:
"[PATCH net-next v3 02/13] net: add lower_dev_list to net_device and make a full mesh"
Could be used for this.


>+	rcu_read_unlock();
>+}
>+
>+/* Notify netdevs that UDP port is no more listening */
>+static void vxlan_notify_del_rx_port(struct net *net, __be16 port)
>+{
>+	struct net_device *dev;
>+
>+	rcu_read_lock();
>+	for_each_netdev_rcu(net, dev) {
>+		if (dev->netdev_ops->ndo_del_vxlan_port)
>+			dev->netdev_ops->ndo_del_vxlan_port(dev, htons(port));
>+	}
>+	rcu_read_unlock();
>+}
>+
> /* Add new entry to forwarding table -- assumes lock held */
> static int vxlan_fdb_create(struct vxlan_dev *vxlan,
> 			    const u8 *mac, __be32 ip,
>@@ -797,13 +823,15 @@ static void vxlan_sock_hold(struct vxlan_sock *vs)
> 
> void vxlan_sock_release(struct vxlan_sock *vs)
> {
>-	struct vxlan_net *vn = net_generic(sock_net(vs->sock->sk), vxlan_net_id);
>+	struct net *net = sock_net(vs->sock->sk);
>+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> 
> 	if (!atomic_dec_and_test(&vs->refcnt))
> 		return;
> 
> 	spin_lock(&vn->sock_lock);
> 	hlist_del_rcu(&vs->hlist);
>+	vxlan_notify_del_rx_port(net, inet_sk(vs->sock->sk)->inet_sport);
> 	spin_unlock(&vn->sock_lock);
> 
> 	queue_work(vxlan_wq, &vs->del_work);
>@@ -1543,6 +1571,31 @@ static struct device_type vxlan_type = {
> 	.name = "vxlan",
> };
> 
>+/* Calls the ndo_add_vxlan_port of the caller in order to
>+ * supply the listening VXLAN udp ports.
>+ */
>+void vxlan_get_rx_port(struct net_device *dev)
>+{
>+	struct vxlan_sock *vs;
>+	struct net *net = dev_net(dev);
>+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>+	u16 port;
>+	int i;
>+
>+	if (!dev || !dev->netdev_ops || !dev->netdev_ops->ndo_add_vxlan_port)
>+		return;
>+
>+	spin_lock(&vn->sock_lock);
>+	for (i = 0; i < PORT_HASH_SIZE; ++i) {
>+		hlist_for_each_entry_rcu(vs, vs_head(net, i), hlist) {
>+			port = htons(inet_sk(vs->sock->sk)->inet_sport);
>+			dev->netdev_ops->ndo_add_vxlan_port(dev, port);
>+		}
>+	}
>+	spin_unlock(&vn->sock_lock);
>+}
>+EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
>+
> /* Initialize the device structure. */
> static void vxlan_setup(struct net_device *dev)
> {
>@@ -1723,6 +1776,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
> 	inet_sk(sk)->mc_loop = 0;
> 	spin_lock(&vn->sock_lock);
> 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
>+	vxlan_notify_add_rx_port(net, port);
> 	spin_unlock(&vn->sock_lock);
> 
> 	/* Mark socket as an encapsulation socket. */
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 077363d..f56b141 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -948,6 +948,18 @@ struct netdev_phys_port_id {
>  *	Called to get ID of physical port of this device. If driver does
>  *	not implement this, it is assumed that the hw is not able to have
>  *	multiple net devices on single physical port.
>+ *
>+ * int (*ndo_add_vxlan_port)(struct  net_device *dev,
>+ *			      __u16 port);
>+ *	Called by vxlan to notiy a driver about the UDP port that vxlan
>+ *	is listnening to. It is called only when a new port starts listening.
>+ *	The operation is protected by the vxlan_net->sock_lock.
>+ *
>+ * int (*ndo_del_vxlan_port)(struct  net_device *dev,
>+ *			    __u16 port);
>+ *	Called by vxlan to notify the driver about a UDP port of vxlan
>+ *	that is not listening anymore. The operation is protected by
>+ *	the vxlan_net->sock_lock.
>  */
> struct net_device_ops {
> 	int			(*ndo_init)(struct net_device *dev);
>@@ -1078,6 +1090,10 @@ struct net_device_ops {
> 						      bool new_carrier);
> 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
> 							struct netdev_phys_port_id *ppid);
>+	int			(*ndo_add_vxlan_port)(struct  net_device *dev,
>+						      __u16 port);
>+	int			(*ndo_del_vxlan_port)(struct  net_device *dev,
>+						      __u16 port);


It doesn't look correct to add more specific device ndos like this. I
think they should be more general. How about to rather use netdev notifier
to propagate the change and then driver can use come vxlan exported
function to get ports in use.




> };
> 
> /*
>diff --git a/include/net/vxlan.h b/include/net/vxlan.h
>index ad342e3..a0dc497 100644
>--- a/include/net/vxlan.h
>+++ b/include/net/vxlan.h
>@@ -36,4 +36,5 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
> 
> __be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb);
> 
>+void vxlan_get_rx_port(struct net_device *netdev);
> #endif
>-- 
>1.8.3.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
