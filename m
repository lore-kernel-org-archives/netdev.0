From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH]bnx2x: tx_has_work should not wait for FW
Date: Mon, 26 Jan 2009 18:55:56 +0200
Message-ID: <1232988956.18353.3.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2593 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783AbZAZQ5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 11:57:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current tx_has_work waited until all packets sent by the driver are marked
as completed by the FW. This is too greedy and it causes the bnx2x_poll to spin
in vain. The driver should only check that all packets FW already completed are
freed - only in unload flow the driver should make sure that transmit queue is
empty

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 4b84f6c..d3e7775 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -57,8 +57,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"

-#define DRV_MODULE_VERSION	"1.45.25"
-#define DRV_MODULE_RELDATE	"2009/01/22"
+#define DRV_MODULE_VERSION	"1.45.26"
+#define DRV_MODULE_RELDATE	"2009/01/26"
 #define BNX2X_BC_VER		0x040200

 /* Time in jiffies before concluding the transmitter is hung */
@@ -740,8 +740,15 @@ static inline int bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
 	/* Tell compiler that status block fields can change */
 	barrier();
 	tx_cons_sb = le16_to_cpu(*fp->tx_cons_sb);
-	return ((fp->tx_pkt_prod != tx_cons_sb) ||
-		(fp->tx_pkt_prod != fp->tx_pkt_cons));
+	return (fp->tx_pkt_cons != tx_cons_sb);
+}
+
+static inline int bnx2x_has_tx_work_unload(struct bnx2x_fastpath *fp)
+{
+	/* Tell compiler that consumer and producer can change */
+	barrier();
+	return (fp->tx_pkt_prod != fp->tx_pkt_cons);
+
 }

 /* free skb in the packet ring at pos idx
@@ -6729,7 +6736,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)

 		cnt = 1000;
 		smp_rmb();
-		while (bnx2x_has_tx_work(fp)) {
+		while (bnx2x_has_tx_work_unload(fp)) {

 			bnx2x_tx_int(fp, 1000);
 			if (!cnt) {
--
1.5.4.3




