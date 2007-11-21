From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2/2][2.6.24] ehea: Reworked rcv queue handling to log only fatal errors
Date: Wed, 21 Nov 2007 17:42:27 +0100
Message-ID: <200711211742.27706.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:54673 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbXKUQn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 11:43:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prevent driver from brawly logging packet checksum errors.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   11 +++++------
 drivers/net/ehea/ehea_qmr.h  |    4 ++--
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 5935899..ea67615 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0082"
+#define DRV_VERSION	"EHEA_0083"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index d2f715d..869e160 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -410,11 +410,6 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	if (cqe->status & EHEA_CQE_STAT_ERR_CRC)
 		pr->p_stats.err_frame_crc++;
 
-	if (netif_msg_rx_err(pr->port)) {
-		ehea_error("CQE Error for QP %d", pr->qp->init_attr.qp_nr);
-		ehea_dump(cqe, sizeof(*cqe), "CQE");
-	}
-
 	if (rq == 2) {
 		*processed_rq2 += 1;
 		skb = get_skb_by_index(pr->rq2_skba.arr, pr->rq2_skba.len, cqe);
@@ -426,7 +421,11 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	}
 
 	if (cqe->status & EHEA_CQE_STAT_FAT_ERR_MASK) {
-		ehea_error("Critical receive error. Resetting port.");
+		if (netif_msg_rx_err(pr->port)) {
+			ehea_error("Critical receive error for QP %d. "
+				   "Resetting port.", pr->qp->init_attr.qp_nr);
+			ehea_dump(cqe, sizeof(*cqe), "CQE");
+		}
 		schedule_work(&pr->port->reset_task);
 		return 1;
 	}
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index 562de0e..bc62d38 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -145,8 +145,8 @@ struct ehea_rwqe {
 #define EHEA_CQE_VLAN_TAG_XTRACT   0x0400
 
 #define EHEA_CQE_TYPE_RQ           0x60
-#define EHEA_CQE_STAT_ERR_MASK     0x720F
-#define EHEA_CQE_STAT_FAT_ERR_MASK 0x1F
+#define EHEA_CQE_STAT_ERR_MASK     0x700F
+#define EHEA_CQE_STAT_FAT_ERR_MASK 0xF
 #define EHEA_CQE_STAT_ERR_TCP      0x4000
 #define EHEA_CQE_STAT_ERR_IP       0x2000
 #define EHEA_CQE_STAT_ERR_CRC      0x1000
-- 
1.5.2
