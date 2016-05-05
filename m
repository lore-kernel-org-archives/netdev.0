From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 10/14] ip6_tun: Add infrastructure for doing encapsulation
Date: Wed, 4 May 2016 18:02:40 -0700
Message-ID: <1462410164-1953217-11-git-send-email-tom@herbertland.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:21241 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755519AbcEEBDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 21:03:02 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4512Kah032692
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 18:03:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22qr8whf63-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 04 May 2016 18:03:01 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1ca3b1aa125d11e6b1ad0002c9dfb610-b2eeac50 for <netdev@vger.kernel.org>;	Wed,
 04 May 2016 18:03:00 -0700
In-Reply-To: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add encap_hlen and ip_tunnel_encap structure to ip6_tnl. Add functions
for getting encap hlen, setting up encap on a tunnel, performing
encapsulation operation.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ip6_tunnel.h   |  8 +++++-
 net/ipv6/ip6_tunnel.c      |  4 +++
 net/ipv6/ip6_tunnel_core.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 1c14c27..1b8db86 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -66,10 +66,16 @@ struct ip6_tnl {
 	__u32 o_seqno;	/* The last output seqno */
 	int hlen;       /* tun_hlen + encap_hlen */
 	int tun_hlen;	/* Precalculated header length */
+	int encap_hlen; /* Encap header length (FOU,GUE) */
+	struct ip_tunnel_encap encap;
 	int mlink;
-
 };
 
+int ip6_tnl_encap_setup(struct ip6_tnl *t,
+			struct ip_tunnel_encap *ipencap);
+int ip6_tnl_encap(struct sk_buff *skb, struct ip6_tnl *t,
+		  u8 *protocol, struct flowi6 *fl6);
+
 /* Tunnel encapsulation limit destination sub-option */
 
 struct ipv6_tlv_tnl_enc_lim {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ade55af..2c096ab 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1013,6 +1013,10 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	unsigned int max_headroom = sizeof(struct ipv6hdr);
 	int err = -1;
 
+	err = ip6_tnl_encap(skb, t, &proto, fl6);
+	if (err)
+		return err;
+
 	/* NBMA tunnel */
 	if (ipv6_addr_any(&t->parms.raddr)) {
 		struct in6_addr *addr6;
diff --git a/net/ipv6/ip6_tunnel_core.c b/net/ipv6/ip6_tunnel_core.c
index 5f5b79e..94aa414 100644
--- a/net/ipv6/ip6_tunnel_core.c
+++ b/net/ipv6/ip6_tunnel_core.c
@@ -42,3 +42,67 @@ int ip6_tnl_encap_del_ops(const struct ip6_tnl_encap_ops *ops,
 }
 EXPORT_SYMBOL(ip6_tnl_encap_del_ops);
 
+static int ip6_encap_hlen(struct ip_tunnel_encap *e)
+{
+	const struct ip6_tnl_encap_ops *ops;
+	int hlen = -EINVAL;
+
+	if (e->type == TUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (e->type >= MAX_IPTUN_ENCAP_OPS)
+		return -EINVAL;
+
+	rcu_read_lock();
+	ops = rcu_dereference(ip6tun_encaps[e->type]);
+	if (likely(ops && ops->encap_hlen))
+		hlen = ops->encap_hlen(e);
+	rcu_read_unlock();
+
+	return hlen;
+}
+
+int ip6_tnl_encap_setup(struct ip6_tnl *t,
+			struct ip_tunnel_encap *ipencap)
+{
+	int hlen;
+
+	memset(&t->encap, 0, sizeof(t->encap));
+
+	hlen = ip6_encap_hlen(ipencap);
+	if (hlen < 0)
+		return hlen;
+
+	t->encap.type = ipencap->type;
+	t->encap.sport = ipencap->sport;
+	t->encap.dport = ipencap->dport;
+	t->encap.flags = ipencap->flags;
+
+	t->encap_hlen = hlen;
+	t->hlen = t->encap_hlen + t->tun_hlen;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip6_tnl_encap_setup);
+
+int ip6_tnl_encap(struct sk_buff *skb, struct ip6_tnl *t,
+		  u8 *protocol, struct flowi6 *fl6)
+{
+	const struct ip6_tnl_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (t->encap.type == TUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (t->encap.type >= MAX_IPTUN_ENCAP_OPS)
+		return -EINVAL;
+
+	rcu_read_lock();
+	ops = rcu_dereference(ip6tun_encaps[t->encap.type]);
+	if (likely(ops && ops->build_header))
+		ret = ops->build_header(skb, &t->encap, protocol, fl6);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(ip6_tnl_encap);
-- 
2.8.0.rc2
