From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 09/27] HFI: Add HFI window resource tracking
Date: Thu, 21 Apr 2011 17:38:39 -0400
Message-ID: <1303421937-2325-10-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e8.ny.us.ibm.com ([32.97.182.138]:47382 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755214Ab1DUVkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:40:03 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLELMK000466
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:14:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdBgp171344
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:19 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLd9H7012555
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:11 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

An HFI window is very roughly similar to an infiniband UD queue pair.

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
 drivers/net/hfi/core/hfidd_adpt.c  |   64 ++++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h |    2 +
 include/linux/hfi/hfidd_adpt.h     |   10 ++++++
 include/linux/hfi/hfidd_client.h   |   27 +++++++++++++++
 include/linux/hfi/hfidd_internal.h |   43 ++++++++++++++++++++++++
 5 files changed, 146 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
index 487ef0e..8e3f5af 100644
--- a/drivers/net/hfi/core/hfidd_adpt.c
+++ b/drivers/net/hfi/core/hfidd_adpt.c
@@ -66,6 +66,16 @@ int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t devno, void *uiop)
 		goto err_exit0;
 
 	*adpt = p_acs;
+
+	/* alloc window structures */
+	ret = hfidd_alloc_windows(p_acs);
+	if (ret) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_alloc_adapter: hfidd_alloc_windows failed, "
+			"ret = 0x%x\n", ret);
+		goto err_exit0;
+	}
+
 	return 0;
 
 err_exit0:
@@ -76,9 +86,63 @@ err_exit0:
 
 void hfidd_free_adapter(struct hfidd_acs *p_acs)
 {
+	hfidd_free_windows(p_acs);
 	kfree(p_acs);
 }
 
+int hfidd_alloc_windows(struct hfidd_acs *p_acs)
+{
+	int		i;
+
+	p_acs->win = kzalloc(sizeof(*p_acs->win) * p_acs->dds.window_num,
+			GFP_KERNEL);
+
+	if (p_acs->win == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_alloc_windows: kzalloc p_acs->win failed\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < p_acs->dds.window_num; i++) {
+		p_acs->win[i] = kzalloc(sizeof(*(p_acs->win[i])),
+			GFP_KERNEL);
+		if (p_acs->win[i] == NULL) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_alloc_windows: kzalloc win 0x%x "
+				"failed\n", i);
+			hfidd_free_windows(p_acs);
+			return -ENOMEM;
+		}
+
+		/* Initialize window fields */
+		spin_lock_init(&(p_acs->win[i]->win_lock));
+
+		p_acs->win[i]->ai = p_acs->index;
+		p_acs->win[i]->index = p_acs->dds.window_start + i;
+
+		if (p_acs->win[i]->index < (p_acs->dds.window_start +
+				MAX_D_WIN_PER_HFI)) {
+			p_acs->win[i]->type  = HFIDD_DYNAMIC_WIN;
+		} else {
+			p_acs->win[i]->type  = HFIDD_RESERVE_WIN;
+		}
+		p_acs->win[i]->state = WIN_AVAILABLE;
+	}
+	return 0;
+}
+
+void hfidd_free_windows(struct hfidd_acs *p_acs)
+{
+	int		i;
+
+	for (i = 0; i < p_acs->dds.window_num; i++) {
+		kfree(p_acs->win[i]);
+		p_acs->win[i] = NULL;
+	}
+	kfree(p_acs->win);
+	p_acs->win = NULL;
+}
+
 /* Allocate the page for the HCALL */
 int hfidd_get_phyp_page(struct hfidd_acs *p_acs, caddr_t *page, caddr_t *laddr,
 	int size)
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index 320f41f..c61387e 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -35,6 +35,8 @@
 
 int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t, void *uiop);
 void hfidd_free_adapter(struct hfidd_acs *p_acs);
