From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 14/15] neigh: Don't require dst in neigh_hh_init
Date: Mon, 02 Mar 2015 00:13:22 -0600
Message-ID: <87vbik53lp.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- Add protocol to neigh_tbl so that dst->ops->protocol is not needed
- Acquire the device from neigh->dev

This results in a neigh_hh_init that will cache the samve values
regardless of the packets flowing through it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/neighbour.h | 1 +
 net/core/neighbour.c    | 8 ++++----
 net/decnet/dn_neigh.c   | 1 +
 net/ipv4/arp.c          | 1 +
 net/ipv6/ndisc.c        | 1 +
 5 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index bc66babb5f27..9f912e4d4232 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -193,6 +193,7 @@ struct neigh_table {
 	int			family;
 	int			entry_size;
 	int			key_len;
+	__be16			protocol;
 	__u32			(*hash)(const void *pkey,
 					const struct net_device *dev,
 					__u32 *hash_rnd);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8a319ff3e8d1..af72b863e968 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1263,10 +1263,10 @@ struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 EXPORT_SYMBOL(neigh_event_ns);
 
 /* called with read_lock_bh(&n->lock); */
-static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst)
+static void neigh_hh_init(struct neighbour *n)
 {
-	struct net_device *dev = dst->dev;
-	__be16 prot = dst->ops->protocol;
+	struct net_device *dev = n->dev;
+	__be16 prot = n->tbl->protocol;
 	struct hh_cache	*hh = &n->hh;
 
 	write_lock_bh(&n->lock);
@@ -1296,7 +1296,7 @@ int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
 		unsigned int seq;
 
 		if (dev->header_ops->cache && !neigh->hh.hh_len)
-			neigh_hh_init(neigh, dst);
+			neigh_hh_init(neigh);
 
 		do {
 			__skb_pull(skb, skb_network_offset(skb));
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 7ca7c3143da3..f123c6c6748c 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -97,6 +97,7 @@ struct neigh_table dn_neigh_table = {
 	.family =			PF_DECnet,
 	.entry_size =			NEIGH_ENTRY_SIZE(sizeof(struct dn_neigh)),
 	.key_len =			sizeof(__le16),
+	.protocol =			cpu_to_be16(ETH_P_DNA_RT),
 	.hash =				dn_neigh_hash,
 	.constructor =			dn_neigh_construct,
 	.id =				"dn_neigh_cache",
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index bca5b9d9b442..6b8aad6a0d7d 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -152,6 +152,7 @@ static const struct neigh_ops arp_direct_ops = {
 struct neigh_table arp_tbl = {
 	.family		= AF_INET,
 	.key_len	= 4,
+	.protocol	= cpu_to_be16(ETH_P_IP),
 	.hash		= arp_hash,
 	.constructor	= arp_constructor,
 	.proxy_redo	= parp_redo,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 471ed24aabae..e363bbc2420d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -117,6 +117,7 @@ static const struct neigh_ops ndisc_direct_ops = {
 struct neigh_table nd_tbl = {
 	.family =	AF_INET6,
 	.key_len =	sizeof(struct in6_addr),
+	.protocol =	cpu_to_be16(ETH_P_IPV6),
 	.hash =		ndisc_hash,
 	.constructor =	ndisc_constructor,
 	.pconstructor =	pndisc_constructor,
-- 
2.2.1

