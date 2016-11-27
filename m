From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/4] bnxt_en: Re-factor bnxt_setup_tc().
Date: Sat, 26 Nov 2016 19:38:32 -0500
Message-ID: <1480207115-21294-2-git-send-email-michael.chan@broadcom.com>
References: <1480207115-21294-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34722 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751268AbcK0Ait (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 19:38:49 -0500
Received: by mail-pg0-f50.google.com with SMTP id x23so42418931pgx.1
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 16:38:48 -0800 (PST)
In-Reply-To: <1480207115-21294-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new function bnxt_setup_mq_tc() to handle MQPRIO.  This new function
will be called during ETS setup when we add DCBNL in the next patch.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 18 ++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8c7bdbe..b75f4d0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6328,17 +6328,10 @@ static int bnxt_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-			 struct tc_to_netdev *ntc)
+int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 {
 	struct bnxt *bp = netdev_priv(dev);
 	bool sh = false;
-	u8 tc;
-
-	if (ntc->type != TC_SETUP_MQPRIO)
-		return -EINVAL;
-
-	tc = ntc->tc;
 
 	if (tc > bp->max_tc) {
 		netdev_err(dev, "too many traffic classes requested: %d Max supported is %d\n",
@@ -6381,6 +6374,15 @@ static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	return 0;
 }
 
+static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+			 struct tc_to_netdev *ntc)
+{
+	if (ntc->type != TC_SETUP_MQPRIO)
+		return -EINVAL;
+
+	return bnxt_setup_mq_tc(dev, ntc->tc);
+}
+
 #ifdef CONFIG_RFS_ACCEL
 static bool bnxt_fltr_match(struct bnxt_ntuple_filter *f1,
 			    struct bnxt_ntuple_filter *f2)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 47be789..fcd07ee 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1225,5 +1225,6 @@ static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
 int bnxt_hwrm_fw_set_time(struct bnxt *);
 int bnxt_open_nic(struct bnxt *, bool, bool);
 int bnxt_close_nic(struct bnxt *, bool, bool);
+int bnxt_setup_mq_tc(struct net_device *dev, u8 tc);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
 #endif
-- 
1.8.3.1
