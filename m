From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 2.6.21-rc1] ehea: Fixed error recovery
Date: Mon, 5 Feb 2007 14:35:42 +0100
Message-ID: <200702051435.42211.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:19985 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932374AbXBENiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 08:38:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Error recovery for QP errors: Reset QPs and dump error information

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---


 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |    8 +++++++-
 drivers/net/ehea/ehea_phyp.c |   10 ++++++++++
 drivers/net/ehea/ehea_phyp.h |    3 +++
 drivers/net/ehea/ehea_qmr.c  |   42 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ehea/ehea_qmr.h  |    5 +++++
 6 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 272e1ec..42295d6 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@ #include <asm/abs_addr.h>
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0045"
+#define DRV_VERSION	"EHEA_0046"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 9de2d38..1ef3846 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -76,7 +76,7 @@ void ehea_dump(void *adr, int len, char 
 	int x;
 	unsigned char *deb = adr;
 	for (x = 0; x < len; x += 16) {
-		printk(DRV_NAME "%s adr=%p ofs=%04x %016lx %016lx\n", msg,
+		printk(DRV_NAME " %s adr=%p ofs=%04x %016lx %016lx\n", msg,
 			  deb, x, *((u64*)&deb[0]), *((u64*)&deb[8]));
 		deb += 16;
 	}
@@ -555,6 +555,7 @@ static irqreturn_t ehea_qp_aff_irq_handl
 {
 	struct ehea_port *port = param;
 	struct ehea_eqe *eqe;
+	struct ehea_qp *qp;
 	u32 qp_token;
 
 	eqe = ehea_poll_eq(port->qp_eq);
@@ -563,9 +564,14 @@ static irqreturn_t ehea_qp_aff_irq_handl
 		qp_token = EHEA_BMASK_GET(EHEA_EQE_QP_TOKEN, eqe->entry);
 		ehea_error("QP aff_err: entry=0x%lx, token=0x%x",
 			   eqe->entry, qp_token);
+
+		qp = port->port_res[qp_token].qp;
+		ehea_error_data(port->adapter, qp->fw_handle);
 		eqe = ehea_poll_eq(port->qp_eq);
 	}
 
+	queue_work(port->adapter->ehea_wq, &port->reset_task);
+
 	return IRQ_HANDLED;
 }
 
diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
index 37716e0..bc3c005 100644
--- a/drivers/net/ehea/ehea_phyp.c
+++ b/drivers/net/ehea/ehea_phyp.c
@@ -612,3 +612,13 @@ u64 ehea_h_reset_events(const u64 adapte
 				       event_mask,		/* R6 */
 				       0, 0, 0, 0);		/* R7-R12 */
 }
+
+u64 ehea_h_error_data(const u64 adapter_handle, const u64 ressource_handle,
+		      void *rblock)
+{
+	return ehea_plpar_hcall_norets(H_ERROR_DATA,
+				       adapter_handle,          /* R4 */
+				       ressource_handle,        /* R5 */
+				       virt_to_abs(rblock),     /* R6 */
+				       0, 0, 0, 0);             /* R7-R12 */
+}
diff --git a/drivers/net/ehea/ehea_phyp.h b/drivers/net/ehea/ehea_phyp.h
index 919f94b..90acddb 100644
--- a/drivers/net/ehea/ehea_phyp.h
+++ b/drivers/net/ehea/ehea_phyp.h
@@ -454,4 +454,7 @@ u64 ehea_h_reg_dereg_bcmc(const u64 adap
 u64 ehea_h_reset_events(const u64 adapter_handle, const u64 neq_handle,
 			const u64 event_mask);
 
+u64 ehea_h_error_data(const u64 adapter_handle, const u64 ressource_handle,
+		      void *rblock);
+
 #endif	/* __EHEA_PHYP_H__ */
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index f143e13..96ff3b6 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -486,6 +486,7 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	if (!qp)
 		return 0;
 
+	ehea_h_disable_and_get_hea(qp->adapter->handle, qp->fw_handle);
 	hret = ehea_h_free_resource(qp->adapter->handle, qp->fw_handle);
 	if (hret != H_SUCCESS) {
 		ehea_error("destroy_qp failed");
@@ -581,4 +582,45 @@ out:
 	return ret;
 }
 
+void print_error_data(u64 *data)
+{
+	int length;
+	u64 type = EHEA_BMASK_GET(ERROR_DATA_TYPE, data[2]);
+	u64 resource = data[1];
+
+	length = EHEA_BMASK_GET(ERROR_DATA_LENGTH, data[0]);
+
+	if (length > EHEA_PAGESIZE)
+		length = EHEA_PAGESIZE;
+
+	if (type == 0x8) /* Queue Pair */
+		ehea_error("QP (resource=%lX) state: AER=0x%lX, AERR=0x%lX, "
+			   "port=%lX", resource, data[6], data[12], data[22]);
+
+	ehea_dump(data, length, "error data");
+}
+
+void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle)
+{
+	unsigned long ret;
+	u64 *rblock;
+
+	rblock = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!rblock) {
+		ehea_error("Cannot allocate rblock memory.");
+		return;
+	}
 
+	ret = ehea_h_error_data(adapter->handle,
+				res_handle,
+				rblock);
+
+	if (ret == H_R_STATE)
+		ehea_error("No error data is available: %lX.", res_handle);
+	else if (ret == H_SUCCESS)
+		print_error_data(rblock);
+	else
+		ehea_error("Error data could not be fetched: %lX", res_handle);
+
+	kfree(rblock);
+}
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index 7efdc96..1ff6098 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -180,6 +180,9 @@ struct ehea_eqe {
 	u64 entry;
 };
 
+#define ERROR_DATA_LENGTH  EHEA_BMASK_IBM(52,63)
+#define ERROR_DATA_TYPE    EHEA_BMASK_IBM(0,7)
+
 static inline void *hw_qeit_calc(struct hw_queue *queue, u64 q_offset)
 {
 	struct ehea_page *current_page;
@@ -355,4 +358,6 @@ int ehea_destroy_qp(struct ehea_qp *qp);
 
 int ehea_reg_mr_adapter(struct ehea_adapter *adapter);
 
+void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle);
+
 #endif	/* __EHEA_QMR_H__ */
