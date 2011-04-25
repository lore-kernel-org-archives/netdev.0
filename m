From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v4 06/27] HFI: Add DD calls to START/STOP INTERFACE HCALLs
Date: Mon, 25 Apr 2011 17:23:46 -0400
Message-ID: <1303766647-30156-7-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:54290 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab1DYVYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:24:22 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PL7tFC005833
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:07:55 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3PLOIZK128202
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:18 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLOH8X032277
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:18 -0600
In-Reply-To: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 drivers/net/hfi/core/hfidd_init.c |   97 +++++++++++++++++++++++++++++++++++++
 1 files changed, 97 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index d181d97..bbfc477 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -318,6 +318,93 @@ hfidd_create_devices_error0:
 	return rc;
 }
 
+/*
+ * Disable message passing to each adapter by calling the
+ * Stop Interface hcall.
+ */
+static void hfidd_stop_adapter(void)
+{
+	int i;
+
+	for (i = 0; i < MAX_HFIS; i++) {
+		hfidd_stop_interface(hfidd_global.p_acs[i],
+			hfidd_global.p_acs[i]->dds.hfi_id);
+	}
+}
+
+/*
+ * Query the interface to check the logical state of HFI.
+ * Enable message passing to each adapter by calling Start
+ * Interface hcall.
+ */
+static int hfidd_start_adapter(void)
+{
+	unsigned long long	hfi_state;
+	int i, j;
+	int rc = 0;
+
+	for (i = 0; i < MAX_HFIS; i++) {
+		rc = hfidd_query_interface(hfidd_global.p_acs[i], COMP_QUERY,
+			hfidd_global.p_acs[i]->dds.hfi_id, &hfi_state);
+		if (hfi_state != NOT_STARTED) {
+			rc = hfidd_stop_interface(hfidd_global.p_acs[i],
+					hfidd_global.p_acs[i]->dds.hfi_id);
+			if (rc) {
+				dev_printk(KERN_ERR,
+					hfidd_global.p_acs[i]->hfidd_dev,
+					"%s: hfidd_start_adapter:"
+					" hfidd_stop_interface failed rc = "
+					" 0x%x\n", hfidd_global.p_acs[i]->name,
+				rc);
+			}
+
+			rc = hfidd_query_interface(hfidd_global.p_acs[i],
+					COMP_QUERY,
+					hfidd_global.p_acs[i]->dds.hfi_id,
+					&hfi_state);
+			if (hfi_state != NOT_STARTED) {
+				dev_printk(KERN_ERR,
+					hfidd_global.p_acs[i]->hfidd_dev,
+					"%s: hfidd_start_adapter: query"
+					" interface bad state 0x%llx\n",
+					hfidd_global.p_acs[i]->name, hfi_state);
+				return -EIO;
+			}
+		}
+
+	}
+
+	for (i = 0; i < MAX_HFIS; i++) {
+		rc = hfidd_start_interface(hfidd_global.p_acs[i]);
+		if (rc) {
+			dev_printk(KERN_ERR, hfidd_global.p_acs[i]->hfidd_dev,
+				"%s: hfidd_start_adapter: "
+				"hfidd_start_interface failed rc = "
+				"%d\n", hfidd_global.p_acs[i]->name, rc);
+			goto hfidd_start_adapter_err;
+		}
+
+		/* query interface to get src ISR */
+		rc = hfidd_query_interface(hfidd_global.p_acs[i], COMP_QUERY,
+				hfidd_global.p_acs[i]->dds.hfi_id, &hfi_state);
+		if (rc) {
+			dev_printk(KERN_ERR, hfidd_global.p_acs[i]->hfidd_dev,
+				"%s: hfidd_start_adapter: "
+				"hfidd_query_interface failed rc = %d\n",
+				hfidd_global.p_acs[i]->name, rc);
+			goto hfidd_start_adapter_err;
+		}
+	}
+	return 0;
+
+hfidd_start_adapter_err:
+	for (j = 0; j < i; j++) {
+		hfidd_stop_interface(hfidd_global.p_acs[j],
+			hfidd_global.p_acs[j]->dds.hfi_id);
+	}
+	return rc;
+}
+
 static int __init hfidd_mod_init(void)
 {
 	int			rc = 0;
@@ -338,9 +425,18 @@ static int __init hfidd_mod_init(void)
 		goto error1;
 	}
 
+	rc = hfidd_start_adapter();
+	if (rc < 0) {
+		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_start_adapter failed"
+			" rc = %d\n", HFIDD_DEV_NAME, rc);
+		goto error2;
+	}
+
 	printk(KERN_INFO "IBM hfi device driver loaded sucessfully\n");
 	return 0;
 
+error2:
+	hfidd_destroy_devices();
 error1:
 	hfidd_destroy_class();
 	return rc;
@@ -348,6 +444,7 @@ error1:
 
 static void __exit hfidd_mod_exit(void)
 {
+	hfidd_stop_adapter();
 	hfidd_destroy_devices();
 	hfidd_destroy_class();
 }
-- 
1.7.3.5

