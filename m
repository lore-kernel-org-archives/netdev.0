From: Varun Prakash <varun@chelsio.com>
Subject: [net-next 5/6] libcxgb: export ppm release and tagmask set api
Date: Fri,  8 Jul 2016 23:03:58 +0530
Message-ID: <d3d6ff733cfba2fa6caf6d4a42887adc60345ea7.1467998293.git.varun@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	varun@chelsio.com
To: davem@davemloft.net
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export cxgbi_ppm_release() to release
ppod manager and cxgbi_tagmask_set() to
set tag mask, they are used by cxgb3i, cxgb4i
and cxgbit.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c | 2 ++
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c                 | 1 +
 drivers/scsi/cxgbi/libcxgbi.c                      | 1 +
 drivers/target/iscsi/cxgbit/cxgbit_main.c          | 2 ++
 4 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
index aa9a9bb..3d6970a 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
@@ -313,6 +313,7 @@ int cxgbi_ppm_release(struct cxgbi_ppm *ppm)
 	}
 	return 1;
 }
+EXPORT_SYMBOL(cxgbi_ppm_release);
 
 static struct cxgbi_ppm_pool *ppm_alloc_cpu_pool(unsigned int *total,
 						 unsigned int *pcpu_ppmax)
@@ -466,6 +467,7 @@ unsigned int cxgbi_tagmask_set(unsigned int ppmax)
 
 	return 1 << (bits + PPOD_IDX_SHIFT);
 }
+EXPORT_SYMBOL(cxgbi_tagmask_set);
 
 static int __init libcxgb_init(void)
 {
diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index d9092c0..44a424d 100644
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
