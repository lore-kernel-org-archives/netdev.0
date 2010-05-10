From: kaber@trash.net
Subject: [PATCH 80/84] netfilter: nf_conntrack: extend with extra stat counter
Date: Mon, 10 May 2010 22:18:51 +0200
Message-ID: <1273522735-24672-81-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54510 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756957Ab0EJUTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:30 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>

I suspect an unfortunatly series of events occuring under a DDoS
attack, in function __nf_conntrack_find() nf_contrack_core.c.

Adding a stats counter to see if the search is restarted too often.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nf_conntrack_common.h      |    1 +
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    7 ++++---
 net/netfilter/nf_conntrack_core.c                  |    4 +++-
 net/netfilter/nf_conntrack_standalone.c            |    7 ++++---
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index c608677..14e6d32 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -113,6 +113,7 @@ struct ip_conntrack_stat {
 	unsigned int expect_new;
 	unsigned int expect_create;
 	unsigned int expect_delete;
+	unsigned int search_restart;
 };
 
 /* call to create an explicit dependency on nf_conntrack. */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 2fb7b76..244f7cb 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -336,12 +336,12 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete\n");
+		seq_printf(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete search_restart\n");
 		return 0;
 	}
 
 	seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x "
-			"%08x %08x %08x %08x %08x  %08x %08x %08x \n",
+			"%08x %08x %08x %08x %08x  %08x %08x %08x %08x\n",
 		   nr_conntracks,
 		   st->searched,
 		   st->found,
@@ -358,7 +358,8 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 
 		   st->expect_new,
 		   st->expect_create,
-		   st->expect_delete
+		   st->expect_delete,
+		   st->search_restart
 		);
 	return 0;
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0c9bbe9..3907efb 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -319,8 +319,10 @@ begin:
 	 * not the expected one, we must restart lookup.
 	 * We probably met an item that was moved to another chain.
 	 */
-	if (get_nulls_value(n) != hash)
+	if (get_nulls_value(n) != hash) {
+		NF_CT_STAT_INC(net, search_restart);
 		goto begin;
+	}
 	local_bh_enable();
 
 	return NULL;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index faa8eb3..ea4a8d3 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -252,12 +252,12 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete\n");
+		seq_printf(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete search_restart\n");
 		return 0;
 	}
 
 	seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x "
-			"%08x %08x %08x %08x %08x  %08x %08x %08x \n",
+			"%08x %08x %08x %08x %08x  %08x %08x %08x %08x\n",
 		   nr_conntracks,
 		   st->searched,
 		   st->found,
@@ -274,7 +274,8 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 
 		   st->expect_new,
 		   st->expect_create,
-		   st->expect_delete
+		   st->expect_delete,
+		   st->search_restart
 		);
 	return 0;
 }
-- 
1.7.0.4

