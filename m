From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.21 6/6] iw_cxgb3: Fix MR permission problems.
Date: Thu, 01 Mar 2007 16:50:48 -0600
Message-ID: <20070301225048.2373.91667.stgit@dell3.ogc.int>
References: <20070301225036.2373.71668.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:32840 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161107AbXCAWut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 17:50:49 -0500
In-Reply-To: <20070301225036.2373.71668.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix MR permission problems.

- remove useless and redundant iwch_mem_perms enum.

- create ib_to_tpt_access_rights() for mapping ib access rights
  to T3 TPT permissions.

- create ib_to_mwbind_access_rights() for mapping ib access rights
  to T3 MWBIND WR permissions.

- fix up the mem reg code to utilize the new functions.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_provider.c |   24 +++-----------------
 drivers/infiniband/hw/cxgb3/iwch_provider.h |   33 +++++++++++----------------
 drivers/infiniband/hw/cxgb3/iwch_qp.c       |    2 +-
 3 files changed, 18 insertions(+), 41 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index a56c902..4af1c0f 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -463,9 +463,6 @@ static struct ib_mr *iwch_register_phys_
 	php = to_iwch_pd(pd);
 	rhp = php->rhp;
 
-	acc = iwch_convert_access(acc);
-
-
 	mhp = kzalloc(sizeof(*mhp), GFP_KERNEL);
 	if (!mhp)
 		return ERR_PTR(-ENOMEM);
@@ -491,12 +488,7 @@ static struct ib_mr *iwch_register_phys_
 	mhp->attr.pdid = php->pdid;
 	mhp->attr.zbva = 0;
 
-	/* NOTE: TPT perms are backwards from BIND WR perms! */
-	mhp->attr.perms = (acc & 0x1) << 3;
-	mhp->attr.perms |= (acc & 0x2) << 1;
-	mhp->attr.perms |= (acc & 0x4) >> 1;
-	mhp->attr.perms |= (acc & 0x8) >> 3;
-
+	mhp->attr.perms = iwch_ib_to_tpt_access(acc);
 	mhp->attr.va_fbo = *iova_start;
 	mhp->attr.page_size = shift - 12;
 
