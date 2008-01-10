From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] [NEIGH] Make /proc/net/arp opening consistent with
	seq_net_open semantics
Date: Thu, 10 Jan 2008 14:32:19 +0300
Message-ID: <20080110113219.GA16233@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlezcano@fr.ibm.com, xemul@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:60981 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753681AbYAJL3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 06:29:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

seq_open_net requires that first field of the seq->private data to be
struct seq_net_private. In reality this is a single pointer to a struct net
for now. The patch makes code consistent.

Signed-off-by: Denis V. Lunev <den@openvz.org>

---

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index a9dda29..09f9fc6 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -223,7 +223,7 @@ extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(struct n
 extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pneigh_entry *));
 
 struct neigh_seq_state {
-	struct net *net;
+	struct seq_net_private p;
 	struct neigh_table *tbl;
 	void *(*neigh_sub_iter)(struct neigh_seq_state *state,
 				struct neighbour *n, loff_t *pos);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8024933..19c0dd1 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2142,7 +2142,7 @@ EXPORT_SYMBOL(__neigh_for_each_release);
 static struct neighbour *neigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net *net = state->net;
+	struct net *net = state->p.net;
 	struct neigh_table *tbl = state->tbl;
 	struct neighbour *n = NULL;
 	int bucket = state->bucket;
@@ -2183,7 +2183,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 					loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net *net = state->net;
+	struct net *net = state->p.net;
 	struct neigh_table *tbl = state->tbl;
 
 	if (state->neigh_sub_iter) {
@@ -2243,7 +2243,7 @@ static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
 static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net * net = state->net;
+	struct net * net = state->p.net;
 	struct neigh_table *tbl = state->tbl;
 	struct pneigh_entry *pn = NULL;
 	int bucket = state->bucket;
@@ -2266,7 +2266,7 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 					    loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net * net = state->net;
+	struct net * net = state->p.net;
 	struct neigh_table *tbl = state->tbl;
 
 	pn = pn->next;
