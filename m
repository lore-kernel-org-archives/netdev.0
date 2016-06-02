From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] net: vrf: ipv6 support for local traffic to local addresses
Date: Thu,  2 Jun 2016 13:15:12 -0700
Message-ID: <1464898512-5157-4-git-send-email-dsa@cumulusnetworks.com>
References: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35666 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932633AbcFBUQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 16:16:44 -0400
Received: by mail-pf0-f171.google.com with SMTP id g64so35124466pfb.2
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 13:16:44 -0700 (PDT)
In-Reply-To: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for locally originated traffic to VRF-local IPv6 addresses.
Similar to IPv4 a local dst is set on the skb and the packet is
reinserted with a call to netif_rx. With this patch, ping, tcp and udp
packets to a local IPv6 address are successfully routed:

    $ ip addr show dev eth1
    4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master red state UP group default qlen 1000
        link/ether 02:e0:f9:1c:b9:74 brd ff:ff:ff:ff:ff:ff
        inet 10.100.1.1/24 brd 10.100.1.255 scope global eth1
           valid_lft forever preferred_lft forever
        inet6 2100:1::1/120 scope global
           valid_lft forever preferred_lft forever
        inet6 fe80::e0:f9ff:fe1c:b974/64 scope link
           valid_lft forever preferred_lft forever

    $ ping6 -c1 -I red 2100:1::1
    ping6: Warning: source address might be selected on device other than red.
    PING 2100:1::1(2100:1::1) from 2100:1::1 red: 56 data bytes
    64 bytes from 2100:1::1: icmp_seq=1 ttl=64 time=0.098 ms

ip6_input is exported so the VRF driver can use it for the dst input
function. The dst_alloc function for IPv4 defaults to setting the input and
output functions; IPv6's does not. VRF does not need to duplicate the Rx path
so just export the ipv6 input function.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 85 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 7df065456893..a0ca158f6ad9 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -52,6 +52,7 @@ struct net_vrf {
 	struct rtable __rcu	*rth;
 	struct rtable __rcu	*rth_local;
 	struct rt6_info	__rcu	*rt6;
+	struct rt6_info	__rcu	*rt6_local;
 	u32                     tb_id;
 };
 
@@ -163,6 +164,46 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 		goto err;
 
 	skb_dst_drop(skb);
+
+	/* if dst.dev is loopback or the VRF device again this is locally
+	 * originated traffic destined to a local address. Short circuit
+	 * to Rx path using our local dst
+	 */
+	if (dst->dev == net->loopback_dev || dst->dev == dev) {
+		struct net_vrf *vrf = netdev_priv(dev);
+		struct rt6_info *rt6_local;
+
+		/* release looked up dst and use cached local dst */
+		dst_release(dst);
+
+		rcu_read_lock();
+
+		rt6_local = rcu_dereference(vrf->rt6_local);
+		if (unlikely(!rt6_local)) {
+			rcu_read_unlock();
+			goto err;
+		}
+
+		/* Ordering issue: cached local dst is created on newlink
+		 * before the IPv6 initialization. Using the local dst
+		 * requires rt6i_idev to be set so make sure it is.
+		 */
+		if (unlikely(!rt6_local->rt6i_idev)) {
+			rt6_local->rt6i_idev = in6_dev_get(dev);
+			if (!rt6_local->rt6i_idev) {
+				rcu_read_unlock();
+				goto err;
+			}
+		}
+
+		dst = &rt6_local->dst;
+		dst_hold(dst);
+
+		rcu_read_unlock();
+
+		return vrf_local_xmit(skb, dev, &rt6_local->dst);
+	}
+
 	skb_dst_set(skb, dst);
 
 	/* strip the ethernet header added for pass through VRF device */
@@ -342,27 +383,38 @@ static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
 static void vrf_rt6_release(struct net_vrf *vrf)
 {
 	struct rt6_info *rt6 = rtnl_dereference(vrf->rt6);
+	struct rt6_info *rt6_local = rtnl_dereference(vrf->rt6_local);
 
-	rcu_assign_pointer(vrf->rt6, NULL);
+	RCU_INIT_POINTER(vrf->rt6, NULL);
+	RCU_INIT_POINTER(vrf->rt6_local, NULL);
+	synchronize_rcu();
 
 	if (rt6)
 		dst_release(&rt6->dst);
+
+	if (rt6_local) {
+		if (rt6_local->rt6i_idev)
+			in6_dev_put(rt6_local->rt6i_idev);
+
+		dst_release(&rt6_local->dst);
+	}
 }
 
 static int vrf_rt6_create(struct net_device *dev)
 {
+	int flags = DST_HOST | DST_NOPOLICY | DST_NOXFRM | DST_NOCACHE;
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct fib6_table *rt6i_table;
-	struct rt6_info *rt6;
+	struct rt6_info *rt6, *rt6_local;
 	int rc = -ENOMEM;
 
 	rt6i_table = fib6_new_table(net, vrf->tb_id);
 	if (!rt6i_table)
 		goto out;
 
-	rt6 = ip6_dst_alloc(net, dev,
-			    DST_HOST | DST_NOPOLICY | DST_NOXFRM | DST_NOCACHE);
+	/* create a dst for routing packets out a VRF device */
+	rt6 = ip6_dst_alloc(net, dev, flags);
 	if (!rt6)
 		goto out;
 
@@ -370,7 +422,25 @@ static int vrf_rt6_create(struct net_device *dev)
 
 	rt6->rt6i_table = rt6i_table;
 	rt6->dst.output	= vrf_output6;
+
+	/* create a dst for local routing - packets sent locally
+	 * to local address via the VRF device as a loopback
+	 */
+	rt6_local = ip6_dst_alloc(net, dev, flags);
+	if (!rt6_local) {
+		dst_release(&rt6->dst);
+		goto out;
+	}
+
+	dst_hold(&rt6_local->dst);
+
+	rt6_local->rt6i_idev  = in6_dev_get(dev);
+	rt6_local->rt6i_flags = RTF_UP | RTF_NONEXTHOP | RTF_LOCAL;
+	rt6_local->rt6i_table = rt6i_table;
+	rt6_local->dst.input  = ip6_input;
+
 	rcu_assign_pointer(vrf->rt6, rt6);
+	rcu_assign_pointer(vrf->rt6_local, rt6_local);
 
 	rc = 0;
 out:
@@ -716,6 +786,16 @@ static bool ipv6_ndisc_frame(const struct sk_buff *skb)
 static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 				   struct sk_buff *skb)
 {
+	/* loopback traffic; do not push through packet taps again.
+	 * Reset pkt_type for upper layers to process skb
+	 */
+	if (skb->pkt_type == PACKET_LOOPBACK) {
+		skb->dev = vrf_dev;
+		skb->skb_iif = vrf_dev->ifindex;
+		skb->pkt_type = PACKET_HOST;
+		goto out;
+	}
+
 	/* if packet is NDISC keep the ingress interface */
 	if (!ipv6_ndisc_frame(skb)) {
 		skb->dev = vrf_dev;
@@ -728,6 +808,7 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 		IP6CB(skb)->flags |= IP6SKB_L3SLAVE;
 	}
 
+out:
 	return skb;
 }
 
-- 
2.1.4
