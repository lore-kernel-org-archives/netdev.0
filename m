From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 3/8] vxlan: Allow multiple receive handlers.
Date: Thu, 20 Jun 2013 00:26:36 -0700
Message-ID: <1371713196-8154-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:34838 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753990Ab3FTH0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 03:26:39 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj3so6063439pad.28
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 00:26:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds basic multiple vxlan protocol handlers.
This does not change any functionality. This is required for
openvswitch vxlan support.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |  212 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 137 insertions(+), 75 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 91d04f9..0830b71 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -57,6 +57,7 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
+#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
@@ -85,9 +86,20 @@ struct vxlan_sock {
 	struct hlist_node hlist;
 	struct rcu_head	  rcu;
 	struct work_struct del_work;
-	unsigned int	  refcnt;
 	struct socket	  *sock;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
+	struct list_head handler_list;
+};
+
+struct vxlan_handler;
+typedef int (vxlan_rcv_t)(struct vxlan_handler *vh, struct sk_buff *skb, __be32 key);
+
+struct vxlan_handler {
+	vxlan_rcv_t *rcv;
+	struct list_head node;
+	struct vxlan_sock *vs;
+	unsigned int refcnt;
+	struct rcu_head	  rcu;
 };
 
 /* per-network namespace private data for this module */
@@ -120,7 +132,7 @@ struct vxlan_fdb {
 struct vxlan_dev {
 	struct hlist_node hlist;	/* vni hash table */
 	struct list_head  next;		/* vxlan's per namespace list */
-	struct vxlan_sock *vn_sock;	/* listening socket */
+	struct vxlan_handler *vh;
 	struct net_device *dev;
 	struct vxlan_rdst default_dst;	/* default destination */
 	__be32		  saddr;	/* source address */
@@ -193,6 +205,17 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
 	return NULL;
 }
 
+static struct vxlan_dev *vxlan_find_vni_port(struct vxlan_sock *vs, u32 id)
+{
+	struct vxlan_dev *vxlan;
+
+	hlist_for_each_entry_rcu(vxlan, vni_head(vs, id), hlist) {
+		if (vxlan->default_dst.remote_vni == id)
+			return vxlan;
+	}
+
+	return NULL;
+}
 /* Fill in neighbour message in skbuff. */
 static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 			   const struct vxlan_fdb *fdb,
@@ -671,7 +694,7 @@ static int vxlan_join_group(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct sock *sk = vxlan->vn_sock->sock->sk;
+	struct sock *sk = vxlan->vh->vs->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
@@ -699,7 +722,7 @@ static int vxlan_leave_group(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	int err = 0;
-	struct sock *sk = vxlan->vn_sock->sock->sk;
+	struct sock *sk = vxlan->vh->vs->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
@@ -722,23 +745,17 @@ static int vxlan_leave_group(struct net_device *dev)
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct iphdr *oip;
+	struct vxlan_handler *vh;
+	struct vxlan_sock *vs;
 	struct vxlanhdr *vxh;
-	struct vxlan_dev *vxlan;
-	struct pcpu_tstats *stats;
 	__be16 port;
-	__u32 vni;
-	int err;
-
-	/* pop off outer UDP header */
-	__skb_pull(skb, sizeof(struct udphdr));
 
 	/* Need Vxlan and inner Ethernet header to be present */
-	if (!pskb_may_pull(skb, sizeof(struct vxlanhdr)))
+	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		goto error;
 
-	/* Drop packets with reserved bits set */
-	vxh = (struct vxlanhdr *) skb->data;
+	/* Return packets with reserved bits set */
+	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
 	if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
 	    (vxh->vx_vni & htonl(0xff))) {
 		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
@@ -746,28 +763,45 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto error;
 	}
 
-	__skb_pull(skb, sizeof(struct vxlanhdr));
+	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
+		goto drop;
 
-	/* Is this VNI defined? */
-	vni = ntohl(vxh->vx_vni) >> 8;
 	port = inet_sk(sk)->inet_sport;
-	vxlan = vxlan_find_vni(sock_net(sk), vni, port);
-	if (!vxlan) {
-		netdev_dbg(skb->dev, "unknown vni %d port %u\n",
-			   vni, ntohs(port));
-		goto drop;
-	}
 
-	if (!pskb_may_pull(skb, ETH_HLEN)) {
-		vxlan->dev->stats.rx_length_errors++;
-		vxlan->dev->stats.rx_errors++;
+	vs = vxlan_find_port(sock_net(sk), port);
+	if (!vs)
 		goto drop;
+
+	list_for_each_entry_rcu(vh, &vs->handler_list, node) {
+		if (vh->rcv(vh, skb, vxh->vx_vni) == PACKET_RCVD)
+			return 0;
 	}
 
-	skb_reset_mac_header(skb);
+drop:
+	/* Consume bad packet */
+	kfree_skb(skb);
+	return 0;
 
-	/* Re-examine inner Ethernet packet */
-	oip = ip_hdr(skb);
+error:
+	/* Return non vxlan pkt */
+	return 1;
+}
+
+static int vxlan_rcv(struct vxlan_handler *vh, struct sk_buff *skb, __be32 vx_vni)
+{
+	struct iphdr *oip;
+	struct vxlan_dev *vxlan;
+	struct pcpu_tstats *stats;
+	__u32 vni;
+	int err;
+
+	vni = ntohl(vx_vni) >> 8;
+	/* Is this VNI defined? */
+	vxlan = vxlan_find_vni_port(vh->vs, vni);
+	if (!vxlan)
+		return PACKET_REJECT;
+
+	skb_reset_mac_header(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
@@ -775,11 +809,12 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			       vxlan->dev->dev_addr) == 0)
 		goto drop;
 
+	/* Re-examine inner Ethernet packet */
+	oip = ip_hdr(skb);
 	if ((vxlan->flags & VXLAN_F_LEARN) &&
 	    vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source))
 		goto drop;
 
-	__skb_tunnel_rx(skb, vxlan->dev);
 	skb_reset_network_header(skb);
 
 	/* If the NIC driver gave us an encapsulated packet with
@@ -813,16 +848,11 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	netif_rx(skb);
 
-	return 0;
-error:
-	/* Put UDP header back */
-	__skb_push(skb, sizeof(struct udphdr));
-
-	return 1;
+	return PACKET_RCVD;
 drop:
 	/* Consume bad packet */
 	kfree_skb(skb);
-	return 0;
+	return PACKET_RCVD;
 }
 
 static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
