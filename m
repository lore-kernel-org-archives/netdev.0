From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v2 16/27] HFI: Add window open hypervisor call
Date: Sun, 17 Apr 2011 23:21:48 -0400
Message-ID: <1303096919-7367-17-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e5.ny.us.ibm.com ([32.97.182.145]:45160 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab1DRDWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:22:34 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I2uTCw020203
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 22:56:29 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3I3MWZb2666522
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3MW6B001314
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
In-Reply-To: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
 drivers/net/hfi/core/hfidd_hcalls.c |   50 +++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h  |    6 +++
 include/linux/hfi/hfidd_hcalls.h    |   69 +++++++++++++++++++++++++++++++++++
 3 files changed, 125 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_hcalls.c b/drivers/net/hfi/core/hfidd_hcalls.c
index aabb2a8..1915336 100644
--- a/drivers/net/hfi/core/hfidd_hcalls.c
+++ b/drivers/net/hfi/core/hfidd_hcalls.c
@@ -131,6 +131,28 @@ static inline long long h_hfi_query_interface(int token,
 	return rc;
 }
 
+static inline long long h_hfi_open_window(int token,
+		u64 HFI_chip_ID,
+		u64 win_num,
+		u64 flag,
+		u64 win_info_ptr,
+		u64 *user_mmio,
+		u64 *kernel_mmio,
+		u64 *send_int_num,
+		u64 *recv_int_num)
+{
+	long long rc;
+	u64 hyp_outputs[PLPAR_HCALL_BUFSIZE];
+
+	rc = plpar_hcall(token, (unsigned long *)hyp_outputs, HFI_chip_ID,
+			win_num, flag, win_info_ptr);
+	*user_mmio = hyp_outputs[0];	/* 1st ret value */
+	*kernel_mmio = hyp_outputs[1];	/* 2nd */
+	*send_int_num = hyp_outputs[2];		/* 3rd */
+	*recv_int_num = hyp_outputs[3];		/* 4th */
+	return rc;
+}
+
 long long hfi_start_nmmu(u64 chip_id, void *nmmu_info)
 {
 	return h_nmmu_start(H_NMMU_START, chip_id, nmmu_info);
@@ -152,6 +174,34 @@ long long hfi_stop_nmmu(u64 chip_id)
 	return hvrc;
 }
 
+long long hfi_open_window(u64 unit_id, u64 win_id, u64 flag,
+		u64 win_info_p,
+		u64 *ummio_addr_p,
+		u64 *pmmio_addr_p,
+		u64 *send_intr,
+		u64 *recv_intr)
+{
+	long long  hvrc;
+	u64 start_time = get_jiffies_64();
+
+	while (1) {
+		hvrc = h_hfi_open_window(H_HFI_OPEN_WINDOW,
+				unit_id,
+				win_id,
+				flag,
+				win_info_p,
+				ummio_addr_p,
+				pmmio_addr_p,
+				send_intr,
+				recv_intr);
+		if (hvrc != H_BUSY)
+			break;
+		if (hfidd_age_hcall(start_time))
+			break;
+	}
+	return hvrc;
+}
+
 long long hfi_allocate_mr(u64 chip_id, u64 res, u64 addr, u64 mr_size,
 		u64 access,
 		u64 job_id,
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index ff39a02..c4ed215 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -67,6 +67,12 @@ int hfidd_start_interface(struct hfidd_acs *p_acs);
 int hfidd_stop_interface(struct hfidd_acs *p_acs, unsigned int hfi_id);
 long long hfi_start_nmmu(u64 chip_id, void *nmmu_info);
 long long hfi_stop_nmmu(u64 chip_id);
+long long hfi_open_window(u64 unit_id, u64 win_id, u64 flag,
+		u64 win_info_p,
+		u64 *ummio_addr_p,
+		u64 *pmmio_addr_p,
+		u64 *send_intr,
+		u64 *recv_intr);
 long long hfi_allocate_mr(u64 chip_id, u64 res, u64 addr,
 		u64 mr_size,
 		u64 access,
diff --git a/include/linux/hfi/hfidd_hcalls.h b/include/linux/hfi/hfidd_hcalls.h
index 3c9f556..a97bb5e 100644
--- a/include/linux/hfi/hfidd_hcalls.h
+++ b/include/linux/hfi/hfidd_hcalls.h
@@ -39,12 +39,19 @@
 #define H_HFI_START_INTERFACE		0xF000
 #define H_HFI_QUERY_INTERFACE		0xF004
 #define H_HFI_STOP_INTERFACE		0xF008
+#define H_HFI_OPEN_WINDOW		0xF00C
 #define H_NMMU_START			0xF028
 #define H_NMMU_STOP			0xF02C
 #define H_NMMU_ALLOCATE_RESOURCE	0xF030
 #define H_NMMU_FREE_RESOURCE		0xF034
 #define H_NMMU_MODIFY_RESOURCE		0xF03C
 
+#define H_OPEN		0x8000000000000000
+#define H_RESUME	0x0000000000000000
+#define H_SUSPEND	0x0000000000000000
+#define H_CLOSE		0x0000000000000001
+#define H_CHECK_CLOSED	0x0000000000000002
+
 #define NMMU_MR		0
 
 #define NMMU_MAP	1
@@ -63,6 +70,68 @@
 
 #define HFI_ACCESS_CTL_SHIFT	32
 
+struct win_open_info {
+	/* Hyp Feedback */
+	unsigned long long	hypervisor_capabilities;
+	unsigned int		error_offset;
+
+	/* Window Control */
+	unsigned int		job_id;			/* send & recv jobid */
+	unsigned int		protection_domain;
+
+	/* Immediate Send Context */
+	unsigned int		immediate_send_pid;
+	unsigned int		immediate_send_slots;
+	unsigned int		immediate_send_update_freq;
+	unsigned long long	immediate_send_finish_vec;
+
+	/* Send Fifo */
+	unsigned long long	sfifo_base_eaddr;
+	unsigned int		sfifo_lkey;
+	unsigned int		sfifo_size;		/* in bytes */
+	unsigned long long	sfifo_finish_vec;
+
+	/* Full RDMA Send Fifo */
+	unsigned long long	fullrdma_fifo_base_eaddr;
+	unsigned int		fullrdma_fifo_lkey;
+	unsigned int		fullrdma_fifo_size;	/* in bytes */
+	unsigned int		fullrdma_msg_breakup_count;
+	unsigned long long	fullrdma_fifo_finish_vec;
+
+	/* Receive Fifo */
+	unsigned long long	rfifo_base_eaddr;
+	unsigned int		rfifo_lkey;
+	unsigned int		rfifo_size;		/* in bytes */
+
+	/* IP2k Free Space Decriptor Fifo */
+	unsigned long long	ip2kfifo_base_eaddr;
+	unsigned int		ip2kfifo_lkey;
+	unsigned int		ip2kfifo_size;		/* in bytes */
+
+	/* RDMA Pending Fifo */
+	unsigned long long      rdmapending_base_eaddr;
+	unsigned int            rdmapending_lkey;
+	unsigned int            rdmapending_size;       /* in bytes */
+	unsigned int            rdmapending_read_req_thresh;
+
+	/* SendSpecial Fifo */
+	unsigned long long	specialfifo_base_eaddr;
+	unsigned int		specialfifo_lkey;
+	unsigned int		specialfifo_size;	/* in bytes */
+
+	/* IP Context */
+	unsigned int		is_ip_window;
+	unsigned int		multicast_enable;
+	unsigned int		disable_src_isr_id_stamp;
+	unsigned int		logical_port_id_valid;
+	unsigned int		logical_port_id;
+
+	/* RDMA Context */
+	unsigned long long	rcxt_base_eaddr;
+	unsigned int		rcxt_lkey;
+	unsigned int		rdma_payload_lkey;
+};
+
 #define EEH_QUERY	1
 #define COMP_QUERY	2
 
-- 
1.7.3.5

