From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] net: vrf: performance improvements for IPv6
Date: Mon, 20 Mar 2017 11:19:45 -0700
Message-ID: <1490033985-14874-3-git-send-email-dsa@cumulusnetworks.com>
References: <1490033985-14874-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35647 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753739AbdCTSTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 14:19:54 -0400
Received: by mail-pf0-f176.google.com with SMTP id 20so21382523pfk.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:19:53 -0700 (PDT)
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

This patch avoids the redirect for IPv6 packets if a qdisc has not
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
sockets, no qdisc) from a +3% improvement for UDP which has a lookup
per packet (VRF being better than no l3mdev) to ~2% loss for TCP_CRR
which connects a socket for each request-response.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 56 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index cdf7253ae89e..4140ff878d63 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -445,18 +445,13 @@ static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
  * packet to go through device based features such as qdisc, netfilter
  * hooks and packet sockets with skb->dev set to vrf device.
  */
-static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
-				   struct sock *sk,
-				   struct sk_buff *skb)
+static struct sk_buff *vrf_ip6_out_redirect(struct net_device *vrf_dev,
+					    struct sk_buff *skb)
 {
 	struct net_vrf *vrf = netdev_priv(vrf_dev);
 	struct dst_entry *dst = NULL;
 	struct rt6_info *rt6;
 
-	/* don't divert link scope packets */
-	if (rt6_need_strict(&ipv6_hdr(skb)->daddr))
-		return skb;
-
 	rcu_read_lock();
 
 	rt6 = rcu_dereference(vrf->rt6);
@@ -478,6 +473,55 @@ static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
 	return skb;
 }
 
+static int vrf_output6_direct(struct net *net, struct sock *sk,
+			      struct sk_buff *skb)
+{
+	skb->protocol = htons(ETH_P_IPV6);
+
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, skb->dev,
+			    vrf_finish_direct,
+			    !(IPCB(skb)->flags & IPSKB_REROUTED));
+}
+
+static struct sk_buff *vrf_ip6_out_direct(struct net_device *vrf_dev,
+					  struct sock *sk,
+					  struct sk_buff *skb)
+{
+	struct net *net = dev_net(vrf_dev);
+	int err;
+
+	skb->dev = vrf_dev;
+
+	err = nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, net, sk,
+		      skb, NULL, vrf_dev, vrf_output6_direct);
+
+	if (likely(err == 1))
+		err = vrf_output6_direct(net, sk, skb);
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
+static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
+				   struct sock *sk,
+				   struct sk_buff *skb)
+{
+	/* don't divert link scope packets */
+	if (rt6_need_strict(&ipv6_hdr(skb)->daddr))
+		return skb;
+
+	if (qdisc_tx_is_default(vrf_dev))
+		return vrf_ip6_out_direct(vrf_dev, sk, skb);
+
+	return vrf_ip6_out_redirect(vrf_dev, skb);
+}
+
 /* holding rtnl */
 static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 {
@@ -1064,9 +1108,11 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 		skb->dev = vrf_dev;
 		skb->skb_iif = vrf_dev->ifindex;
 
-		skb_push(skb, skb->mac_len);
-		dev_queue_xmit_nit(skb, vrf_dev);
-		skb_pull(skb, skb->mac_len);
+		if (!list_empty(&vrf_dev->ptype_all)) {
+			skb_push(skb, skb->mac_len);
+			dev_queue_xmit_nit(skb, vrf_dev);
+			skb_pull(skb, skb->mac_len);
+		}
 
 		IP6CB(skb)->flags |= IP6SKB_L3SLAVE;
 	}
-- 
2.1.4
