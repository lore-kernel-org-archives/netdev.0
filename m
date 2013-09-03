From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: use reciprocal_divide instead of reimplementing it
Date: Tue,  3 Sep 2013 12:26:50 +0200
Message-ID: <1378204010-27050-3-git-send-email-dborkman@redhat.com>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759869Ab3ICK0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 06:26:55 -0400
In-Reply-To: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace these places with reciprocal_divide() inline function instead of
reimplementing it each time, thus it will become easier to read. We do not
need to explicitly include its header as it's pulled in from linux/net.h
anyway.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: netfilter-devel@vger.kernel.org
---
 net/core/dev.c                      | 2 +-
 net/core/flow_dissector.c           | 5 ++---
 net/ipv4/inet_hashtables.c          | 2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c  | 2 +-
 net/ipv4/udp.c                      | 6 +++---
 net/ipv6/inet6_hashtables.c         | 2 +-
 net/ipv6/udp.c                      | 4 ++--
 net/netfilter/nf_conntrack_core.c   | 2 +-
 net/netfilter/nf_conntrack_expect.c | 2 +-
 net/netfilter/nf_nat_core.c         | 4 ++--
 net/netfilter/xt_HMARK.c            | 2 +-
 net/netfilter/xt_NFQUEUE.c          | 4 ++--
 net/netfilter/xt_cluster.c          | 2 +-
 net/netfilter/xt_hashlimit.c        | 2 +-
 net/sched/sch_fq_codel.c            | 2 +-
 15 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6fbb0c9..bc7c839 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3040,7 +3040,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	if (map) {
-		tcpu = map->cpus[((u64) skb->rxhash * map->len) >> 32];
+		tcpu = map->cpus[reciprocal_divide(skb->rxhash, map->len)];
 
 		if (cpu_online(tcpu)) {
 			cpu = tcpu;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 159737c..59521e0 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -233,7 +233,7 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		hash = (__force u16) skb->protocol;
 	hash = jhash_1word(hash, hashrnd);
 
-	return (u16) (((u64) hash * qcount) >> 32) + qoffset;
+	return (u16) reciprocal_divide(hash, qcount) + qoffset;
 }
 EXPORT_SYMBOL(__skb_tx_hash);
 
@@ -324,8 +324,7 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 					hash = (__force u16) skb->protocol ^
 					    skb->rxhash;
 				hash = jhash_1word(hash, hashrnd);
-				queue_index = map->queues[
-				    ((u64)hash * map->len) >> 32];
+				queue_index = map->queues[reciprocal_divide(hash, map->len)];
 			}
 			if (unlikely(queue_index >= dev->real_num_tx_queues))
 				queue_index = -1;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 7bd8983..731dcbf 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -204,7 +204,7 @@ begin:
 			}
 		} else if (score == hiscore && reuseport) {
 			matches++;
-			if (((u64)phash * matches) >> 32 == 0)
+			if (reciprocal_divide(phash, matches) == 0)
 				result = sk;
 			phash = next_pseudo_random32(phash);
 		}
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 0b732ef..0fede8b 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -273,7 +273,7 @@ clusterip_hashfn(const struct sk_buff *skb,
 	}
 
 	/* node numbers are 1..n, not 0..n */
-	return (((u64)hashval * config->num_total_nodes) >> 32) + 1;
+	return reciprocal_divide(hashval, config->num_total_nodes) + 1;
 }
 
 static inline int
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 74d2c95..5db0725 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -223,7 +223,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		remaining = (high - low) + 1;
 
 		rand = net_random();
-		first = (((u64)rand * remaining) >> 32) + low;
+		first = reciprocal_divide(rand, remaining) + low;
 		/*
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
 		 */
@@ -435,7 +435,7 @@ begin:
 			}
 		} else if (score == badness && reuseport) {
 			matches++;
-			if (((u64)hash * matches) >> 32 == 0)
+			if (reciprocal_divide(hash, matches) == 0)
 				result = sk;
 			hash = next_pseudo_random32(hash);
 		}
@@ -516,7 +516,7 @@ begin:
 			}
 		} else if (score == badness && reuseport) {
 			matches++;
-			if (((u64)hash * matches) >> 32 == 0)
+			if (reciprocal_divide(hash, matches) == 0)
 				result = sk;
 			hash = next_pseudo_random32(hash);
 		}
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 32b4a16..d9d8908 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -187,7 +187,7 @@ begin:
 			}
 		} else if (score == hiscore && reuseport) {
 			matches++;
-			if (((u64)phash * matches) >> 32 == 0)
+			if (reciprocal_divide(phash, matches) == 0)
 				result = sk;
 			phash = next_pseudo_random32(phash);
 		}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f405815..610013a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -226,7 +226,7 @@ begin:
 				goto exact_match;
 		} else if (score == badness && reuseport) {
 			matches++;
-			if (((u64)hash * matches) >> 32 == 0)
+			if (reciprocal_divide(hash, matches) == 0)
 				result = sk;
 			hash = next_pseudo_random32(hash);
 		}
