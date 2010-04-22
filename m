From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 15:31:06 +0200
Message-ID: <1271943066.14501.194.camel@jdb-workstation>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56344 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712Ab0DVNix convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 09:38:53 -0400
In-Reply-To: <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have added a stats counter to prove my case, which I think we should add to the kernel (to detect the case in the future).
The DDoS attack has disappeared, so I guess I'll try to see if I can reproduce the problem in my testlab.



[PATCH] net: netfilter conntrack extended with extra stat counter.

From: Jesper Dangaard Brouer <hawk@comx.dk>

I suspect an unfortunatly series of events occuring under a DDoS
attack, in function __nf_conntrack_find() nf_contrack_core.c.

Adding a stats counter to see if the search is restarted too often.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 include/linux/netfilter/nf_conntrack_common.h      |    1 +
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    7 ++++---
 net/netfilter/nf_conntrack_core.c                  |    4 +++-
 net/netfilter/nf_conntrack_standalone.c            |    7 ++++---
 4 files changed, 12 insertions(+), 7 deletions(-)


diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index a8248ee..57ff312 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -93,6 +93,7 @@ struct ip_conntrack_stat
 	unsigned int expect_new;
 	unsigned int expect_create;
 	unsigned int expect_delete;
+	unsigned int search_restart;
 };
 
 /* call to create an explicit dependency on nf_conntrack. */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 8668a3d..b94f510 100644
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
index 4299db7..5ca8286 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -315,8 +315,10 @@ begin:
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
index 1935153..4812750 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -245,12 +245,12 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
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
@@ -267,7 +267,8 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 
 		   st->expect_new,
 		   st->expect_create,
-		   st->expect_delete
+		   st->expect_delete,
+		   st->search_restart
 		);
 	return 0;
 }



-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
