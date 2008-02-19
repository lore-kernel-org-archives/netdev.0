From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 12/17 net-2.6.26] [NETNS]: Process /proc/net/rt_cache inside a namespace.
Date: Tue, 19 Feb 2008 10:31:32 +0300
Message-ID: <1203406297-32725-12-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:64727 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754501AbYBSHbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:15 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show routing cache for a particular namespace only.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 67df872..c11e6bf 100644
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

