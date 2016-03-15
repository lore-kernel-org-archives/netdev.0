From: Aaron Young <Aaron.Young@oracle.com>
Subject: [PATCH net-next v2 2/4] ldmvsw: Make sunvnet_common compatible with ldmvsw
Date: Tue, 15 Mar 2016 11:35:38 -0700
Message-ID: <64dcf1999107a6b66e89aac18e8f1e46f512e1be.1458006737.git.Aaron.Young@oracle.com>
References: <cover.1458006737.git.Aaron.Young@oracle.com>
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	alexandre.chartre@oracle.com, rashmi.narasimhan@oracle.com,
	aaron.young@oracle.com, atish.patra@oracle.com,
	Aaron Young <Aaron.Young@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43876 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965590AbcCOSfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:35:20 -0400
In-Reply-To: <cover.1458006737.git.Aaron.Young@oracle.com>
In-Reply-To: <cover.1458006737.git.Aaron.Young@oracle.com>
References: <cover.1458006737.git.Aaron.Young@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  From: Aaron Young <aaron.young@oracle.com>

  Modify sunvnet common code and data structures to be compatible
  with both sunvnet and ldmvsw drivers.

  Details:

  Sunvnet operates on "vnet-port" nodes which appear in the Machine
  Description (MD) in a guest domain. Ldmvsw operates on "vsw-port"
  nodes which appear in the MD of a service domain.

  A difference between the sunvnet driver and the ldmvsw driver is
  the sunvnet driver creates a network interface (i.e. a struct net_device)
  for every vnet-port *parent* "network" node. Several vnet-ports may appear
  under this common parent network node - each corresponding to a common parent
  network interface.  Conversely, since bridge/vswitch software will need
  to interface with every vsw-port in a system, the ldmvsw driver creates
  a network interface (i.e. a struct net_device) for every vsw-port - not
  every parent node as with sunvnet.  This difference required some special
  handling in the common code as explained below.

  There are 2 key data structures used by the sunvnet and ldmvsw drivers
  (which are now found in sunvnet_common.h):

  1. struct vnet_port
     This structure represents a vnet-port node in sunvnet and a vsw-port
     in the ldmvsw driver.

  2. struct vnet
     This structure represents a parent "network" node in sunvnet and a parent
     "virtual-network-switch" node in ldmvsw.

  Since the sunvnet driver allocates a net_device for every parent "network"
  node, a net_device member appears in the struct vnet. Since the ldmvsw
  driver allocates a net_device for every port, a net_device member was
  added to the vnet_port. The common code distinguishes which structure
  net_device member to use by checking a 'vsw' bit that was added to the
  vnet_port structure. See the VNET_PORT_TO_NET_DEVICE() marco in
  sunvnet_common.h.

  The netdev_priv() in sunvnet is allocated as a vnet. The netdev_priv()
  in ldmvsw is a vnet_port. Therefore, any place in the common code
  where a netdev_priv() call was made, a wrapper function was implemented
  in each driver to first get the vnet and/or vnet_port (in a driver
  specific way) and pass them as newly added parameters to the common
  functions (see wrapper funcs: vnet_set_rx_mode() and vnet_poll_controller()).
  Since these wrapper functions call __tx_port_find(), __tx_port_find() was
  moved from the common code back into sunvnet.c. Note - ldmvsw.c does not
  require this function.

  These changes also required that port_is_up() be made
  into a common function and thus it was given a _common suffix and
  exported like the other common functions.

  A wrapper function was also added for vnet_start_xmit_common() to pass a
  driver-specific function arg to return the port associated with a given
  struct sk_buff and struct net_device. This was required because
  vnet_start_xmit_common() grabs a lock prior to getting the associated
  port. Using a function pointer arg allowed the code to work unchanged
  without risking changes to the non-trivial locking logic in
  vnet_start_xmit_common().

  Signed-off-by: Aaron Young <aaron.young@oracle.com>
  Signed-off-by: Rashmi Narasimhan <rashmi.narasimhan@oracle.com>
  Reviewed-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
  Reviewed-by: Alexandre Chartre <Alexandre.Chartre@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c        |   74 ++++++++++++++++++++++-
 drivers/net/ethernet/sun/sunvnet_common.c |   89 ++++++++++-------------------
 drivers/net/ethernet/sun/sunvnet_common.h |   28 +++++++---
 3 files changed, 121 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 5b91135..98c5f16 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1,6 +1,7 @@
 /* sunvnet.c: Sun LDOM Virtual Network Driver.
  *
  * Copyright (C) 2007, 2008 David S. Miller <davem@davemloft.net>
+ * Copyright (C) 2016 Oracle. All rights reserved.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -84,18 +85,83 @@ static const struct ethtool_ops vnet_ethtool_ops = {
 static LIST_HEAD(vnet_list);
 static DEFINE_MUTEX(vnet_list_mutex);
 
+static struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
+{
+	unsigned int hash = vnet_hashfn(skb->data);
+	struct hlist_head *hp = &vp->port_hash[hash];
+	struct vnet_port *port;
+
+	hlist_for_each_entry_rcu(port, hp, hash) {
+		if (!sunvnet_port_is_up_common(port))
+			continue;
+		if (ether_addr_equal(port->raddr, skb->data))
+			return port;
+	}
+	list_for_each_entry_rcu(port, &vp->port_list, list) {
+		if (!port->switch_port)
+			continue;
+		if (!sunvnet_port_is_up_common(port))
+			continue;
+		return port;
+	}
+	return NULL;
+}
+
+/* func arg to vnet_start_xmit_common() to get the proper tx port */
+static struct vnet_port *vnet_tx_port_find(struct sk_buff *skb,
+					   struct net_device *dev)
+{
+	struct vnet *vp = netdev_priv(dev);
+
+	return __tx_port_find(vp, skb);
+}
+
+static u16 vnet_select_queue(struct net_device *dev, struct sk_buff *skb,
+			     void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct vnet *vp = netdev_priv(dev);
+	struct vnet_port *port = __tx_port_find(vp, skb);
+
+	if (!port)
+		return 0;
+
+	return port->q_index;
+}
+
+/* Wrappers to common functions */
+static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	return sunvnet_start_xmit_common(skb, dev, vnet_tx_port_find);
+}
+
+static void vnet_set_rx_mode(struct net_device *dev)
+{
+	struct vnet *vp = netdev_priv(dev);
+
+	return sunvnet_set_rx_mode_common(dev, vp);
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void vnet_poll_controller(struct net_device *dev)
+{
+	struct vnet *vp = netdev_priv(dev);
+
+	return sunvnet_poll_controller_common(dev, vp);
+}
+#endif
+
 static const struct net_device_ops vnet_ops = {
 	.ndo_open		= sunvnet_open_common,
 	.ndo_stop		= sunvnet_close_common,
-	.ndo_set_rx_mode	= sunvnet_set_rx_mode_common,
+	.ndo_set_rx_mode	= vnet_set_rx_mode,
 	.ndo_set_mac_address	= sunvnet_set_mac_addr_common,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= sunvnet_tx_timeout_common,
 	.ndo_change_mtu		= sunvnet_change_mtu_common,
-	.ndo_start_xmit		= sunvnet_start_xmit_common,
-	.ndo_select_queue	= sunvnet_select_queue_common,
+	.ndo_start_xmit		= vnet_start_xmit,
+	.ndo_select_queue	= vnet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= sunvnet_poll_controller_common,
+	.ndo_poll_controller	= vnet_poll_controller,
 #endif
 };
 
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 49e85d0..083f41c 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1,6 +1,7 @@
 /* sunvnet.c: Sun LDOM Virtual Network Driver.
  *
  * Copyright (C) 2007, 2008 David S. Miller <davem@davemloft.net>
+ * Copyright (C) 2016 Oracle. All rights reserved.
  */
 
 #include <linux/module.h>
@@ -62,7 +63,7 @@ static int vnet_port_alloc_tx_ring(struct vnet_port *port);
 int sunvnet_send_attr_common(struct vio_driver_state *vio)
 {
 	struct vnet_port *port = to_vnet_port(vio);
-	struct net_device *dev = port->vp->dev;
+	struct net_device *dev = VNET_PORT_TO_NET_DEVICE(port);
 	struct vio_net_attr_info pkt;
 	int framelen = ETH_FRAME_LEN;
 	int i, err;
@@ -330,7 +331,7 @@ static inline void vnet_fullcsum(struct sk_buff *skb)
 
 static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 {
-	struct net_device *dev = port->vp->dev;
+	struct net_device *dev = VNET_PORT_TO_NET_DEVICE(port);
 	unsigned int len = desc->size;
 	unsigned int copy_len;
 	struct sk_buff *skb;
@@ -633,7 +634,6 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	struct vio_dring_state *dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 	struct vio_dring_data *pkt = msgbuf;
 	struct net_device *dev;
-	struct vnet *vp;
 	u32 end;
 	struct vio_net_desc *desc;
 	struct netdev_queue *txq;
@@ -642,8 +642,7 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 		return 0;
 
 	end = pkt->end_idx;
-	vp = port->vp;
-	dev = vp->dev;
+	dev = VNET_PORT_TO_NET_DEVICE(port);
 	netif_tx_lock(dev);
 	if (unlikely(!idx_is_pending(dr, end))) {
 		netif_tx_unlock(dev);
@@ -688,10 +687,11 @@ static int vnet_nack(struct vnet_port *port, void *msgbuf)
 static int handle_mcast(struct vnet_port *port, void *msgbuf)
 {
 	struct vio_net_mcast_info *pkt = msgbuf;
+	struct net_device *dev = VNET_PORT_TO_NET_DEVICE(port);
 
 	if (pkt->tag.stype != VIO_SUBTYPE_ACK)
 		pr_err("%s: Got unexpected MCAST reply [%02x:%02x:%04x:%08x]\n",
-		       port->vp->dev->name,
+		       dev->name,
 		       pkt->tag.type,
 		       pkt->tag.stype,
 		       pkt->tag.stype_env,
@@ -708,7 +708,8 @@ static void maybe_tx_wakeup(struct vnet_port *port)
 {
 	struct netdev_queue *txq;
 
-	txq = netdev_get_tx_queue(port->vp->dev, port->q_index);
+	txq = netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
+				  port->q_index);
 	__netif_tx_lock(txq, smp_processor_id());
 	if (likely(netif_tx_queue_stopped(txq))) {
 		struct vio_dring_state *dr;
@@ -719,12 +720,13 @@ static void maybe_tx_wakeup(struct vnet_port *port)
 	__netif_tx_unlock(txq);
 }
 
-static inline bool port_is_up(struct vnet_port *vnet)
+bool sunvnet_port_is_up_common(struct vnet_port *vnet)
 {
 	struct vio_driver_state *vio = &vnet->vio;
 
 	return !!(vio->hs_state & VIO_HS_COMPLETE);
 }
+EXPORT_SYMBOL_GPL(sunvnet_port_is_up_common);
 
 static int vnet_event_napi(struct vnet_port *port, int budget)
 {
@@ -797,7 +799,7 @@ ldc_ctrl:
 napi_resume:
 		if (likely(msgbuf.tag.type == VIO_TYPE_DATA)) {
 			if (msgbuf.tag.stype == VIO_SUBTYPE_INFO) {
-				if (!port_is_up(port)) {
+				if (!sunvnet_port_is_up_common(port)) {
 					/* failures like handshake_failure()
 					 * may have cleaned up dring, but
 					 * NAPI polling may bring us here.
@@ -911,28 +913,6 @@ static int __vnet_tx_trigger(struct vnet_port *port, u32 start)
 	return err;
 }
 
-static struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
-{
-	unsigned int hash = vnet_hashfn(skb->data);
-	struct hlist_head *hp = &vp->port_hash[hash];
-	struct vnet_port *port;
-
-	hlist_for_each_entry_rcu(port, hp, hash) {
-		if (!port_is_up(port))
-			continue;
-		if (ether_addr_equal(port->raddr, skb->data))
-			return port;
-	}
-	list_for_each_entry_rcu(port, &vp->port_list, list) {
-		if (!port->switch_port)
-			continue;
-		if (!port_is_up(port))
-			continue;
-		return port;
-	}
-	return NULL;
-}
-
 static struct sk_buff *vnet_clean_tx_ring(struct vnet_port *port,
 					  unsigned *pending)
 {
@@ -994,9 +974,9 @@ void sunvnet_clean_timer_expire_common(unsigned long port0)
 	struct sk_buff *freeskbs;
 	unsigned pending;
 
-	netif_tx_lock(port->vp->dev);
+	netif_tx_lock(VNET_PORT_TO_NET_DEVICE(port));
 	freeskbs = vnet_clean_tx_ring(port, &pending);
-	netif_tx_unlock(port->vp->dev);
+	netif_tx_unlock(VNET_PORT_TO_NET_DEVICE(port));
 
 	vnet_free_skbs(freeskbs);
 
@@ -1140,21 +1120,11 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 	return skb;
 }
 
-u16 sunvnet_select_queue_common(struct net_device *dev, struct sk_buff *skb,
-		  void *accel_priv, select_queue_fallback_t fallback)
+static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb,
+				struct vnet_port *(*vnet_tx_port)
+				(struct sk_buff *, struct net_device *))
 {
-	struct vnet *vp = netdev_priv(dev);
-	struct vnet_port *port = __tx_port_find(vp, skb);
-
-	if (port == NULL)
-		return 0;
-	return port->q_index;
-}
-EXPORT_SYMBOL_GPL(sunvnet_select_queue_common);
-
-static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
-{
-	struct net_device *dev = port->vp->dev;
+	struct net_device *dev = VNET_PORT_TO_NET_DEVICE(port);
 	struct vio_dring_state *dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 	struct sk_buff *segs;
 	int maclen, datalen;
@@ -1239,7 +1209,8 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
 			curr->csum_offset = offsetof(struct udphdr, check);
 
 		if (!(status & NETDEV_TX_MASK))
-			status = sunvnet_start_xmit_common(curr, dev);
+			status = sunvnet_start_xmit_common(curr, dev,
+							   vnet_tx_port);
 		if (status & NETDEV_TX_MASK)
 			dev_kfree_skb_any(curr);
 	}
@@ -1253,9 +1224,10 @@ out_dropped:
 	return NETDEV_TX_OK;
 }
 
-int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev)
+int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
+			      struct vnet_port *(*vnet_tx_port)
+			      (struct sk_buff *, struct net_device *))
 {
-	struct vnet *vp = netdev_priv(dev);
 	struct vnet_port *port = NULL;
 	struct vio_dring_state *dr;
 	struct vio_net_desc *d;
@@ -1266,14 +1238,14 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev)
 	struct netdev_queue *txq;
 
 	rcu_read_lock();
-	port = __tx_port_find(vp, skb);
+	port = vnet_tx_port(skb, dev);
 	if (unlikely(!port)) {
 		rcu_read_unlock();
 		goto out_dropped;
 	}
 
 	if (skb_is_gso(skb) && skb->len > port->tsolen) {
-		err = vnet_handle_offloads(port, skb);
+		err = vnet_handle_offloads(port, skb, vnet_tx_port);
 		rcu_read_unlock();
 		return err;
 	}
@@ -1588,9 +1560,8 @@ static void __send_mc_list(struct vnet *vp, struct vnet_port *port)
 	}
 }
 
-void sunvnet_set_rx_mode_common(struct net_device *dev)
+void sunvnet_set_rx_mode_common(struct net_device *dev, struct vnet *vp)
 {
-	struct vnet *vp = netdev_priv(dev);
 	struct vnet_port *port;
 
 	rcu_read_lock();
@@ -1717,9 +1688,8 @@ err_out:
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-void sunvnet_poll_controller_common(struct net_device *dev)
+void sunvnet_poll_controller_common(struct net_device *dev, struct vnet *vp)
 {
-	struct vnet *vp = netdev_priv(dev);
 	struct vnet_port *port;
 	unsigned long flags;
 
@@ -1741,13 +1711,16 @@ void sunvnet_port_add_txq_common(struct vnet_port *port)
 	n = vp->nports++;
 	n = n & (VNET_MAX_TXQS - 1);
 	port->q_index = n;
-	netif_tx_wake_queue(netdev_get_tx_queue(vp->dev, port->q_index));
+	netif_tx_wake_queue(netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
+						port->q_index));
+
 }
 EXPORT_SYMBOL_GPL(sunvnet_port_add_txq_common);
 
 void sunvnet_port_rm_txq_common(struct vnet_port *port)
 {
 	port->vp->nports--;
-	netif_tx_stop_queue(netdev_get_tx_queue(port->vp->dev, port->q_index));
+	netif_tx_stop_queue(netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
+						port->q_index));
 }
 EXPORT_SYMBOL_GPL(sunvnet_port_rm_txq_common);
diff --git a/drivers/net/ethernet/sun/sunvnet_common.h b/drivers/net/ethernet/sun/sunvnet_common.h
index c29c526..bd36528 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.h
+++ b/drivers/net/ethernet/sun/sunvnet_common.h
@@ -32,6 +32,13 @@ struct vnet_tx_entry {
 };
 
 struct vnet;
+
+/* Structure to describe a vnet-port or vsw-port in the MD.
+ * If the vsw bit is set, this structure represents a vswitch
+ * port, and the net_device can be found from ->dev. If the
+ * vsw bit is not set, the net_device is available from ->vp->dev.
+ * See the VNET_PORT_TO_NET_DEVICE macro below.
+ */
 struct vnet_port {
 	struct vio_driver_state	vio;
 
@@ -39,9 +46,11 @@ struct vnet_port {
 	u8			raddr[ETH_ALEN];
 	unsigned		switch_port:1;
 	unsigned		tso:1;
-	unsigned		__pad:14;
+	unsigned		vsw:1;
+	unsigned		__pad:13;
 
 	struct vnet		*vp;
+	struct net_device	*dev;
 
 	struct vnet_tx_entry	tx_bufs[VNET_TX_RING_SIZE];
 
@@ -105,21 +114,23 @@ struct vnet {
 	int			nports;
 };
 
+/* Def used by common code to get the net_device from the proper location */
+#define VNET_PORT_TO_NET_DEVICE(__port) \
+	((__port)->vsw ? (__port)->dev : (__port)->vp->dev)
+
 /* Common funcs */
 void sunvnet_clean_timer_expire_common(unsigned long port0);
 int sunvnet_open_common(struct net_device *dev);
 int sunvnet_close_common(struct net_device *dev);
-void sunvnet_set_rx_mode_common(struct net_device *dev);
+void sunvnet_set_rx_mode_common(struct net_device *dev, struct vnet *vp);
 int sunvnet_set_mac_addr_common(struct net_device *dev, void *p);
 void sunvnet_tx_timeout_common(struct net_device *dev);
 int sunvnet_change_mtu_common(struct net_device *dev, int new_mtu);
-int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev);
-u16 sunvnet_select_queue_common(struct net_device *dev,
-				struct sk_buff *skb,
-				void *accel_priv,
-				select_queue_fallback_t fallback);
+int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
+			   struct vnet_port *(*vnet_tx_port)
+			   (struct sk_buff *, struct net_device *));
 #ifdef CONFIG_NET_POLL_CONTROLLER
-void sunvnet_poll_controller_common(struct net_device *dev);
+void sunvnet_poll_controller_common(struct net_device *dev, struct vnet *vp);
 #endif
 void sunvnet_event_common(void *arg, int event);
 int sunvnet_send_attr_common(struct vio_driver_state *vio);
@@ -127,6 +138,7 @@ int sunvnet_handle_attr_common(struct vio_driver_state *vio, void *arg);
 void sunvnet_handshake_complete_common(struct vio_driver_state *vio);
 int sunvnet_poll_common(struct napi_struct *napi, int budget);
 void sunvnet_port_free_tx_bufs_common(struct vnet_port *port);
+bool sunvnet_port_is_up_common(struct vnet_port *vnet);
 void sunvnet_port_add_txq_common(struct vnet_port *port);
 void sunvnet_port_rm_txq_common(struct vnet_port *port);
 
-- 
1.7.1
