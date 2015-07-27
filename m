From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net PATCH] fib_trie: Drop unnecessary calls to leaf_pull_suffix
Date: Mon, 27 Jul 2015 13:08:06 -0700
Message-ID: <20150727195631.26840.93266.stgit@ahduyck-vm-fedora22>
References: <55B6612C.7050506@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754373AbbG0UIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 16:08:07 -0400
In-Reply-To: <55B6612C.7050506@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was reported that update_suffix was taking a long time on systems where
a large number of leaves were attached to a single node.  As it turns out
fib_table_flush was calling update_suffix for each leaf that didn't have all
of the aliases stripped from it.  As a result, on this large node removing
one leaf would result in us calling update_suffix for every other leaf on
the node.

The fix is to just remove the calls to leaf_pull_suffix since they are
redundant as we already have a call in resize that will go through and
update the suffix length for the node before we exit out of
fib_table_flush or fib_table_flush_external.

Reported-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

This patch should apply to linux-4.1.y and newer kernels.

I've done a bit of testing on my system and I no longer see update_suffix
dominating the performance traces.  David if you can test with this patch
to see if you still see the issue I would appreciate it.

 net/ipv4/fib_trie.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ef90d73911de..70168ca4716b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1791,8 +1791,6 @@ void fib_table_flush_external(struct fib_table *tb)
 		if (hlist_empty(&n->leaf)) {
 			put_child_root(pn, n->key, NULL);
 			node_free(n);
-		} else {
-			leaf_pull_suffix(pn, n);
 		}
 	}
 }
@@ -1862,8 +1860,6 @@ int fib_table_flush(struct fib_table *tb)
 		if (hlist_empty(&n->leaf)) {
 			put_child_root(pn, n->key, NULL);
 			node_free(n);
-		} else {
-			leaf_pull_suffix(pn, n);
 		}
 	}
 
