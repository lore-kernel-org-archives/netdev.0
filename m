From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] net: vrf: ipv4 support for local traffic to local addresses
Date: Thu,  2 Jun 2016 13:15:11 -0700
Message-ID: <1464898512-5157-3-git-send-email-dsa@cumulusnetworks.com>
References: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33763 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932220AbcFBUQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 16:16:43 -0400
Received: by mail-pf0-f174.google.com with SMTP id b124so35100083pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 13:16:43 -0700 (PDT)
In-Reply-To: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for locally originated traffic to VRF-local addresses. If
destination device for an skb is the loopback or VRF device then set
its dst to a local version of the VRF cached dst_entry and call netif_rx
to insert the packet onto the rx queue - similar to what is done for
loopback. This patch handles IPv4 support; follow on patch handles IPv6.

With this patch, ping, tcp and udp packets to a local IPv4 address are
successfully routed:

    $ ip addr show dev eth1
    4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master red state UP group default qlen 1000
        link/ether 02:e0:f9:1c:b9:74 brd ff:ff:ff:ff:ff:ff
        inet 10.100.1.1/24 brd 10.100.1.255 scope global eth1
           valid_lft forever preferred_lft forever
        inet6 2100:1::1/120 scope global
           valid_lft forever preferred_lft forever
        inet6 fe80::e0:f9ff:fe1c:b974/64 scope link
           valid_lft forever preferred_lft forever

    $ ping -c1 -I red 10.100.1.1
    ping: Warning: source address might be selected on device other than red.
    PING 10.100.1.1 (10.100.1.1) from 10.100.1.1 red: 56(84) bytes of data.
    64 bytes from 10.100.1.1: icmp_seq=1 ttl=64 time=0.057 ms

This patch also enables use of IPv4 loopback address on the VRF device:
    $ ip addr add dev red 127.0.0.1/8

    $ ping -c1 -I red 127.0.0.1
    PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 red: 56(84) bytes of data.
    64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.058 ms

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 100 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 98 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index d678aaeba572..7df065456893 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -50,6 +50,7 @@ module_param(rule_pref, uint,  S_IRUGO);
 
 struct net_vrf {
 	struct rtable __rcu	*rth;
+	struct rtable __rcu	*rth_local;
 	struct rt6_info	__rcu	*rt6;
 	u32                     tb_id;
 };
@@ -60,9 +61,20 @@ struct pcpu_dstats {
 	u64			tx_drps;
 	u64			rx_pkts;
 	u64			rx_bytes;
+	u64			rx_drps;
 	struct u64_stats_sync	syncp;
 };
 
+static void vrf_rx_stats(struct net_device *dev, int len)
+{
+	struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
+
+	u64_stats_update_begin(&dstats->syncp);
+	dstats->rx_pkts++;
+	dstats->rx_bytes += len;
+	u64_stats_update_end(&dstats->syncp);
+}
+
 static void vrf_tx_error(struct net_device *vrf_dev, struct sk_buff *skb)
 {
 	vrf_dev->stats.tx_errors++;
@@ -97,6 +109,34 @@ static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
 	return stats;
 }
 
+/* Local traffic destined to local address. Reinsert the packet to rx
+ * path, similar to loopback handling.
+ */
+static int vrf_local_xmit(struct sk_buff *skb, struct net_device *dev,
+			  struct dst_entry *dst)
+{
+	int len = skb->len;
+
+	skb_orphan(skb);
+
+	skb_dst_set(skb, dst);
+	skb_dst_force(skb);
+
+	/* set pkt_type to avoid skb hitting packet taps twice -
+	 * once on Tx and again in Rx processing
+	 */
+	skb->pkt_type = PACKET_LOOPBACK;
+
+	skb->protocol = eth_type_trans(skb, dev);
+
+	if (likely(netif_rx(skb) == NET_RX_SUCCESS))
+		vrf_rx_stats(dev, len);
+	else
+		this_cpu_inc(dev->dstats->rx_drps);
+
+	return NETDEV_TX_OK;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 					   struct net_device *dev)
@@ -175,6 +215,34 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 	}
 
 	skb_dst_drop(skb);
+
+	/* if dst.dev is loopback or the VRF device again this is locally
+	 * originated traffic destined to a local address. Short circuit
+	 * to Rx path using our local dst
+	 */
+	if (rt->dst.dev == net->loopback_dev || rt->dst.dev == vrf_dev) {
+		struct net_vrf *vrf = netdev_priv(vrf_dev);
+		struct rtable *rth_local;
+		struct dst_entry *dst = NULL;
+
+		ip_rt_put(rt);
+
+		rcu_read_lock();
+
+		rth_local = rcu_dereference(vrf->rth_local);
+		if (likely(rth_local)) {
+			dst = &rth_local->dst;
+			dst_hold(dst);
+		}
+
+		rcu_read_unlock();
+
+		if (unlikely(!dst))
+			goto err;
+
+		return vrf_local_xmit(skb, vrf_dev, dst);
+	}
+
 	skb_dst_set(skb, &rt->dst);
 
 	/* strip the ethernet header added for pass through VRF device */
@@ -381,29 +449,48 @@ static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 static void vrf_rtable_release(struct net_vrf *vrf)
 {
 	struct rtable *rth = rtnl_dereference(vrf->rth);
+	struct rtable *rth_local = rtnl_dereference(vrf->rth_local);
 
-	rcu_assign_pointer(vrf->rth, NULL);
+	RCU_INIT_POINTER(vrf->rth, NULL);
+	RCU_INIT_POINTER(vrf->rth_local, NULL);
+	synchronize_rcu();
 
 	if (rth)
 		dst_release(&rth->dst);
+
+	if (rth_local)
+		dst_release(&rth_local->dst);
 }
 
 static int vrf_rtable_create(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	struct rtable *rth;
+	struct rtable *rth, *rth_local;
 
 	if (!fib_new_table(dev_net(dev), vrf->tb_id))
 		return -ENOMEM;
 
+	/* create a dst for routing packets out through a VRF device */
 	rth = rt_dst_alloc(dev, 0, RTN_UNICAST, 1, 1, 0);
 	if (!rth)
 		return -ENOMEM;
 
+	/* create a dst for local ingress routing - packets sent locally
+	 * to local address via the VRF device as a loopback
+	 */
+	rth_local = rt_dst_alloc(dev, RTCF_LOCAL, RTN_LOCAL, 1, 1, 0);
+	if (!rth_local) {
+		dst_release(&rth->dst);
+		return -ENOMEM;
+	}
+
 	rth->dst.output	= vrf_output;
 	rth->rt_table_id = vrf->tb_id;
 
+	rth_local->rt_table_id = vrf->tb_id;
+
 	rcu_assign_pointer(vrf->rth, rth);
+	rcu_assign_pointer(vrf->rth_local, rth_local);
 
 	return 0;
 }
@@ -658,10 +745,19 @@ static struct sk_buff *vrf_ip_rcv(struct net_device *vrf_dev,
 	skb->dev = vrf_dev;
 	skb->skb_iif = vrf_dev->ifindex;
 
+	/* loopback traffic; do not push through packet taps again.
+	 * Reset pkt_type for upper layers to process skb
+	 */
+	if (skb->pkt_type == PACKET_LOOPBACK) {
+		skb->pkt_type = PACKET_HOST;
+		goto out;
+	}
+
 	skb_push(skb, skb->mac_len);
 	dev_queue_xmit_nit(skb, vrf_dev);
 	skb_pull(skb, skb->mac_len);
 
+out:
 	return skb;
 }
 
-- 
2.1.4
