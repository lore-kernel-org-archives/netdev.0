From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 01/10] fib_trie: Minor cleanups to
 fib_table_flush_external
Date: Fri, 06 Mar 2015 09:53:56 -0800
Message-ID: <20150306175356.2452.11301.stgit@ahduyck-vm-fedora20>
References: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752905AbbCFRx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 12:53:58 -0500
In-Reply-To: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change just does a couple of minor cleanups on
fib_table_flush_external.  Specifically it addresses the fact that resize
was being called even though nothing was being removed from the table, and
it drops an unecessary indent since we could just call continue on the
inverse of the fi && flag check.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 0131f36..488cebc 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1586,13 +1586,8 @@ backtrace:
 			while (!(cindex--)) {
 				t_key pkey = pn->key;
 
-				n = pn;
-				pn = node_parent(n);
-
-				/* resize completed node */
-				resize(t, n);
-
 				/* if we got the root we are done */
+				pn = node_parent(pn);
 				if (!pn)
 					return;
 
@@ -1607,12 +1602,13 @@ backtrace:
 	hlist_for_each_entry(fa, &n->leaf, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
-		if (fi && (fi->fib_flags & RTNH_F_EXTERNAL)) {
-			netdev_switch_fib_ipv4_del(n->key,
-						   KEYLENGTH - fa->fa_slen,
-						   fi, fa->fa_tos,
-						   fa->fa_type, tb->tb_id);
-		}
+		if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
+			continue;
+
+		netdev_switch_fib_ipv4_del(n->key,
+					   KEYLENGTH - fa->fa_slen,
+					   fi, fa->fa_tos,
+					   fa->fa_type, tb->tb_id);
 	}
 
 	/* if trie is leaf only loop is completed */
