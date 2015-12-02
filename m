From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/3] vxlan: move IPv6 outpute route calculation to a function
Date: Wed,  2 Dec 2015 19:12:09 +0100
Message-ID: <0e6452ff305a6b1e4179a3df5a66ac6a98e3c9d5.1449079592.git.jbenc@redhat.com>
References: <cover.1449079592.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758501AbbLBSMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 13:12:38 -0500
In-Reply-To: <cover.1449079592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will be used also for ndo_fill_metadata_dst.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 45 +++++++++++++++++++++++++++++++++++----------
 1 file changed, 35 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 085d0c5b82b7..2945cf7f9c73 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1869,6 +1869,35 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 	return rt;
 }
 
+
+#if IS_ENABLED(CONFIG_IPV6)
+static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
+					  struct sk_buff *skb, int oif, u8 tos,
+					  const struct in6_addr *daddr,
+					  struct in6_addr *saddr)
+{
+	struct dst_entry *ndst;
+	struct flowi6 fl6;
+	int err;
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_oif = oif;
+	fl6.daddr = *daddr;
+	fl6.saddr = vxlan->cfg.saddr.sin6.sin6_addr;
+	fl6.flowi6_mark = skb->mark;
+	fl6.flowi6_proto = IPPROTO_UDP;
+
+	err = ipv6_stub->ipv6_dst_lookup(vxlan->net,
+					 vxlan->vn6_sock->sock->sk,
+					 &ndst, &fl6);
+	if (err < 0)
+		return ERR_PTR(err);
+
+	*saddr = fl6.saddr;
+	return ndst;
+}
+#endif
+
 /* Bypass encapsulation if the destination is local */
 static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 			       struct vxlan_dev *dst_vxlan)
@@ -2051,21 +2080,17 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		struct dst_entry *ndst;
-		struct flowi6 fl6;
+		struct in6_addr saddr;
 		u32 rt6i_flags;
 
 		if (!vxlan->vn6_sock)
 			goto drop;
 		sk = vxlan->vn6_sock->sock->sk;
 
-		memset(&fl6, 0, sizeof(fl6));
-		fl6.flowi6_oif = rdst ? rdst->remote_ifindex : 0;
-		fl6.daddr = dst->sin6.sin6_addr;
-		fl6.saddr = vxlan->cfg.saddr.sin6.sin6_addr;
-		fl6.flowi6_mark = skb->mark;
-		fl6.flowi6_proto = IPPROTO_UDP;
-
-		if (ipv6_stub->ipv6_dst_lookup(vxlan->net, sk, &ndst, &fl6)) {
+		ndst = vxlan6_get_route(vxlan, skb,
+					rdst ? rdst->remote_ifindex : 0, tos,
+					&dst->sin6.sin6_addr, &saddr);
+		if (IS_ERR(ndst)) {
 			netdev_dbg(dev, "no route to %pI6\n",
 				   &dst->sin6.sin6_addr);
 			dev->stats.tx_carrier_errors++;
@@ -2097,7 +2122,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
-		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &fl6.saddr, &fl6.daddr,
+		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &saddr, &dst->sin6.sin6_addr,
 				      0, ttl, src_port, dst_port, htonl(vni << 8), md,
 				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
 				      flags);
-- 
1.8.3.1
