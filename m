From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v5 2/7] vxlan: Restructure vxlan receive for multiple protocols.
Date: Wed, 31 Jul 2013 16:14:29 -0700
Message-ID: <1375312469-18623-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:41544 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751075Ab3GaXOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 19:14:32 -0400
Received: by mail-pd0-f171.google.com with SMTP id bv13so1108461pdb.16
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 16:14:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once we have ovs-vxlan functionality, one UDP port can be assigned
to kernel-vxlan or ovs-vxlan port.  Therefore following patch adds
vxlan demux functionality, so that vxlan or ovs module can
register for particular port.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |  113 ++++++++++++++++++++++++++++++++-------------------
 1 files changed, 71 insertions(+), 42 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 279c7dc..8efee59 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -57,6 +57,7 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
+#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
@@ -82,8 +83,12 @@ static int vxlan_net_id;
 
 static const u8 all_zeros_mac[ETH_ALEN];
 
+struct vxlan_sock;
+typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
+
 /* per UDP socket information */
 struct vxlan_sock {
+	vxlan_rcv_t	 *rcv;
 	struct hlist_node hlist;
 	struct rcu_head	  rcu;
 	struct work_struct del_work;
@@ -211,6 +216,18 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
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
@@ -836,23 +853,16 @@ static void vxlan_igmp_work(struct work_struct *work)
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct iphdr *oip;
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
@@ -860,28 +870,44 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
+
+	vs = vxlan_find_sock(sock_net(sk), port);
+	if (!vs)
 		goto drop;
-	}
 
-	if (!pskb_may_pull(skb, ETH_HLEN)) {
-		vxlan->dev->stats.rx_length_errors++;
-		vxlan->dev->stats.rx_errors++;
+	vs->rcv(vs, skb, vxh->vx_vni);
+	return 0;
+
+drop:
+	/* Consume bad packet */
+	kfree_skb(skb);
+	return 0;
+
+error:
+	/* Return non vxlan pkt */
+	return 1;
+}
+
+static void vxlan_rcv(struct vxlan_sock *vs,
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
+	vxlan = vxlan_find_vni_port(vs, vni);
+	if (!vxlan)
 		goto drop;
-	}
 
 	skb_reset_mac_header(skb);
-
-	/* Re-examine inner Ethernet packet */
-	oip = ip_hdr(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
@@ -889,11 +915,12 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
@@ -927,16 +954,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	netif_rx(skb);
 
-	return 0;
-error:
-	/* Put UDP header back */
-	__skb_push(skb, sizeof(struct udphdr));
-
-	return 1;
+	return;
 drop:
 	/* Consume bad packet */
 	kfree_skb(skb);
-	return 0;
 }
 
 static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
@@ -1608,7 +1629,8 @@ static void vxlan_del_work(struct work_struct *work)
 	kfree_rcu(vs, rcu);
 }
 
-static void vxlan_socket_create(struct net *net, __be16 port)
+static void vxlan_socket_create(struct net *net, __be16 port,
+				vxlan_rcv_t *rcv)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
@@ -1656,6 +1678,7 @@ static void vxlan_socket_create(struct net *net, __be16 port)
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
+	vs->rcv = rcv;
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
 	spin_unlock(&vn->sock_lock);
@@ -1668,21 +1691,27 @@ static void vxlan_socket_create(struct net *net, __be16 port)
 }
 
 /* Scheduled at device creation to bind to a socket */
-static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port)
+static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+					 vxlan_rcv_t *rcv)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
-	vxlan_socket_create(net, port);
+	vxlan_socket_create(net, port, rcv);
 
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(net, port);
-	if (vs)
-		atomic_inc(&vs->refcnt);
-	else
+	if (vs) {
+		if (vs->rcv == rcv)
+			atomic_inc(&vs->refcnt);
+		else
+			vs = ERR_PTR(-EBUSY);
+	}
+	spin_unlock(&vn->sock_lock);
+
+	if (!vs)
 		vs = ERR_PTR(-EINVAL);
 
-	spin_unlock(&vn->sock_lock);
 	return vs;
 }
 
@@ -1694,7 +1723,7 @@ static void vxlan_sock_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_sock *nvs;
 
-	nvs = vxlan_sock_add(net, port);
+	nvs = vxlan_sock_add(net, port, vxlan_rcv);
 	spin_lock(&vn->sock_lock);
 	if (!IS_ERR(nvs))
 		vxlan_vs_add_dev(nvs, vxlan);
-- 
1.7.1
