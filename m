From: kaber@trash.net
Subject: [PATCH 5/8] netfilter: af_info: add network namespace parameter to route hook
Date: Tue,  5 Apr 2011 15:04:16 +0200
Message-ID: <1302008659-21141-6-git-send-email-kaber@trash.net>
References: <1302008659-21141-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1302008659-21141-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

This is required to eventually replace the rt6_lookup call in
xt_addrtype.c with nf_afinfo->route().

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter.h              |    3 ++-
 net/ipv4/netfilter.c                   |    5 +++--
 net/ipv6/netfilter.c                   |    5 +++--
 net/netfilter/nf_conntrack_h323_main.c |    8 ++++----
 net/netfilter/xt_TCPMSS.c              |    2 +-
 5 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index eeec00a..20ed452 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -270,7 +270,8 @@ struct nf_afinfo {
 					    unsigned int dataoff,
 					    unsigned int len,
 					    u_int8_t protocol);
-	int		(*route)(struct dst_entry **dst, struct flowi *fl);
+	int		(*route)(struct net *net, struct dst_entry **dst,
+				 struct flowi *fl);
 	void		(*saveroute)(const struct sk_buff *skb,
 				     struct nf_queue_entry *entry);
 	int		(*reroute)(struct sk_buff *skb,
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index f3c0b54..f1035f0 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -221,9 +221,10 @@ static __sum16 nf_ip_checksum_partial(struct sk_buff *skb, unsigned int hook,
 	return csum;
 }
 
-static int nf_ip_route(struct dst_entry **dst, struct flowi *fl)
+static int nf_ip_route(struct net *net, struct dst_entry **dst,
+		       struct flowi *fl)
 {
-	struct rtable *rt = ip_route_output_key(&init_net, &fl->u.ip4);
+	struct rtable *rt = ip_route_output_key(net, &fl->u.ip4);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 	*dst = &rt->dst;
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 39aaca2..e008b9b 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -90,9 +90,10 @@ static int nf_ip6_reroute(struct sk_buff *skb,
 	return 0;
 }
 
-static int nf_ip6_route(struct dst_entry **dst, struct flowi *fl)
+static int nf_ip6_route(struct net *net, struct dst_entry **dst,
+			struct flowi *fl)
 {
-	*dst = ip6_route_output(&init_net, NULL, &fl->u.ip6);
+	*dst = ip6_route_output(net, NULL, &fl->u.ip6);
 	return (*dst)->error;
 }
 
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 533a183..39a4538 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -731,9 +731,9 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 
 		memset(&fl2, 0, sizeof(fl2));
 		fl2.daddr = dst->ip;
-		if (!afinfo->route((struct dst_entry **)&rt1,
+		if (!afinfo->route(&init_net, (struct dst_entry **)&rt1,
 				   flowi4_to_flowi(&fl1))) {
-			if (!afinfo->route((struct dst_entry **)&rt2,
+			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
 					   flowi4_to_flowi(&fl2))) {
 				if (rt1->rt_gateway == rt2->rt_gateway &&
 				    rt1->dst.dev  == rt2->dst.dev)
@@ -755,9 +755,9 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 
 		memset(&fl2, 0, sizeof(fl2));
 		ipv6_addr_copy(&fl2.daddr, &dst->in6);
-		if (!afinfo->route((struct dst_entry **)&rt1,
+		if (!afinfo->route(&init_net, (struct dst_entry **)&rt1,
 				   flowi6_to_flowi(&fl1))) {
-			if (!afinfo->route((struct dst_entry **)&rt2,
+			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
 					   flowi6_to_flowi(&fl2))) {
 				if (!memcmp(&rt1->rt6i_gateway, &rt2->rt6i_gateway,
 					    sizeof(rt1->rt6i_gateway)) &&
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 6e6b46c..8690125 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -166,7 +166,7 @@ static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
 	rcu_read_lock();
 	ai = nf_get_afinfo(family);
 	if (ai != NULL)
-		ai->route((struct dst_entry **)&rt, &fl);
+		ai->route(&init_net, (struct dst_entry **)&rt, &fl);
 	rcu_read_unlock();
 
 	if (rt != NULL) {
-- 
1.7.2.3

