From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/29] netfilter: conntrack: resched gc again if eviction rate is high
Date: Mon,  5 Sep 2016 12:58:41 +0200
Message-ID: <1473073124-5015-27-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35386 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933578AbcIEK7T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:19 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1B65B2EFEB8
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 08BB0114D69
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 13B161150DA
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:16 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

If we evicted a large fraction of the scanned conntrack entries re-schedule
the next gc cycle for immediate execution.

This triggers during tests where load is high, then drops to zero and
many connections will be in TW/CLOSE state with < 30 second timeouts.

Without this change it will take several minutes until conntrack count
comes back to normal.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f95a9e9..7c66ce40 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -945,6 +945,7 @@ static void gc_worker(struct work_struct *work)
 {
 	unsigned int i, goal, buckets = 0, expired_count = 0;
 	unsigned long next_run = GC_INTERVAL;
+	unsigned int ratio, scanned = 0;
 	struct conntrack_gc_work *gc_work;
 
 	gc_work = container_of(work, struct conntrack_gc_work, dwork.work);
@@ -969,6 +970,7 @@ static void gc_worker(struct work_struct *work)
 		hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[i], hnnode) {
 			tmp = nf_ct_tuplehash_to_ctrack(h);
 
+			scanned++;
 			if (nf_ct_is_expired(tmp)) {
 				nf_ct_gc_expired(tmp);
 				expired_count++;
@@ -988,6 +990,10 @@ static void gc_worker(struct work_struct *work)
 	if (gc_work->exiting)
 		return;
 
+	ratio = scanned ? expired_count * 100 / scanned : 0;
+	if (ratio >= 90)
+		next_run = 0;
+
 	gc_work->last_bucket = i;
 	schedule_delayed_work(&gc_work->dwork, next_run);
 }
-- 
2.1.4
