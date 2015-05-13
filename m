From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] netfilter: Use correct return for seq_show
 functions
Date: Tue, 12 May 2015 18:28:23 -0700
Message-ID: <1431480503.2884.110.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0230.hostedemail.com ([216.40.44.230]:45291 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964834AbbEMB21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 21:28:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using seq_has_overflowed doesn't produce the right return value.
Either 0 or -1 is, but 0 is much more common and works well when
seq allocation retries.

I believe this doesn't matter as the initial allocation is always
sufficient, this is just a correctness patch.

Miscellanea:

o Don't use strlen, use *ptr to determine if a string
  should be emitted like all the other tests here
o Delete unnecessary return statements

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/nfnetlink_queue_core.c |  2 +-
 net/netfilter/x_tables.c             | 18 ++++++------------
 2 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 0b98c74..bec7c60 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1257,7 +1257,7 @@ static int seq_show(struct seq_file *s, void *v)
 		   inst->copy_mode, inst->copy_range,
 		   inst->queue_dropped, inst->queue_user_dropped,
 		   inst->id_sequence, 1);
-	return seq_has_overflowed(s);
+	return 0;
 }
 
 static const struct seq_operations nfqnl_seq_ops = {
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 51a459c..8303246 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -947,11 +947,9 @@ static int xt_table_seq_show(struct seq_file *seq, void *v)
 {
 	struct xt_table *table = list_entry(v, struct xt_table, list);
 
-	if (strlen(table->name)) {
+	if (*table->name)
 		seq_printf(seq, "%s\n", table->name);
-		return seq_has_overflowed(seq);
-	} else
-		return 0;
+	return 0;
 }
 
 static const struct seq_operations xt_table_seq_ops = {
@@ -1087,10 +1085,8 @@ static int xt_match_seq_show(struct seq_file *seq, void *v)
 		if (trav->curr == trav->head)
 			return 0;
 		match = list_entry(trav->curr, struct xt_match, list);
-		if (*match->name == '\0')
-			return 0;
-		seq_printf(seq, "%s\n", match->name);
-		return seq_has_overflowed(seq);
+		if (*match->name)
+			seq_printf(seq, "%s\n", match->name);
 	}
 	return 0;
 }
@@ -1142,10 +1138,8 @@ static int xt_target_seq_show(struct seq_file *seq, void *v)
 		if (trav->curr == trav->head)
 			return 0;
 		target = list_entry(trav->curr, struct xt_target, list);
-		if (*target->name == '\0')
-			return 0;
-		seq_printf(seq, "%s\n", target->name);
-		return seq_has_overflowed(seq);
+		if (*target->name)
+			seq_printf(seq, "%s\n", target->name);
 	}
 	return 0;
 }
