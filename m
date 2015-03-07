From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 6/6] neigh: Use neigh table index for neigh_packet_xmit
Date: Sat, 07 Mar 2015 16:25:56 -0600
Message-ID: <87vbic30nf.fsf@x220.int.ebiederm.org>
References: <874mpw5u3x.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50047 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbCGW3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 17:29:34 -0500
In-Reply-To: <874mpw5u3x.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sat, 07 Mar 2015 16:18:58 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove a little bit of unnecessary work when transmitting a packet with
neigh_packet_xmit.  Use the neighbour table index not the address family
as a parameter.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/neighbour.h |  1 +
 net/core/neighbour.c    | 22 +++++++++++-----------
 net/mpls/af_mpls.c      | 35 ++++++++++++++++++++++-------------
 3 files changed, 34 insertions(+), 24 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index afb8237b0a8c..d48b8ec8b5f4 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -226,6 +226,7 @@ enum {
 	NEIGH_ND_TABLE = 1,
 	NEIGH_DN_TABLE = 2,
 	NEIGH_NR_TABLES,
+	NEIGH_LINK_TABLE = NEIGH_NR_TABLES /* Pseudo table for neigh_xmit */
 };
 
 static inline int neigh_parms_family(struct neigh_parms *p)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index cffaf00561e7..ad07990e943d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2391,22 +2391,15 @@ void __neigh_for_each_release(struct neigh_table *tbl,
 }
 EXPORT_SYMBOL(__neigh_for_each_release);
 
