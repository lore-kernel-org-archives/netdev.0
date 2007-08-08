From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] Block device throttling [Re: Distributed storage.]
Date: Wed, 8 Aug 2007 14:17:09 +0400
Message-ID: <20070808101708.GA23815@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708051423.45484.phillips@phunq.net> <20070807120523.GX5245@kernel.dk> <200708071124.56859.phillips@phunq.net> <20070807205538.GB5245@kernel.dk> <20070808095448.GA3440@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Phillips <phillips@phunq.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933627AbXHHKRv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070808095448.GA3440@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This throttling mechanism allows to limit maximum amount of queued bios 
per physical device. By default it is turned off and old block layer 
behaviour with unlimited number of bios is used. When turned on (queue
limit is set to something different than -1U via blk_set_queue_limit()),
generic_make_request() will sleep until there is room in the queue.
number of bios is increased in generic_make_request() and reduced either
in bio_endio(), when bio is completely processed (bi_size is zero), and
recharged from original queue when new device is assigned to bio via
blk_set_bdev(). All oerations are not atomic, since we do not care about
precise number of bios, but a fact, that we are close or close enough to
the limit.

Tested on distributed storage device - with limit of 2 bios it works
slow :)

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/block/ll_rw_blk.c b/block/ll_rw_blk.c
index c99b463..1882c9b 100644
--- a/block/ll_rw_blk.c
+++ b/block/ll_rw_blk.c
@@ -1851,6 +1851,10 @@ request_queue_t *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
 	q->backing_dev_info.unplug_io_data = q;
 
+	q->bio_limit = -1U;
+	q->bio_queued = 0;
+	init_waitqueue_head(&q->wait);
+
 	mutex_init(&q->sysfs_lock);
 
 	return q;
@@ -3237,6 +3241,16 @@ end_io:
  */
 void generic_make_request(struct bio *bio)
 {
+	request_queue_t *q;
+
+	BUG_ON(!bio->bi_bdev)
+
+	q = bdev_get_queue(bio->bi_bdev);
+	if (q && q->bio_limit != -1U) {
+		wait_event_interruptible(q->wait, q->bio_queued + 1 <= q->bio_limit);
+		q->bio_queued++;
+	}
+
 	if (current->bio_tail) {
 		/* make_request is active */
 		*(current->bio_tail) = bio;
diff --git a/fs/bio.c b/fs/bio.c
index 093345f..0a33958 100644
--- a/fs/bio.c
+++ b/fs/bio.c
@@ -1028,6 +1028,16 @@ void bio_endio(struct bio *bio, unsigned int bytes_done, int error)
 	bio->bi_size -= bytes_done;
 	bio->bi_sector += (bytes_done >> 9);
 
+	if (!bio->bi_size && bio->bi_bdev) {
+		request_queue_t *q;
+
+		q = bdev_get_queue(bio->bi_bdev);
+		if (q) {
+			q->bio_queued--;
+			wake_up(&q->wait);
+		}
+	}
+
 	if (bio->bi_end_io)
 		bio->bi_end_io(bio, bytes_done, error);
 }
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index db5b00a..7ce0cd7 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -467,6 +467,9 @@ struct request_queue
 	struct request		*orig_bar_rq;
 	unsigned int		bi_size;
 
+	wait_queue_head_t	wait;
+	unsigned int		bio_limit, bio_queued;
+
 	struct mutex		sysfs_lock;
 };
 
@@ -764,6 +767,30 @@ extern long nr_blockdev_pages(void);
 int blk_get_queue(request_queue_t *);
 request_queue_t *blk_alloc_queue(gfp_t);
 request_queue_t *blk_alloc_queue_node(gfp_t, int);
+
+static inline void blk_queue_set_limit(request_queue_t *q, unsigned int limit)
+{
+	q->bio_limit = limit;
+}
+
+static inline void blk_set_bdev(struct bio *bio, struct block_device *bdev)
+{
+	request_queue_t *q;
+
+	if (!bio->bi_bdev) {
+		bio->bi_bdev = bdev;
+		return;
+	}
+	
+	q = bdev_get_queue(bio->bi_bdev);
+	if (q) {
+		q->bio_queued--;
+		wake_up(&q->wait);
+	}
+
+	bio->bi_bdev = bdev;
+}
+
 extern void blk_put_queue(request_queue_t *);
 
 /*

-- 
	Evgeniy Polyakov
