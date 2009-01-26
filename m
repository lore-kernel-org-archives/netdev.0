From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 2/2] iw_cxgb3 - handle chip reset notifications
Date: Mon, 26 Jan 2009 09:46:11 -0800
Message-ID: <20090126174611.29736.55008.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:18394 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753782AbZAZRqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:46:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Freeze activity when notified that the underlying chip
is getting reset on a EEH event or fatal error.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/infiniband/hw/cxgb3/cxio_hal.c |    3 +++
 drivers/infiniband/hw/cxgb3/cxio_hal.h |    2 ++
 drivers/infiniband/hw/cxgb3/iwch.c     |   15 ++++++++++++++-
 3 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index 4dcf08b..11efd35 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -701,6 +701,9 @@ static int __cxio_tpt_op(struct cxio_rdev *rdev_p, u32 reset_tpt_entry,
 	u32 stag_idx;
 	u32 wptr;
 
+	if (rdev_p->flags)
+		return -EIO;
+
 	stag_state = stag_state > 0;
 	stag_idx = (*stag) >> 8;
 
diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.h b/drivers/infiniband/hw/cxgb3/cxio_hal.h
index 656fe47..9ed65b0 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.h
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.h
@@ -108,6 +108,8 @@ struct cxio_rdev {
 	struct gen_pool *pbl_pool;
 	struct gen_pool *rqt_pool;
 	struct list_head entry;
+	u32	flags;
+#define	CXIO_ERROR_FATAL	1
 };
 
 static inline int cxio_num_stags(struct cxio_rdev *rdev_p)
diff --git a/drivers/infiniband/hw/cxgb3/iwch.c b/drivers/infiniband/hw/cxgb3/iwch.c
index 4489c89..37a4fc2 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.c
+++ b/drivers/infiniband/hw/cxgb3/iwch.c
@@ -51,13 +51,15 @@ cxgb3_cpl_handler_func t3c_handlers[NUM_CPL_CMDS];
 
 static void open_rnic_dev(struct t3cdev *);
 static void close_rnic_dev(struct t3cdev *);
+static void iwch_err_handler(struct t3cdev *, u32, u32);
 
 struct cxgb3_client t3c_client = {
 	.name = "iw_cxgb3",
 	.add = open_rnic_dev,
 	.remove = close_rnic_dev,
 	.handlers = t3c_handlers,
-	.redirect = iwch_ep_redirect
+	.redirect = iwch_ep_redirect,
+	.err_handler = iwch_err_handler
 };
 
 static LIST_HEAD(dev_list);
@@ -160,6 +162,17 @@ static void close_rnic_dev(struct t3cdev *tdev)
 	mutex_unlock(&dev_mutex);
 }
 
+static void iwch_err_handler(struct t3cdev *tdev, u32 status, u32 error)
+{
+	struct cxio_rdev *rdev = tdev->ulp;
+
+	if (status == OFFLOAD_STATUS_DOWN)
+		rdev->flags = CXIO_ERROR_FATAL;
+
+	return;
+
+}
+
 static int __init iwch_init_module(void)
 {
 	int err;

