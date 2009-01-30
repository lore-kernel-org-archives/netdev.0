From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] netfilter: use sequence number synchronization for counters
Date: Fri, 30 Jan 2009 13:57:05 -0800
Message-ID: <20090130215729.536716172@vyatta.com>
References: <20090130215700.965611970@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49661 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756973AbZA3V6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 16:58:00 -0500
Content-Disposition: inline; filename=counters-seqcount.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change how synchronization is done on the iptables counters. Use seqcount
wrapper instead of depending on reader/writer lock.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/netfilter/x_tables.c	2009-01-30 09:15:52.648542116 -0800
+++ b/net/netfilter/x_tables.c	2009-01-30 09:17:03.669061821 -0800
@@ -577,18 +577,36 @@ int xt_compat_target_to_user(struct xt_e
 EXPORT_SYMBOL_GPL(xt_compat_target_to_user);
 #endif
 
+static DEFINE_PER_CPU(seqcount_t, xt_counter_sequence);
+
+/* Update the counters on the current CPU. preempt must be disabled. */
 void xt_add_counter(struct xt_counters *c, unsigned b, unsigned p)
 {
+	seqcount_t *seq = &__get_cpu_var(xt_counter_sequence);
+
+	write_seqcount_begin(seq);
 	c->bcnt += b;
 	c->pcnt += p;
+	write_seqcount_end(seq);
 }
 EXPORT_SYMBOL_GPL(xt_add_counter);
 
+/* Fetch counters on other CPU. */
 void xt_sum_counter(struct xt_counters *t, int cpu,
 		    const struct xt_counters *c)
 {
-	t->pcnt += c->pcnt;
-	t->bcnt += c->bcnt;
+	seqcount_t *seq = &per_cpu(xt_counter_sequence, cpu);
+	unsigned start;
+	struct xt_counters v;
+
+	/* Atomic fetch of counter value */
+	do {
+		start = read_seqcount_begin(seq);
+		v = *c;
+	} while (read_seqcount_retry(seq, start));
+
+	t->pcnt += v.pcnt;
+	t->bcnt += v.bcnt;
 }
 EXPORT_SYMBOL_GPL(xt_sum_counter);
 

-- 

