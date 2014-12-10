From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] net: replace remaining users of arch_fast_hash with jhash
Date: Wed, 10 Dec 2014 16:33:11 +0100
Message-ID: <1418225592-29322-3-git-send-email-dborkman@redhat.com>
References: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, tgraf@suug.ch, hannes@stressinduktion.org,
	Neil Brown <neilb@suse.de>, Francesco Fusco <fusco@ntop.org>,
	Jesse Gross <jesse@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757620AbaLJPeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 10:34:24 -0500
In-Reply-To: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch effectively reverts commit 500f80872645 ("net: ovs: use CRC32
accelerated flow hash if available"), and other remaining arch_fast_hash()
users such as from nfsd via commit 6282cd565553 ("NFSD: Don't hand out
delegations for 30 seconds after recalling them.") where it has been used
as a hash function for bloom filtering.

While we think that these users are actually not much of concern, it has
been requested to remove the arch_fast_hash() library bits that arose
from [1] entirely as per recent discussion [2]. The main argument is that
using it as a hash may introduce bias due to its linearity (see avalanche
criterion) and thus makes it less clear (though we tried to document that)
when this security/performance trade-off is actually acceptable for a
general purpose library function.

Lets therefore avoid any further confusion on this matter and remove it to
prevent any future accidental misuse of it. For the time being, this is
going to make hashing of flow keys a bit more expensive in the ovs case,
but future work could reevaluate a different hashing discipline.

  [1] https://patchwork.ozlabs.org/patch/299369/
  [2] https://patchwork.ozlabs.org/patch/418756/

Cc: Neil Brown <neilb@suse.de>
Cc: Francesco Fusco <fusco@ntop.org>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 fs/nfsd/nfs4state.c          | 6 +++---
 lib/rhashtable.c             | 8 ++++----
 net/openvswitch/flow_table.c | 4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9c3afe..4e1d726 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -41,7 +41,7 @@
 #include <linux/ratelimit.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/addr.h>
-#include <linux/hash.h>
+#include <linux/jhash.h>
 #include "xdr4.h"
 #include "xdr4cb.h"
 #include "vfs.h"
@@ -594,7 +594,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
 		}
 		spin_unlock(&blocked_delegations_lock);
 	}
-	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
+	hash = jhash(&fh->fh_base, fh->fh_size, 0);
 	if (test_bit(hash&255, bd->set[0]) &&
 	    test_bit((hash>>8)&255, bd->set[0]) &&
 	    test_bit((hash>>16)&255, bd->set[0]))
@@ -613,7 +613,7 @@ static void block_delegations(struct knfsd_fh *fh)
 	u32 hash;
 	struct bloom_pair *bd = &blocked_delegations;
 
-	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
+	hash = jhash(&fh->fh_base, fh->fh_size, 0);
 
 	spin_lock(&blocked_delegations_lock);
 	__set_bit(hash&255, bd->set[bd->new]);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index c7e987a..6c3c723 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -20,7 +20,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/mm.h>
-#include <linux/hash.h>
+#include <linux/jhash.h>
 #include <linux/random.h>
 #include <linux/rhashtable.h>
 
@@ -524,7 +524,7 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
  *	.head_offset = offsetof(struct test_obj, node),
  *	.key_offset = offsetof(struct test_obj, key),
  *	.key_len = sizeof(int),
- *	.hashfn = arch_fast_hash,
+ *	.hashfn = jhash,
  * #ifdef CONFIG_PROVE_LOCKING
  *	.mutex_is_held = &my_mutex_is_held,
  * #endif
@@ -545,7 +545,7 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
  *
  * struct rhashtable_params params = {
  *	.head_offset = offsetof(struct test_obj, node),
- *	.hashfn = arch_fast_hash,
+ *	.hashfn = jhash,
  *	.obj_hashfn = my_hash_fn,
  * #ifdef CONFIG_PROVE_LOCKING
  *	.mutex_is_held = &my_mutex_is_held,
@@ -778,7 +778,7 @@ static int __init test_rht_init(void)
 		.head_offset = offsetof(struct test_obj, node),
 		.key_offset = offsetof(struct test_obj, value),
 		.key_len = sizeof(int),
-		.hashfn = arch_fast_hash,
+		.hashfn = jhash,
 #ifdef CONFIG_PROVE_LOCKING
 		.mutex_is_held = &test_mutex_is_held,
 #endif
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index e0a7fef..5899bf1 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -25,7 +25,7 @@
 #include <linux/if_vlan.h>
 #include <net/llc_pdu.h>
 #include <linux/kernel.h>
-#include <linux/hash.h>
+#include <linux/jhash.h>
 #include <linux/jiffies.h>
 #include <linux/llc.h>
 #include <linux/module.h>
@@ -366,7 +366,7 @@ static u32 flow_hash(const struct sw_flow_key *key, int key_start,
 	/* Make sure number of hash bytes are multiple of u32. */
 	BUILD_BUG_ON(sizeof(long) % sizeof(u32));
 
-	return arch_fast_hash2(hash_key, hash_u32s, 0);
+	return jhash2(hash_key, hash_u32s, 0);
 }
 
 static int flow_key_start(const struct sw_flow_key *key)
-- 
1.7.11.7
