From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/4] cnic: Fix occasional NULL pointer
 dereference during reboot.
Date: Wed, 27 Jun 2012 18:08:19 -0700
Message-ID: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3195 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932185Ab2F1A50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 20:57:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We register with bnx2x before we allocate ctx_tbl structure, so it is
possible for bnx2x to call cnic_ctl before the structure is allocated.
This can sometimes cause NULL pointer dereference of cp->ctx_tbl.  We
fix this by adding simple checking for valid state before proceeding.
The cnic_ctl call is RCU protected so we don't have to deal with race
conditions.

Because of the additional checking, we need to finish the shutdown
before clearing the CNIC_UP flag.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 0e9be2b..31b05ad 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -291,6 +291,9 @@ static int cnic_get_l5_cid(struct cnic_local *cp, u32 cid, u32 *l5_cid)
 {
 	u32 i;
 
+	if (!cp->ctx_tbl)
+		return -EINVAL;
+
 	for (i = 0; i < cp->max_cid_space; i++) {
 		if (cp->ctx_tbl[i].cid == cid) {
 			*l5_cid = i;
@@ -3220,6 +3223,9 @@ static int cnic_ctl(void *data, struct cnic_ctl_info *info)
 		u32 l5_cid;
 		struct cnic_local *cp = dev->cnic_priv;
 
+		if (!test_bit(CNIC_F_CNIC_UP, &dev->flags))
+			break;
+
 		if (cnic_get_l5_cid(cp, cid, &l5_cid) == 0) {
 			struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
 
@@ -4253,8 +4259,6 @@ static int cnic_cm_shutdown(struct cnic_dev *dev)
 	struct cnic_local *cp = dev->cnic_priv;
 	int i;
 
-	cp->stop_cm(dev);
-
 	if (!cp->csk_tbl)
 		return 0;
 
@@ -5290,6 +5294,7 @@ static void cnic_stop_hw(struct cnic_dev *dev)
 			i++;
 		}
 		cnic_shutdown_rings(dev);
+		cp->stop_cm(dev);
 		clear_bit(CNIC_F_CNIC_UP, &dev->flags);
 		RCU_INIT_POINTER(cp->ulp_ops[CNIC_ULP_L4], NULL);
 		synchronize_rcu();
-- 
1.7.1
