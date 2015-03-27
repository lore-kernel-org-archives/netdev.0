From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 2/2] fib_trie: Cleanup ip_fib_net_exit code path
Date: Fri, 27 Mar 2015 14:14:22 -0700
Message-ID: <20150327211422.2465.50276.stgit@ahduyck-vm-fedora22>
References: <20150327211416.2465.23170.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbbC0VOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 17:14:24 -0400
In-Reply-To: <20150327211416.2465.23170.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While fixing a recent issue I noticed that we are doing some unnecessary
work inside the loop for ip_fib_net_exit.  As such I am pulling out the
initialization to NULL for the locally stored fib_local, fib_main, and
fib_default.

In addition I am restoring the original code for flushing the table as
there is no need to split up the fib_table_flush and hlist_del work since
the code for packing the tnodes with multiple key vectors was dropped.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_frontend.c |   29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 767120111d90..718b0a16ea40 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1176,35 +1176,20 @@ static void ip_fib_net_exit(struct net *net)
 
 	rtnl_lock();
 
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+	RCU_INIT_POINTER(net->ipv4.fib_local, NULL);
+	RCU_INIT_POINTER(net->ipv4.fib_main, NULL);
+	RCU_INIT_POINTER(net->ipv4.fib_default, NULL);
+#endif
+
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[i];
 		struct hlist_node *tmp;
 		struct fib_table *tb;
 
-		/* this is done in two passes as flushing the table could
-		 * cause it to be reallocated in order to accommodate new
-		 * tnodes at the root as the table shrinks.
-		 */
-		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist)
-			fib_table_flush(tb);
-
 		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist) {
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-			switch (tb->tb_id) {
-			case RT_TABLE_LOCAL:
-				RCU_INIT_POINTER(net->ipv4.fib_local, NULL);
-				break;
-			case RT_TABLE_MAIN:
-				RCU_INIT_POINTER(net->ipv4.fib_main, NULL);
-				break;
-			case RT_TABLE_DEFAULT:
-				RCU_INIT_POINTER(net->ipv4.fib_default, NULL);
-				break;
-			default:
-				break;
-			}
-#endif
 			hlist_del(&tb->tb_hlist);
+			fib_table_flush(tb);
 			fib_free_table(tb);
 		}
 	}
