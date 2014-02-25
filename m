From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next 2/3] bnx2x: save RAM in kdump kernel by using a single queue
Date: Tue, 25 Feb 2014 16:04:25 +0100
Message-ID: <1393340666-3539-3-git-send-email-mschmidt@redhat.com>
References: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, ariele@broadcom.com, dmitry@broadcom.com,
	yuvalmin@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923AbaBYPEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 10:04:38 -0500
In-Reply-To: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in a kdump kernel, make sure to use only a single ethernet
queue even if a num_queues option in /etc/modprobe.d/*.conf would specify
otherwise. This saves memory, which tends to be scarce in kdump.

This saves about 40 MB in the kdump environment on a setup with
num_queues=8 in the config file.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 64c17b6..500d38a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -62,6 +62,11 @@ static void bnx2x_add_all_napi(struct bnx2x *bp)
 static int bnx2x_calc_num_queues(struct bnx2x *bp)
 {
 	int nq = bnx2x_num_queues ? : netif_get_num_default_rss_queues();
+
+	/* Reduce memory usage in kdump environment by using only one queue */
+	if (reset_devices)
+		nq = 1;
+
 	nq = clamp(nq, 1, BNX2X_MAX_QUEUES(bp));
 	return nq;
 }
-- 
1.8.5.3