-int neigh_xmit(int family, struct net_device *dev,
+int neigh_xmit(int index, struct net_device *dev,
 	       const void *addr, struct sk_buff *skb)
 {
-	int err;
-	if (family == AF_PACKET) {
-		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
-				      addr, NULL, skb->len);
-		if (err < 0)
-			goto out_kfree_skb;
-		err = dev_queue_xmit(skb);
-	} else {
+	int err = -EAFNOSUPPORT;
+	if (likely(index < NEIGH_NR_TABLES)) {
 		struct neigh_table *tbl;
 		struct neighbour *neigh;
 
-		err = -ENETDOWN;
-		tbl = neigh_find_table(family);
+		tbl = neigh_tables[index];
 		if (!tbl)
 			goto out;
 		neigh = __neigh_lookup_noref(tbl, addr, dev);
@@ -2417,6 +2410,13 @@ int neigh_xmit(int family, struct net_device *dev,
 			goto out_kfree_skb;
 		err = neigh->output(neigh, skb);
 	}
+	else if (index == NEIGH_LINK_TABLE) {
+		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+				      addr, NULL, skb->len);
+		if (err < 0)
+			goto out_kfree_skb;
+		err = dev_queue_xmit(skb);
+	}
 out:
 	return err;
 out_kfree_skb:
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index e120074157de..0ad8f7141be2 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -28,9 +28,9 @@ struct mpls_route { /* next hop label forwarding entry */
 	struct rcu_head		rt_rcu;
 	u32			rt_label[MAX_NEW_LABELS];
 	u8			rt_protocol; /* routing protocol that set this entry */
-	u8			rt_labels:2,
-				rt_via_alen:6;
-	unsigned short		rt_via_family;
+	u8			rt_labels;
+	u8			rt_via_alen;
+	u8			rt_via_table;
 	u8			rt_via[0];
 };
 
@@ -201,7 +201,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	err = neigh_xmit(rt->rt_via_family, out_dev, rt->rt_via, skb);
+	err = neigh_xmit(rt->rt_via_table, out_dev, rt->rt_via, skb);
 	if (err)
 		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
 				    __func__, err);
@@ -225,7 +225,7 @@ static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
 struct mpls_route_config {
 	u32		rc_protocol;
 	u32		rc_ifindex;
-	u16		rc_via_family;
+	u16		rc_via_table;
 	u16		rc_via_alen;
 	u8		rc_via[MAX_VIA_ALEN];
 	u32		rc_label;
@@ -343,7 +343,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		goto errout;
 
 	err = -EINVAL;
-	if ((cfg->rc_via_family == AF_PACKET) &&
+	if ((cfg->rc_via_table == NEIGH_LINK_TABLE) &&
 	    (dev->addr_len != cfg->rc_via_alen))
 		goto errout;
 
@@ -376,7 +376,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		rt->rt_label[i] = cfg->rc_output_label[i];
 	rt->rt_protocol = cfg->rc_protocol;
 	RCU_INIT_POINTER(rt->rt_dev, dev);
-	rt->rt_via_family = cfg->rc_via_family;
+	rt->rt_via_table = cfg->rc_via_table;
 	memcpy(rt->rt_via, cfg->rc_via, cfg->rc_via_alen);
 
 	mpls_route_update(net, index, NULL, rt, &cfg->rc_nlinfo);
@@ -448,15 +448,22 @@ static struct notifier_block mpls_dev_notifier = {
 };
 
 static int nla_put_via(struct sk_buff *skb,
-		       u16 family, const void *addr, int alen)
+		       u8 table, const void *addr, int alen)
 {
+	static const int table_to_family[NEIGH_NR_TABLES + 1] = {
+		AF_INET, AF_INET6, AF_DECnet, AF_PACKET,
+	};
 	struct nlattr *nla;
 	struct rtvia *via;
+	int family = AF_UNSPEC;
 
 	nla = nla_reserve(skb, RTA_VIA, alen + 2);
 	if (!nla)
 		return -EMSGSIZE;
 
+	if (table <= NEIGH_NR_TABLES)
+		family = table_to_family[table];
+
 	via = nla_data(nla);
 	via->rtvia_family = family;
 	memcpy(via->rtvia_addr, addr, alen);
@@ -599,21 +606,23 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			struct rtvia *via = nla_data(nla);
 			if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
 				goto errout;
-			cfg->rc_via_family = via->rtvia_family;
 			cfg->rc_via_alen   = nla_len(nla) -
 				offsetof(struct rtvia, rtvia_addr);
 			if (cfg->rc_via_alen > MAX_VIA_ALEN)
 				goto errout;
 
 			/* Validate the address family */
-			switch(cfg->rc_via_family) {
+			switch(via->rtvia_family) {
 			case AF_PACKET:
+				cfg->rc_via_table = NEIGH_LINK_TABLE;
 				break;
 			case AF_INET:
+				cfg->rc_via_table = NEIGH_ARP_TABLE;
 				if (cfg->rc_via_alen != 4)
 					goto errout;
 				break;
 			case AF_INET6:
+				cfg->rc_via_table = NEIGH_ND_TABLE;
 				if (cfg->rc_via_alen != 16)
 					goto errout;
 				break;
@@ -686,7 +695,7 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	if (rt->rt_labels &&
 	    nla_put_labels(skb, RTA_NEWDST, rt->rt_labels, rt->rt_label))
 		goto nla_put_failure;
-	if (nla_put_via(skb, rt->rt_via_family, rt->rt_via, rt->rt_via_alen))
+	if (nla_put_via(skb, rt->rt_via_table, rt->rt_via, rt->rt_via_alen))
 		goto nla_put_failure;
 	dev = rtnl_dereference(rt->rt_dev);
 	if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
@@ -799,7 +808,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 			goto nort0;
 		RCU_INIT_POINTER(rt0->rt_dev, lo);
 		rt0->rt_protocol = RTPROT_KERNEL;
-		rt0->rt_via_family = AF_PACKET;
+		rt0->rt_via_table = NEIGH_LINK_TABLE;
 		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
 	}
 	if (limit > LABEL_IPV6_EXPLICIT_NULL) {
@@ -809,7 +818,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 			goto nort2;
 		RCU_INIT_POINTER(rt2->rt_dev, lo);
 		rt2->rt_protocol = RTPROT_KERNEL;
-		rt2->rt_via_family = AF_PACKET;
+		rt2->rt_via_table = NEIGH_LINK_TABLE;
 		memcpy(rt2->rt_via, lo->dev_addr, lo->addr_len);
 	}
 
-- 
2.2.1
