From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH] cxgb4/csiostor:  Don't use MASTER_MUST for fw_hello call
Date: Thu, 11 Dec 2014 11:11:43 +0530
Message-ID: <1418276503-23001-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	leedom@chelsio.com, anish@chelsio.com, nirranjan@chelsio.com,
	praveenm@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:50361
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751222AbaLKFgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 00:36:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove use of calls into t4_fw_hello() with MASTER_MUST, which results in
FW_HELLO_CMD_MASTERFORCE being set. The firmware doesn't support this and of
course any existing PF Drivers will totally go for a toss.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   12 ++----------
 drivers/scsi/csiostor/csio_hw.c                 |    6 +-----
 drivers/scsi/csiostor/csio_hw.h                 |    1 -
 3 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 279873c..30deaf1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5687,14 +5687,8 @@ static int adap_init0(struct adapter *adap)
 	struct fw_caps_config_cmd caps_cmd;
 	int reset = 1;
 
-	/*
-	 * Contact FW, advertising Master capability (and potentially forcing
-	 * ourselves as the Master PF if our module parameter force_init is
-	 * set).
-	 */
-	ret = t4_fw_hello(adap, adap->mbox, adap->fn,
-			  force_init ? MASTER_MUST : MASTER_MAY,
-			  &state);
+	/* Contact FW, advertising Master capability */
+	ret = t4_fw_hello(adap, adap->mbox, adap->mbox, MASTER_MAY, &state);
 	if (ret < 0) {
 		dev_err(adap->pdev_dev, "could not connect to FW, error %d\n",
 			ret);
@@ -5702,8 +5696,6 @@ static int adap_init0(struct adapter *adap)
 	}
 	if (ret == adap->mbox)
 		adap->flags |= MASTER_PF;
-	if (force_init && state == DEV_STATE_INIT)
-		state = DEV_STATE_UNINIT;
 
 	/*
 	 * If we're the Master PF Driver and the device is uninitialized,
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 0eaec47..5b909c0 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -47,7 +47,6 @@
 #include "csio_lnode.h"
 #include "csio_rnode.h"
 
-int csio_force_master;
 int csio_dbg_level = 0xFEFF;
 unsigned int csio_port_mask = 0xf;
 
@@ -889,7 +888,6 @@ csio_do_hello(struct csio_hw *hw, enum csio_dev_state *state)
 {
 	struct csio_mb	*mbp;
 	int	rv = 0;
-	enum csio_dev_master master;
 	enum fw_retval retval;
 	uint8_t mpfn;
 	char state_str[16];
@@ -904,11 +902,9 @@ csio_do_hello(struct csio_hw *hw, enum csio_dev_state *state)
 		goto out;
 	}
 
-	master = csio_force_master ? CSIO_MASTER_MUST : CSIO_MASTER_MAY;
-
 retry:
 	csio_mb_hello(hw, mbp, CSIO_MB_DEFAULT_TMO, hw->pfn,
-		      hw->pfn, master, NULL);
+		      hw->pfn, CSIO_MASTER_MAY, NULL);
 
 	rv = csio_mb_issue(hw, mbp);
 	if (rv) {
diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
index 5db2d85..68248da 100644
--- a/drivers/scsi/csiostor/csio_hw.h
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -110,7 +110,6 @@ struct csio_scsi_cpu_info {
 };
 
 extern int csio_dbg_level;
-extern int csio_force_master;
 extern unsigned int csio_port_mask;
 extern int csio_msi;
 
-- 
1.7.1
