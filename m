From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V4 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 14 Jan 2014 18:00:12 +0200
Message-ID: <1389715212-14504-4-git-send-email-ogerlitz@mellanox.com>
References: <1389715212-14504-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, hkchu@google.com, edumazet@google.com,
	herbert@gondor.apana.org.au, yanb@mellanox.com,
	shlomop@mellanox.com, therbert@google.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42348 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751550AbaANQDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 11:03:17 -0500
In-Reply-To: <1389715212-14504-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add GRO handlers for vxlann, by using the UDP GRO infrastructure.

For single TCP session that goes through vxlan tunneling I got nice
improvement from 6.8Gbs to 11.5Gbs

--> UDP/VXLAN GRO disabled
$ netperf  -H 192.168.52.147 -c -C

$ netperf -t TCP_STREAM -H 192.168.52.147 -c -C
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.52.147 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  65536  65536    10.00      6799.75   12.54    24.79    0.604   1.195

--> UDP/VXLAN GRO enabled

$ netperf -t TCP_STREAM -H 192.168.52.147 -c -C
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.52.147 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  65536  65536    10.00      11562.72   24.90    20.34    0.706   0.577

Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/vxlan.c |  117 +++++++++++++++++++++++++++++++++++++++++++++++---
 include/net/vxlan.h |    1 +
 2 files changed, 111 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 481f85d..27a25ce 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -40,6 +40,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/vxlan.h>
+#include <net/protocol.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -554,13 +555,106 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	return 1;
 }
 
+static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct sk_buff *p, **pp = NULL;
+	struct vxlanhdr *vh, *vh2;
+	struct ethhdr *eh, *eh2;
+	unsigned int hlen, off_vx, off_eth;
+	const struct packet_offload *ptype;
+	__be16 type;
+	int flush = 1;
+
+	off_vx = skb_gro_offset(skb);
+	hlen = off_vx + sizeof(*vh);
+	vh   = skb_gro_header_fast(skb, off_vx);
+	if (skb_gro_header_hard(skb, hlen)) {
+		vh = skb_gro_header_slow(skb, hlen, off_vx);
+		if (unlikely(!vh))
+			goto out;
+	}
+	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
+
+	off_eth = skb_gro_offset(skb);
+	hlen = off_eth + sizeof(*eh);
+	eh   = skb_gro_header_fast(skb, off_eth);
+	if (skb_gro_header_hard(skb, hlen)) {
+		eh = skb_gro_header_slow(skb, hlen, off_eth);
+		if (unlikely(!eh))
+			goto out;
+	}
+
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		vh2 = (struct vxlanhdr *)(p->data + off_vx);
+		eh2 = (struct ethhdr   *)(p->data + off_eth);
+		if (vh->vx_vni != vh2->vx_vni || compare_ether_header(eh, eh2)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+		goto found;
+	}
+
+found:
+	type = eh->h_proto;
+
+	rcu_read_lock();
+	ptype = gro_find_receive_by_type(type);
+	if (ptype == NULL) {
+		flush = 1;
+		goto out_unlock;
+	}
+
+	skb_gro_pull(skb, sizeof(*eh)); /* pull inner eth header */
+	pp = ptype->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct ethhdr *eh;
+	struct packet_offload *ptype;
+	__be16 type;
+	int vxlan_len  = sizeof(struct vxlanhdr) + sizeof(struct ethhdr);
+	int err = -ENOSYS;
+
+	eh = (struct ethhdr *)(skb->data + nhoff + sizeof(struct vxlanhdr));
+	type = eh->h_proto;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype != NULL)
+		err = ptype->callbacks.gro_complete(skb, nhoff + vxlan_len);
+
+	rcu_read_unlock();
+	return err;
+}
+
 /* Notify netdevs that UDP port started listening */
-static void vxlan_notify_add_rx_port(struct sock *sk)
+static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 {
 	struct net_device *dev;
+	struct sock *sk = vs->sock->sk;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
+	int err;
+
+	if (sa_family == AF_INET) {
+		err = udp_add_offload(&vs->udp_offloads);
+		if (err)
+			pr_warn("vxlan: udp_add_offload failed with status %d\n", err);
+	}
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
@@ -572,9 +666,10 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
 }
 
 /* Notify netdevs that UDP port is no more listening */
-static void vxlan_notify_del_rx_port(struct sock *sk)
+static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 {
 	struct net_device *dev;
+	struct sock *sk = vs->sock->sk;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
@@ -586,6 +681,9 @@ static void vxlan_notify_del_rx_port(struct sock *sk)
 							    port);
 	}
 	rcu_read_unlock();
+
+	if (sa_family == AF_INET)
+		udp_del_offload(&vs->udp_offloads);
 }
 
 /* Add new entry to forwarding table -- assumes lock held */
@@ -964,7 +1062,7 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
 	rcu_assign_sk_user_data(vs->sock->sk, NULL);
-	vxlan_notify_del_rx_port(sk);
+	vxlan_notify_del_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
 	queue_work(vxlan_wq, &vs->del_work);
@@ -1125,8 +1223,8 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 	 * leave the CHECKSUM_UNNECESSARY, the device checksummed it
 	 * for us. Otherwise force the upper layers to verify it.
 	 */
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY || !skb->encapsulation ||
-	    !(vxlan->dev->features & NETIF_F_RXCSUM))
+	if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||
+	    !skb->encapsulation || !(vxlan->dev->features & NETIF_F_RXCSUM))
 		skb->ip_summed = CHECKSUM_NONE;
 
 	skb->encapsulation = 0;
@@ -2304,7 +2402,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	struct sock *sk;
 	unsigned int h;
 
-	vs = kmalloc(sizeof(*vs), GFP_KERNEL);
+	vs = kzalloc(sizeof(*vs), GFP_KERNEL);
 	if (!vs)
 		return ERR_PTR(-ENOMEM);
 
@@ -2329,9 +2427,14 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	vs->data = data;
 	rcu_assign_sk_user_data(vs->sock->sk, vs);
 
+	/* Initialize the vxlan udp offloads structure */
+	vs->udp_offloads.port = port;
+	vs->udp_offloads.callbacks.gro_receive  = vxlan_gro_receive;
+	vs->udp_offloads.callbacks.gro_complete = vxlan_gro_complete;
+
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
-	vxlan_notify_add_rx_port(sk);
+	vxlan_notify_add_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
 	/* Mark socket as an encapsulation socket. */
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 6b6d180..5deef1a 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -21,6 +21,7 @@ struct vxlan_sock {
 	struct rcu_head	  rcu;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
+	struct udp_offload udp_offloads;
 };
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-- 
1.7.1