@@ -944,7 +974,7 @@ static void vxlan_sock_put(struct sk_buff *skb)
 static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct sock *sk = vxlan->vn_sock->sock->sk;
+	struct sock *sk = vxlan->vh->vs->sock->sk;
 
 	skb_orphan(skb);
 	sock_hold(sk);
@@ -1493,22 +1523,81 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
 
+	INIT_LIST_HEAD(&vs->handler_list);
+
 	/* Mark socket as an encapsulation socket. */
 	udp_sk(sk)->encap_type = 1;
 	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
 	udp_encap_enable();
-
-	vs->refcnt = 1;
 	return vs;
 }
 
+
+static struct vxlan_handler *vxlan_add_handler(struct net *net,
+					       __be16 portno, vxlan_rcv_t *rcv)
+{
+	struct vxlan_handler *vh;
+	struct vxlan_sock *vs;
+
+	ASSERT_RTNL();
+
+	vs = vxlan_find_port(net, portno);
+	if (!vs) {
+		/* Drop lock because socket create acquires RTNL lock */
+		rtnl_unlock();
+		vs = vxlan_socket_create(net, portno);
+		rtnl_lock();
+		if (IS_ERR(vs))
+			return (void *)vs;
+
+		hlist_add_head_rcu(&vs->hlist, vs_head(net, portno));
+	}
+
+	list_for_each_entry_rcu(vh, &vs->handler_list, node) {
+		if (vh->rcv == rcv) {
+			vh->refcnt++;
+			return vh;
+		}
+	}
+
+	vh = kzalloc(sizeof(*vh), GFP_KERNEL);
+	if (!vh)
+		return ERR_PTR(-ENOMEM);
+
+	vh->rcv = rcv;
+	vh->vs = vs;
+	vh->refcnt = 1;
+
+	list_add_rcu(&vh->node, &vs->handler_list);
+	return vh;
+}
+
+static void vxlan_del_handler(struct vxlan_handler *vh)
+{
+	struct vxlan_sock *vs = vh->vs;
+
+	ASSERT_RTNL();
+
+	if (!vs)
+		return;
+
+	if (--vh->refcnt == 0) {
+		list_del_rcu(&vh->node);
+		kfree_rcu(vh, rcu);
+
+		if (list_empty(&vs->handler_list)) {
+			hlist_del_rcu(&vs->hlist);
+			schedule_work(&vs->del_work);
+		}
+	}
+}
+
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
-	struct vxlan_sock *vs;
 	__u32 vni;
 	int err;
 
@@ -1581,43 +1670,20 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_VXLAN_PORT])
 		vxlan->dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
 
-	if (vxlan_find_vni(net, vni, vxlan->dst_port)) {
-		pr_info("duplicate VNI %u\n", vni);
-		return -EEXIST;
-	}
-
-	vs = vxlan_find_port(net, vxlan->dst_port);
-	if (vs)
-		++vs->refcnt;
-	else {
-		/* Drop lock because socket create acquires RTNL lock */
-		rtnl_unlock();
-		vs = vxlan_socket_create(net, vxlan->dst_port);
-		rtnl_lock();
-		if (IS_ERR(vs))
-			return PTR_ERR(vs);
-
-		hlist_add_head_rcu(&vs->hlist, vs_head(net, vxlan->dst_port));
-	}
-	vxlan->vn_sock = vs;
+	vxlan->vh = vxlan_add_handler(net, vxlan->dst_port, vxlan_rcv);
+	if (IS_ERR(vxlan->vh))
+		return PTR_ERR(vxlan->vh);
 
 	SET_ETHTOOL_OPS(dev, &vxlan_ethtool_ops);
 
 	err = register_netdevice(dev);
 	if (err) {
-		if (--vs->refcnt == 0) {
-			hlist_del_rcu(&vs->hlist);
-			rtnl_unlock();
-
-			sk_release_kernel(vs->sock->sk);
-			kfree_rcu(vs, rcu);
-			rtnl_lock();
-		}
+		vxlan_del_handler(vxlan->vh);
 		return err;
 	}
 
 	list_add(&vxlan->next, &vn->vxlan_list);
-	hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
+	hlist_add_head_rcu(&vxlan->hlist, vni_head(vxlan->vh->vs, vni));
 
 	return 0;
 }
@@ -1625,16 +1691,12 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	hlist_del_rcu(&vxlan->hlist);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
 
-	if (--vs->refcnt == 0) {
-		hlist_del_rcu(&vs->hlist);
-		schedule_work(&vs->del_work);
-	}
+	vxlan_del_handler(vxlan->vh);
 }
 
 static size_t vxlan_get_size(const struct net_device *dev)
-- 
1.7.1