@@ -525,7 +517,6 @@ static int iwch_reregister_phys_mem(stru
 	struct iwch_mr mh, *mhp;
 	struct iwch_pd *php;
 	struct iwch_dev *rhp;
-	int new_acc;
 	__be64 *page_list = NULL;
 	int shift = 0;
 	u64 total_size;
@@ -546,14 +537,12 @@ static int iwch_reregister_phys_mem(stru
 	if (rhp != php->rhp)
 		return -EINVAL;
 
-	new_acc = mhp->attr.perms;
-
 	memcpy(&mh, mhp, sizeof *mhp);
 
 	if (mr_rereg_mask & IB_MR_REREG_PD)
 		php = to_iwch_pd(pd);
 	if (mr_rereg_mask & IB_MR_REREG_ACCESS)
-		mh.attr.perms = iwch_convert_access(acc);
+		mh.attr.perms = iwch_ib_to_tpt_access(acc);
 	if (mr_rereg_mask & IB_MR_REREG_TRANS)
 		ret = build_phys_page_list(buffer_list, num_phys_buf,
 					   iova_start,
@@ -568,7 +557,7 @@ static int iwch_reregister_phys_mem(stru
 	if (mr_rereg_mask & IB_MR_REREG_PD)
 		mhp->attr.pdid = php->pdid;
 	if (mr_rereg_mask & IB_MR_REREG_ACCESS)
-		mhp->attr.perms = acc;
+		mhp->attr.perms = iwch_ib_to_tpt_access(acc);
 	if (mr_rereg_mask & IB_MR_REREG_TRANS) {
 		mhp->attr.zbva = 0;
 		mhp->attr.va_fbo = *iova_start;
@@ -613,8 +602,6 @@ static struct ib_mr *iwch_reg_user_mr(st
 		goto err;
 	}
 
-	acc = iwch_convert_access(acc);
-
 	i = n = 0;
 
 	list_for_each_entry(chunk, &region->chunk_list, list)
@@ -630,10 +617,7 @@ static struct ib_mr *iwch_reg_user_mr(st
 	mhp->rhp = rhp;
 	mhp->attr.pdid = php->pdid;
 	mhp->attr.zbva = 0;
-	mhp->attr.perms = (acc & 0x1) << 3;
-	mhp->attr.perms |= (acc & 0x2) << 1;
-	mhp->attr.perms |= (acc & 0x4) >> 1;
-	mhp->attr.perms |= (acc & 0x8) >> 3;
+	mhp->attr.perms = iwch_ib_to_tpt_access(acc);
 	mhp->attr.va_fbo = region->virt_base;
 	mhp->attr.page_size = shift - 12;
 	mhp->attr.len = (u32) region->length;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.h b/drivers/infiniband/hw/cxgb3/iwch_provider.h
index de0fe1b..93bcc56 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.h
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.h
@@ -286,27 +286,20 @@ static inline int iwch_convert_state(enu
 	}
 }
 
-enum iwch_mem_perms {
-	IWCH_MEM_ACCESS_LOCAL_READ = 1 << 0,
-	IWCH_MEM_ACCESS_LOCAL_WRITE = 1 << 1,
-	IWCH_MEM_ACCESS_REMOTE_READ = 1 << 2,
-	IWCH_MEM_ACCESS_REMOTE_WRITE = 1 << 3,
-	IWCH_MEM_ACCESS_ATOMICS = 1 << 4,
-	IWCH_MEM_ACCESS_BINDING = 1 << 5,
-	IWCH_MEM_ACCESS_LOCAL =
-	    (IWCH_MEM_ACCESS_LOCAL_READ | IWCH_MEM_ACCESS_LOCAL_WRITE),
-	IWCH_MEM_ACCESS_REMOTE =
-	    (IWCH_MEM_ACCESS_REMOTE_WRITE | IWCH_MEM_ACCESS_REMOTE_READ)
-	    /* cannot go beyond 1 << 31 */
-} __attribute__ ((packed));
-
-static inline u32 iwch_convert_access(int acc)
+static inline u32 iwch_ib_to_tpt_access(int acc)
 {
-	return (acc & IB_ACCESS_REMOTE_WRITE ? IWCH_MEM_ACCESS_REMOTE_WRITE : 0)
-	    | (acc & IB_ACCESS_REMOTE_READ ? IWCH_MEM_ACCESS_REMOTE_READ : 0) |
-	    (acc & IB_ACCESS_LOCAL_WRITE ? IWCH_MEM_ACCESS_LOCAL_WRITE : 0) |
-	    (acc & IB_ACCESS_MW_BIND ? IWCH_MEM_ACCESS_BINDING : 0) |
-	    IWCH_MEM_ACCESS_LOCAL_READ;
+	return (acc & IB_ACCESS_REMOTE_WRITE ? TPT_REMOTE_WRITE : 0) |
+	       (acc & IB_ACCESS_REMOTE_READ ? TPT_REMOTE_READ : 0) |
+	       (acc & IB_ACCESS_LOCAL_WRITE ? TPT_LOCAL_WRITE : 0) |
+	       TPT_LOCAL_READ;
+}
+
+static inline u32 iwch_ib_to_mwbind_access(int acc)
+{
+	return (acc & IB_ACCESS_REMOTE_WRITE ? T3_MEM_ACCESS_REM_WRITE : 0) |
+	       (acc & IB_ACCESS_REMOTE_READ ? T3_MEM_ACCESS_REM_READ : 0) |
+	       (acc & IB_ACCESS_LOCAL_WRITE ? T3_MEM_ACCESS_LOCAL_WRITE : 0) |
+	       T3_MEM_ACCESS_LOCAL_READ;
 }
 
 enum iwch_mmid_state {
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index 9ea00cc..0a472c9 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -439,7 +439,7 @@ int iwch_bind_mw(struct ib_qp *qp,
 	wqe->bind.type = T3_VA_BASED_TO;
 
 	/* TBD: check perms */
-	wqe->bind.perms = iwch_convert_access(mw_bind->mw_access_flags);
+	wqe->bind.perms = iwch_ib_to_mwbind_access(mw_bind->mw_access_flags);
 	wqe->bind.mr_stag = cpu_to_be32(mw_bind->mr->lkey);
 	wqe->bind.mw_stag = cpu_to_be32(mw->rkey);
 	wqe->bind.mw_len = cpu_to_be32(mw_bind->length);
