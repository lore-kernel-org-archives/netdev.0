From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/12] nfp: don't wait for resources indefinitely
Date: Sat, 27 May 2017 17:34:08 -0700
Message-ID: <20170528003411.17603-10-jakub.kicinski@netronome.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33665 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdE1Aet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:49 -0400
Received: by mail-pf0-f170.google.com with SMTP id e193so32674403pfh.0
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:49 -0700 (PDT)
In-Reply-To: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is currently no timeout to the resource and lock acquiring
loops.  We printed warnings and depended on user sending a signal
to the waiting process to stop the waiting.  This doesn't work
very well when wait happens out of a work queue.  The simplest
example of that is PCI probe.  When user loads the module and card
is in a broken state modprobe will wait forever and signals sent
to it will not actually reach the probing thread.

Make sure all wait loops have a time out.  Set the upper wait time
to 60 seconds to stay on the safe side.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h      |  5 +++++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mutex.c    |  9 +++++++--
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c | 10 ++++++++--
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
index 8d46b9acb69f..0a46c0984e68 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
@@ -63,6 +63,11 @@
 /* Max size of area it should be safe to request */
 #define NFP_CPP_SAFE_AREA_SIZE		SZ_2M
 
+/* NFP_MUTEX_WAIT_* are timeouts in seconds when waiting for a mutex */
+#define NFP_MUTEX_WAIT_FIRST_WARN	15
+#define NFP_MUTEX_WAIT_NEXT_WARN	5
+#define NFP_MUTEX_WAIT_ERROR		60
+
 struct device;
 
 struct nfp_cpp_area;
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mutex.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mutex.c
index 8a99c189efa8..f7b958181126 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mutex.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mutex.c
@@ -195,7 +195,8 @@ void nfp_cpp_mutex_free(struct nfp_cpp_mutex *mutex)
  */
 int nfp_cpp_mutex_lock(struct nfp_cpp_mutex *mutex)
 {
-	unsigned long warn_at = jiffies + 15 * HZ;
+	unsigned long warn_at = jiffies + NFP_MUTEX_WAIT_FIRST_WARN * HZ;
+	unsigned long err_at = jiffies + NFP_MUTEX_WAIT_ERROR * HZ;
 	unsigned int timeout_ms = 1;
 	int err;
 
@@ -214,12 +215,16 @@ int nfp_cpp_mutex_lock(struct nfp_cpp_mutex *mutex)
 			return -ERESTARTSYS;
 
 		if (time_is_before_eq_jiffies(warn_at)) {
-			warn_at = jiffies + 60 * HZ;
+			warn_at = jiffies + NFP_MUTEX_WAIT_NEXT_WARN * HZ;
 			nfp_warn(mutex->cpp,
 				 "Warning: waiting for NFP mutex [depth:%hd target:%d addr:%llx key:%08x]\n",
 				 mutex->depth,
 				 mutex->target, mutex->address, mutex->key);
 		}
+		if (time_is_before_eq_jiffies(err_at)) {
+			nfp_err(mutex->cpp, "Error: mutex wait timed out\n");
+			return -EBUSY;
+		}
 	}
 
 	return err;
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
index 2d15a7c9d0de..072612263dab 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
@@ -181,7 +181,8 @@ nfp_resource_try_acquire(struct nfp_cpp *cpp, struct nfp_resource *res,
 struct nfp_resource *
 nfp_resource_acquire(struct nfp_cpp *cpp, const char *name)
 {
-	unsigned long warn_at = jiffies + 15 * HZ;
+	unsigned long warn_at = jiffies + NFP_MUTEX_WAIT_FIRST_WARN * HZ;
+	unsigned long err_at = jiffies + NFP_MUTEX_WAIT_ERROR * HZ;
 	struct nfp_cpp_mutex *dev_mutex;
 	struct nfp_resource *res;
 	int err;
@@ -214,10 +215,15 @@ nfp_resource_acquire(struct nfp_cpp *cpp, const char *name)
 		}
 
 		if (time_is_before_eq_jiffies(warn_at)) {
-			warn_at = jiffies + 60 * HZ;
+			warn_at = jiffies + NFP_MUTEX_WAIT_NEXT_WARN * HZ;
 			nfp_warn(cpp, "Warning: waiting for NFP resource %s\n",
 				 name);
 		}
+		if (time_is_before_eq_jiffies(err_at)) {
+			nfp_err(cpp, "Error: resource %s timed out\n", name);
+			err = -EBUSY;
+			goto err_free;
+		}
 	}
 
 	nfp_cpp_mutex_free(dev_mutex);
-- 
2.11.0
