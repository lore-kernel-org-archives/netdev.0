From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v7 3/8] vxlan: Add vxlan recv demux.
Date: Mon,  5 Aug 2013 10:47:19 -0700
Message-ID: <1375724839-19427-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:42901 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753516Ab3HERrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 13:47:23 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so3581585pad.19
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 10:47:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once we have ovs-vxlan functionality, one UDP port can be assigned
to kernel-vxlan or ovs-vxlan port.  Therefore following patch adds
vxlan demux functionality, so that vxlan or ovs module can
register for particular port.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v5-v6:
split from second patch from v5 patch series.
---
 drivers/net/vxlan.c |  103 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 67 insertions(+), 36 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1cb55bf..b54953a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -83,8 +83,12 @@ static int vxlan_net_id;
 
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
@@ -200,16 +204,10 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
 	return NULL;
 }
 
-/* Look up VNI in a per net namespace table */
-static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
+static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, u32 id)
 {
-	struct vxlan_sock *vs;
 	struct vxlan_dev *vxlan;
 
-	vs = vxlan_find_sock(net, port);
-	if (!vs)
-		return NULL;
-
 	hlist_for_each_entry_rcu(vxlan, vni_head(vs, id), hlist) {
 		if (vxlan->default_dst.remote_vni == id)
 			return vxlan;
@@ -218,6 +216,18 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
 	return NULL;
 }
 
+/* Look up VNI in a per net namespace table */
+static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
+{
+	struct vxlan_sock *vs;
+
+	vs = vxlan_find_sock(net, port);
+	if (!vs)
+		return NULL;
+
+	return vxlan_vs_find_vni(vs, id);
+}
+
 /* Fill in neighbour message in skbuff. */
 static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 			  const struct vxlan_fdb *fdb,
@@ -861,13 +871,9 @@ static void vxlan_igmp_leave(struct work_struct *work)
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
 
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
@@ -882,24 +888,44 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto error;
 	}
 
-	/* Is this VNI defined? */
-	vni = ntohl(vxh->vx_vni) >> 8;
+	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
+		goto drop;
+
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
 
-	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB))) {
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
+		      struct sk_buff *skb, __be32 vx_vni)
+{
+	struct iphdr *oip;
+	struct vxlan_dev *vxlan;
+	struct pcpu_tstats *stats;
+	__u32 vni;
+	int err;
+
+	vni = ntohl(vx_vni) >> 8;
+	/* Is this VNI defined? */
+	vxlan = vxlan_vs_find_vni(vs, vni);
+	if (!vxlan)
 		goto drop;
-	}
 
 	skb_reset_mac_header(skb);
-
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
@@ -946,13 +972,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	netif_rx(skb);
 
-	return 0;
-error:
-	return 1;
+	return;
 drop:
 	/* Consume bad packet */
 	kfree_skb(skb);
-	return 0;
 }
 
 static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
@@ -1629,7 +1652,8 @@ static void vxlan_del_work(struct work_struct *work)
 	kfree_rcu(vs, rcu);
 }
 
-static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
+static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
+					      vxlan_rcv_t *rcv)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
@@ -1675,6 +1699,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 		return ERR_PTR(rc);
 	}
 	atomic_set(&vs->refcnt, 1);
+	vs->rcv = rcv;
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
@@ -1689,23 +1714,29 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	return vs;
 }
 
-static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port)
+static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+					 vxlan_rcv_t *rcv)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
-	vs = vxlan_socket_create(net, port);
+	vs = vxlan_socket_create(net, port, rcv);
 	if (!IS_ERR(vs))
 		return vs;
 
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
 
@@ -1718,7 +1749,7 @@ static void vxlan_sock_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_sock *nvs;
 
-	nvs = vxlan_sock_add(net, port);
+	nvs = vxlan_sock_add(net, port, vxlan_rcv);
 	spin_lock(&vn->sock_lock);
 	if (!IS_ERR(nvs))
 		vxlan_vs_add_dev(nvs, vxlan);
-- 
1.7.1
