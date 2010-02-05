From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 10/13] net: x25: use seq_list_foo() helpers
Date: Fri, 05 Feb 2010 09:47:09 +0800
Message-ID: <4B6B789D.1000903@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56269 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932877Ab0BEBqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 20:46:53 -0500
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/x25/x25_proc.c |   84 +++++-----------------------------------------------
 1 files changed, 8 insertions(+), 76 deletions(-)

diff --git a/net/x25/x25_proc.c b/net/x25/x25_proc.c
index c4cd322..7ff3737 100644
--- a/net/x25/x25_proc.c
+++ b/net/x25/x25_proc.c
@@ -25,49 +25,17 @@
 #include <net/x25.h>
 
 #ifdef CONFIG_PROC_FS
-static __inline__ struct x25_route *x25_get_route_idx(loff_t pos)
-{
-	struct list_head *route_entry;
-	struct x25_route *rt = NULL;
-
-	list_for_each(route_entry, &x25_route_list) {
-		rt = list_entry(route_entry, struct x25_route, node);
-		if (!pos--)
-			goto found;
-	}
-	rt = NULL;
-found:
-	return rt;
-}
 
 static void *x25_seq_route_start(struct seq_file *seq, loff_t *pos)
 	__acquires(x25_route_list_lock)
 {
-	loff_t l = *pos;
-
 	read_lock_bh(&x25_route_list_lock);
-	return l ? x25_get_route_idx(--l) : SEQ_START_TOKEN;
+	return seq_list_start_head(&x25_route_list, *pos);
 }
 
 static void *x25_seq_route_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct x25_route *rt;
-
-	++*pos;
-	if (v == SEQ_START_TOKEN) {
-		rt = NULL;
-		if (!list_empty(&x25_route_list))
-			rt = list_entry(x25_route_list.next,
-					struct x25_route, node);
-		goto out;
-	}
-	rt = v;
-	if (rt->node.next != &x25_route_list)
-		rt = list_entry(rt->node.next, struct x25_route, node);
-	else
-		rt = NULL;
-out:
-	return rt;
+	return seq_list_next(v, &x25_route_list, pos);
 }
 
 static void x25_seq_route_stop(struct seq_file *seq, void *v)
@@ -78,9 +46,9 @@ static void x25_seq_route_stop(struct seq_file *seq, void *v)
 
 static int x25_seq_route_show(struct seq_file *seq, void *v)
 {
-	struct x25_route *rt;
+	struct x25_route *rt = list_entry(v, struct x25_route, node);
 
-	if (v == SEQ_START_TOKEN) {
+	if (v == &x25_route_list) {
 		seq_puts(seq, "Address          Digits  Device\n");
 		goto out;
 	}
@@ -146,51 +114,16 @@ out:
 	return 0;
 }
 
-static __inline__ struct x25_forward *x25_get_forward_idx(loff_t pos)
-{
-	struct x25_forward *f;
-	struct list_head *entry;
-
-	list_for_each(entry, &x25_forward_list) {
-		f = list_entry(entry, struct x25_forward, node);
-		if (!pos--)
-			goto found;
-	}
-
-	f = NULL;
-found:
-	return f;
-}
-
 static void *x25_seq_forward_start(struct seq_file *seq, loff_t *pos)
 	__acquires(x25_forward_list_lock)
 {
-	loff_t l = *pos;
-
 	read_lock_bh(&x25_forward_list_lock);
-	return l ? x25_get_forward_idx(--l) : SEQ_START_TOKEN;
+	return seq_list_start_head(&x25_forward_list, *pos);
 }
 
 static void *x25_seq_forward_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct x25_forward *f;
-
-	++*pos;
-	if (v == SEQ_START_TOKEN) {
-		f = NULL;
-		if (!list_empty(&x25_forward_list))
-			f = list_entry(x25_forward_list.next,
-					struct x25_forward, node);
-		goto out;
-	}
-	f = v;
-	if (f->node.next != &x25_forward_list)
-		f = list_entry(f->node.next, struct x25_forward, node);
-	else
-		f = NULL;
-out:
-	return f;
-
+	return seq_list_next(v, &x25_forward_list, pos);
 }
 
 static void x25_seq_forward_stop(struct seq_file *seq, void *v)
@@ -201,9 +134,9 @@ static void x25_seq_forward_stop(struct seq_file *seq, void *v)
 
 static int x25_seq_forward_show(struct seq_file *seq, void *v)
 {
-	struct x25_forward *f;
+	struct x25_forward *f = list_entry(v, struct x25_forward, node);
 
-	if (v == SEQ_START_TOKEN) {
+	if (v == &x25_forward_list) {
 		seq_printf(seq, "lci dev1       dev2\n");
 		goto out;
 	}
@@ -212,7 +145,6 @@ static int x25_seq_forward_show(struct seq_file *seq, void *v)
 
 	seq_printf(seq, "%d %-10s %-10s\n",
 			f->lci, f->dev1->name, f->dev2->name);
-
 out:
 	return 0;
 }
-- 
1.6.3

