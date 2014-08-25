From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/5] bnx2x: Be more forgiving toward SW GRO
Date: Mon, 25 Aug 2014 17:48:32 +0300
Message-ID: <1408978113-27902-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35102 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932803AbaHYOtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:49:05 -0400
In-Reply-To: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>

This introduces 2 new relaxations in the bnx2x driver regarding GRO:
  1. Don't prevent SW GRO if HW GRO is disabled.
  2. If all aggregations are disabled, when GRO configuration changes
     there's no need to perform an inner-reload [since it will have no
     actual effect].

Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 6304da2..de65640 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4816,11 +4816,15 @@ netdev_features_t bnx2x_fix_features(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 
 	/* TPA requires Rx CSUM offloading */
-	if (!(features & NETIF_F_RXCSUM) || bp->disable_tpa) {
+	if (!(features & NETIF_F_RXCSUM)) {
 		features &= ~NETIF_F_LRO;
 		features &= ~NETIF_F_GRO;
 	}
 
+	/* Note: do not disable SW GRO in kernel when HW GRO is off */
+	if (bp->disable_tpa)
+		features &= ~NETIF_F_LRO;
+
 	return features;
 }
 
@@ -4859,6 +4863,10 @@ int bnx2x_set_features(struct net_device *dev, netdev_features_t features)
 	if ((changes & GRO_ENABLE_FLAG) && (flags & TPA_ENABLE_FLAG))
 		changes &= ~GRO_ENABLE_FLAG;
 
+	/* if GRO is changed while HW TPA is off, don't force a reload */
+	if ((changes & GRO_ENABLE_FLAG) && bp->disable_tpa)
+		changes &= ~GRO_ENABLE_FLAG;
+
 	if (changes)
 		bnx2x_reload = true;
 
-- 
1.8.3.1
