From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v4 2/7] vxlan: Restructure vxlan receive for multiple protocol handlers.
Date: Fri, 26 Jul 2013 16:14:54 -0700
Message-ID: <1374880494-2922-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:49199 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759964Ab3GZXO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 19:14:57 -0400
Received: by mail-pd0-f170.google.com with SMTP id x11so3422227pdj.15
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 16:14:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once we have ovs-vxlan functionality, one UDP port can be shared
between vxlan and openvswitch module.  Following patch adds this
functionality so that vxlan_handler_add() user can pass its own rcv
handler function.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
split from first patch of version 3.
---
 drivers/net/vxlan.c |  118 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 78 insertions(+), 40 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0bbe2d2..a5692a7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -57,6 +57,7 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
+#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
@@ -91,7 +92,12 @@ struct vxlan_sock {
 	struct list_head  handler_list;
 };
 
+struct vxlan_handler;
+typedef int (vxlan_rcv_t)(struct vxlan_handler *vh,
+			  struct sk_buff *skb, __be32 key);
+
 struct vxlan_handler {
+	vxlan_rcv_t	  *rcv;
 	struct list_head   node;
 	struct vxlan_sock *vs;
 	atomic_t	   refcnt;
@@ -100,7 +106,8 @@ struct vxlan_handler {
 };
 
 static struct vxlan_handler *vs_handler_add(struct vxlan_sock *vs,
-					    __be16 portno);
+					    __be16 portno,
+					    vxlan_rcv_t *rcv);
 static void vxlan_handler_hold(struct vxlan_handler *vh);
 static void vxlan_handler_put(struct vxlan_handler *vh);
 
@@ -224,6 +231,18 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
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
+
 /* Fill in neighbour message in skbuff. */
 static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 			  const struct vxlan_fdb *fdb,
@@ -832,23 +851,17 @@ static void vxlan_igmp_work(struct work_struct *work)
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
@@ -856,28 +869,46 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
+	vs = vxlan_find_sock(sock_net(sk), port);
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
+static int vxlan_rcv(struct vxlan_handler *vh,
+		     struct sk_buff *skb, __be32 vx_vni)
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
@@ -885,11 +916,12 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
@@ -923,16 +955,11 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
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
@@ -1354,7 +1381,7 @@ static int vxlan_init(struct net_device *dev)
 		struct vxlan_handler *vh;
 
 		/* If we have a socket with same port already, reuse it */
-		vh = vs_handler_add(vs, vxlan->dst_port);
+		vh = vs_handler_add(vs, vxlan->dst_port, vxlan_rcv);
 		vxlan_vh_add_dev(vh, vxlan);
 	} else {
 		/* otherwise make new socket outside of RTNL */
@@ -1671,15 +1698,25 @@ static void vh_del_work(struct work_struct *work)
 }
 
 static struct vxlan_handler *vs_handler_add(struct vxlan_sock *vs,
-					    __be16 portno)
+					    __be16 portno,
+					    vxlan_rcv_t *rcv)
 {
 	struct vxlan_handler *vh;
 
+	/* Try existing vxlan hanlders for this socket. */
+	list_for_each_entry(vh, &vs->handler_list, node) {
+		if (vh->rcv == rcv) {
+			atomic_inc(&vh->refcnt);
+			return vh;
+		}
+	}
+
 	vh = kzalloc(sizeof(*vh), GFP_KERNEL);
 	if (!vh) {
 		vxlan_socket_del(vs);
 		return ERR_PTR(-ENOMEM);
 	}
+	vh->rcv = rcv;
 	vh->vs = vs;
 	atomic_set(&vh->refcnt, 1);
 	INIT_WORK(&vh->del_work, vh_del_work);
@@ -1688,7 +1725,8 @@ static struct vxlan_handler *vs_handler_add(struct vxlan_sock *vs,
 	return vh;
 }
 
-static struct vxlan_handler *vxlan_handler_add(struct net *net, __be16 portno)
+static struct vxlan_handler *vxlan_handler_add(struct net *net,
+					       __be16 portno, vxlan_rcv_t *rcv)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_handler *vh;
@@ -1705,7 +1743,7 @@ static struct vxlan_handler *vxlan_handler_add(struct net *net, __be16 portno)
 		vh = ERR_PTR(-ENOENT);
 		goto out;
 	}
-	vh = vs_handler_add(vs, portno);
+	vh = vs_handler_add(vs, portno, rcv);
 
 out:
 	mutex_unlock(&vn->sock_lock);
@@ -1747,7 +1785,7 @@ static void vxlan_handler_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_handler *vh = NULL;
 
-	vh = vxlan_handler_add(net, port);
+	vh = vxlan_handler_add(net, port, vxlan_rcv);
 	vxlan_vh_add_dev(vh, vxlan);
 	dev_put(dev);
 }
-- 
1.7.1
