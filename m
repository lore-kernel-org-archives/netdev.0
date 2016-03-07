From: sunil.kovvuri@gmail.com
Subject: [PATCH 2/2] net: thunderx: Adjust nicvf structure to reduce cache misses
Date: Mon,  7 Mar 2016 13:05:57 +0530
Message-ID: <1457336157-31508-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1457336157-31508-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36314 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbcCGHct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 02:32:49 -0500
In-Reply-To: <1457336157-31508-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sunil Goutham <sgoutham@cavium.com>

Adjusted nicvf structure such that all elements used in hot
path like napi, xmit e.t.c fall into same cache line. This reduced
no of cache misses and resulted in ~2% increase in no of packets
handled on a core.

Also modified elements with :1 notation to boolean, to be
consistent with other element definitions.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h |   52 ++++++++++++++++------------
 1 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 5628aea..c063d92 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -263,46 +263,54 @@ struct nicvf {
 	struct nicvf		*pnicvf;
 	struct net_device	*netdev;
 	struct pci_dev		*pdev;
+	void __iomem		*reg_base;
+	struct queue_set	*qs;
+	struct nicvf_cq_poll	*napi[8];
 	u8			vf_id;
-	u8			node;
-	u8			tns_mode:1;
-	u8			sqs_mode:1;
-	u8			loopback_supported:1;
+	u8			sqs_id;
+	bool                    sqs_mode;
 	bool			hw_tso;
-	u16			mtu;
-	struct queue_set	*qs;
+
+	/* Receive buffer alloc */
+	u32			rb_page_offset;
+	u16			rb_pageref;
+	bool			rb_alloc_fail;
+	bool			rb_work_scheduled;
+	struct page		*rb_page;
+	struct delayed_work	rbdr_work;
+	struct tasklet_struct	rbdr_task;
+
+	/* Secondary Qset */
+	u8			sqs_count;
 #define	MAX_SQS_PER_VF_SINGLE_NODE		5
 #define	MAX_SQS_PER_VF				11
-	u8			sqs_id;
-	u8			sqs_count; /* Secondary Qset count */
 	struct nicvf		*snicvf[MAX_SQS_PER_VF];
+
+	/* Queue count */
 	u8			rx_queues;
 	u8			tx_queues;
 	u8			max_queues;
-	void __iomem		*reg_base;
+
+	u8			node;
+	u8			cpi_alg;
+	u16			mtu;
 	bool			link_up;
 	u8			duplex;
 	u32			speed;
-	struct page		*rb_page;
-	u32			rb_page_offset;
-	u16			rb_pageref;
-	bool			rb_alloc_fail;
-	bool			rb_work_scheduled;
-	struct delayed_work	rbdr_work;
-	struct tasklet_struct	rbdr_task;
-	struct tasklet_struct	qs_err_task;
-	struct tasklet_struct	cq_task;
-	struct nicvf_cq_poll	*napi[8];
+	bool			tns_mode;
+	bool			loopback_supported;
 	struct nicvf_rss_info	rss_info;
-	u8			cpi_alg;
+	struct tasklet_struct	qs_err_task;
+	struct work_struct	reset_task;
+
 	/* Interrupt coalescing settings */
 	u32			cq_coalesce_usecs;
-
 	u32			msg_enable;
+
+	/* Stats */
 	struct nicvf_hw_stats   hw_stats;
 	struct nicvf_drv_stats  drv_stats;
 	struct bgx_stats	bgx_stats;
-	struct work_struct	reset_task;
 
 	/* MSI-X  */
 	bool			msix_enabled;
-- 
1.7.1
