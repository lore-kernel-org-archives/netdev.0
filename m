From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 08:32:07 +0100
Message-ID: <20071031073207.GA5059@kernel.dk>
References: <20071030.204002.193703502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:21286 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852AbXJaHer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 03:34:47 -0400
Content-Disposition: inline
In-Reply-To: <20071030.204002.193703502.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30 2007, David Miller wrote:
> 
> I just checked the following bug fix into net-2.6
> 
> Rusty, have a quick look at virtio_net wrt. the changes I
> made to skb_to_sgvec()'s behavior.  I think I might have
> even fixed something :-)
> 
> Jens, please review my commentary wrt. sg_mark_end() and
> it's nonintuitive behavior which led to these bugs.

I fully agree, lets just change sg_mark_end() to NOT overwrite a stored
page there. The current interface isn't nice and can't be used after
filling the sg table, which is what users would want. I've added such a
patch to the sg repo.

>From 5a0347663f51850eb52b89c4dcf6a714ea8d3965 Mon Sep 17 00:00:00 2001
From: Jens Axboe <jens.axboe@oracle.com>
Date: Wed, 31 Oct 2007 08:31:23 +0100
Subject: [PATCH] [SG] Remove __sg_mark_end()

Make sg_mark_end() NOT overwrite the page link. Then it can be used
after filling the sg table, which is what users want. That means that
__sg_mark_end() is no longer useful, so kill it.

It's important the sg entries be initialized before using sg_mark_end(),
so also add a debug check to catch use-before-init.

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 block/ll_rw_blk.c           |    2 +-
 include/linux/scatterlist.h |   10 ++++------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/block/ll_rw_blk.c b/block/ll_rw_blk.c
index e948407..fdc0707 100644
--- a/block/ll_rw_blk.c
+++ b/block/ll_rw_blk.c
@@ -1369,7 +1369,7 @@ new_segment:
 	} /* segments in rq */
 
 	if (sg)
-		__sg_mark_end(sg);
+		sg_mark_end(sg);
 
 	return nsegs;
 }
diff --git a/include/linux/scatterlist.h b/include/linux/scatterlist.h
index d5e1876..aa97954 100644
--- a/include/linux/scatterlist.h
+++ b/include/linux/scatterlist.h
@@ -195,13 +195,11 @@ static inline void sg_chain(struct scatterlist *prv, unsigned int prv_nents,
  *   Marks the last entry as the termination point for sg_next()
  *
  **/
-static inline void sg_mark_end(struct scatterlist *sgl, unsigned int nents)
-{
-	sgl[nents - 1].page_link = 0x02;
-}
-
-static inline void __sg_mark_end(struct scatterlist *sg)
+static inline void sg_mark_end(struct scatterlist *sg)
 {
+#ifdef CONFIG_DEBUG_SG
+	BUG_ON(sg->sg_magic != SG_MAGIC);
+#endif
 	sg->page_link |= 0x02;
 }
 
-- 
1.5.3.GIT


-- 
Jens Axboe

