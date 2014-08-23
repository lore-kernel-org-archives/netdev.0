From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: use reciprocal_scale() helper
Date: Sat, 23 Aug 2014 20:58:54 +0200
Message-ID: <1408820334-2088-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7812 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546AbaHWS7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2014 14:59:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace open codings of (((u64) <x> * <y>) >> 32) with reciprocal_scale().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/dev.c                      | 3 +--
 net/core/flow_dissector.c           | 7 +++----
 net/ipv4/inet_hashtables.c          | 2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c  | 2 +-
 net/ipv4/udp.c                      | 6 +++---
 net/ipv6/inet6_hashtables.c         | 2 +-
 net/ipv6/udp.c                      | 4 ++--
 net/netfilter/nf_conntrack_core.c   | 2 +-
 net/netfilter/nf_conntrack_expect.c | 3 ++-
 net/netfilter/nf_nat_core.c         | 5 +++--
 net/netfilter/xt_HMARK.c            | 2 +-
 net/netfilter/xt_cluster.c          | 3 ++-
 net/netfilter/xt_hashlimit.c        | 2 +-
 net/sched/sch_fq_codel.c            | 3 ++-
 14 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b65a505..1421dad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3124,8 +3124,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	if (map) {
-		tcpu = map->cpus[((u64) hash * map->len) >> 32];
-
+		tcpu = map->cpus[reciprocal_scale(hash, map->len)];
 		if (cpu_online(tcpu)) {
 			cpu = tcpu;
 			goto done;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 5f362c1..624869c 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -286,7 +286,7 @@ u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
 		qcount = dev->tc_to_txq[tc].count;
 	}
 
-	return (u16) (((u64)skb_get_hash(skb) * qcount) >> 32) + qoffset;
+	return (u16) reciprocal_scale(skb_get_hash(skb), qcount) + qoffset;
 }
 EXPORT_SYMBOL(__skb_tx_hash);
 
@@ -359,9 +359,8 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 			if (map->len == 1)
 				queue_index = map->queues[0];
 			else
-				queue_index = map->queues[
-				    ((u64)skb_get_hash(skb) * map->len) >> 32];
-
+				queue_index = map->queues[reciprocal_scale(skb_get_hash(skb),
+									   map->len)];
 			if (unlikely(queue_index >= dev->real_num_tx_queues))
 				queue_index = -1;
 		}
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 43116e8..9111a4e 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -229,7 +229,7 @@ begin:
 			}
 		} else if (score == hiscore && reuseport) {
 			matches++;
-			if (((u64)phash * matches) >> 32 == 0)
+			if (reciprocal_scale(phash, matches) == 0)
 				result = sk;
 			phash = next_pseudo_random32(phash);
 		}
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 2510c02..e90f83a 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -285,7 +285,7 @@ clusterip_hashfn(const struct sk_buff *skb,
 	}
 
 	/* node numbers are 1..n, not 0..n */
-	return (((u64)hashval * config->num_total_nodes) >> 32) + 1;
+	return reciprocal_scale(hashval, config->num_total_nodes) + 1;
 }
 
 static inline int
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f57c0e4..32f9571 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -224,7 +224,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		remaining = (high - low) + 1;
 
 		rand = prandom_u32();
-		first = (((u64)rand * remaining) >> 32) + low;
+		first = reciprocal_scale(rand, remaining) + low;
 		/*
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
 		 */
@@ -448,7 +448,7 @@ begin:
 			}
 		} else if (score == badness && reuseport) {
 			matches++;
-			if (((u64)hash * matches) >> 32 == 0)
+			if (reciprocal_scale(hash, matches) == 0)
 				result = sk;
 			hash = next_pseudo_random32(hash);
 		}
@@ -529,7 +529,7 @@ begin:
 			}
 		} else if (score == badness && reuseport) {
 			matches++;
-			if (((u64)hash * matches) >> 32 == 0)
+			if (reciprocal_scale(hash, matches) == 0)
 				result = sk;
 			hash = next_pseudo_random32(hash);
 		}
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 262e13c..8260190 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -198,7 +198,7 @@ begin:
 			}
 		} else if (score == hiscore && reuseport) {
 			matches++;
-			if (((u64)phash * matches) >> 32 == 0)
+			if (reciprocal_scale(phash, matches) == 0)
 				result = sk;
 			phash = next_pseudo_random32(phash);
 		}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4836af8..25ffe73 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -243,7 +243,7 @@ begin:
 				goto exact_match;
 		} else if (score == badness && reuseport) {
 			matches++;
-			if (((u64)hash * matches) >> 32 == 0)
+			if (reciprocal_scale(hash, matches) == 0)
 				result = sk;
 			hash = next_pseudo_random32(hash);
 		}
