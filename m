From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 4/6] IPv6: Don't allocate memory for Tunnel Encapsulation
 Limit Option
Date: Thu, 02 Nov 2006 13:35:10 +0200
Message-ID: <4549D7EE.4000301@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070706060202090501080209"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:54665 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1751328AbWKBLfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 06:35:18 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070706060202090501080209
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


--------------070706060202090501080209
Content-Type: text/plain;
 name*0="0004-IPv6-Don-t-allocate-memory-for-Tunnel-Encapsulation-Limit-O";
 name*1="ption.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0004-IPv6-Don-t-allocate-memory-for-Tunnel-Encapsulation-Lim";
 filename*1="it-Option.txt"

>From b278633af228bcc986856f6492b02422c25656c7 Mon Sep 17 00:00:00 2001
From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Thu, 2 Nov 2006 12:47:54 +0200
Subject: [PATCH 4/6] IPv6: Don't allocate memory for Tunnel Encapsulation Limit Option

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/ip6_tunnel.c |   58 ++++++++++++++++++------------------------------
 1 files changed, 22 insertions(+), 36 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 008bd11..a97eb52 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -571,31 +571,23 @@ discard:
 	return 0;
 }
 
-static inline struct ipv6_txoptions *create_tel(__u8 encap_limit)
-{
-	struct ipv6_tlv_tnl_enc_lim *tel;
-	struct ipv6_txoptions *opt;
-	__u8 *raw;
-
-	int opt_len = sizeof(*opt) + 8;
-
-	if (!(opt = kzalloc(opt_len, GFP_ATOMIC))) {
-		return NULL;
-	}
-	opt->tot_len = opt_len;
-	opt->dst0opt = (struct ipv6_opt_hdr *) (opt + 1);
-	opt->opt_nflen = 8;
+struct ipv6_tel_txoption {
+	struct ipv6_txoptions ops;
+	__u8 dst_opt[8];
+};
 
-	tel = (struct ipv6_tlv_tnl_enc_lim *) (opt->dst0opt + 1);
-	tel->type = IPV6_TLV_TNL_ENCAP_LIMIT;
-	tel->length = 1;
-	tel->encap_limit = encap_limit;
+static void init_tel_txopt(struct ipv6_tel_txoption *opt, __u8 encap_limit)
+{
+	memset(opt, 0, sizeof(struct ipv6_tel_txoption));
 
-	raw = (__u8 *) opt->dst0opt;
-	raw[5] = IPV6_TLV_PADN;
-	raw[6] = 1;
+	opt->dst_opt[2] = IPV6_TLV_TNL_ENCAP_LIMIT;
+	opt->dst_opt[3] = 1;
+	opt->dst_opt[4] = encap_limit;
+	opt->dst_opt[5] = IPV6_TLV_PADN;
+	opt->dst_opt[6] = 1;
 
-	return opt;
+	opt->ops.dst0opt = (struct ipv6_opt_hdr *) opt->dst_opt;
+	opt->ops.opt_nflen = 8;
 }
 
 /**
@@ -665,8 +657,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net_device_stats *stats = &t->stat;
 	struct ipv6hdr *ipv6h = skb->nh.ipv6h;
-	struct ipv6_txoptions *opt = NULL;
 	int encap_limit = -1;
+	struct ipv6_tel_txoption opt;
 	__u16 offset;
 	struct flowi fl;
 	struct dst_entry *dst;
@@ -695,9 +687,9 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 			goto tx_err;
 		}
 		encap_limit = tel->encap_limit - 1;
-	} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT)) {
+	} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		encap_limit = t->parms.encap_limit;
-	}
+
 	memcpy(&fl, &t->fl, sizeof (fl));
 	proto = fl.proto;
 
@@ -707,9 +699,6 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL))
 		fl.fl6_flowlabel |= (*(__u32 *) ipv6h & IPV6_FLOWLABEL_MASK);
 
-	if (encap_limit >= 0 && (opt = create_tel(encap_limit)) == NULL)
-		goto tx_err;
-
 	if ((dst = ip6_tnl_dst_check(t)) != NULL)
 		dst_hold(dst);
 	else {
@@ -730,7 +719,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 		goto tx_err_dst_release;
 	}
 	mtu = dst_mtu(dst) - sizeof (*ipv6h);
-	if (opt) {
+	if (encap_limit >= 0) {
 		max_headroom += 8;
 		mtu -= 8;
 	}
@@ -768,9 +757,10 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 
 	skb->h.raw = skb->nh.raw;
 
-	if (opt)
-		ipv6_push_nfrag_opts(skb, opt, &proto, NULL);
-
+	if (encap_limit >= 0) {
+		init_tel_txopt(&opt, encap_limit);
+		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
+	}
 	skb->nh.raw = skb_push(skb, sizeof(struct ipv6hdr));
 	ipv6h = skb->nh.ipv6h;
 	*(u32*)ipv6h = fl.fl6_flowlabel | htonl(0x60000000);
@@ -794,9 +784,6 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 		stats->tx_aborted_errors++;
 	}
 	ip6_tnl_dst_store(t, dst);
-
-	kfree(opt);
-
 	t->recursion--;
 	return 0;
 tx_err_link_failure:
@@ -804,7 +791,6 @@ tx_err_link_failure:
 	dst_link_failure(skb);
 tx_err_dst_release:
 	dst_release(dst);
-	kfree(opt);
 tx_err:
 	stats->tx_errors++;
 	stats->tx_dropped++;
-- 
1.4.3.2


--------------070706060202090501080209--
