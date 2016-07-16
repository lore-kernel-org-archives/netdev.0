From: Varun Prakash <varun@chelsio.com>
Subject: [net-next v2 5/6] libcxgb: export ppm release and tagmask set api
Date: Sat, 16 Jul 2016 22:49:19 +0530
Message-ID: <cf7a242eb9b5e844b263e36e411030792273ea3e.1468689125.git.varun@chelsio.com>
References: <cover.1468689125.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	hariprasad@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:30103 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751918AbcGPRWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 13:22:25 -0400
In-Reply-To: <cover.1468689125.git.varun@chelsio.com>
In-Reply-To: <cover.1468689125.git.varun@chelsio.com>
References: <cover.1468689125.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export cxgbi_ppm_release() to release
ppod manager and cxgbi_tagmask_set() to
set tag mask, they are used by cxgb3i, cxgb4i
and cxgbit.

Signed-off-by: Varun Prakash <varun@chelsio.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c | 2 ++
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c                 | 1 +
 drivers/scsi/cxgbi/libcxgbi.c                      | 1 +
 drivers/target/iscsi/cxgbit/cxgbit_main.c          | 2 ++
 4 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
index 4cd1072..96c9651 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
@@ -337,6 +337,7 @@ int cxgbi_ppm_release(struct cxgbi_ppm *ppm)
 	}
 	return 1;
 }
+EXPORT_SYMBOL(cxgbi_ppm_release);
 
 static struct cxgbi_ppm_pool *ppm_alloc_cpu_pool(unsigned int *total,
 						 unsigned int *pcpu_ppmax)
@@ -490,6 +491,7 @@ unsigned int cxgbi_tagmask_set(unsigned int ppmax)
 
 	return 1 << (bits + PPOD_IDX_SHIFT);
 }
+EXPORT_SYMBOL(cxgbi_tagmask_set);
 
 static int __init libcxgb_init(void)
 {
diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index bb25ebb..61f16a2 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -1234,6 +1234,7 @@ static int cxgb3i_ddp_init(struct cxgbi_device *cdev)
 	}
 
 	ppmax = (uinfo.ulimit - uinfo.llimit + 1) >> PPOD_SIZE_SHIFT;
+	tagmask = cxgbi_tagmask_set(ppmax);
 
 	pr_info("T3 %s: 0x%x~0x%x, 0x%x, tagmask 0x%x -> 0x%x.\n",
 		ndev->name, uinfo.llimit, uinfo.ulimit, ppmax, uinfo.tagmask,
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 9d425a7..d142113 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -121,6 +121,7 @@ static inline void cxgbi_device_destroy(struct cxgbi_device *cdev)
 		"cdev 0x%p, p# %u.\n", cdev, cdev->nports);
 	cxgbi_hbas_remove(cdev);
 	cxgbi_device_portmap_cleanup(cdev);
+	cxgbi_ppm_release(cdev->cdev2ppm(cdev));
 	if (cdev->pmap.max_connect)
 		cxgbi_free_big_mem(cdev->pmap.port_csk);
 	kfree(cdev);
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_main.c b/drivers/target/iscsi/cxgbit/cxgbit_main.c
index 60dccd0..27dd11a 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_main.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_main.c
@@ -26,6 +26,8 @@ void _cxgbit_free_cdev(struct kref *kref)
 	struct cxgbit_device *cdev;
 
 	cdev = container_of(kref, struct cxgbit_device, kref);
+
+	cxgbi_ppm_release(cdev2ppm(cdev));
 	kfree(cdev);
 }
 
-- 
2.0.2
