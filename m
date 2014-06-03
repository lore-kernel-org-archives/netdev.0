From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH 1/3 v2] cnic: Don't take rcu_read_lock in cnic_rcv_netevent()
Date: Mon, 2 Jun 2014 23:08:46 -0700
Message-ID: <1401775728-21043-2-git-send-email-mchan@broadcom.com>
References: <1401775728-21043-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <nhorman@tuxdriver.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:53004 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbaFCEsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 00:48:09 -0400
In-Reply-To: <1401775728-21043-1-git-send-email-mchan@broadcom.com>
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
index 09f3fef..a0aae72 100644
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
+						lockdep_is_held(&cnic_lock));
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
