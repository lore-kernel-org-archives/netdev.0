From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/10] net/smc: do not use IB_SEND_INLINE together with mapped data
Date: Mon, 10 Apr 2017 14:58:05 +0200
Message-ID: <20170410125805.13653-11-ubraun@linux.vnet.ibm.com>
References: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:43170 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753386AbdDJM62 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:28 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACtYFY093210
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:27 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29r5autu04-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:27 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:25 +0100
In-Reply-To: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smc specifies IB_SEND_INLINE for IB_WR_SEND ib_post_send calls, but
provides a mapped buffer to be sent. This is inconsistent, since
IB_SEND_INLINE works without mapped buffer. Problem has not been
detected in the past, because tests had been limited to Connect X3 cards
from Mellanox, whose mlx4 driver just ignored the IB_SEND_INLINE flag.
For now, the IB_SEND_INLINE flag is removed.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 net/smc/smc_ib.c | 1 -
 net/smc/smc_wr.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index b762577..16b7c80 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -257,7 +257,6 @@ int smc_ib_create_queue_pair(struct smc_link *lnk)
 			.max_recv_wr = SMC_WR_BUF_CNT * 3,
 			.max_send_sge = SMC_IB_MAX_SEND_SGE,
 			.max_recv_sge = 1,
-			.max_inline_data = SMC_WR_TX_SIZE,
 		},
 		.sq_sig_type = IB_SIGNAL_REQ_WR,
 		.qp_type = IB_QPT_RC,
diff --git a/net/smc/smc_wr.c b/net/smc/smc_wr.c
index eadf157..874ee9f 100644
--- a/net/smc/smc_wr.c
+++ b/net/smc/smc_wr.c
@@ -447,7 +447,7 @@ static void smc_wr_init_sge(struct smc_link *lnk)
 		lnk->wr_tx_ibs[i].num_sge = 1;
 		lnk->wr_tx_ibs[i].opcode = IB_WR_SEND;
 		lnk->wr_tx_ibs[i].send_flags =
-			IB_SEND_SIGNALED | IB_SEND_SOLICITED | IB_SEND_INLINE;
+			IB_SEND_SIGNALED | IB_SEND_SOLICITED;
 	}
 	for (i = 0; i < lnk->wr_rx_cnt; i++) {
 		lnk->wr_rx_sges[i].addr =
-- 
2.10.2