+int hfidd_alloc_windows(struct hfidd_acs *p_acs);
+void hfidd_free_windows(struct hfidd_acs *p_acs);
 int hfidd_init_adapter(struct hfidd_acs *p_acs, void *uiop);
 int hfidd_age_hcall(u64 time_start);
 int hfidd_get_phyp_page(struct hfidd_acs *p_acs, caddr_t *page,
diff --git a/include/linux/hfi/hfidd_adpt.h b/include/linux/hfi/hfidd_adpt.h
index e3271e9..babdb14 100644
--- a/include/linux/hfi/hfidd_adpt.h
+++ b/include/linux/hfi/hfidd_adpt.h
@@ -47,4 +47,14 @@
 #define HFI_GOING_UNAVAIL	2
 #define HFI_UNAVAIL		3
 
+/* HFI window states */
+#define WIN_AVAILABLE		0
+#define WIN_RESERVED		1
+#define WIN_OPENED		2
+#define WIN_SUSPENDED		3
+#define WIN_ERROR		4
+#define WIN_HERROR		5
+#define WIN_PENDING		6
+#define WIN_FAIL_CLOSE		7
+
 #endif /* _HFIDD_ADPT_H_ */
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
index b2ebd01..c3c8fef 100644
--- a/include/linux/hfi/hfidd_client.h
+++ b/include/linux/hfi/hfidd_client.h
@@ -64,6 +64,33 @@ struct hfi_req_hdr {
 };
 #define HFIDD_REQ_HDR_SIZE			sizeof(struct hfi_req_hdr)
 
+struct fifo_info {
+	struct hfi_64b		eaddr;
+	unsigned long long	size;		/* bytes */
+};
+
+#define HFIDD_IP_WIN		1	/* IP windows get broadcasts forwarded
+						to them... */
+#define HFIDD_KERNEL_WIN	2	/* ... other kernel windows do not */
+#define HFIDD_RESERVE_WIN	3	/* Must be reserved by job scheduler */
+#define HFIDD_DYNAMIC_WIN	4	/* First come, first served. Window# is
+						returned */
+struct hfi_client_info {
+	struct hfi_req_hdr	hdr;
+
+	unsigned int		window;
+	unsigned int		win_type;		/* HFIDD_*_WIN */
+	unsigned int		job_id;
+	unsigned int		protection_key_flag;
+	unsigned int		protection_key;
+	unsigned int		local_isrid;		/* Output */
+	struct fifo_info	sfifo;
+	struct fifo_info	rfifo;
+	struct hfi_64b		sfifo_finish_vec;
+	unsigned int		sfifo_lkey;		/* Output	*/
+	struct hfi_64b		mmio_regs;		/* Output	*/
+};
+
 #define MAX_TORRENTS            1
 #define MAX_HFI_PER_TORRENT     2
 #define MAX_HFIS                (MAX_TORRENTS * MAX_HFI_PER_TORRENT)
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index 0cc8c88..420d55a 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -59,9 +59,13 @@
 #include <asm/pgalloc.h>
 #include <asm/ibmebus.h>
 #include <linux/kthread.h>
+
 #include <linux/hfi/hfidd_client.h>
 #include <linux/hfi/hfidd_adpt.h>
 #include <linux/hfi/hfidd_hcalls.h>
+
+#define MAX_D_WIN_PER_HFI	(p_acs->dds.num_d_windows)
+
 #define HFIDD_DEV_NAME		"hfi"
 #define HFIDD_CLASS_NAME	"hfi"
 
@@ -76,6 +80,44 @@ struct hfidd_dds {
 	unsigned long long	fw_ec_level;	/* Firmware Level */
 };
 
+struct hfidd_fifo {
+	unsigned long long	eaddr;
+	unsigned long long	size;
+};
+
+#define IRQ_NAME_SIZE	20
+
+struct hfidd_window {
+	spinlock_t		win_lock;	/* lock for window */
+	int			index;
+	unsigned int		type;		/* dynamic/scheduled */
+	int			state;
+
+	unsigned int		ai;		/* index to p_acs */
+	unsigned int		is_ip;
+
+	unsigned int		job_id;
+	unsigned int		pid;
+	unsigned int		protection_key_flag;	/* by job/task */
+
+	unsigned int		recv_intr;		/* Recv interrupt */
+	unsigned int		send_intr;		/* Send interrupt */
+	char			recv_name[IRQ_NAME_SIZE];
+	char			send_name[IRQ_NAME_SIZE];
+
+	uid_t			uid;
+
+	struct hfi_client_info	client_info;		/* From user input */
+	struct win_open_info	*win_open_info_p;	/* virtual addr
+							   OPEN_WINDOW hcall */
+	caddr_t			win_open_info_laddr;	/* logical addr
+							   OPEN_WINDOW hcall */
+	unsigned long long	mmio_regs;		/* logical addr from
+							   OPEN WINDOW hcall */
+	struct hfidd_vlxmem	*sfifo_x_tab;
+	struct hfidd_vlxmem	*rfifo_x_tab;
+};
+
 #define HFI_DEVICE_NAME_MAX 8
 /* hfi global */
 struct hfidd_acs {
@@ -87,6 +129,7 @@ struct hfidd_acs {
 
 	unsigned int		isr;
 
+	struct hfidd_window	**win;
 	struct device		*hfidd_dev;
 	struct hfidd_dds	dds;
 };
-- 
1.7.3.5

