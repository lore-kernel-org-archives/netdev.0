From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 12/17] [NETNS]: Process /proc/net/rt_cache inside a namespace.
Date: Wed,  6 Feb 2008 13:53:32 +0300
Message-ID: <1202295217-22769-12-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:58926 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758647AbYBFKxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 05:53:15 -0500
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show routing cache for a particular namespace only.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b03de57..cc002d8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -273,6 +273,7 @@ static unsigned int rt_hash_code(u32 daddr, u32 saddr)
 
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
+	struct seq_net_private p;
 	int bucket;
 	int genid;
 };
@@ -285,7 +286,8 @@ static struct rtable *rt_cache_get_first(struct rt_cache_iter_state *st)
 		rcu_read_lock_bh();
 		r = rcu_dereference(rt_hash_table[st->bucket].chain);
 		while (r) {
-			if (r->rt_genid == st->genid)
+			if (r->u.dst.dev->nd_net == st->p.net &&
+			    r->rt_genid == st->genid)
 				return r;
 			r = rcu_dereference(r->u.dst.rt_next);
 		}
@@ -312,6 +314,8 @@ static struct rtable *rt_cache_get_next(struct rt_cache_iter_state *st,
 					struct rtable *r)
 {
 	while ((r = __rt_cache_get_next(st, r)) != NULL) {
+		if (r->u.dst.dev->nd_net != st->p.net)
+			continue;
 		if (r->rt_genid == st->genid)
 			break;
 	}
@@ -398,7 +402,7 @@ static const struct seq_operations rt_cache_seq_ops = {
 
 static int rt_cache_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &rt_cache_seq_ops,
+	return seq_open_net(inode, file, &rt_cache_seq_ops,
 			sizeof(struct rt_cache_iter_state));
 }
 
@@ -407,7 +411,7 @@ static const struct file_operations rt_cache_seq_fops = {
 	.open	 = rt_cache_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 
-- 
1.5.3.rc5

