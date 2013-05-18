From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net-bnx2x: dont reload on GRO change
Date: Sat, 18 May 2013 10:14:53 -0700
Message-ID: <1368897293.3301.152.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:40908 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab3ERROz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 13:14:55 -0400
Received: by mail-pa0-f45.google.com with SMTP id lj1so4496311pab.18
        for <netdev@vger.kernel.org>; Sat, 18 May 2013 10:14:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

bnx2x_set_features() forces a driver reload if GRO setting is changed.

A reload makes the ethernet port unresponsive for about 5 seconds.

This is not needed in the common case LRO is enabled, as LRO
(TPA_ENABLE_FLAG) has precedence over GRO (GRO_ENABLE_FLAG)
    
Tested:
 Verified that "ethtool -K eth0 gro {on|off}" doesn't blackout
 the NIC anymore
    
Google-Bug-Id: 8440442
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index b8fbe26..6cc5101 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4599,6 +4599,7 @@ int bnx2x_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 flags = bp->flags;
+	u32 changes;
 	bool bnx2x_reload = false;
 
 	if (features & NETIF_F_LRO)
@@ -4623,10 +4624,16 @@ int bnx2x_set_features(struct net_device *dev, netdev_features_t features)
 		}
 	}
 
-	if (flags ^ bp->flags) {
-		bp->flags = flags;
+	changes = flags ^ bp->flags;
+
+	/* if GRO is changed while LRO is enabled, dont force a reload */
+	if ((changes & GRO_ENABLE_FLAG) && (flags & TPA_ENABLE_FLAG))
+		changes &= ~GRO_ENABLE_FLAG;
+
+	if (changes)
 		bnx2x_reload = true;
-	}
+
+	bp->flags = flags;
 
 	if (bnx2x_reload) {
 		if (bp->recovery_state == BNX2X_RECOVERY_DONE)
