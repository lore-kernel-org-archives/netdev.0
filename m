From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 1/4] bnxt_en: Re-factor bnxt_setup_tc().
Date: Fri,  2 Dec 2016 21:17:15 -0500
Message-ID: <1480731438-22671-2-git-send-email-michael.chan@broadcom.com>
References: <1480731438-22671-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33683 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754136AbcLCCRb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 21:17:31 -0500
Received: by mail-pf0-f181.google.com with SMTP id d2so55457037pfd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 18:17:30 -0800 (PST)
In-Reply-To: <1480731438-22671-1-git-send-email-michael.chan@broadcom.com>
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
index 0e4f168..7664281 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6337,17 +6337,10 @@ static int bnxt_change_mtu(struct net_device *dev, int new_mtu)
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
@@ -6390,6 +6383,15 @@ static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
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
