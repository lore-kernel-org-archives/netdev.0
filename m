From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 10/29] drivers,
 md: convert stripe_head.count from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:20:57 +0200
Message-ID: <1488810076-3754-11-git-send-email-elena.reshetova@intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, linux-pci@vger.kernel.org,
 target-devel@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
 Elena Reshetova <elena.reshetova@intel.com>, devel@driverdev.osuosl.org,
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-serial@vger.kernel.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, open-iscsi@googlegroups.com,
 linux-media@vger.kernel.org, Kees Cook <keescook@chromium.org>,
 linux-raid@vger.kernel.org, linux-bcache@vger.kernel.org,
 Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 drivers/md/raid5-cache.c |  8 +++---
 drivers/md/raid5.c       | 66 ++++++++++++++++++++++++------------------------
 drivers/md/raid5.h       |  3 ++-
 3 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/drivers/md/raid5-cache.c b/drivers/md/raid5-cache.c
index 3f307be..6c05e12 100644
--- a/drivers/md/raid5-cache.c
+++ b/drivers/md/raid5-cache.c
@@ -979,7 +979,7 @@ int r5l_write_stripe(struct r5l_log *log, struct stripe_head *sh)
 	 * don't delay.
 	 */
 	clear_bit(STRIPE_DELAYED, &sh->state);
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 
 	mutex_lock(&log->io_mutex);
 	/* meta + data */
@@ -1321,7 +1321,7 @@ static void r5c_flush_stripe(struct r5conf *conf, struct stripe_head *sh)
 	assert_spin_locked(&conf->device_lock);
 
 	list_del_init(&sh->lru);
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 
 	set_bit(STRIPE_HANDLE, &sh->state);
 	atomic_inc(&conf->active_stripes);
