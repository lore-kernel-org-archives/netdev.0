From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/2] net: vrf: performance improvements for IPv4
Date: Mon, 20 Mar 2017 11:19:44 -0700
Message-ID: <1490033985-14874-2-git-send-email-dsa@cumulusnetworks.com>
References: <1490033985-14874-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36772 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756115AbdCTSUD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 14:20:03 -0400
Received: by mail-pf0-f170.google.com with SMTP id o126so69271251pfb.3
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:19:58 -0700 (PDT)
In-Reply-To: <1490033985-14874-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VRF driver allows users to implement device based features for an
entire domain. For example, a qdisc or netfilter rules can be attached
to a VRF device or tcpdump can be used to view packets for all devices
in the L3 domain.

The device-based features come with a performance penalty, most
notably in the Tx path. The VRF driver uses the l3mdev_l3_out hook
to switch the dst on an skb to its private dst. This allows the skb
to traverse the xmit stack with the device set to the VRF device
which in turn enables the netfilter and qdisc features. The VRF
driver then performs the FIB lookup again and reinserts the packet.

This patch avoids the redirect for IPv4 packets if a qdisc has not
been attached to a VRF device which is the default config. In this
case the netfilter hooks and network taps are directly traversed in
the l3mdev_l3_out handler. If a qdisc is attached to a VRF device,
then the redirect using the vrf dst is done.

Additional overhead is removed by only checking packet taps if a
socket is open on the device (vrf_dev->ptype_all list is not empty).
Packet sockets bound to any device will still get a copy of the
packet via the real ingress or egress interface.

The end result of this change is a decrease in the overhead of VRF
for the default, baseline case (ie., no netfilter rules, no packet
sockets, no qdisc) to ~3% for UDP which has a lookup per packet and
< 1% overhead for connected sockets that leverage early demux and
avoid FIB lookups.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 106 ++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 96 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 7f28021d9d93..cdf7253ae89e 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -104,6 +104,23 @@ static void vrf_get_stats64(struct net_device *dev,
 	}
 }
 
+/* by default VRF devices do not have a qdisc and are expected
+ * to be created with only a single queue.
+ */
+static bool qdisc_tx_is_default(const struct net_device *dev)
+{
+	struct netdev_queue *txq;
+	struct Qdisc *qdisc;
+
+	if (dev->num_tx_queues > 1)
+		return false;
+
+	txq = netdev_get_tx_queue(dev, 0);
+	qdisc = rcu_access_pointer(txq->qdisc);
+
+	return !qdisc->enqueue;
+}
+
 /* Local traffic destined to local address. Reinsert the packet to rx
  * path, similar to loopback handling.
  */
@@ -357,6 +374,29 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
+static int vrf_finish_direct(struct net *net, struct sock *sk,
+			     struct sk_buff *skb)
+{
+	struct net_device *vrf_dev = skb->dev;
+
+	if (!list_empty(&vrf_dev->ptype_all) &&
+	    likely(skb_headroom(skb) >= ETH_HLEN)) {
+		struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+
+		ether_addr_copy(eth->h_source, vrf_dev->dev_addr);
+		eth_zero_addr(eth->h_dest);
+		eth->h_proto = skb->protocol;
+
+		rcu_read_lock_bh();
+		dev_queue_xmit_nit(skb, vrf_dev);
+		rcu_read_unlock_bh();
+
+		skb_pull(skb, ETH_HLEN);
+	}
+
+	return 1;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 /* modelled after ip6_finish_output2 */
 static int vrf_finish_output6(struct net *net, struct sock *sk,
@@ -607,18 +647,13 @@ static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
  * packet to go through device based features such as qdisc, netfilter
  * hooks and packet sockets with skb->dev set to vrf device.
  */
-static struct sk_buff *vrf_ip_out(struct net_device *vrf_dev,
-				  struct sock *sk,
-				  struct sk_buff *skb)
+static struct sk_buff *vrf_ip_out_redirect(struct net_device *vrf_dev,
+					   struct sk_buff *skb)
 {
 	struct net_vrf *vrf = netdev_priv(vrf_dev);
 	struct dst_entry *dst = NULL;
 	struct rtable *rth;
 
-	/* don't divert multicast */
-	if (ipv4_is_multicast(ip_hdr(skb)->daddr))
-		return skb;
-
 	rcu_read_lock();
 
 	rth = rcu_dereference(vrf->rth);
@@ -640,6 +675,55 @@ static struct sk_buff *vrf_ip_out(struct net_device *vrf_dev,
 	return skb;
 }
 
+static int vrf_output_direct(struct net *net, struct sock *sk,
+			     struct sk_buff *skb)
+{
+	skb->protocol = htons(ETH_P_IP);
+
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, skb->dev,
+			    vrf_finish_direct,
+			    !(IPCB(skb)->flags & IPSKB_REROUTED));
+}
+
+static struct sk_buff *vrf_ip_out_direct(struct net_device *vrf_dev,
+					 struct sock *sk,
+					 struct sk_buff *skb)
+{
+	struct net *net = dev_net(vrf_dev);
+	int err;
+
+	skb->dev = vrf_dev;
+
+	err = nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT, net, sk,
+		      skb, NULL, vrf_dev, vrf_output_direct);
+
+	if (likely(err == 1))
+		err = vrf_output_direct(net, sk, skb);
+
+	/* reset skb device */
+	if (likely(err == 1))
+		nf_reset(skb);
+	else
+		skb = NULL;
+
+	return skb;
+}
+
+static struct sk_buff *vrf_ip_out(struct net_device *vrf_dev,
+				  struct sock *sk,
+				  struct sk_buff *skb)
+{
+	/* don't divert multicast */
+	if (ipv4_is_multicast(ip_hdr(skb)->daddr))
+		return skb;
+
+	if (qdisc_tx_is_default(vrf_dev))
+		return vrf_ip_out_direct(vrf_dev, sk, skb);
+
+	return vrf_ip_out_redirect(vrf_dev, skb);
+}
+
 /* called with rcu lock held */
 static struct sk_buff *vrf_l3_out(struct net_device *vrf_dev,
 				  struct sock *sk,
@@ -1023,9 +1107,11 @@ static struct sk_buff *vrf_ip_rcv(struct net_device *vrf_dev,
 
 	vrf_rx_stats(vrf_dev, skb->len);
 
-	skb_push(skb, skb->mac_len);
-	dev_queue_xmit_nit(skb, vrf_dev);
-	skb_pull(skb, skb->mac_len);
+	if (!list_empty(&vrf_dev->ptype_all)) {
+		skb_push(skb, skb->mac_len);
+		dev_queue_xmit_nit(skb, vrf_dev);
+		skb_pull(skb, skb->mac_len);
+	}
 
 	skb = vrf_rcv_nfhook(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, vrf_dev);
 out:
-- 
2.1.4
