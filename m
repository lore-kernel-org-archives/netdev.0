From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/2] vxlan: Use UDP fast port
Date: Sat, 26 Jul 2014 15:29:29 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407261520350.27340@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:62214 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbaGZW3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 18:29:30 -0400
Received: by mail-oa0-f74.google.com with SMTP id eb12so1663929oac.1
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2014 15:29:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change to have vxlan register ports with UDP fast port to improve
RX performance.

Performance test: using 200 TCP_RR netperf streams

Without UFP
  94.57 CPU utilization
  153/245/455 90/95/995% latencies
  1.18699e+06 tps

With UFP enabled
  94.58 CPU utilization
  147/230/408 90/95/995% latencies
  1.20311e+06 tps

Also tested UDP_RR wihtout encapsulation, did not observe any
noticeable regression in normal UDP path.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c | 38 +++++++++++++++++++++++++++++++-------
 include/net/vxlan.h |  2 ++
 2 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d3f3e5d..e36eef7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1060,6 +1060,8 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 	if (!atomic_dec_and_test(&vs->refcnt))
 		return;
 
+	udp_remove_fast_port(&vs->udp_fast_port);
+
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
 	rcu_assign_sk_user_data(vs->sock->sk, NULL);
@@ -1132,10 +1134,8 @@ static void vxlan_igmp_leave(struct work_struct *work)
 	dev_put(vxlan->dev);
 }
 
-/* Callback from net/ipv4/udp.c to receive packets */
-static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
+static int __vxlan_encap_recv(struct vxlan_sock *vs, struct sk_buff *skb)
 {
-	struct vxlan_sock *vs;
 	struct vxlanhdr *vxh;
 
 	/* Need Vxlan and inner Ethernet header to be present */
@@ -1154,10 +1154,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
 
-	vs = rcu_dereference_sk_user_data(sk);
-	if (!vs)
-		goto drop;
-
 	skb_pop_rcv_encapsulation(skb);
 
 	vs->rcv(vs, skb, vxh->vx_vni);
@@ -1173,6 +1169,30 @@ error:
 	return 1;
 }
 
+/* Callback from net/ipv4/udp.c to receive packets */
+static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct vxlan_sock *vs;
+
+	vs = rcu_dereference_sk_user_data(sk);
+	if (!vs) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	return __vxlan_encap_recv(vs, skb);
+}
+
+static int vxlan_udp_fast_port_recv(struct udp_fast_port *ufp,
+				    struct sk_buff *skb)
+{
+	struct vxlan_sock *vs;
+
+	vs = container_of(ufp, struct vxlan_sock, udp_fast_port);
+
+	return __vxlan_encap_recv(vs, skb);
+}
+
 static void vxlan_rcv(struct vxlan_sock *vs,
 		      struct sk_buff *skb, __be32 vx_vni)
 {
@@ -2429,6 +2449,10 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 #endif
 		udp_encap_enable();
 
+	vs->udp_fast_port.port = port;
+	vs->udp_fast_port.encap_rcv = vxlan_udp_fast_port_recv;
+	udp_add_fast_port(&vs->udp_fast_port);
+
 	return vs;
 }
 
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index d5f59f3..1f95ecd 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -4,6 +4,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/udp.h>
+#include <net/udp.h>
 
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
@@ -22,6 +23,7 @@ struct vxlan_sock {
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
 	struct udp_offload udp_offloads;
+	struct udp_fast_port udp_fast_port;
 };
 
 #define VXLAN_F_LEARN			0x01
-- 
2.0.0.526.g5318336
