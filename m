From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 nf-next 1/2] netfilter: x_tables: make xt_replace_table wait until old rules are not used anymore
Date: Tue, 10 Oct 2017 23:39:44 +0200
Message-ID: <20171010213945.19074-2-fw@strlen.de>
References: <20171010213945.19074-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, Dan Williams <dcbw@redhat.com>
To: <netdev@vger.kernel.org>, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:37044 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755147AbdJJVjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:39:42 -0400
In-Reply-To: <20171010213945.19074-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xt_replace_table relies on table replacement counter retrieval (which
uses xt_recseq to synchronize pcpu counters).

This is fine, however with large rule set get_counters() can take
a very long time -- it needs to synchronize all counters because
it has to assume concurrent modifications can occur.

Make xt_replace_table synchronize by itself by waiting until all cpus
had an even seqcount.

This allows a followup patch to copy the counters of the old ruleset
without any synchonization after xt_replace_table has completed.

Cc: Dan Williams <dcbw@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 v2: fix Erics email address

 net/netfilter/x_tables.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index c83a3b5e1c6c..f2d4a365768f 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1153,6 +1153,7 @@ xt_replace_table(struct xt_table *table,
 	      int *error)
 {
 	struct xt_table_info *private;
+	unsigned int cpu;
 	int ret;
 
 	ret = xt_jumpstack_alloc(newinfo);
@@ -1184,12 +1185,20 @@ xt_replace_table(struct xt_table *table,
 
 	/*
 	 * Even though table entries have now been swapped, other CPU's
-	 * may still be using the old entries. This is okay, because
-	 * resynchronization happens because of the locking done
-	 * during the get_counters() routine.
+	 * may still be using the old entries...
 	 */
 	local_bh_enable();
 
+	/* ... so wait for even xt_recseq on all cpus */
+	for_each_possible_cpu(cpu) {
+		seqcount_t *s = &per_cpu(xt_recseq, cpu);
+
+		while (raw_read_seqcount(s) & 1)
+			cpu_relax();
+
+		cond_resched();
+	}
+
 #ifdef CONFIG_AUDIT
 	if (audit_enabled) {
 		audit_log(current->audit_context, GFP_KERNEL,
-- 
2.13.6
