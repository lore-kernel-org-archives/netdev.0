From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/2] rhashtable: unconditionally grow when max_shift is not specified
Date: Wed, 25 Feb 2015 16:31:53 +0100
Message-ID: <0973a6e9b73a2ca14477c0cf98093d5f1b3d3d40.1424877322.git.daniel@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ying Xue <ying.xue@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50442 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbbBYPcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 10:32:03 -0500
In-Reply-To: <cover.1424877322.git.daniel@iogearbox.net>
In-Reply-To: <cover.1424877322.git.daniel@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While commit c0c09bfdc415 ("rhashtable: avoid unnecessary wakeup for
worker queue") rightfully moved part of the decision making of
whether we should expand or shrink from the expand/shrink functions
themselves into insert/delete functions in order to avoid unnecessary
worker wake-ups, it however introduced a regression by doing so.

Before that change, if no max_shift was specified (= 0) on rhashtable
initialization, rhashtable_expand() would just grow unconditionally
and lets the available memory be the limiting factor. After that
change, if no max_shift was specified, there would be _no_ expansion
step at all.

Given that netlink and tipc have a max_shift specified, it was not
visible there, but Josh Hunt reported that if nft that starts out
with a default element hint of 3 if not otherwise provided, would
slow i.e. inserts down trememdously as it cannot grow larger to
relax table occupancy.

Given that the test case verifies shrinks/expands manually, we also
must remove pointer to the helper functions to explicitly avoid
parallel resizing on insertions/deletions. test_bucket_stats() and
test_rht_lookup() could also be wrapped around rhashtable mutex to
explicitly synchronize a walk from resizing, but I think that defeats
the actual test case which intended to have explicit test steps,
i.e. 1) inserts, 2) expands, 3) shrinks, 4) deletions, with object
verification after each stage.

Reported-by: Josh Hunt <johunt@akamai.com>
Fixes: c0c09bfdc415 ("rhashtable: avoid unnecessary wakeup for worker queue")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Ying Xue <ying.xue@windriver.com>
Cc: Josh Hunt <johunt@akamai.com>
---
 lib/rhashtable.c      | 2 +-
 lib/test_rhashtable.c | 2 --
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e3a04e4..bcf119b 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -251,7 +251,7 @@ bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size)
 {
 	/* Expand table when exceeding 75% load */
 	return atomic_read(&ht->nelems) > (new_size / 4 * 3) &&
-	       (ht->p.max_shift && atomic_read(&ht->shift) < ht->p.max_shift);
+	       (!ht->p.max_shift || atomic_read(&ht->shift) < ht->p.max_shift);
 }
 EXPORT_SYMBOL_GPL(rht_grow_above_75);
 
diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 58b9953..f9e9d73 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -202,8 +202,6 @@ static int __init test_rht_init(void)
 		.key_len = sizeof(int),
 		.hashfn = jhash,
 		.nulls_base = (3U << RHT_BASE_SHIFT),
-		.grow_decision = rht_grow_above_75,
-		.shrink_decision = rht_shrink_below_30,
 	};
 	int err;
 
-- 
1.9.3
