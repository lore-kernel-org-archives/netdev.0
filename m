From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: Prevent null pointer dereference in AFEX
 mode
Date: Wed, 10 Apr 2013 13:34:39 +0300
Message-ID: <1365590079-7422-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2650 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376Ab3DJLhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 07:37:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cnic module is responsible for initializing various bnx2x structs
via callbacks provided by the bnx2x module.
One such struct is the queue object for the FCoE queue.

If a device is working in AFEX mode and its configuration allows FCoE yet 
the cnic module is not loaded, it's very likely a null pointer dereference
will occur, as the bnx2x will erroneously access the FCoE's queue object.

Prevent said access until cnic properly registers itself.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

This small patch prevents a possible null pointer dereference in bnx2x.

Please consider applying it to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fdfe33b..25df400 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -4959,7 +4959,7 @@ static void bnx2x_after_function_update(struct bnx2x *bp)
 				  q);
 	}
 
-	if (!NO_FCOE(bp)) {
+	if (!NO_FCOE(bp) && CNIC_ENABLED(bp)) {
 		fp = &bp->fp[FCOE_IDX(bp)];
 		queue_params.q_obj = &bnx2x_sp_obj(bp, fp).q_obj;
 
@@ -13450,6 +13450,7 @@ static int bnx2x_unregister_cnic(struct net_device *dev)
 	RCU_INIT_POINTER(bp->cnic_ops, NULL);
 	mutex_unlock(&bp->cnic_mutex);
 	synchronize_rcu();
+	bp->cnic_enabled = false;
 	kfree(bp->cnic_kwq);
 	bp->cnic_kwq = NULL;
 
-- 
1.8.1.227.g44fe835
