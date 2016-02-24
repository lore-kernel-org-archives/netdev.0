From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/6] qede: Don't report link change needlessly
Date: Wed, 24 Feb 2016 16:52:47 +0200
Message-ID: <1456325570-1514-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40592 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753884AbcBXOxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 09:53:08 -0500
In-Reply-To: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several corner cases where driver might get a 2nd notification
about the same link change. Don't log any additional changes if the
physical carrier is already reported as it should.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f07b9a9..c0dd236 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2780,13 +2780,17 @@ static void qede_link_update(void *dev, struct qed_link_output *link)
 	}
 
 	if (link->link_up) {
-		DP_NOTICE(edev, "Link is up\n");
-		netif_tx_start_all_queues(edev->ndev);
-		netif_carrier_on(edev->ndev);
+		if (!netif_carrier_ok(edev->ndev)) {
+			DP_NOTICE(edev, "Link is up\n");
+			netif_tx_start_all_queues(edev->ndev);
+			netif_carrier_on(edev->ndev);
+		}
 	} else {
-		DP_NOTICE(edev, "Link is down\n");
-		netif_tx_disable(edev->ndev);
-		netif_carrier_off(edev->ndev);
+		if (netif_carrier_ok(edev->ndev)) {
+			DP_NOTICE(edev, "Link is down\n");
+			netif_tx_disable(edev->ndev);
+			netif_carrier_off(edev->ndev);
+		}
 	}
 }
 
-- 
1.9.3
