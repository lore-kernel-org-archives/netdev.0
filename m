From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/15] nfp: don't ignore return value of wait_event_interruptible
Date: Tue, 21 Mar 2017 17:59:14 -0700
Message-ID: <20170322005921.10965-9-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35977 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758583AbdCVBIm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:08:42 -0400
Received: by mail-pf0-f182.google.com with SMTP id o126so86735858pfb.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:08:38 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When signal interrupts waiting for an area to become available
we assume success.  Pay attention to the return code.  Unpack
the code a little bit to make it more readable.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   | 56 +++++++++++++++-------
 1 file changed, 38 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index 5189fedb0f4f..2e4796b52b84 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -411,9 +411,43 @@ nfp_cpp_area_alloc(struct nfp_cpp *cpp, u32 dest,
  */
 void nfp_cpp_area_free(struct nfp_cpp_area *area)
 {
+	if (atomic_read(&area->refcount))
+		nfp_warn(area->cpp, "Warning: freeing busy area\n");
 	nfp_cpp_area_put(area);
 }
 
+static bool nfp_cpp_area_acquire_try(struct nfp_cpp_area *area, int *status)
+{
+	*status = area->cpp->op->area_acquire(area);
+
+	return *status != -EAGAIN;
+}
+
+static int __nfp_cpp_area_acquire(struct nfp_cpp_area *area)
+{
+	int err, status;
+
+	if (atomic_inc_return(&area->refcount) > 1)
+		return 0;
+
+	if (!area->cpp->op->area_acquire)
+		return 0;
+
+	err = wait_event_interruptible(area->cpp->waitq,
+				       nfp_cpp_area_acquire_try(area, &status));
+	if (!err)
+		err = status;
+	if (err) {
+		nfp_warn(area->cpp, "Warning: area wait failed: %d\n", err);
+		atomic_dec(&area->refcount);
+		return err;
+	}
+
+	nfp_cpp_area_get(area);
+
+	return 0;
+}
+
 /**
  * nfp_cpp_area_acquire() - lock down a CPP area for access
  * @area:	CPP area handle
@@ -425,27 +459,13 @@ void nfp_cpp_area_free(struct nfp_cpp_area *area)
  */
 int nfp_cpp_area_acquire(struct nfp_cpp_area *area)
 {
-	mutex_lock(&area->mutex);
-	if (atomic_inc_return(&area->refcount) == 1) {
-		int (*a_a)(struct nfp_cpp_area *);
-
-		a_a = area->cpp->op->area_acquire;
-		if (a_a) {
-			int err;
+	int ret;
 
-			wait_event_interruptible(area->cpp->waitq,
-						 (err = a_a(area)) != -EAGAIN);
-			if (err < 0) {
-				atomic_dec(&area->refcount);
-				mutex_unlock(&area->mutex);
-				return err;
-			}
-		}
-	}
+	mutex_lock(&area->mutex);
+	ret = __nfp_cpp_area_acquire(area);
 	mutex_unlock(&area->mutex);
 
-	nfp_cpp_area_get(area);
-	return 0;
+	return ret;
 }
 
 /**
-- 
2.11.0
