From: pablo@netfilter.org
Subject: [PATCH 07/10] netfilter: sparse endian fixes
Date: Thu, 23 Aug 2012 01:38:43 +0200
Message-ID: <1345678726-3109-8-git-send-email-pablo@netfilter.org>
References: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Fix a couple of endian annotation in net/netfilter:

net/netfilter/nfnetlink_acct.c:82:30: warning: cast to restricted __be64
net/netfilter/nfnetlink_acct.c:86:30: warning: cast to restricted __be64
net/netfilter/nfnetlink_cthelper.c:77:28: warning: cast to restricted __be16
net/netfilter/xt_NFQUEUE.c:46:16: warning: restricted __be32 degrades to integer
net/netfilter/xt_NFQUEUE.c:60:34: warning: restricted __be32 degrades to integer
net/netfilter/xt_NFQUEUE.c:68:34: warning: restricted __be32 degrades to integer
net/netfilter/xt_osf.c:272:55: warning: cast to restricted __be16

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c     |    4 ++--
 net/netfilter/nfnetlink_cthelper.c |    2 +-
 net/netfilter/xt_NFQUEUE.c         |    8 +++++---
 net/netfilter/xt_osf.c             |    2 +-
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index b2e7310..d7ec928 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -79,11 +79,11 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 
 	if (tb[NFACCT_BYTES]) {
 		atomic64_set(&nfacct->bytes,
-			     be64_to_cpu(nla_get_u64(tb[NFACCT_BYTES])));
+			     be64_to_cpu(nla_get_be64(tb[NFACCT_BYTES])));
 	}
 	if (tb[NFACCT_PKTS]) {
 		atomic64_set(&nfacct->pkts,
-			     be64_to_cpu(nla_get_u64(tb[NFACCT_PKTS])));
+			     be64_to_cpu(nla_get_be64(tb[NFACCT_PKTS])));
 	}
 	atomic_set(&nfacct->refcnt, 1);
 	list_add_tail_rcu(&nfacct->head, &nfnl_acct_list);
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index d683619..32a1ba3 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -74,7 +74,7 @@ nfnl_cthelper_parse_tuple(struct nf_conntrack_tuple *tuple,
 	if (!tb[NFCTH_TUPLE_L3PROTONUM] || !tb[NFCTH_TUPLE_L4PROTONUM])
 		return -EINVAL;
 
-	tuple->src.l3num = ntohs(nla_get_u16(tb[NFCTH_TUPLE_L3PROTONUM]));
+	tuple->src.l3num = ntohs(nla_get_be16(tb[NFCTH_TUPLE_L3PROTONUM]));
 	tuple->dst.protonum = nla_get_u8(tb[NFCTH_TUPLE_L4PROTONUM]);
 
 	return 0;
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 7babe7d..817f9e9 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -43,7 +43,7 @@ static u32 hash_v4(const struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 
 	/* packets in either direction go into same queue */
-	if (iph->saddr < iph->daddr)
+	if ((__force u32)iph->saddr < (__force u32)iph->daddr)
 		return jhash_3words((__force u32)iph->saddr,
 			(__force u32)iph->daddr, iph->protocol, jhash_initval);
 
@@ -57,7 +57,8 @@ static u32 hash_v6(const struct sk_buff *skb)
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	u32 a, b, c;
 
-	if (ip6h->saddr.s6_addr32[3] < ip6h->daddr.s6_addr32[3]) {
+	if ((__force u32)ip6h->saddr.s6_addr32[3] <
+	    (__force u32)ip6h->daddr.s6_addr32[3]) {
 		a = (__force u32) ip6h->saddr.s6_addr32[3];
 		b = (__force u32) ip6h->daddr.s6_addr32[3];
 	} else {
@@ -65,7 +66,8 @@ static u32 hash_v6(const struct sk_buff *skb)
 		a = (__force u32) ip6h->daddr.s6_addr32[3];
 	}
 
-	if (ip6h->saddr.s6_addr32[1] < ip6h->daddr.s6_addr32[1])
+	if ((__force u32)ip6h->saddr.s6_addr32[1] <
+	    (__force u32)ip6h->daddr.s6_addr32[1])
 		c = (__force u32) ip6h->saddr.s6_addr32[1];
 	else
 		c = (__force u32) ip6h->daddr.s6_addr32[1];
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 846f895..a5e673d 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -269,7 +269,7 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 						mss <<= 8;
 						mss |= optp[2];
 
-						mss = ntohs(mss);
+						mss = ntohs((__force __be16)mss);
 						break;
 					case OSFOPT_TS:
 						loop_cont = 1;
-- 
1.7.10.4