@@ -1424,7 +1424,7 @@ static void r5c_do_reclaim(struct r5conf *conf)
 			 */
 			if (!list_empty(&sh->lru) &&
 			    !test_bit(STRIPE_HANDLE, &sh->state) &&
-			    atomic_read(&sh->count) == 0) {
+			    refcount_read(&sh->count) == 0) {
 				r5c_flush_stripe(conf, sh);
 				if (count++ >= R5C_RECLAIM_STRIPE_GROUP)
 					break;
@@ -2650,7 +2650,7 @@ r5c_cache_data(struct r5l_log *log, struct stripe_head *sh,
 	 * don't delay.
 	 */
 	clear_bit(STRIPE_DELAYED, &sh->state);
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 
 	mutex_lock(&log->io_mutex);
 	/* meta + data */
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 2ce23b0..30c96a8 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -296,7 +296,7 @@ static void do_release_stripe(struct r5conf *conf, struct stripe_head *sh,
 static void __release_stripe(struct r5conf *conf, struct stripe_head *sh,
 			     struct list_head *temp_inactive_list)
 {
-	if (atomic_dec_and_test(&sh->count))
+	if (refcount_dec_and_test(&sh->count))
 		do_release_stripe(conf, sh, temp_inactive_list);
 }
 
@@ -388,7 +388,7 @@ void raid5_release_stripe(struct stripe_head *sh)
 
 	/* Avoid release_list until the last reference.
 	 */
-	if (atomic_add_unless(&sh->count, -1, 1))
+	if (refcount_dec_not_one(&sh->count))
 		return;
 
 	if (unlikely(!conf->mddev->thread) ||
@@ -401,7 +401,7 @@ void raid5_release_stripe(struct stripe_head *sh)
 slow_path:
 	local_irq_save(flags);
 	/* we are ok here if STRIPE_ON_RELEASE_LIST is set or not */
-	if (atomic_dec_and_lock(&sh->count, &conf->device_lock)) {
+	if (refcount_dec_and_lock(&sh->count, &conf->device_lock)) {
 		INIT_LIST_HEAD(&list);
 		hash = sh->hash_lock_index;
 		do_release_stripe(conf, sh, &list);
@@ -491,7 +491,7 @@ static void init_stripe(struct stripe_head *sh, sector_t sector, int previous)
 	struct r5conf *conf = sh->raid_conf;
 	int i, seq;
 
-	BUG_ON(atomic_read(&sh->count) != 0);
+	BUG_ON(refcount_read(&sh->count) != 0);
 	BUG_ON(test_bit(STRIPE_HANDLE, &sh->state));
 	BUG_ON(stripe_operations_active(sh));
 	BUG_ON(sh->batch_head);
@@ -668,11 +668,11 @@ raid5_get_active_stripe(struct r5conf *conf, sector_t sector,
 					  &conf->cache_state);
 			} else {
 				init_stripe(sh, sector, previous);
-				atomic_inc(&sh->count);
+				refcount_inc(&sh->count);
 			}
-		} else if (!atomic_inc_not_zero(&sh->count)) {
+		} else if (!refcount_inc_not_zero(&sh->count)) {
 			spin_lock(&conf->device_lock);
-			if (!atomic_read(&sh->count)) {
+			if (!refcount_read(&sh->count)) {
 				if (!test_bit(STRIPE_HANDLE, &sh->state))
 					atomic_inc(&conf->active_stripes);
 				BUG_ON(list_empty(&sh->lru) &&
@@ -688,7 +688,7 @@ raid5_get_active_stripe(struct r5conf *conf, sector_t sector,
 					sh->group = NULL;
 				}
 			}
-			atomic_inc(&sh->count);
+			refcount_inc(&sh->count);
 			spin_unlock(&conf->device_lock);
 		}
 	} while (sh == NULL);
@@ -752,9 +752,9 @@ static void stripe_add_to_batch_list(struct r5conf *conf, struct stripe_head *sh
 	hash = stripe_hash_locks_hash(head_sector);
 	spin_lock_irq(conf->hash_locks + hash);
 	head = __find_stripe(conf, head_sector, conf->generation);
-	if (head && !atomic_inc_not_zero(&head->count)) {
+	if (head && !refcount_inc_not_zero(&head->count)) {
 		spin_lock(&conf->device_lock);
-		if (!atomic_read(&head->count)) {
+		if (!refcount_read(&head->count)) {
 			if (!test_bit(STRIPE_HANDLE, &head->state))
 				atomic_inc(&conf->active_stripes);
 			BUG_ON(list_empty(&head->lru) &&
@@ -770,7 +770,7 @@ static void stripe_add_to_batch_list(struct r5conf *conf, struct stripe_head *sh
 				head->group = NULL;
 			}
 		}
-		atomic_inc(&head->count);
+		refcount_inc(&head->count);
 		spin_unlock(&conf->device_lock);
 	}
 	spin_unlock_irq(conf->hash_locks + hash);
@@ -833,7 +833,7 @@ static void stripe_add_to_batch_list(struct r5conf *conf, struct stripe_head *sh
 		sh->batch_head->bm_seq = seq;
 	}
 
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 unlock_out:
 	unlock_two_stripes(head, sh);
 out:
@@ -1036,9 +1036,9 @@ static void ops_run_io(struct stripe_head *sh, struct stripe_head_state *s)
 			pr_debug("%s: for %llu schedule op %d on disc %d\n",
 				__func__, (unsigned long long)sh->sector,
 				bi->bi_opf, i);
-			atomic_inc(&sh->count);
+			refcount_inc(&sh->count);
 			if (sh != head_sh)
-				atomic_inc(&head_sh->count);
+				refcount_inc(&head_sh->count);
 			if (use_new_offset(conf, sh))
 				bi->bi_iter.bi_sector = (sh->sector
 						 + rdev->new_data_offset);
@@ -1097,9 +1097,9 @@ static void ops_run_io(struct stripe_head *sh, struct stripe_head_state *s)
 				 "replacement disc %d\n",
 				__func__, (unsigned long long)sh->sector,
 				rbi->bi_opf, i);
-			atomic_inc(&sh->count);
+			refcount_inc(&sh->count);
 			if (sh != head_sh)
-				atomic_inc(&head_sh->count);
+				refcount_inc(&head_sh->count);
 			if (use_new_offset(conf, sh))
 				rbi->bi_iter.bi_sector = (sh->sector
 						  + rrdev->new_data_offset);
@@ -1275,7 +1275,7 @@ static void ops_run_biofill(struct stripe_head *sh)
 		}
 	}
 
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 	init_async_submit(&submit, ASYNC_TX_ACK, tx, ops_complete_biofill, sh, NULL);
 	async_trigger_callback(&submit);
 }
@@ -1353,7 +1353,7 @@ ops_run_compute5(struct stripe_head *sh, struct raid5_percpu *percpu)
 		if (i != target)
 			xor_srcs[count++] = sh->dev[i].page;
 
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 
 	init_async_submit(&submit, ASYNC_TX_FENCE|ASYNC_TX_XOR_ZERO_DST, NULL,
 			  ops_complete_compute, sh, to_addr_conv(sh, percpu, 0));
@@ -1441,7 +1441,7 @@ ops_run_compute6_1(struct stripe_head *sh, struct raid5_percpu *percpu)
 	BUG_ON(!test_bit(R5_Wantcompute, &tgt->flags));
 	dest = tgt->page;
 
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 
 	if (target == qd_idx) {
 		count = set_syndrome_sources(blocks, sh, SYNDROME_SRC_ALL);
@@ -1516,7 +1516,7 @@ ops_run_compute6_2(struct stripe_head *sh, struct raid5_percpu *percpu)
 	pr_debug("%s: stripe: %llu faila: %d failb: %d\n",
 		 __func__, (unsigned long long)sh->sector, faila, failb);
 
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 
 	if (failb == syndrome_disks+1) {
 		/* Q disk is one of the missing disks */
@@ -1784,7 +1784,7 @@ ops_run_reconstruct5(struct stripe_head *sh, struct raid5_percpu *percpu,
 			break;
 	}
 	if (i >= sh->disks) {
-		atomic_inc(&sh->count);
+		refcount_inc(&sh->count);
 		set_bit(R5_Discard, &sh->dev[pd_idx].flags);
 		ops_complete_reconstruct(sh);
 		return;
@@ -1825,7 +1825,7 @@ ops_run_reconstruct5(struct stripe_head *sh, struct raid5_percpu *percpu,
 		flags = ASYNC_TX_ACK |
 			(prexor ? ASYNC_TX_XOR_DROP_DST : ASYNC_TX_XOR_ZERO_DST);
 
-		atomic_inc(&head_sh->count);
+		refcount_inc(&head_sh->count);
 		init_async_submit(&submit, flags, tx, ops_complete_reconstruct, head_sh,
 				  to_addr_conv(sh, percpu, j));
 	} else {
@@ -1867,7 +1867,7 @@ ops_run_reconstruct6(struct stripe_head *sh, struct raid5_percpu *percpu,
 			break;
 	}
 	if (i >= sh->disks) {
-		atomic_inc(&sh->count);
+		refcount_inc(&sh->count);
 		set_bit(R5_Discard, &sh->dev[sh->pd_idx].flags);
 		set_bit(R5_Discard, &sh->dev[sh->qd_idx].flags);
 		ops_complete_reconstruct(sh);
@@ -1891,7 +1891,7 @@ ops_run_reconstruct6(struct stripe_head *sh, struct raid5_percpu *percpu,
 				 struct stripe_head, batch_list) == head_sh;
 
 	if (last_stripe) {
-		atomic_inc(&head_sh->count);
+		refcount_inc(&head_sh->count);
 		init_async_submit(&submit, txflags, tx, ops_complete_reconstruct,
 				  head_sh, to_addr_conv(sh, percpu, j));
 	} else
@@ -1948,7 +1948,7 @@ static void ops_run_check_p(struct stripe_head *sh, struct raid5_percpu *percpu)
 	tx = async_xor_val(xor_dest, xor_srcs, 0, count, STRIPE_SIZE,
 			   &sh->ops.zero_sum_result, &submit);
 
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 	init_async_submit(&submit, ASYNC_TX_ACK, tx, ops_complete_check, sh, NULL);
 	tx = async_trigger_callback(&submit);
 }
@@ -1967,7 +1967,7 @@ static void ops_run_check_pq(struct stripe_head *sh, struct raid5_percpu *percpu
 	if (!checkp)
 		srcs[count] = NULL;
 
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 	init_async_submit(&submit, ASYNC_TX_ACK, NULL, ops_complete_check,
 			  sh, to_addr_conv(sh, percpu, 0));
 	async_syndrome_val(srcs, 0, count+2, STRIPE_SIZE,
@@ -2057,7 +2057,7 @@ static struct stripe_head *alloc_stripe(struct kmem_cache *sc, gfp_t gfp,
 		INIT_LIST_HEAD(&sh->lru);
 		INIT_LIST_HEAD(&sh->r5c);
 		INIT_LIST_HEAD(&sh->log_list);
-		atomic_set(&sh->count, 1);
+		refcount_set(&sh->count, 1);
 		sh->log_start = MaxSector;
 		for (i = 0; i < disks; i++) {
 			struct r5dev *dev = &sh->dev[i];
@@ -2354,7 +2354,7 @@ static int drop_one_stripe(struct r5conf *conf)
 	spin_unlock_irq(conf->hash_locks + hash);
 	if (!sh)
 		return 0;
-	BUG_ON(atomic_read(&sh->count));
+	BUG_ON(refcount_read(&sh->count));
 	shrink_buffers(sh);
 	kmem_cache_free(conf->slab_cache, sh);
 	atomic_dec(&conf->active_stripes);
@@ -2386,7 +2386,7 @@ static void raid5_end_read_request(struct bio * bi)
 			break;
 
 	pr_debug("end_read_request %llu/%d, count: %d, error %d.\n",
-		(unsigned long long)sh->sector, i, atomic_read(&sh->count),
+		(unsigned long long)sh->sector, i, refcount_read(&sh->count),
 		bi->bi_error);
 	if (i == disks) {
 		bio_reset(bi);
@@ -2523,7 +2523,7 @@ static void raid5_end_write_request(struct bio *bi)
 		}
 	}
 	pr_debug("end_write_request %llu/%d, count %d, error: %d.\n",
-		(unsigned long long)sh->sector, i, atomic_read(&sh->count),
+		(unsigned long long)sh->sector, i, refcount_read(&sh->count),
 		bi->bi_error);
 	if (i == disks) {
 		bio_reset(bi);
@@ -4545,7 +4545,7 @@ static void handle_stripe(struct stripe_head *sh)
 	pr_debug("handling stripe %llu, state=%#lx cnt=%d, "
 		"pd_idx=%d, qd_idx=%d\n, check:%d, reconstruct:%d\n",
 	       (unsigned long long)sh->sector, sh->state,
-	       atomic_read(&sh->count), sh->pd_idx, sh->qd_idx,
+	       refcount_read(&sh->count), sh->pd_idx, sh->qd_idx,
 	       sh->check_state, sh->reconstruct_state);
 
 	analyse_stripe(sh, &s);
@@ -4924,7 +4924,7 @@ static void activate_bit_delay(struct r5conf *conf,
 		struct stripe_head *sh = list_entry(head.next, struct stripe_head, lru);
 		int hash;
 		list_del_init(&sh->lru);
-		atomic_inc(&sh->count);
+		refcount_inc(&sh->count);
 		hash = sh->hash_lock_index;
 		__release_stripe(conf, sh, &temp_inactive_list[hash]);
 	}
@@ -5240,7 +5240,7 @@ static struct stripe_head *__get_priority_stripe(struct r5conf *conf, int group)
 		sh->group = NULL;
 	}
 	list_del_init(&sh->lru);
-	BUG_ON(atomic_inc_return(&sh->count) != 1);
+	BUG_ON(refcount_inc_not_zero(&sh->count));
 	return sh;
 }
 
diff --git a/drivers/md/raid5.h b/drivers/md/raid5.h
index 4bb27b9..a1ed351 100644
--- a/drivers/md/raid5.h
+++ b/drivers/md/raid5.h
@@ -3,6 +3,7 @@
 
 #include <linux/raid/xor.h>
 #include <linux/dmaengine.h>
+#include <linux/refcount.h>
 
 /*
  *
@@ -207,7 +208,7 @@ struct stripe_head {
 	short			ddf_layout;/* use DDF ordering to calculate Q */
 	short			hash_lock_index;
 	unsigned long		state;		/* state flags */
-	atomic_t		count;	      /* nr of active thread/requests */
+	refcount_t		count;	      /* nr of active thread/requests */
 	int			bm_seq;	/* sequence number for bitmap flushes */
 	int			disks;		/* disks in stripe */
 	int			overwrite_disks; /* total overwrite disks in stripe,
-- 
2.7.4
