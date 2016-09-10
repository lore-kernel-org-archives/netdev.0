From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 04/11] net: vrf: Flip IPv4 output path from FIB lookup hook to out hook
Date: Sat, 10 Sep 2016 12:09:55 -0700
Message-ID: <1473534602-23602-5-git-send-email-dsa@cumulusnetworks.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34105 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753229AbcIJTL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:11:29 -0400
Received: by mail-pa0-f42.google.com with SMTP id to9so38543782pac.1
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:11:29 -0700 (PDT)
In-Reply-To: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flip the IPv4 output path to use the l3mdev tx out hook. The VRF dst
is not returned on the first FIB lookup. Instead, the dst on the
skb is switched at the beginning of the IPv4 output processing to
send the packet to the VRF driver on xmit.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/route.c  |  4 ----
 2 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 1ce7420322ee..08540b96ec18 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -227,6 +227,20 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 }
 #endif
 
+/* based on ip_local_out; can't use it b/c the dst is switched pointing to us */
+static int vrf_ip_local_out(struct net *net, struct sock *sk,
+			    struct sk_buff *skb)
+{
+	int err;
+
+	err = nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT, net, sk,
+		      skb, NULL, skb_dst(skb)->dev, dst_output);
+	if (likely(err == 1))
+		err = dst_output(net, sk, skb);
+
+	return err;
+}
+
 static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 					   struct net_device *vrf_dev)
 {
@@ -292,7 +306,7 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 					       RT_SCOPE_LINK);
 	}
 
-	ret = ip_local_out(dev_net(skb_dst(skb)->dev), skb->sk, skb);
+	ret = vrf_ip_local_out(dev_net(skb_dst(skb)->dev), skb->sk, skb);
 	if (unlikely(net_xmit_eval(ret)))
 		vrf_dev->stats.tx_errors++;
 	else
@@ -531,6 +545,53 @@ static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
+/* set dst on skb to send packet to us via dev_xmit path. Allows
+ * packet to go through device based features such as qdisc, netfilter
+ * hooks and packet sockets with skb->dev set to vrf device.
+ */
+static struct sk_buff *vrf_ip_out(struct net_device *vrf_dev,
+				  struct sock *sk,
+				  struct sk_buff *skb)
+{
+	struct net_vrf *vrf = netdev_priv(vrf_dev);
+	struct dst_entry *dst = NULL;
+	struct rtable *rth;
+
+	rcu_read_lock();
+
+	rth = rcu_dereference(vrf->rth);
+	if (likely(rth)) {
+		dst = &rth->dst;
+		dst_hold(dst);
+	}
+
+	rcu_read_unlock();
+
+	if (unlikely(!dst)) {
+		vrf_tx_error(vrf_dev, skb);
+		return NULL;
+	}
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
+
+	return skb;
+}
+
+/* called with rcu lock held */
+static struct sk_buff *vrf_l3_out(struct net_device *vrf_dev,
+				  struct sock *sk,
+				  struct sk_buff *skb,
+				  u16 proto)
+{
+	switch (proto) {
+	case AF_INET:
+		return vrf_ip_out(vrf_dev, sk, skb);
+	}
+
+	return skb;
+}
+
 /* holding rtnl */
 static void vrf_rtable_release(struct net_device *dev, struct net_vrf *vrf)
 {
@@ -1067,6 +1128,7 @@ static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_get_rtable	= vrf_get_rtable,
 	.l3mdev_get_saddr	= vrf_get_saddr,
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
+	.l3mdev_l3_out		= vrf_l3_out,
 #if IS_ENABLED(CONFIG_IPV6)
 	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
 	.l3mdev_get_saddr6	= vrf_get_saddr6,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f49b2c534e92..ad83f85fb240 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2246,10 +2246,6 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_HOST);
 		}
-
-		rth = l3mdev_get_rtable(dev_out, fl4);
-		if (rth)
-			goto out;
 	}
 
 	if (!fl4->daddr) {
-- 
2.1.4
