From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/6) tr - fix the seq_file next operation
Date: Wed, 20 Aug 2003 17:22:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820172227.04cf127d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Better version of my seq_file next operation.
Use current pointer to find next element.  Should be more
stable with changing list (no duplicate entries).

P.s: Tested this stuff on 2.6.0-test3 by creating a test stub
to put random entries into the table; no real hardware was
needed.

diff -Nru a/net/802/tr.c b/net/802/tr.c
--- a/net/802/tr.c	Wed Aug 20 16:28:21 2003
+++ b/net/802/tr.c	Wed Aug 20 16:28:21 2003
@@ -477,8 +477,8 @@
 	struct rif_cache_s *entry;
 	loff_t off = 0;
 
-	for(i=0;i < RIF_TABLE_SIZE;i++) 
-		for(entry=rif_table[i];entry;entry=entry->next) {
+	for(i = 0; i < RIF_TABLE_SIZE; i++) 
+		for(entry = rif_table[i]; entry; entry = entry->next) {
 			if (off == pos)
 				return entry;
 			++off;
@@ -496,7 +496,26 @@
 
 static void *rif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	return rif_get_idx(*pos++);
+	int i;
+	struct rif_cache_s *ent = v;
+
+	++*pos;
+
+	if (v == RIF_PROC_START) {
+		i = -1;
+		goto scan;
+	}
+
+	if (ent->next) 
+		return ent->next;
+
+	i = rif_hash(ent->addr);
+ scan:
+	while (++i < RIF_TABLE_SIZE) {
+		if ((ent = rif_table[i]) != NULL)
+			return ent;
+	}
+	return NULL;
 }
 
 static void rif_seq_stop(struct seq_file *seq, void *v)
