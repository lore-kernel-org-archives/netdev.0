From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v4 14/27] HFI: Add hypercalls to create/modify/free page tables in the nMMU
Date: Mon, 25 Apr 2011 17:23:54 -0400
Message-ID: <1303766647-30156-15-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e38.co.us.ibm.com ([32.97.110.159]:41218 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755324Ab1DYVYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:24:30 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PDcgYQ006064
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 07:38:42 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3PLOOMB364418
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:24 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLOOsB032559
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:24 -0600
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
 drivers/net/hfi/core/hfidd_hcalls.c |  124 +++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h  |   15 ++++
 include/linux/hfi/hfidd_hcalls.h    |    3 +
 3 files changed, 142 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_hcalls.c b/drivers/net/hfi/core/hfidd_hcalls.c
index 2ca1c8a..aabb2a8 100644
--- a/drivers/net/hfi/core/hfidd_hcalls.c
+++ b/drivers/net/hfi/core/hfidd_hcalls.c
@@ -45,6 +45,64 @@ static inline long long h_nmmu_stop(int token, u64 torrent_chip_ID)
 	return plpar_hcall_norets(token, torrent_chip_ID);
 }
 
+static inline long long h_nmmu_allocate_resource(int token,
+		u64 torrent_chip_ID,
+		u64 resource_name,
+		u64 eaddr,
+		u64 memory_region_size,
+		u64 access_controls,
+		u64 protection_domain,
+		u64 MR_Handle_In,
+		u64 *MR_Handle_out,
+		u64 *L_Key,
+		u64 *liobn)
+{
+	u64 hyp_outputs[PLPAR_HCALL9_BUFSIZE];
+	long long rc;
+
+	rc = plpar_hcall9(token, (unsigned long *)hyp_outputs,
+			torrent_chip_ID, resource_name, eaddr,
+			memory_region_size, access_controls,
+			protection_domain, MR_Handle_In);
+	*MR_Handle_out = hyp_outputs[0];	/* 1st ret value */
+	*L_Key = hyp_outputs[1];		/* 2nd */
+	*liobn = hyp_outputs[3];		/* 4th */
+
+	return rc;
+}
+
+static inline long long h_nmmu_free_resource(int token,
+		u64 torrent_chip_ID,
+		u64 resource_name,
+		u64 MR_Handle,
+		u64 subregion)
+{
+	return  plpar_hcall_norets(token,
+				torrent_chip_ID,
+				resource_name,
+				MR_Handle,
+				subregion);
+}
+
+static inline long long h_nmmu_modify_resource(int token,
+		u64 torrent_chip_ID,
+		u64 request,
+		u64 MR_Handle,
+		u64 subregion,
+		u64 eaddr,
+		u64 laddr,
+		u64 num_pg_sz)
+{
+	return  plpar_hcall_norets(token,
+				torrent_chip_ID,
+				request,
+				MR_Handle,
+				subregion,
+				eaddr,
+				laddr,
+				num_pg_sz);
+}
+
 static inline long long h_hfi_start_interface(int token,
 		u64 HFI_chip_ID)
 {
@@ -94,6 +152,72 @@ long long hfi_stop_nmmu(u64 chip_id)
 	return hvrc;
 }
 
+long long hfi_allocate_mr(u64 chip_id, u64 res, u64 addr, u64 mr_size,
+		u64 access,
+		u64 job_id,
+		u64 mr_handle_in,
+		u64 *mr_handle_out,
+		u64 *lkey_p,
+		u64 *liobn)
+{
+	return h_nmmu_allocate_resource(H_NMMU_ALLOCATE_RESOURCE,
+			chip_id,
+			res,
+			addr,
+			mr_size,
+			access,
+			job_id,
+			mr_handle_in,
+			mr_handle_out,
+			lkey_p,
+			liobn);
+}
+
+long long hfi_modify_mr(u64 chip_id, u64 request, u64 mr_handle,
+		u64 sub_id,
+		u64 e_addr,
+		u64 l_addr,
+		u64 num_pg_sz)
+{
+	long long  hvrc;
+	u64 start_time = get_jiffies_64();
+
+	while (1) {
+		hvrc = h_nmmu_modify_resource(H_NMMU_MODIFY_RESOURCE,
+				chip_id,
+				request,
+				mr_handle,
+				sub_id,
+				e_addr,
+				l_addr,
+				num_pg_sz);
+		if (hvrc != H_BUSY)
+			break;
+		if (hfidd_age_hcall(start_time))
+			break;
+	}
+	return hvrc;
+}
+
+long long hfi_free_mr(u64 chip_id, u64 res, u64 mr_handle, u64 sub_region_id)
+{
+	long long	hvrc;
+	u64 start_time = get_jiffies_64();
+
+	while (1) {
+		hvrc = h_nmmu_free_resource(H_NMMU_FREE_RESOURCE,
+				chip_id,
+				res,
+				mr_handle,
+				sub_region_id);
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
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index 001f6d5..fb9c8c8 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -64,6 +64,21 @@ int hfidd_start_interface(struct hfidd_acs *p_acs);
 int hfidd_stop_interface(struct hfidd_acs *p_acs, unsigned int hfi_id);
 long long hfi_start_nmmu(u64 chip_id, void *nmmu_info);
 long long hfi_stop_nmmu(u64 chip_id);
+long long hfi_allocate_mr(u64 chip_id, u64 res, u64 addr,
+		u64 mr_size,
+		u64 access,
+		u64 job_id,
+		u64 mr_handle_in,
+		u64 *mr_handle_out,
+		u64 *lkey_p,
+		u64 *liobn);
+long long hfi_modify_mr(u64 chip_id, u64 request, u64 mr_handle,
+		u64 sub_id,
+		u64 e_addr,
+		u64 l_addr,
+		u64 num_pg_sz);
+long long hfi_free_mr(u64 chip_id, u64 res, u64 mr_handle,
+		u64 sub_region_id);
 long long hfi_hquery_interface(u64 unit_id, u64 subtype, u64 query_p,
 		u64 *state);
 long long hfi_start_interface(u64 unit_id);
diff --git a/include/linux/hfi/hfidd_hcalls.h b/include/linux/hfi/hfidd_hcalls.h
index 57140a0..9fa87c5 100644
--- a/include/linux/hfi/hfidd_hcalls.h
+++ b/include/linux/hfi/hfidd_hcalls.h
@@ -41,6 +41,9 @@
 #define H_HFI_STOP_INTERFACE		0xF008
 #define H_NMMU_START			0xF028
 #define H_NMMU_STOP			0xF02C
+#define H_NMMU_ALLOCATE_RESOURCE	0xF030
+#define H_NMMU_FREE_RESOURCE		0xF034
+#define H_NMMU_MODIFY_RESOURCE		0xF03C
 
 #define HFI_PAGE_CODE_SHIFT	28
 
-- 
1.7.3.5