@@ -323,7 +323,7 @@ begin:
 			}
 		} else if (score == badness && reuseport) {
 			matches++;
-			if (((u64)hash * matches) >> 32 == 0)
+			if (reciprocal_scale(hash, matches) == 0)
 				result = sk;
 			hash = next_pseudo_random32(hash);
 		}
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index de88c4a..b7daee0 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -142,7 +142,7 @@ static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple, u16 zone)
 
 static u32 __hash_bucket(u32 hash, unsigned int size)
 {
-	return ((u64)hash * size) >> 32;
+	return reciprocal_scale(hash, size);
 }
 
 static u32 hash_bucket(u32 hash, const struct net *net)
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index f87e8f6..91a1837 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -83,7 +83,8 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 	hash = jhash2(tuple->dst.u3.all, ARRAY_SIZE(tuple->dst.u3.all),
 		      (((tuple->dst.protonum ^ tuple->src.l3num) << 16) |
 		       (__force __u16)tuple->dst.u.all) ^ nf_conntrack_hash_rnd);
-	return ((u64)hash * nf_ct_expect_hsize) >> 32;
+
+	return reciprocal_scale(hash, nf_ct_expect_hsize);
 }
 
 struct nf_conntrack_expect *
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 552f97c..4e0b478 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -126,7 +126,8 @@ hash_by_src(const struct net *net, u16 zone,
 	/* Original src, to ensure we map it consistently if poss. */
 	hash = jhash2((u32 *)&tuple->src, sizeof(tuple->src) / sizeof(u32),
 		      tuple->dst.protonum ^ zone ^ nf_conntrack_hash_rnd);
-	return ((u64)hash * net->ct.nat_htable_size) >> 32;
+
+	return reciprocal_scale(hash, net->ct.nat_htable_size);
 }
 
 /* Is this tuple already taken? (not by us) */
@@ -274,7 +275,7 @@ find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 		}
 
 		var_ipp->all[i] = (__force __u32)
-			htonl(minip + (((u64)j * dist) >> 32));
+			htonl(minip + reciprocal_scale(j, dist));
 		if (var_ipp->all[i] != range->max_addr.all[i])
 			full_range = true;
 
diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
index 73b73f6..02afaf4 100644
--- a/net/netfilter/xt_HMARK.c
+++ b/net/netfilter/xt_HMARK.c
@@ -126,7 +126,7 @@ hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
 	hash = jhash_3words(src, dst, t->uports.v32, info->hashrnd);
 	hash = hash ^ (t->proto & info->proto_mask);
 
-	return (((u64)hash * info->hmodulus) >> 32) + info->hoffset;
+	return reciprocal_scale(hash, info->hmodulus) + info->hoffset;
 }
 
 static void
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index f4af1bf..96fa26b 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -55,7 +55,8 @@ xt_cluster_hash(const struct nf_conn *ct,
 		WARN_ON(1);
 		break;
 	}
-	return (((u64)hash * info->total_nodes) >> 32);
+
+	return reciprocal_scale(hash, info->total_nodes);
 }
 
 static inline bool
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 47dc683..52eb3e0 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -135,7 +135,7 @@ hash_dst(const struct xt_hashlimit_htable *ht, const struct dsthash_dst *dst)
 	 * give results between [0 and cfg.size-1] and same hash distribution,
 	 * but using a multiply, less expensive than a divide
 	 */
-	return ((u64)hash * ht->cfg.size) >> 32;
+	return reciprocal_scale(hash, ht->cfg.size);
 }
 
 static struct dsthash_ent *
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 063b726..cc56c8b 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -77,7 +77,8 @@ static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
 	hash = jhash_3words((__force u32)keys.dst,
 			    (__force u32)keys.src ^ keys.ip_proto,
 			    (__force u32)keys.ports, q->perturbation);
-	return ((u64)hash * q->flows_cnt) >> 32;
+
+	return reciprocal_scale(hash, q->flows_cnt);
 }
 
 static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
-- 
1.9.3
