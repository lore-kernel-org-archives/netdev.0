From: Juliusz Chroboczek <jch@pps.jussieu.fr>
Subject: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 00:37:12 +0200
Message-ID: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from witko.kerneis.info ([213.186.56.95]:52960 "EHLO
	witko.kerneis.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbYDGXCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 19:02:09 -0400
Received: from [2001:660:3301:8063:20e:35ff:fea5:9005] (helo=ip6-localhost)
	by witko.kerneis.info with esmtpsa (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <jch@pps.jussieu.fr>)
	id 1Jizxh-0004Yy-EG
	for netdev@vger.kernel.org; Tue, 08 Apr 2008 00:37:13 +0200
Received: from jch by ip6-localhost with local (Exim 4.69)
	(envelope-from <jch@pirx.pps.jussieu.fr>)
	id 1Jizxh-0002dR-2Y
	for netdev@vger.kernel.org; Tue, 08 Apr 2008 00:37:13 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The attached is an implementation of the Stochastic Fair Blue queue
discipline for Linux.

I would like to request a review of the following code, and whether it
is worthwile to add the Kconfig bits and submit it for inclusion into
the mainline kernel.

You will find a ready to build tarball on

  http://www.pps.jussieu.fr/~jch/software/files/sch_sfb-20080407.tar.gz
  http://www.pps.jussieu.fr/~jch/software/files/sch_sfb-20080407.tar.gz.asc

and a short description on

  http://www.pps.jussieu.fr/~jch/software/sfb/

Thanks,

                                        Juliusz Chroboczek

diff -urN empty/Makefile sch_sfb/Makefile
--- empty/Makefile	1970-01-01 01:00:00.000000000 +0100
+++ sch_sfb/Makefile	2008-04-08 00:28:43.000000000 +0200
@@ -0,0 +1,11 @@
+KERNEL_SOURCE=/lib/modules/$(shell uname -r)/build
+
+obj-m += sch_sfb.o
+
+all:
+	make -C $(KERNEL_SOURCE) M=$(PWD) modules
+
+clean:
+	make -C $(KERNEL_SOURCE) M=$(PWD) clean
+	-rm -f *~ Module.symvers
+
diff -urN empty/README sch_sfb/README
--- empty/README	1970-01-01 01:00:00.000000000 +0100
+++ sch_sfb/README	2008-04-08 00:28:43.000000000 +0200
@@ -0,0 +1,160 @@
+                    Stochastic Fair Blue for Linux
+                    ******************************
+
+
+Sch_sfb is an implementation of the Stochastic Fair Blue (SFB) queue
+management algorithm for Linux.  SFB is described in
+
+  Stochastic Fair Blue: A Queue Management Algorithm for Enforcing
+  Fairness.  Wu-chang Feng, Dilip D. Kandlur, Debanjan Saha and
+  Kang G. Shin.  Proc. INFOCOM'01. 2001.
+
+SFB aims to keep your queues short while avoiding packet drops,
+maximising link utilisation and preserving fairness between flows.
+SFB will detect flows that do not respond to congestion indications,
+and limit them to a constant share of the link's capacity.
+
+SFB only deals with marking and/or droping packets.  Reordering of
+packets is handled by sfb's child qdisc; by default, this is pfifo,
+meaning that no reordering will happen.  You may want to use something
+like prio or sfq as sfb's child.
+
+Unlike most other fair queueing policies, SFB doesn't actually keep
+per-flow state; it manages flow information using a Bloom filter,
+which means that hash collisions are reduced to a minimum while using
+fairly little memory.
+
+
+Differences from the paper
+**************************
+
+This implementation takes the minimum of the mark probabilities of all
+matching buckets, rather than the maximum, as suggested in the paper.
+Either the paper is wrong, or I don't understand how Bloom filters
+work.
+
+If an aggregate has a very high marking rate, then either it is
+unresponsive, or we are badly congested.  In either case, it is a good
+idea to start dropping packets rather than just marking them.  If pm
+is below 1/2, we mark with probability pm; if pm is larger than 1/2,
+then we drop with probability pm * (2 * pm - 1/2), and mark with
+probability pm * (3/2 - 2 * pm).
+
+
+Quick start:
+************
+
+  tc qdisc add dev eth0 root handle 1: sfb
+
+Sfb only deals with marking/dropping packets, but doesn't reorder
+them.  You may want to put a reordering qdisc below sfb.
+
+  tc qdisc add dev eth0 handle 2: parent 1: prio
+
+Since sfb penalises inelastic flows rather severely, you may want to
+put another qdisc above sfb to bypass sfb for such flows.  And of
+course if you're rate-limiting (e.g. using cbq, tbf or htb) you'll
+want to do that above sfb.
+
+If you have the patched version of tc (see below), you may set
+non-default values and see some of sfb's statistics:
+
+  tc qdisc add dev eth0 root handle 1: sfb target 30 max 50 penalty_rate 100
+  tc -s qdisc show dev eth0
+
+
+Building
+********
+
+  $ cd sch_sfb/
+  $ make KERNEL_SOURCE=/usr/src/linux
+  $ insmod ./sch_sfb.ko
+
+You will also want to patch your tc tool; a patch for current versions
+of iproute2 is in the file iproute-sfb.patch.
+
+
+Parameters
+**********
+
+hash-type: one of ``flow'' (per-flow hashing), ``source'' (hash on the
+source IP address), ``dest'' (hash on the destination address), or
+``source-dest'' (hash on both the source and destination addresses).
+
+hashes HASHES, buckets BUCKETS: the size of the Bloom filter to use.
+The amount of space used is proportional to HASHES x BUCKETS, and the
+per-packet CPU time is roughly proportional to HASHES.
+
+rehash SECS: specifies how often we will switch to a fresh Bloom
+filter and a different set of hash functions.  Since Bloom filters are
+more resistent to hash collisions that hash tables, this may be set to
+a fairly large value.
+
+db SECS: specifies fow how long we will perform double-buffering
+before switching to a new Bloom filter.  This should be long enough to
+make sure that the new filter is ``primed'' before it is used, a few
+tens of seconds should be enough.
+
+limit PACKETS: the hard limit on the number of packets in sfb's queue.
+Set it to some large value, it should never be reached anyway.
+
+target PACKETS: the target per-flow queue size in packets.  sfb will
+try to keep each per-aggregate queue between 0 and target.
+
+max PACKETS: the maximum number of packets queued for a given aggregate.
+It should be very slightly larger than target, in order to absorb
+transient bursts.  Setting this to more than roughly 1.5 times target
+will cause instabilities that Blue is not designed to cope with.
+
+increment FLOAT, decrement FLOAT: the values by which per-flow
+dropping probability is in/decreased on queue under/overflow.  These
+should be a small fraction of a percent, and increment should be a few
+times smaller than decrement.
+
+penalty_rate PPS, penalty_burst PACKETS: when a flow doesn't back off
+in response to congestion indication, sbf will categorise it as
+``non-reactive'' and will rate-limit it.  Penalty-rate specifies the
+total throughput that non-reactive flows are allowed to use; burst is
+the size of the token bucket.  You should set penalty_rate to some
+reasonable fraction of your up-link throughput (the default values are
+probably too small).
+
+
+Statistics
+**********
+
+  $ tc -s qdisc show dev eth1
+  ...
+  qdisc sfb 2: dev eth1 parent 1: hash flow limit 1000 max 30 target 20
+    increment 0.00050 decrement 0.00005 penalty rate 10 burst 20 (600s 60s 8x24)
+   Sent 9317012 bytes 74577 pkt (dropped 3165, overlimits 3235 requeues 58519) 
+   rate 0bit 0pps backlog 0b 0p requeues 58519 
+    earlydrop 2196 ratedrop 0 bucketdrop 969 queuedrop 0 marked 70
+    maxqlen 0 maxprob 0.01494
+
+earlydrop: the number of packets dropped before a per-flow queue was full.
+
+ratedrop: the number of packets dropped because of rate-limiting.
+
+bucketdrop: the number of packets dropped because a per-flow queue was
+full.
+
+queuedrop: the number of packets dropped due to reaching limit.  This
+should normally be 0.
+
+marked: the number of packets marked with ECN.
+
+maxqlen: the length of the longest per-flow (virtual) queue.
+
+maxprob: the maximum per-flow drop probability.  1 means that some
+flows have been detected as non-reactive.
+
+
+If ratedrop is high, you're sending your non-reactive flows through
+sfb; this may not be a good idea.  If bucketdrop is high, you're
+probably sending a lot of aggressive short-lived flows through sfb.
+If queuedrop is not 0, something is wrong.
+
+
+                                        Juliusz Chroboczek
+                                        <jch@pps.jussieu.fr>
diff -urN empty/sch_sfb.c sch_sfb/sch_sfb.c
--- empty/sch_sfb.c	1970-01-01 01:00:00.000000000 +0100
+++ sch_sfb/sch_sfb.c	2008-04-08 00:29:14.000000000 +0200
@@ -0,0 +1,687 @@
+/*
+ * sch_sfb.c    Stochastic Fair Blue
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Juliusz Chroboczek <jch@pps.jussieu.fr>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/random.h>
+#include <linux/jhash.h>
+#include <net/ip.h>
+#include <net/pkt_sched.h>
+#include <net/inet_ecn.h>
+
+#include "sfb.h"
+
+struct bucket {
+        u16 qlen;
+        u16 pm;
+};
+
+struct sfb_sched_data
+{
+        u16 numhashes, numbuckets;
+        u16 rehash_interval, db_interval;
+        u16 max, target;
+        u16 increment, decrement;
+        u32 limit;
+        u32 penalty_rate, penalty_burst;
+        u32 tokens_avail;
+        psched_time_t rehash_time, token_time;
+
+        u8 hash_type;
+        u8 filter;
+        u8 double_buffering;
+        u32 perturbation[2][MAXHASHES];
+        struct bucket buckets[2][MAXHASHES][MAXBUCKETS];
+	struct Qdisc *qdisc;
+
+        __u32 earlydrop, penaltydrop, bucketdrop, queuedrop, marked;
+};
+
+static unsigned sfb_hash(struct sk_buff *skb, int hash, int filter,
+                         struct sfb_sched_data *q)
+{
+	u32 h, h2;
+        u8 hash_type = q->hash_type;
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+	{
+		const struct iphdr *iph = ip_hdr(skb);
+		h = hash_type == SFB_HASH_SOURCE ? 0 : iph->daddr;
+		h2 = hash_type == SFB_HASH_DEST ? 0 : iph->saddr;
+		if (hash_type == SFB_HASH_FLOW) {
+                        h2 ^= iph->protocol;
+                        if(!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
+                           (iph->protocol == IPPROTO_TCP ||
+                            iph->protocol == IPPROTO_UDP ||
+                            iph->protocol == IPPROTO_UDPLITE ||
+                            iph->protocol == IPPROTO_SCTP ||
+                            iph->protocol == IPPROTO_DCCP ||
+                            iph->protocol == IPPROTO_ESP)) {
+                                h2 ^= *(((u32*)iph) + iph->ihl);
+                        }
+                }
+		break;
+	}
+	case __constant_htons(ETH_P_IPV6):
+	{
+		struct ipv6hdr *iph = ipv6_hdr(skb);
+		h = hash_type == SFB_HASH_SOURCE ? 0 :
+                        iph->daddr.s6_addr32[1] ^ iph->daddr.s6_addr32[3];
+		h2 = hash_type == SFB_HASH_DEST ? 0 :
+                        iph->saddr.s6_addr32[1] ^ iph->saddr.s6_addr32[3];
+                if (hash_type == SFB_HASH_FLOW) {
+                        h2 ^= iph->nexthdr;
+                        if(iph->nexthdr == IPPROTO_TCP ||
+                           iph->nexthdr == IPPROTO_UDP ||
+                           iph->nexthdr == IPPROTO_UDPLITE ||
+                           iph->nexthdr == IPPROTO_SCTP ||
+                           iph->nexthdr == IPPROTO_DCCP ||
+                           iph->nexthdr == IPPROTO_ESP)
+                                h2 ^= *(u32*)&iph[1];
+                }
+		break;
+	}
+	default:
+		h = skb->protocol;
+                if(hash_type != SFB_HASH_SOURCE)
+                        h ^= (u32)(unsigned long)skb->dst;
+                h2 = hash_type == SFB_HASH_FLOW ?
+                        (u32)(unsigned long)skb->sk : 0;
+	}
+
+        return jhash_2words(h, h2, q->perturbation[filter][hash]) %
+                q->numbuckets;
+
+}
+
+static inline u16 prob_plus(u16 p1, u16 p2)
+{
+        return p1 < SFB_MAX_PROB - p2 ? p1 + p2 : SFB_MAX_PROB;
+}
+
+static inline u16 prob_minus(u16 p1, u16 p2)
+{
+        return p1 > p2 ? p1 - p2 : 0;
+}
+
+static void
+increment_one_qlen(struct sk_buff *skb, int filter, struct sfb_sched_data *q)
+{
+        int i;
+        for(i = 0; i < q->numhashes; i++) {
+                unsigned hash = sfb_hash(skb, i, filter, q);
+                if(q->buckets[filter][i][hash].qlen < 0xFFFF)
+                        q->buckets[filter][i][hash].qlen++;
+        }
+}
+
+static void
+increment_qlen(struct sk_buff *skb, struct sfb_sched_data *q)
+{
+        increment_one_qlen(skb, q->filter, q);
+        if(q->double_buffering)
+                increment_one_qlen(skb, !q->filter, q);
+}
+
+static void
+decrement_one_qlen(struct sk_buff *skb, int filter, struct sfb_sched_data *q)
+{
+        int i;
+        for(i = 0; i < q->numhashes; i++) {
+                unsigned hash = sfb_hash(skb, i, filter, q);
+                if(q->buckets[filter][i][hash].qlen > 0)
+                    q->buckets[filter][i][hash].qlen--;
+        }
+}
+
+static void
+decrement_qlen(struct sk_buff *skb, struct sfb_sched_data *q)
+{
+        decrement_one_qlen(skb, q->filter, q);
+        if(q->double_buffering)
+                decrement_one_qlen(skb, !q->filter, q);
+}
+
+static inline void
+decrement_prob(int filter, int bucket, unsigned hash, struct sfb_sched_data *q)
+{
+        q->buckets[filter][bucket][hash].pm =
+                prob_minus(q->buckets[filter][bucket][hash].pm,
+                           q->decrement);
+}
+
+static inline void
+increment_prob(int filter, int bucket, unsigned hash, struct sfb_sched_data *q)
+{
+        q->buckets[filter][bucket][hash].pm =
+                prob_plus(q->buckets[filter][bucket][hash].pm,
+                           q->increment);
+}
+
+static void
+zero_all_buckets(int filter, struct sfb_sched_data *q)
+{
+        int i, j;
+        for(i = 0; i < MAXHASHES; i++) {
+                for(j = 0; j < MAXBUCKETS; j++) {
+                        q->buckets[filter][i][j].pm = 0;
+                        q->buckets[filter][i][j].qlen = 0;
+                }
+        }
+}
+
+static void
+compute_qlen(u16 *qlen_r, u16 *prob_r, struct sfb_sched_data *q)
+{
+        int i, j, filter = q->filter;
+        u16 qlen = 0, prob = 0;
+        for(i = 0; i < q->numhashes; i++) {
+                for(j = 0; j < q->numbuckets; j++) {
+                        if(qlen < q->buckets[filter][i][j].qlen)
+                                qlen = q->buckets[filter][i][j].qlen;
+                        if(qlen < q->buckets[filter][i][j].pm)
+                                prob = q->buckets[filter][i][j].pm;
+                }
+        }
+        *qlen_r = qlen;
+        *prob_r = prob;
+}
+
+
+static void
+init_perturbation(int filter, struct sfb_sched_data *q)
+{
+        get_random_bytes(q->perturbation[filter],
+                         sizeof(q->perturbation[filter]));
+}
+
+static void
+swap_buffers(struct sfb_sched_data *q)
+{
+        q->filter = !q->filter;
+        zero_all_buckets(!q->filter, q);
+        init_perturbation(!q->filter, q);
+        q->double_buffering = 0;
+}
+
+static int rate_limit(struct sk_buff *skb, psched_time_t now,
+                      struct sfb_sched_data* q)
+{
+        if(q->penalty_rate == 0 || q->penalty_burst == 0)
+                return 1;
+
+        if(q->tokens_avail < 1) {
+                psched_tdiff_t age;
+
+                age = psched_tdiff_bounded(now, q->token_time,
+                                           256 * PSCHED_TICKS_PER_SEC);
+                q->tokens_avail =
+                        (age * q->penalty_rate / PSCHED_TICKS_PER_SEC);
+                if(q->tokens_avail > q->penalty_burst)
+                        q->tokens_avail = q->penalty_burst;
+                q->token_time = now;
+                if(q->tokens_avail < 1)
+                        return 1;
+        }
+
+        q->tokens_avail--;
+        return 0;
+}
+
+static int sfb_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+{
+
+	struct sfb_sched_data *q = qdisc_priv(sch);
+        struct Qdisc *child = q->qdisc;
+        psched_time_t now;
+        int filter;
+        u16 minprob = SFB_MAX_PROB;
+        u16 minqlen = (u16)(~0);
+        u32 r;
+        int ret, i;
+
+        now = psched_get_time();
+
+        if(q->rehash_interval > 0) {
+                psched_tdiff_t age;
+                age = psched_tdiff_bounded(now, q->rehash_time,
+                                           q->rehash_interval *
+                                           PSCHED_TICKS_PER_SEC);
+                if(unlikely(age >= q->rehash_interval * PSCHED_TICKS_PER_SEC)) {
+                        swap_buffers(q);
+                        q->rehash_time = now;
+                }
+                if(unlikely(!q->double_buffering && q->db_interval > 0 &&
+                            age >= (q->rehash_interval - q->db_interval) *
+                            PSCHED_TICKS_PER_SEC))
+                        q->double_buffering = 1;
+        }
+
+        filter = q->filter;
+
+        for(i = 0; i < q->numhashes; i++) {
+                unsigned hash = sfb_hash(skb, i, filter, q);
+                if(q->buckets[filter][i][hash].qlen == 0)
+                        decrement_prob(filter, i, hash, q);
+                else if(unlikely(q->buckets[filter][i][hash].qlen >= q->target))
+                        increment_prob(filter, i, hash, q);
+                if(minqlen > q->buckets[filter][i][hash].qlen)
+                        minqlen = q->buckets[filter][i][hash].qlen;
+                if(minprob > q->buckets[filter][i][hash].pm)
+                        minprob = q->buckets[filter][i][hash].pm;
+        }
+
+        if(q->double_buffering) {
+                for(i = 0; i < q->numhashes; i++) {
+                        unsigned hash = sfb_hash(skb, i, !filter, q);
+                        if(q->buckets[!filter][i][hash].qlen == 0)
+                                decrement_prob(!filter, i, hash, q);
+                        else if(unlikely(q->buckets[!filter][i][hash].qlen >=
+                                         q->target))
+                                increment_prob(!filter, i, hash, q);
+                }
+        }
+        
+        if(unlikely(minqlen >= q->max || sch->q.qlen >= q->limit)) {
+                sch->qstats.overlimits++;
+                if(likely(minqlen >= q->max))
+                        q->bucketdrop++;
+                else
+                        q->queuedrop++;
+                goto drop;
+        }
+
+        if(unlikely(minprob >= SFB_MAX_PROB)) {
+                /* Inelastic flow */
+                if(rate_limit(skb, now, q)) {
+                        sch->qstats.overlimits++;
+                        q->penaltydrop++;
+                        goto drop;
+                }
+                goto enqueue;
+        }
+
+        r = net_random() & SFB_MAX_PROB;
+
+        if(unlikely(r < minprob)) {
+                if(unlikely(minprob > SFB_MAX_PROB / 2)) {
+                        /* If we're marking that many packets, then either
+                           this flow is unresponsive, or we're badly congested.
+                           In either case, we want to start dropping packets. */
+                        if(r < (minprob - SFB_MAX_PROB / 2) * 2) {
+                                q->earlydrop++;
+                                goto drop;
+                        }
+                }
+                if(INET_ECN_set_ce(skb)) {
+                        q->marked++;
+                } else {
+                        q->earlydrop++;
+                        goto drop;
+                }
+        }
+
+ enqueue:
+        ret = child->enqueue(skb, child);
+        if(likely(ret == NET_XMIT_SUCCESS)) {
+                sch->q.qlen++;
+                increment_qlen(skb, q);
+		sch->bstats.packets++;
+		sch->bstats.bytes += skb->len;
+                sch->qstats.backlog += skb->len;
+        } else {
+                q->queuedrop++;
+        }
+        return ret;
+
+ drop:
+        qdisc_drop(skb, sch);
+        return NET_XMIT_CN;
+}
+
+static int sfb_requeue(struct sk_buff *skb, struct Qdisc* sch)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+        struct Qdisc *child = q->qdisc;
+        int ret;
+
+        ret = child->ops->requeue(skb, child);
+        if(unlikely(ret != NET_XMIT_SUCCESS)) {
+                sch->qstats.drops++;
+                return ret;
+        }
+
+        sch->q.qlen++;
+        increment_qlen(skb, q);
+        sch->qstats.backlog += skb->len;
+        sch->qstats.requeues++;
+        return ret;
+}
+
+static struct sk_buff *sfb_dequeue(struct Qdisc* sch)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+        struct Qdisc *child = q->qdisc;
+	struct sk_buff *skb;
+
+	skb = child->dequeue(q->qdisc);
+
+        if(skb) {
+                sch->q.qlen--;
+		sch->qstats.backlog -= skb->len;
+                decrement_qlen(skb, q);
+        }
+
+        return skb;
+}
+
+static void sfb_reset(struct Qdisc* sch)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+
+	qdisc_reset(q->qdisc);
+        sch->q.qlen = 0;
+        sch->qstats.backlog = 0;
+        q->filter = 0;
+        q->double_buffering = 0;
+        zero_all_buckets(0, q);
+        zero_all_buckets(1, q);
+        init_perturbation(q->filter, q);
+}
+
+static void sfb_destroy(struct Qdisc *sch)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	qdisc_destroy(q->qdisc);
+        q->qdisc = NULL;
+}
+
+static struct Qdisc *sfb_create_dflt(struct Qdisc *sch, u32 limit)
+{
+	struct Qdisc *q;
+	struct rtattr *rta;
+	int ret;
+
+	q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+			      TC_H_MAKE(sch->handle, 1));
+	if (q) {
+		rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)),
+			      GFP_KERNEL);
+		if (rta) {
+			rta->rta_type = RTM_NEWQDISC;
+			rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
+			((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
+
+			ret = q->ops->change(q, rta);
+			kfree(rta);
+
+			if (ret == 0)
+				return q;
+		}
+		qdisc_destroy(q);
+	}
+	return NULL;
+}
+
+static int sfb_change(struct Qdisc *sch, struct rtattr *opt)
+{
+        struct sfb_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *child = NULL;
+	struct rtattr *tb[TCA_SFB_MAX];
+	struct tc_sfb_qopt *ctl;
+        u16 numhashes, numbuckets, rehash_interval, db_interval;
+        u8 hash_type;
+        u32 limit;
+        u16 max, target;
+        u16 increment, decrement;
+        u32 penalty_rate, penalty_burst;
+
+	if (opt == NULL) {
+                numhashes = 6;
+                numbuckets = 32;
+                hash_type = SFB_HASH_FLOW;
+                rehash_interval = 600;
+                db_interval = 60;
+                limit = 0;
+                max = 25;
+                target = 20;
+                increment = (SFB_MAX_PROB + 1000) / 2000;
+                decrement = (SFB_MAX_PROB + 10000) / 20000;
+                penalty_rate = 10;
+                penalty_burst = 20;
+        } else {
+                if(rtattr_parse_nested(tb, TCA_SFB_MAX, opt))
+                        return -EINVAL;
+
+                if (tb[TCA_SFB_PARMS-1] == NULL ||
+                    RTA_PAYLOAD(tb[TCA_SFB_PARMS-1]) < sizeof(*ctl))
+                        return -EINVAL;
+                
+                ctl = RTA_DATA(tb[TCA_SFB_PARMS-1]);
+                numhashes = ctl->numhashes;
+                numbuckets = ctl->numbuckets;
+                rehash_interval = ctl->rehash_interval;
+                db_interval = ctl->db_interval;
+                hash_type = ctl->hash_type;
+                limit = ctl->limit;
+                max = ctl->max;
+                target = ctl->target;
+                increment = ctl->increment;
+                decrement = ctl->decrement;
+                penalty_rate = ctl->penalty_rate;
+                penalty_burst = ctl->penalty_burst;
+        }
+
+        if(numbuckets <= 0 || numbuckets > MAXBUCKETS)
+                numbuckets = MAXBUCKETS;
+        if(numhashes <= 0 || numhashes > MAXHASHES)
+                numhashes = MAXHASHES;
+        if(hash_type >= __SFB_HASH_MAX)
+                hash_type = SFB_HASH_FLOW;
+        if(limit == 0)
+                limit = sch->dev->tx_queue_len ? sch->dev->tx_queue_len : 1;
+
+        child = sfb_create_dflt(sch, limit);
+        if(child == NULL)
+                return -ENOMEM;
+                
+        sch_tree_lock(sch);
+	if(child) {
+		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
+		qdisc_destroy(xchg(&q->qdisc, child));
+	}
+
+        q->numhashes = numhashes;
+        q->numbuckets = numbuckets;
+        q->rehash_interval = rehash_interval;
+        q->db_interval = db_interval;
+        q->hash_type = hash_type;
+        q->limit = limit;
+        q->increment = increment;
+        q->decrement = decrement;
+        q->max = max;
+        q->target = target;
+        q->penalty_rate = penalty_rate;
+        q->penalty_burst = penalty_burst;
+
+        q->filter = 0;
+        q->double_buffering = 0;
+        zero_all_buckets(0, q);
+        zero_all_buckets(1, q);
+        init_perturbation(q->filter, q);
+
+	sch_tree_unlock(sch);
+
+	return 0;
+}
+
+static int sfb_init(struct Qdisc *sch, struct rtattr *opt)
+{
+      	struct sfb_sched_data *q = qdisc_priv(sch);
+
+        q->qdisc = &noop_qdisc;
+        return sfb_change(sch, opt);
+}
+
+static int sfb_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct rtattr *opts = NULL;
+	struct tc_sfb_qopt opt = { .numhashes = q->numhashes,
+                                   .numbuckets = q->numbuckets,
+                                   .rehash_interval = q->rehash_interval,
+                                   .db_interval = q->db_interval,
+                                   .hash_type = q->hash_type,
+                                   .limit = q->limit,
+                                   .max = q->max,
+                                   .target = q->target,
+                                   .increment = q->increment,
+                                   .decrement = q->decrement,
+                                   .penalty_rate = q->penalty_rate,
+                                   .penalty_burst = q->penalty_burst,
+        };
+
+	opts = RTA_NEST(skb, TCA_OPTIONS);
+	RTA_PUT(skb, TCA_SFB_PARMS, sizeof(opt), &opt);
+	return RTA_NEST_END(skb, opts);
+
+rtattr_failure:
+	return -1;
+}
+
+static int sfb_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct tc_sfb_xstats st = { .earlydrop = q->earlydrop,
+                                    .penaltydrop = q->penaltydrop,
+                                    .bucketdrop = q->bucketdrop,
+                                    .marked = q->marked};
+
+        compute_qlen(&st.maxqlen, &st.maxprob, q);
+
+	return gnet_stats_copy_app(d, &st, sizeof(st));
+}
+        
+static int sfb_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+        return -ENOSYS;
+}
+
+static int sfb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		     struct Qdisc **old)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+
+	if (new == NULL)
+		new = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	*old = xchg(&q->qdisc, new);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static struct Qdisc *sfb_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	return q->qdisc;
+}
+
+static unsigned long sfb_get(struct Qdisc *sch, u32 classid)
+{
+	return 1;
+}
+
+static void sfb_put(struct Qdisc *sch, unsigned long arg)
+{
+	return;
+}
+
+static int sfb_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			    struct rtattr **tca, unsigned long *arg)
+{
+	return -ENOSYS;
+}
+
+static int sfb_delete(struct Qdisc *sch, unsigned long cl)
+{
+	return -ENOSYS;
+}
+
+static void sfb_walk(struct Qdisc *sch, struct qdisc_walker *walker)
+{
+	if (!walker->stop) {
+		if (walker->count >= walker->skip)
+			if (walker->fn(sch, 1, walker) < 0) {
+				walker->stop = 1;
+				return;
+			}
+		walker->count++;
+	}
+}
+
+static struct tcf_proto **sfb_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	return NULL;
+}
+
+static struct Qdisc_class_ops sfb_class_ops =
+{
+	.graft		=	sfb_graft,
+	.leaf		=	sfb_leaf,
+	.get		=	sfb_get,
+	.put		=	sfb_put,
+	.change		=	sfb_change_class,
+	.delete		=	sfb_delete,
+	.walk		=	sfb_walk,
+	.tcf_chain	=	sfb_find_tcf,
+	.dump		=	sfb_dump_class,
+};
+
+struct Qdisc_ops sfb_qdisc_ops = {
+	.id		=	"sfb",
+	.priv_size	=	sizeof(struct sfb_sched_data),
+	.cl_ops		=	&sfb_class_ops,
+	.enqueue	=	sfb_enqueue,
+	.dequeue	=	sfb_dequeue,
+	.requeue	=	sfb_requeue,
+	.init		=	sfb_init,
+	.reset		=	sfb_reset,
+	.destroy	=	sfb_destroy,
+	.change		=	sfb_change,
+	.dump		=	sfb_dump,
+	.dump_stats	=	sfb_dump_stats,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init sfb_module_init(void)
+{
+	return register_qdisc(&sfb_qdisc_ops);
+}
+
+static void __exit sfb_module_exit(void)
+{
+	unregister_qdisc(&sfb_qdisc_ops);
+}
+
+module_init(sfb_module_init)
+module_exit(sfb_module_exit)
+
+MODULE_DESCRIPTION("Stochastic Fair Blue queue discipline");
+MODULE_AUTHOR("Juliusz Chroboczek");
+MODULE_LICENSE("GPL");
diff -urN empty/sfb.h sch_sfb/sfb.h
--- empty/sfb.h	1970-01-01 01:00:00.000000000 +0100
+++ sch_sfb/sfb.h	2008-04-08 00:28:43.000000000 +0200
@@ -0,0 +1,52 @@
+/*
+ * sfb.h        Stochastic Fair Blue
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Juliusz Chroboczek <jch@pps.jussieu.fr>
+ */
+
+#include <linux/types.h>
+
+#define MAXHASHES 12
+#define MAXBUCKETS 32
+
+enum
+{
+	TCA_SFB_UNSPEC,
+	TCA_SFB_PARMS,
+	__TCA_SFB_MAX,
+};
+
+enum {
+        SFB_HASH_FLOW,
+        SFB_HASH_SOURCE,
+        SFB_HASH_DEST,
+        SFB_HASH_SOURCE_DEST,
+        __SFB_HASH_MAX,
+};
+
+#define TCA_SFB_MAX (__TCA_SFB_MAX - 1)
+
+struct tc_sfb_qopt
+{
+        __u8 hash_type, pad;
+        __u16 numhashes, numbuckets;
+        __u16 rehash_interval, db_interval;
+        __u16 max, target;
+        __u16 increment, decrement;
+        __u16 pad2;
+        __u32 limit;
+        __u32 penalty_rate, penalty_burst;
+};
+
+struct tc_sfb_xstats
+{
+        __u32 earlydrop, penaltydrop, bucketdrop, queuedrop, marked;
+        __u16 maxqlen, maxprob;
+};
+
+#define SFB_MAX_PROB 0xFFFF
diff --git a/tc/Makefile b/tc/Makefile
index 0facc88..2e7cddb 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -13,6 +13,7 @@ TCMODULES += q_tbf.o
 TCMODULES += q_cbq.o
 TCMODULES += q_rr.o
 TCMODULES += q_netem.o
+TCMODULES += q_sfb.o
 TCMODULES += f_rsvp.o
 TCMODULES += f_u32.o
 TCMODULES += f_route.o
diff --git a/tc/q_sfb.c b/tc/q_sfb.c
new file mode 100644
index 0000000..41512db
--- /dev/null
+++ b/tc/q_sfb.c
@@ -0,0 +1,252 @@
+/*
+ * q_red.c	Stochastic Fair Blue.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Juliusz Chroboczek <jch@pps.jussieu.fr>
+ *
+ */
+
+
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+
+#include "utils.h"
+#include "tc_util.h"
+
+#include "sfb.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+                "Usage: ... sfb "
+                "hashes N buckets N hash-type TYPE rehash SECS db SECS\n"
+                "           limit PACKETS max PACKETS target PACKETS\n"
+                "           increment FLOAT decrement FLOAT\n"
+                "           penalty_rate PPS penalty_burst PACKETS\n");
+}
+
+static int get_prob(__u16 *val, const char *arg)
+{
+        double d;
+        char *ptr;
+
+        if(!arg || !*arg)
+                return -1;
+        d = strtod(arg, &ptr);
+        if(!ptr || ptr == arg || d < 0.0 || d > 1.0)
+                return -1;
+        *val = (__u16)(d * SFB_MAX_PROB + 0.5);
+        return 0;
+}
+
+static char *
+hash_type(__u8 val)
+{
+        switch(val) {
+        case SFB_HASH_FLOW: return "flow";
+        case SFB_HASH_SOURCE: return "source";
+        case SFB_HASH_DEST: return "dest";
+        case SFB_HASH_SOURCE_DEST: return "source-dest";
+        default: return "???";
+        }
+}
+
+static int get_hash_type(__u8 *val, const char *arg)
+{
+        if(strcmp(arg, "flow") == 0)
+                *val = SFB_HASH_FLOW;
+        else if(strcmp(arg, "source") == 0)
+                *val = SFB_HASH_SOURCE;
+        else if(strcmp(arg, "dest") == 0)
+                *val = SFB_HASH_DEST;
+        else if(strcmp(arg, "source-dest") == 0)
+                *val = SFB_HASH_SOURCE_DEST;
+        else
+                return -1;
+
+        return 0;
+}
+
+static int sfb_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+                         struct nlmsghdr *n)
+{
+	struct tc_sfb_qopt opt;
+	struct rtattr *tail;
+
+	memset(&opt, 0, sizeof(opt));
+        opt.numhashes = 6;
+        opt.numbuckets = 32;
+        opt.rehash_interval = 600;
+        opt.db_interval = 60;
+        opt.penalty_rate = 10;
+        opt.penalty_burst = 20;
+        opt.increment = (SFB_MAX_PROB + 1000) / 2000;
+        opt.decrement = (SFB_MAX_PROB + 10000) / 20000;
+
+	while (argc > 0) {
+                if (strcmp(*argv, "hashes") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.numhashes, *argv, 0)) {
+				fprintf(stderr, "Illegal \"hashes\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "buckets") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.numbuckets, *argv, 0)) {
+				fprintf(stderr, "Illegal \"buckets\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "hash-type") == 0) {
+			NEXT_ARG();
+			if (get_hash_type(&opt.hash_type, *argv)) {
+				fprintf(stderr, "Illegal \"hash-type\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "rehash") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.rehash_interval, *argv, 0)) {
+				fprintf(stderr, "Illegal \"rehash\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "db") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.db_interval, *argv, 0)) {
+				fprintf(stderr, "Illegal \"db\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "max") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.max, *argv, 0)) {
+				fprintf(stderr, "Illegal \"max\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "target") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.target, *argv, 0)) {
+				fprintf(stderr, "Illegal \"target\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "increment") == 0) {
+			NEXT_ARG();
+			if (get_prob(&opt.increment, *argv)) {
+				fprintf(stderr, "Illegal \"increment\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "decrement") == 0) {
+			NEXT_ARG();
+			if (get_prob(&opt.decrement, *argv)) {
+				fprintf(stderr, "Illegal \"decrement\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "penalty_rate") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.penalty_rate, *argv, 0)) {
+				fprintf(stderr, "Illegal \"penalty_rate\"\n");
+				return -1;
+			}
+                } else if (strcmp(*argv, "penalty_burst") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.penalty_burst, *argv, 0)) {
+				fprintf(stderr, "Illegal \"penalty_burst\"\n");
+				return -1;
+			}
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+        if(opt.max == 0) {
+                if(opt.target >= 1)
+                        opt.max = (opt.target * 5 + 1) / 4;
+                else
+                        opt.max = 25;
+        }
+        if(opt.target == 0)
+                opt.target = (opt.max * 4 + 3) / 5;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	addattr_l(n, 1024, TCA_SFB_PARMS, &opt, sizeof(opt));
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int sfb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+    	struct rtattr *tb[__TCA_SFB_MAX];
+	struct tc_sfb_qopt *qopt;
+
+	if(opt == NULL)
+		return 0;
+
+        parse_rtattr_nested(tb, TCA_SFB_MAX, opt);
+	if(tb[TCA_SFB_PARMS] == NULL)
+		return -1;
+	qopt = RTA_DATA(tb[TCA_SFB_PARMS]);
+	if(RTA_PAYLOAD(tb[TCA_SFB_PARMS]) < sizeof(*qopt))
+		return -1;
+
+        fprintf(f,
+                "hash %s limit %d max %d target %d\n"
+                "  increment %.5f decrement %.5f penalty rate %d burst %d "
+                "(%ds %ds %dx%d)",
+                hash_type(qopt->hash_type),
+                qopt->limit, qopt->max, qopt->target,
+                (double)qopt->increment / SFB_MAX_PROB,
+                (double)qopt->decrement / SFB_MAX_PROB,
+                qopt->penalty_rate, qopt->penalty_burst,
+                qopt->rehash_interval, qopt->db_interval,
+                qopt->numhashes, qopt->numbuckets);
+
+        return 0;
+}
+
+static int sfb_print_xstats(struct qdisc_util *qu, FILE *f,
+                            struct rtattr *xstats)
+{
+    struct tc_sfb_xstats *st;
+
+    if(xstats == NULL)
+            return 0;
+
+    if(RTA_PAYLOAD(xstats) < sizeof(*st))
+            return -1;
+
+    st = RTA_DATA(xstats);
+    fprintf(f,
+            "  earlydrop %u penaltydrop %u bucketdrop %u queuedrop %u marked %u\n"
+            "  maxqlen %u maxprob %.5f",
+            st->earlydrop, st->penaltydrop, st->bucketdrop, st->queuedrop,
+            st->marked,
+            st->maxqlen, (double)st->maxprob / SFB_MAX_PROB);
+
+    return 0;
+}
+
+struct qdisc_util sfb_qdisc_util = {
+	.id		= "sfb",
+	.parse_qopt	= sfb_parse_opt,
+	.print_qopt	= sfb_print_opt,
+	.print_xstats	= sfb_print_xstats,
+};
