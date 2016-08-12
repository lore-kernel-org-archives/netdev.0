From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] rhashtable: fix shift by 64 when shrinking
Date: Fri, 12 Aug 2016 20:10:44 +0200
Message-ID: <1471025444-22800-1-git-send-email-vegard.nossum@oracle.com>
Cc: netdev@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17577 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbcHLSKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 14:10:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got this:

    ================================================================================
    UBSAN: Undefined behaviour in ./include/linux/log2.h:63:13
    shift exponent 64 is too large for 64-bit type 'long unsigned int'
    CPU: 1 PID: 721 Comm: kworker/1:1 Not tainted 4.8.0-rc1+ #87
    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
    Workqueue: events rht_deferred_worker
     0000000000000000 ffff88011661f8d8 ffffffff82344f50 0000000041b58ab3
     ffffffff84f98000 ffffffff82344ea4 ffff88011661f900 ffff88011661f8b0
     0000000000000001 ffff88011661f6b8 dffffc0000000000 ffffffff867f7640
    Call Trace:
     [<ffffffff82344f50>] dump_stack+0xac/0xfc
     [<ffffffff82344ea4>] ? _atomic_dec_and_lock+0xc4/0xc4
     [<ffffffff8242f5b8>] ubsan_epilogue+0xd/0x8a
     [<ffffffff82430c41>] __ubsan_handle_shift_out_of_bounds+0x255/0x29a
     [<ffffffff824309ec>] ? __ubsan_handle_out_of_bounds+0x180/0x180
     [<ffffffff84003436>] ? nl80211_req_set_reg+0x256/0x2f0
     [<ffffffff812112ba>] ? print_context_stack+0x8a/0x160
     [<ffffffff81200031>] ? amd_pmu_reset+0x341/0x380
     [<ffffffff823af808>] rht_deferred_worker+0x1618/0x1790
     [<ffffffff823af808>] ? rht_deferred_worker+0x1618/0x1790
     [<ffffffff823ae1f0>] ? rhashtable_jhash2+0x370/0x370
     [<ffffffff8134c12d>] ? process_one_work+0x6fd/0x1970
     [<ffffffff8134c1cf>] process_one_work+0x79f/0x1970
     [<ffffffff8134c12d>] ? process_one_work+0x6fd/0x1970
     [<ffffffff8134ba30>] ? try_to_grab_pending+0x4c0/0x4c0
     [<ffffffff8134d564>] ? worker_thread+0x1c4/0x1340
     [<ffffffff8134d8ff>] worker_thread+0x55f/0x1340
     [<ffffffff845e904f>] ? __schedule+0x4df/0x1d40
     [<ffffffff8134d3a0>] ? process_one_work+0x1970/0x1970
     [<ffffffff8134d3a0>] ? process_one_work+0x1970/0x1970
     [<ffffffff813642f7>] kthread+0x237/0x390
     [<ffffffff813640c0>] ? __kthread_parkme+0x280/0x280
     [<ffffffff845f8c93>] ? _raw_spin_unlock_irq+0x33/0x50
     [<ffffffff845f95df>] ret_from_fork+0x1f/0x40
     [<ffffffff813640c0>] ? __kthread_parkme+0x280/0x280
    ================================================================================

roundup_pow_of_two() is undefined when called with an argument of 0, so
let's avoid the call and just fall back to ht->p.min_size (which should
never be smaller than HASH_MIN_SIZE).

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 lib/rhashtable.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5d845ff..fc47ca39 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -321,12 +321,14 @@ static int rhashtable_expand(struct rhashtable *ht)
 static int rhashtable_shrink(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
-	unsigned int size;
+	unsigned int nelems = atomic_read(&ht->nelems);
+	unsigned int size = 0;
 	int err;
 
 	ASSERT_RHT_MUTEX(ht);
 
-	size = roundup_pow_of_two(atomic_read(&ht->nelems) * 3 / 2);
+	if (nelems)
+		size = roundup_pow_of_two(nelems * 3 / 2);
 	if (size < ht->p.min_size)
 		size = ht->p.min_size;
 
-- 
1.9.1
