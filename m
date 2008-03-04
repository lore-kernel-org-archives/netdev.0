From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.25] RDMA/IWCM: don't access the cm_id after dereferencing it.
Date: Tue, 04 Mar 2008 16:44:52 -0600
Message-ID: <20080304224451.8548.33855.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com, sean.hefty@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:57851 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754081AbYCDWow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:44:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


RDMA/IWCM: don't access the cm_id after dereferencing it.

cm_work_handler() can access cm_id_priv after it was potentially freed
by iwch_deref_id().  The fix is to note whether IWCM_F_CALLBACK_DESTROY
is set before dereferencing.  Then if it was set, free the cm_id on
this thread.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/core/iwcm.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/iwcm.c b/drivers/infiniband/core/iwcm.c
index 223b1aa..81c9195 100644
--- a/drivers/infiniband/core/iwcm.c
+++ b/drivers/infiniband/core/iwcm.c
@@ -839,6 +839,7 @@ static void cm_work_handler(struct work_struct *_work)
 	unsigned long flags;
 	int empty;
 	int ret = 0;
+	int destroy_id;
 
 	spin_lock_irqsave(&cm_id_priv->lock, flags);
 	empty = list_empty(&cm_id_priv->work_list);
@@ -857,9 +858,9 @@ static void cm_work_handler(struct work_struct *_work)
 			destroy_cm_id(&cm_id_priv->id);
 		}
 		BUG_ON(atomic_read(&cm_id_priv->refcount)==0);
+		destroy_id = test_bit(IWCM_F_CALLBACK_DESTROY, &cm_id_priv->flags);
 		if (iwcm_deref_id(cm_id_priv)) {
-			if (test_bit(IWCM_F_CALLBACK_DESTROY,
-				     &cm_id_priv->flags)) {
+			if (destroy_id) {
 				BUG_ON(!list_empty(&cm_id_priv->work_list));
 				free_cm_id(cm_id_priv);
 			}
