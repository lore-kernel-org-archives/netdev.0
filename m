From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib: introduce fib_alias_accessed() helper
Date: Thu, 21 Oct 2010 10:03:38 +0200
Message-ID: <1287648218.6871.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44020 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282Ab0JUIDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 04:03:42 -0400
Received: by wwf26 with SMTP id 26so2244769wwf.1
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 01:03:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perf tools session at NFWS 2010 pointed out a false sharing on struct
fib_alias that can be avoided pretty easily, if we set FA_S_ACCESSED bit
only if needed (ie : not already set)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
net/ipv4/fib_hash.c      |    3 ++-
net/ipv4/fib_lookup.h    |    7 +++++++
net/ipv4/fib_semantics.c |    2 +-
net/ipv4/fib_trie.c      |    3 ++-
4 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 4f1aafd..43e1c59 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -335,7 +335,8 @@ void fib_table_select_default(struct fib_table *tb,
 			if (!next_fi->fib_nh[0].nh_gw ||
 			    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
 				continue;
-			fa->fa_state |= FA_S_ACCESSED;
+
+			fib_alias_accessed(fa);
 
 			if (fi == NULL) {
 				if (next_fi != res->fi)
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 5072d8e..a29edf2 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -17,6 +17,13 @@ struct fib_alias {
 
 #define FA_S_ACCESSED	0x01
 
+/* Dont write on fa_state unless needed, to keep it shared on all cpus */
+static inline void fib_alias_accessed(struct fib_alias *fa)
+{
+	if (!(fa->fa_state & FA_S_ACCESSED))
+		fa->fa_state |= FA_S_ACCESSED;
+}
+
 /* Exported by fib_semantics.c */
 extern int fib_semantic_match(struct list_head *head,
 			      const struct flowi *flp,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 6734c9c..3e0da3e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -901,7 +901,7 @@ int fib_semantic_match(struct list_head *head, const struct flowi *flp,
 		if (fa->fa_scope < flp->fl4_scope)
 			continue;
 
-		fa->fa_state |= FA_S_ACCESSED;
+		fib_alias_accessed(fa);
 
 		err = fib_props[fa->fa_type].error;
 		if (err == 0) {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 31494f3..cd5e13a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1838,7 +1838,8 @@ void fib_table_select_default(struct fib_table *tb,
 		if (!next_fi->fib_nh[0].nh_gw ||
 		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
 			continue;
-		fa->fa_state |= FA_S_ACCESSED;
+
+		fib_alias_accessed(fa);
 
 		if (fi == NULL) {
 			if (next_fi != res->fi)






