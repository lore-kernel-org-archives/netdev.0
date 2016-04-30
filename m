From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH next-next 4/7] ipv6: Create ip6_tnl_xmit
Date: Fri, 29 Apr 2016 17:12:18 -0700
Message-ID: <1461975141-954269-5-git-send-email-tom@herbertland.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:63384 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751979AbcD3AOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:14:45 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3U0CBid027397
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22mf0j8nsc-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:45 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 89fb238a0e6811e6b5d224be0595f910-d43f7c50 for <netdev@vger.kernel.org>;	Fri,
 29 Apr 2016 17:14:43 -0700
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch renames ip6_tnl_xmit2 to ip6_tnl_xmit and exports it. Other
users like GRE will be able to call this. The original ip6_tnl_xmit
function is renamed to ip6_tnl_start_xmit (this is an ndo_start_xmit
function).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ip6_tunnel.h |  2 ++
 net/ipv6/ip6_tunnel.c    | 47 ++++++++++++++++++++++++++++++-----------------
 2 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index eab3a9b..835491b 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -69,6 +69,8 @@ int ip6_tnl_rcv(struct ip6_tnl *tunnel, struct sk_buff *skb,
 		bool log_ecn_error);
 int ip6_tnl_xmit_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
 		     const struct in6_addr *raddr);
+int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
+		 struct flowi6 *fl6, int encap_limit, __u32 *pmtu, __u8 proto);
 __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 94ed065..b1f31d2 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -979,13 +979,14 @@ int ip6_tnl_xmit_ctl(struct ip6_tnl *t,
 EXPORT_SYMBOL_GPL(ip6_tnl_xmit_ctl);
 
 /**
- * ip6_tnl_xmit2 - encapsulate packet and send
+ * ip6_tnl_xmit - encapsulate packet and send
  *   @skb: the outgoing socket buffer
  *   @dev: the outgoing tunnel device
  *   @dsfield: dscp code for outer header
- *   @fl: flow of tunneled packet
+ *   @fl6: flow of tunneled packet
  *   @encap_limit: encapsulation limit
  *   @pmtu: Path MTU is stored if packet is too big
+ *   @proto: next header value
  *
  * Description:
  *   Build new header and do some sanity checks on the packet before sending
@@ -997,12 +998,9 @@ EXPORT_SYMBOL_GPL(ip6_tnl_xmit_ctl);
  *   %-EMSGSIZE message too big. return mtu in this case.
  **/
 
-static int ip6_tnl_xmit2(struct sk_buff *skb,
-			 struct net_device *dev,
-			 __u8 dsfield,
-			 struct flowi6 *fl6,
-			 int encap_limit,
-			 __u32 *pmtu)
+int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
+		 struct flowi6 *fl6, int encap_limit, __u32 *pmtu,
+		 __u8 proto)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net *net = t->net;
@@ -1013,7 +1011,6 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	struct net_device *tdev;
 	int mtu;
 	unsigned int max_headroom = sizeof(struct ipv6hdr);
-	u8 proto;
 	int err = -1;
 
 	/* NBMA tunnel */
@@ -1075,12 +1072,23 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		mtu = IPV6_MIN_MTU;
 	if (skb_dst(skb))
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		*pmtu = mtu;
 		err = -EMSGSIZE;
 		goto tx_err_dst_release;
 	}
 
+	if (t->err_count > 0) {
+		if (time_before(jiffies,
+				t->err_time + IP6TUNNEL_ERR_TIMEO)) {
+			t->err_count--;
+
+			dst_link_failure(skb);
+		} else {
+			t->err_count = 0;
+		}
+	}
+
 	skb_scrub_packet(skb, !net_eq(t->net, dev_net(dev)));
 
 	/*
@@ -1108,7 +1116,6 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 
 	skb->transport_header = skb->network_header;
 
-	proto = fl6->flowi6_proto;
 	if (encap_limit >= 0) {
 		init_tel_txopt(&opt, encap_limit);
 		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
@@ -1119,6 +1126,11 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		skb->encapsulation = 1;
 	}
 
+	max_headroom = LL_RESERVED_SPACE(dst->dev) + sizeof(struct ipv6hdr)
+			+ dst->header_len;
+	if (max_headroom > dev->needed_headroom)
+		dev->needed_headroom = max_headroom;
+
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
@@ -1137,6 +1149,7 @@ tx_err_dst_release:
 	dst_release(dst);
 	return err;
 }
+EXPORT_SYMBOL(ip6_tnl_xmit);
 
 static inline int
 ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -1160,7 +1173,6 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_IPIP;
 
 	dsfield = ipv4_get_dsfield(iph);
 
@@ -1170,7 +1182,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
-	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
+	err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
+			   IPPROTO_IPIP);
 	if (err != 0) {
 		/* XXX: send ICMP error even if DF is not set. */
 		if (err == -EMSGSIZE)
@@ -1214,7 +1227,6 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_IPV6;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
@@ -1224,7 +1236,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
-	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
+	err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
+			   IPPROTO_IPV6);
 	if (err != 0) {
 		if (err == -EMSGSIZE)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
@@ -1235,7 +1248,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static netdev_tx_t
-ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
+ip6_tnl_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net_device_stats *stats = &t->dev->stats;
@@ -1556,7 +1569,7 @@ EXPORT_SYMBOL(ip6_tnl_get_iflink);
 static const struct net_device_ops ip6_tnl_netdev_ops = {
 	.ndo_init	= ip6_tnl_dev_init,
 	.ndo_uninit	= ip6_tnl_dev_uninit,
-	.ndo_start_xmit = ip6_tnl_xmit,
+	.ndo_start_xmit = ip6_tnl_start_xmit,
 	.ndo_do_ioctl	= ip6_tnl_ioctl,
 	.ndo_change_mtu = ip6_tnl_change_mtu,
 	.ndo_get_stats	= ip6_get_stats,
-- 
2.8.0.rc2
