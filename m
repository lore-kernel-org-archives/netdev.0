From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH 1/3] cnic: Don't take rcu_read_lock in cnic_rcv_netevent()
Date: Fri, 30 May 2014 16:18:41 -0700
Message-ID: <1401491923-5480-2-git-send-email-mchan@broadcom.com>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <nhorman@tuxdriver.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:52116 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934587AbaE3V7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 17:59:18 -0400
In-Reply-To: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the called function, such as bnx2fc_indicate_netevent(), can sleep,
we cannot take rcu_lock().  To prevent the rcu protected ulp_ops from going
away, we use the cnic_lock mutex and set the ULP_F_CALL_PENDING flag.
The code already waits for ULP_F_CALL_PENDING flag to clear in
cnic_unregister_device().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 09f3fef..7f40a2c 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5624,20 +5624,27 @@ static void cnic_rcv_netevent(struct cnic_local *cp, unsigned long event,
 {
 	int if_type;
 
-	rcu_read_lock();
 	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
 		struct cnic_ulp_ops *ulp_ops;
 		void *ctx;
 
-		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
-		if (!ulp_ops || !ulp_ops->indicate_netevent)
+		mutex_lock(&cnic_lock);
+		ulp_ops = rcu_dereference_protected(cp->ulp_ops[if_type],
+						lockdep_is held(&cnic_lock));
+		if (!ulp_ops || !ulp_ops->indicate_netevent) {
+			mutex_unlock(&cnic_lock);
 			continue;
+		}
 
 		ctx = cp->ulp_handle[if_type];
 
+		set_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
+		mutex_unlock(&cnic_lock);
+
 		ulp_ops->indicate_netevent(ctx, event, vlan_id);
+
+		clear_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
 	}
-	rcu_read_unlock();
 }
 
 /* netdev event handler */
-- 
1.7.1
