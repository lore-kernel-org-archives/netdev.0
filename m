From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v2 net 2/5] ipv6: Rename the dst_cache helper functions in ip6_tunnel
Date: Fri, 4 Sep 2015 16:12:39 -0700
Message-ID: <1441408362-4177515-3-git-send-email-kafai@fb.com>
References: <1441408362-4177515-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:3207 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934116AbbIDXM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 19:12:58 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t84NC1qo025436
	for <netdev@vger.kernel.org>; Fri, 4 Sep 2015 16:12:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wqkds04xd-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 16:12:57 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 79c90b0e535a11e58b010002c992ebde-a23fd240 for <netdev@vger.kernel.org>;	Fri,
 04 Sep 2015 16:12:56 -0700
In-Reply-To: <1441408362-4177515-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work to fix the dst_entry refcnt bugs in
ip6_tunnel.

This patch rename:
1. ip6_tnl_dst_check() to ip6_tnl_dst_get() to better
   reflect that it will take a dst refcnt in the next patch.
2. ip6_tnl_dst_store() to ip6_tnl_dst_set() to have a more
   conventional name matching with ip6_tnl_dst_get().

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/ip6_tunnel.h |  4 ++--
 net/ipv6/ip6_gre.c       |  4 ++--
 net/ipv6/ip6_tunnel.c    | 12 ++++++------
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 76c091b..6ebccce 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -60,9 +60,9 @@ struct ipv6_tlv_tnl_enc_lim {
 	__u8 encap_limit;	/* tunnel encapsulation limit   */
 } __packed;
 
-struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t);
+struct dst_entry *ip6_tnl_dst_get(struct ip6_tnl *t);
 void ip6_tnl_dst_reset(struct ip6_tnl *t);
-void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst);
+void ip6_tnl_dst_set(struct ip6_tnl *t, struct dst_entry *dst);
 int ip6_tnl_rcv_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
 		const struct in6_addr *raddr);
 int ip6_tnl_xmit_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index be6b0b9..4903c9a 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -633,7 +633,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	}
 
 	if (!fl6->flowi6_mark)
-		dst = ip6_tnl_dst_check(tunnel);
+		dst = ip6_tnl_dst_get(tunnel);
 
 	if (!dst) {
 		ndst = ip6_route_output(net, NULL, fl6);
@@ -762,7 +762,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 
 	ip6tunnel_xmit(skb, dev);
 	if (ndst)
-		ip6_tnl_dst_store(tunnel, ndst);
+		ip6_tnl_dst_set(tunnel, ndst);
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 96abdd0..2c5a1e3 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -132,7 +132,7 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
  * Locking : hash tables are protected by RCU and RTNL
  */
 
-struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
+struct dst_entry *ip6_tnl_dst_get(struct ip6_tnl *t)
 {
 	struct dst_entry *dst = t->dst_cache;
 
@@ -145,7 +145,7 @@ struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 
 	return dst;
 }
-EXPORT_SYMBOL_GPL(ip6_tnl_dst_check);
+EXPORT_SYMBOL_GPL(ip6_tnl_dst_get);
 
 void ip6_tnl_dst_reset(struct ip6_tnl *t)
 {
@@ -154,14 +154,14 @@ void ip6_tnl_dst_reset(struct ip6_tnl *t)
 }
 EXPORT_SYMBOL_GPL(ip6_tnl_dst_reset);
 
-void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
+void ip6_tnl_dst_set(struct ip6_tnl *t, struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *) dst;
 	t->dst_cookie = rt6_get_cookie(rt);
 	dst_release(t->dst_cache);
 	t->dst_cache = dst;
 }
-EXPORT_SYMBOL_GPL(ip6_tnl_dst_store);
+EXPORT_SYMBOL_GPL(ip6_tnl_dst_set);
 
 /**
  * ip6_tnl_lookup - fetch tunnel matching the end-point addresses
@@ -1016,7 +1016,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
 		neigh_release(neigh);
 	} else if (!fl6->flowi6_mark)
-		dst = ip6_tnl_dst_check(t);
+		dst = ip6_tnl_dst_get(t);
 
 	if (!ip6_tnl_xmit_ctl(t, &fl6->saddr, &fl6->daddr))
 		goto tx_err_link_failure;
@@ -1108,7 +1108,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	ipv6h->daddr = fl6->daddr;
 	ip6tunnel_xmit(skb, dev);
 	if (ndst)
-		ip6_tnl_dst_store(t, ndst);
+		ip6_tnl_dst_set(t, ndst);
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
-- 
1.8.1
