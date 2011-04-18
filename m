From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v2 07/27] HFI: Add nMMU start/stop hypervisor calls
Date: Sun, 17 Apr 2011 23:21:39 -0400
Message-ID: <1303096919-7367-8-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e1.ny.us.ibm.com ([32.97.182.141]:48486 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101Ab1DRDWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:22:33 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I3Bute023578
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:11:56 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3I3MWpt299476
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3MVSs001212
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
In-Reply-To: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

H_NMMU_START resets/inits state for the nMMU in the hypervisor.
H_NMMU_STOP cleans up hypervisor nMMU state, called on DD unload after HFIs are
stopped.

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
 drivers/net/hfi/core/hfidd_adpt.c   |   36 +++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_hcalls.c |   33 ++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_init.c   |   29 +++++++++++++++++++++++++--
 drivers/net/hfi/core/hfidd_proto.h  |    3 ++
 include/linux/hfi/hfidd_hcalls.h    |    2 +
 5 files changed, 100 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
index d2bef84..ef795bf 100644
--- a/drivers/net/hfi/core/hfidd_adpt.c
+++ b/drivers/net/hfi/core/hfidd_adpt.c
@@ -162,6 +162,42 @@ query1:
 	return rc;
 }
 
+int hfidd_start_nmmu(struct hfidd_acs *p_acs)
+{
+	long long		hvrc;
+	int			rc = 0;
+	struct nmmu_info	*nmmu_info;
+	caddr_t			laddr = NULL;
+	u64	start_time = get_jiffies_64();
+
+	rc = hfidd_get_phyp_page(p_acs, (caddr_t *)&nmmu_info, &laddr,
+			PAGE_SIZE_4K);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_start_nmmu: hfidd_get_phyp_page failed\n");
+		return -ENOMEM;
+	}
+
+	while (1) {
+		hvrc = hfi_start_nmmu(p_acs->dds.torr_id,
+				(struct nmmu_info *) laddr);
+		if (hvrc != H_BUSY)
+			break;
+		if (hfidd_age_hcall(start_time))
+			break;
+	}
+
+	if (hvrc != H_SUCCESS) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_start_nmmu: HFI_START_NMMU failed "
+			"hvrc 0x%llx\n", hvrc);
+		rc = -EPERM;
+	}
+
+	hfidd_release_phyp_page((caddr_t)nmmu_info, PAGE_SIZE_4K);
+	return rc;
+}
+
 int hfidd_start_interface(struct hfidd_acs *p_acs)
 {
 	long long hvrc = 0;
diff --git a/drivers/net/hfi/core/hfidd_hcalls.c b/drivers/net/hfi/core/hfidd_hcalls.c
index 84467b3..2ca1c8a 100644
--- a/drivers/net/hfi/core/hfidd_hcalls.c
+++ b/drivers/net/hfi/core/hfidd_hcalls.c
@@ -33,6 +33,18 @@
 #include <linux/hfi/hfidd_internal.h>
 #include "hfidd_proto.h"
 
+static inline long long h_nmmu_start(int token,
+		u64 torrent_chip_ID,
+		void *output_page_ptr)
+{
+	return plpar_hcall_norets(token, torrent_chip_ID, output_page_ptr);
+}
+
+static inline long long h_nmmu_stop(int token, u64 torrent_chip_ID)
+{
+	return plpar_hcall_norets(token, torrent_chip_ID);
+}
+
 static inline long long h_hfi_start_interface(int token,
 		u64 HFI_chip_ID)
 {
@@ -61,6 +73,27 @@ static inline long long h_hfi_query_interface(int token,
 	return rc;
 }
 
+long long hfi_start_nmmu(u64 chip_id, void *nmmu_info)
+{
+	return h_nmmu_start(H_NMMU_START, chip_id, nmmu_info);
+}
+
+long long hfi_stop_nmmu(u64 chip_id)
+{
+	long long hvrc;
+	u64 start_time = get_jiffies_64();
+
+	while (1) {
+		hvrc = h_nmmu_stop(H_NMMU_STOP,
+				chip_id);
+		if (hvrc != H_BUSY)
+			break;
+		if (hfidd_age_hcall(start_time))
+			break;
+	}
+	return hvrc;
+}
+
 long long hfi_hquery_interface(u64 unit_id, u64 subtype,
 			       u64 query_p, u64 *state)
 {
diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index 99bacab..cbc616d 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -321,30 +321,43 @@ hfidd_create_devices_error0:
 
 /*
  * Disable message passing to each adapter by calling the
- * Stop Interface hcall.
+ * Stop Interface hcall and free phyp NMMU tables for this
+ * lpar by calling STOP NMMU
  */
 static void hfidd_stop_adapter(void)
 {
 	int i;
+	long long hvrc;
 
 	for (i = 0; i < MAX_HFIS; i++) {
 		hfidd_stop_interface(hfidd_global.p_acs[i],
 			hfidd_global.p_acs[i]->dds.hfi_id);
 	}
+	hvrc = hfi_stop_nmmu(hfidd_global.p_acs[0]->dds.torr_id);
+	if (hvrc != H_SUCCESS)
+		dev_printk(KERN_ERR, hfidd_global.p_acs[0]->hfidd_dev,
+			"%s: hfidd_stop_adapter: HFI_STOP_NMMU failed"
+			" hvrc = 0x%llx\n", HFIDD_DEV_NAME, hvrc);
 }
 
 /*
  * Query the interface to check the logical state of HFI.
- * Enable message passing to each adapter by calling Start
- * Interface hcall.
+ * Initialize the phyp NMMU tables for this lpar by calling
+ * the START NMMU hcall and enable message passing to each
+ * adapter by calling Start Interface hcall.
  */
 static int hfidd_start_adapter(void)
 {
+	long long hvrc;
 	unsigned long long	hfi_state;
 	int i, j;
 	int rc = 0;
 
 	for (i = 0; i < MAX_HFIS; i++) {
+		/* query interface before doing START_NMMU.
+		 * If we crashed the LPAR a few minutes ago, we never did the
+		 * stop interface and the stop nmmu.  Do it now.
+		 */
 		rc = hfidd_query_interface(hfidd_global.p_acs[i], COMP_QUERY,
 			hfidd_global.p_acs[i]->dds.hfi_id, &hfi_state);
 		if (hfi_state != NOT_STARTED) {
@@ -375,6 +388,15 @@ static int hfidd_start_adapter(void)
 
 	}
 
+	hfi_stop_nmmu(hfidd_global.p_acs[0]->dds.torr_id);
+	hvrc = hfidd_start_nmmu(hfidd_global.p_acs[0]);
+	if (hvrc != H_SUCCESS) {
+		dev_printk(KERN_ERR, hfidd_global.p_acs[0]->hfidd_dev,
+			"%s: hfidd_start_adapter: HFI_START_NMMU failed"
+			" hvrc = 0x%llx\n", HFIDD_DEV_NAME, hvrc);
+		return -EIO;
+	}
+
 	for (i = 0; i < MAX_HFIS; i++) {
 		rc = hfidd_start_interface(hfidd_global.p_acs[i]);
 		if (rc) {
@@ -403,6 +425,7 @@ hfidd_start_adapter_err:
 		hfidd_stop_interface(hfidd_global.p_acs[j],
 			hfidd_global.p_acs[j]->dds.hfi_id);
 	}
+	hfi_stop_nmmu(hfidd_global.p_acs[0]->dds.torr_id);
 	return rc;
 }
 
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index 6ec9245..320f41f 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -42,8 +42,11 @@ int hfidd_get_phyp_page(struct hfidd_acs *p_acs, caddr_t *page,
 void hfidd_release_phyp_page(caddr_t page, int size);
 int hfidd_query_interface(struct hfidd_acs *p_acs, unsigned int subtype,
 	unsigned int hfi_id, unsigned long long *state);
+int hfidd_start_nmmu(struct hfidd_acs *p_acs);
 int hfidd_start_interface(struct hfidd_acs *p_acs);
 int hfidd_stop_interface(struct hfidd_acs *p_acs, unsigned int hfi_id);
+long long hfi_start_nmmu(u64 chip_id, void *nmmu_info);
+long long hfi_stop_nmmu(u64 chip_id);
 long long hfi_hquery_interface(u64 unit_id, u64 subtype, u64 query_p,
 		u64 *state);
 long long hfi_start_interface(u64 unit_id);
diff --git a/include/linux/hfi/hfidd_hcalls.h b/include/linux/hfi/hfidd_hcalls.h
index 5349e9e..2a374e6 100644
--- a/include/linux/hfi/hfidd_hcalls.h
+++ b/include/linux/hfi/hfidd_hcalls.h
@@ -39,6 +39,8 @@
 #define H_HFI_START_INTERFACE		0xF000
 #define H_HFI_QUERY_INTERFACE		0xF004
 #define H_HFI_STOP_INTERFACE		0xF008
+#define H_NMMU_START			0xF028
+#define H_NMMU_STOP			0xF02C
 
 #define EEH_QUERY	1
 #define COMP_QUERY	2
-- 
1.7.3.5

