From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Don't sleep when mbox cmd is issued from interrupt context
Date: Tue,  3 May 2016 18:58:01 +0530
Message-ID: <1462282082-6894-2-git-send-email-hariprasad@chelsio.com>
References: <1462282082-6894-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:46771 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755608AbcECNXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 09:23:45 -0400
In-Reply-To: <1462282082-6894-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When link goes down, from the interrupt handler DCB priority for the
Tx queues needs to be unset. We issue mbox command to unset the Tx queue
priority with negative timeout. In t4_wr_mbox_meat_timeout() do not sleep
when negative timeout is passed, since it is called from interrupt context.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 49bcbf16c9ca..59f5e0b40286 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -304,6 +304,12 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 	if (adap->pdev->error_state != pci_channel_io_normal)
 		return -EIO;
 
+	/* If we have a negative timeout, that implies that we can't sleep. */
+	if (timeout < 0) {
+		sleep_ok = false;
+		timeout = -timeout;
+	}
+
 	v = MBOWNER_G(t4_read_reg(adap, ctl_reg));
 	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
 		v = MBOWNER_G(t4_read_reg(adap, ctl_reg));
-- 
2.3.4
