From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] RDMA/cxgb3: test before subtraction on unsigned
Date: Tue, 03 Mar 2009 14:38:35 +0100
Message-ID: <49AD32DB.20407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: swise@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:53199 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910AbZCCNij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 08:38:39 -0500
Received: by ewy25 with SMTP id 25so2323564ewy.37
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2009 05:38:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think there's someting wrong in iwch_post_send():

// vi drivers/infiniband/hw/cxgb3/iwch_qp.c +353
int iwch_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
                      struct ib_send_wr **bad_wr)
{
	...
        u32 num_wrs;
	...
        num_wrs = Q_FREECNT(qhp->wq.sq_rptr, qhp->wq.sq_wptr,
                  qhp->wq.sq_size_log2);
        if (num_wrs <= 0) {
                spin_unlock_irqrestore(&qhp->lock, flag);
                return -ENOMEM;
        }

// vi drivers/infiniband/hw/cxgb3/cxio_wr.h +50
#define Q_FREECNT(rptr,wptr,size_log2) ((1UL<<size_log2)-((wptr)-(rptr)))

Since num_wrs is unsigned, I think the test should occur before the subtraction,
right? please review.
------------------------------>8-------------8<---------------------------------
num_wrs is unsigned so test before the subtraction.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index 19661b2..1c6ebaf 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -369,12 +369,13 @@ int iwch_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		spin_unlock_irqrestore(&qhp->lock, flag);
 		return -EINVAL;
 	}
-	num_wrs = Q_FREECNT(qhp->wq.sq_rptr, qhp->wq.sq_wptr,
-		  qhp->wq.sq_size_log2);
-	if (num_wrs <= 0) {
+	if ((1UL << qhp->wq.sq_size_log2) + qhp->wq.sq_rptr <=
+			qhp->wq.sq_wptr) {
 		spin_unlock_irqrestore(&qhp->lock, flag);
 		return -ENOMEM;
 	}
+	num_wrs = Q_FREECNT(qhp->wq.sq_rptr, qhp->wq.sq_wptr,
+		  qhp->wq.sq_size_log2);
 	while (wr) {
 		if (num_wrs == 0) {
 			err = -ENOMEM;


