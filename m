From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 06/13] net: netrom: use seq_hlist_foo() helpers
Date: Fri, 05 Feb 2010 09:46:10 +0800
Message-ID: <4B6B7862.3090604@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56673 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932519Ab0BEBpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 20:45:54 -0500
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/netrom/af_netrom.c |   21 ++----------------
 net/netrom/nr_route.c  |   53 ++++++++---------------------------------------
 2 files changed, 12 insertions(+), 62 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 71604c6..a249127 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1267,28 +1267,13 @@ static int nr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 static void *nr_info_start(struct seq_file *seq, loff_t *pos)
 {
-	struct sock *s;
-	struct hlist_node *node;
-	int i = 1;
-
 	spin_lock_bh(&nr_list_lock);
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-
-	sk_for_each(s, node, &nr_list) {
-		if (i == *pos)
-			return s;
-		++i;
-	}
-	return NULL;
+	return seq_hlist_start_head(&nr_list, *pos);
 }
 
 static void *nr_info_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	++*pos;
-
-	return (v == SEQ_START_TOKEN) ? sk_head(&nr_list)
-		: sk_next((struct sock *)v);
+	return seq_hlist_next(v, &nr_list, pos);
 }
 
 static void nr_info_stop(struct seq_file *seq, void *v)
@@ -1298,7 +1283,7 @@ static void nr_info_stop(struct seq_file *seq, void *v)
 
 static int nr_info_show(struct seq_file *seq, void *v)
 {
-	struct sock *s = v;
+	struct sock *s = sk_entry(v);
 	struct net_device *dev;
 	struct nr_sock *nr;
 	const char *devname;
diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index e2e2d33..5cc6480 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -863,33 +863,13 @@ int nr_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 
 static void *nr_node_start(struct seq_file *seq, loff_t *pos)
 {
-	struct nr_node *nr_node;
-	struct hlist_node *node;
-	int i = 1;
-
 	spin_lock_bh(&nr_node_list_lock);
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-
-	nr_node_for_each(nr_node, node, &nr_node_list) {
-		if (i == *pos)
-			return nr_node;
-		++i;
-	}
-
-	return NULL;
+	return seq_hlist_start_head(&nr_node_list, *pos);
 }
 
 static void *nr_node_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct hlist_node *node;
-	++*pos;
-
-	node = (v == SEQ_START_TOKEN)
-		? nr_node_list.first
-		: ((struct nr_node *)v)->node_node.next;
-
-	return hlist_entry(node, struct nr_node, node_node);
+	return seq_hlist_next(v, &nr_node_list, pos);
 }
 
 static void nr_node_stop(struct seq_file *seq, void *v)
@@ -906,7 +886,9 @@ static int nr_node_show(struct seq_file *seq, void *v)
 		seq_puts(seq,
 			 "callsign  mnemonic w n qual obs neigh qual obs neigh qual obs neigh\n");
 	else {
-		struct nr_node *nr_node = v;
+		struct nr_node *nr_node = hlist_entry(v, struct nr_node,
+						      node_node);
+
 		nr_node_lock(nr_node);
 		seq_printf(seq, "%-9s %-7s  %d %d",
 			ax2asc(buf, &nr_node->callsign),
@@ -949,31 +931,13 @@ const struct file_operations nr_nodes_fops = {
 
 static void *nr_neigh_start(struct seq_file *seq, loff_t *pos)
 {
-	struct nr_neigh *nr_neigh;
-	struct hlist_node *node;
-	int i = 1;
-
 	spin_lock_bh(&nr_neigh_list_lock);
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-
-	nr_neigh_for_each(nr_neigh, node, &nr_neigh_list) {
-		if (i == *pos)
-			return nr_neigh;
-	}
-	return NULL;
+	return seq_hlist_start_head(&nr_neigh_list, *pos);
 }
 
 static void *nr_neigh_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct hlist_node *node;
-	++*pos;
-
-	node = (v == SEQ_START_TOKEN)
-		? nr_neigh_list.first
-		: ((struct nr_neigh *)v)->neigh_node.next;
-
-	return hlist_entry(node, struct nr_neigh, neigh_node);
+	return seq_hlist_next(v, &nr_neigh_list, pos);
 }
 
 static void nr_neigh_stop(struct seq_file *seq, void *v)
@@ -989,8 +953,9 @@ static int nr_neigh_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, "addr  callsign  dev  qual lock count failed digipeaters\n");
 	else {
-		struct nr_neigh *nr_neigh = v;
+		struct nr_neigh *nr_neigh;
 
+		nr_neigh = hlist_entry(v, struct nr_neigh, neigh_node);
 		seq_printf(seq, "%05d %-9s %-4s  %3d    %d   %3d    %3d",
 			nr_neigh->number,
 			ax2asc(buf, &nr_neigh->callsign),
-- 
1.6.3