@@ -306,7 +306,7 @@ begin:
 			}
 		} else if (score == badness && reuseport) {
 			matches++;
-			if (((u64)hash * matches) >> 32 == 0)
+			if (reciprocal_divide(hash, matches) == 0)
 				result = sk;
 			hash = next_pseudo_random32(hash);
 		}
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5d892fe..6378441 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -97,7 +97,7 @@ static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple, u16 zone)
 
 static u32 __hash_bucket(u32 hash, unsigned int size)
 {
-	return ((u64)hash * size) >> 32;
+	return reciprocal_divide(hash, size);
 }
 
 static u32 hash_bucket(u32 hash, const struct net *net)
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4fd1ca9..c0865e6 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -83,7 +83,7 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 	hash = jhash2(tuple->dst.u3.all, ARRAY_SIZE(tuple->dst.u3.all),
 		      (((tuple->dst.protonum ^ tuple->src.l3num) << 16) |
 		       (__force __u16)tuple->dst.u.all) ^ nf_conntrack_hash_rnd);
-	return ((u64)hash * nf_ct_expect_hsize) >> 32;
+	return reciprocal_divide(hash, nf_ct_expect_hsize);
 }
 
 struct nf_conntrack_expect *
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 6f0f4f7..ce9083e 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -126,7 +126,7 @@ hash_by_src(const struct net *net, u16 zone,
 	/* Original src, to ensure we map it consistently if poss. */
 	hash = jhash2((u32 *)&tuple->src, sizeof(tuple->src) / sizeof(u32),
 		      tuple->dst.protonum ^ zone ^ nf_conntrack_hash_rnd);
-	return ((u64)hash * net->ct.nat_htable_size) >> 32;
+	return reciprocal_divide(hash, net->ct.nat_htable_size);
 }
 
 /* Is this tuple already taken? (not by us) */
@@ -274,7 +274,7 @@ find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 		}
 
 		var_ipp->all[i] = (__force __u32)
-			htonl(minip + (((u64)j * dist) >> 32));
+			htonl(minip + reciprocal_divide(j, dist));
 		if (var_ipp->all[i] != range->max_addr.all[i])
 			full_range = true;
 
diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
index 73b73f6..3dd05c4 100644
--- a/net/netfilter/xt_HMARK.c
+++ b/net/netfilter/xt_HMARK.c
@@ -126,7 +126,7 @@ hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
 	hash = jhash_3words(src, dst, t->uports.v32, info->hashrnd);
 	hash = hash ^ (t->proto & info->proto_mask);
 
-	return (((u64)hash * info->hmodulus) >> 32) + info->hoffset;
+	return reciprocal_divide(hash, info->hmodulus) + info->hoffset;
 }
 
 static void
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 1e2fae3..88443c1 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -83,10 +83,10 @@ nfqueue_hash(const struct sk_buff *skb, const struct xt_action_param *par)
 	u32 queue = info->queuenum;
 
 	if (par->family == NFPROTO_IPV4)
-		queue += ((u64) hash_v4(skb) * info->queues_total) >> 32;
+		queue += reciprocal_divide(hash_v4(skb), info->queues_total);
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	else if (par->family == NFPROTO_IPV6)
-		queue += ((u64) hash_v6(skb) * info->queues_total) >> 32;
+		queue += reciprocal_divide(hash_v6(skb), info->queues_total);
 #endif
 
 	return queue;
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index f4af1bf..845fc16 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -55,7 +55,7 @@ xt_cluster_hash(const struct nf_conn *ct,
 		WARN_ON(1);
 		break;
 	}
-	return (((u64)hash * info->total_nodes) >> 32);
+	return reciprocal_divide(hash, info->total_nodes);
 }
 
 static inline bool
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 9ff035c..9af9021 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -135,7 +135,7 @@ hash_dst(const struct xt_hashlimit_htable *ht, const struct dsthash_dst *dst)
 	 * give results between [0 and cfg.size-1] and same hash distribution,
 	 * but using a multiply, less expensive than a divide
 	 */
-	return ((u64)hash * ht->cfg.size) >> 32;
+	return reciprocal_divide(hash, ht->cfg.size);
 }
 
 static struct dsthash_ent *
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 5578628..4869671 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -77,7 +77,7 @@ static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
 	hash = jhash_3words((__force u32)keys.dst,
 			    (__force u32)keys.src ^ keys.ip_proto,
 			    (__force u32)keys.ports, q->perturbation);
-	return ((u64)hash * q->flows_cnt) >> 32;
+	return reciprocal_divide(hash, q->flows_cnt);
 }
 
 static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
-- 
1.7.11.7
