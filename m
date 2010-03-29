From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/5] netxen: fix corner cases of firmware recovery
Date: Mon, 29 Mar 2010 05:43:42 -0700
Message-ID: <1269866625-26151-3-git-send-email-amit.salecha@qlogic.com>
References: <1269866625-26151-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48639 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751434Ab0C2Mnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 08:43:46 -0400
In-Reply-To: <1269866625-26151-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

o DEV_NEED_RESET state was not handled during fw intialization phase.
o nx_decr_dev_ref_cnt() can return error, if fail to grab pcie seamphore.
---
 drivers/net/netxen/netxen_nic_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 08780ef..68903bf 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2294,6 +2294,7 @@ netxen_fwinit_work(struct work_struct *work)
 		}
 		break;
 
+	case NX_DEV_NEED_RESET:
 	case NX_DEV_INITALIZING:
 		if (++adapter->fw_wait_cnt < FW_POLL_THRESH) {
 			netxen_schedule_work(adapter,
@@ -2337,6 +2338,9 @@ netxen_detach_work(struct work_struct *work)
 
 	ref_cnt = nx_decr_dev_ref_cnt(adapter);
 
+	if (ref_cnt == -EIO)
+		goto err_ret;
+
 	delay = (ref_cnt == 0) ? 0 : (2 * FW_POLL_DELAY);
 
 	adapter->fw_wait_cnt = 0;
-- 
1.6.0.2

