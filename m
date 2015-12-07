From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net v3 1/2] vxlan: move IPv6 outpute route calculation to a function
Date: Mon,  7 Dec 2015 13:04:30 +0100
Message-ID: <b3c4ff515223f02cf2f3051a17680719e9e3f2ac.1449489733.git.jbenc@redhat.com>
References: <cover.1449489733.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363AbbLGMEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 07:04:48 -0500
In-Reply-To: <cover.1449489733.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will be used also for ndo_fill_metadata_dst.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: removed the unused 'tos' parameter that leaked from the IPv4 version
---
 drivers/net/vxlan.c | 44 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 34 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6369a5734d4c..5a38558da157 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1848,6 +1848,34 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 				   !(vxflags & VXLAN_F_UDP_CSUM));
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
+					  struct sk_buff *skb, int oif,
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
@@ -2035,21 +2063,17 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
+					rdst ? rdst->remote_ifindex : 0,
+					&dst->sin6.sin6_addr, &saddr);
+		if (IS_ERR(ndst)) {
 			netdev_dbg(dev, "no route to %pI6\n",
 				   &dst->sin6.sin6_addr);
 			dev->stats.tx_carrier_errors++;
@@ -2081,7 +2105,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
-		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &fl6.saddr, &fl6.daddr,
+		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &saddr, &dst->sin6.sin6_addr,
 				      0, ttl, src_port, dst_port, htonl(vni << 8), md,
 				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
 				      flags);
-- 
1.8.3.1
