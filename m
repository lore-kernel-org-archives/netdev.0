From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 4/7] qlcnic: protect resoruce cleanup by rtnl lock
Date: Mon,  1 Feb 2010 07:24:57 -0800
Message-ID: <1265037900-20403-5-git-send-email-amit.salecha@qlogic.com>
References: <1265037900-20403-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:11619 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755173Ab0BAPZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 10:25:04 -0500
In-Reply-To: <1265037900-20403-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o context resources can be in used, while resoruce cleanup is in progress,
  during fw recover.
o Null pointer execption can occur in send_cmd_desc, if fw recovery
  module frees tx ring without rtnl lock.
o Same applies to ethtool register dump and FW health registers should be dump
  in any case.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    6 +++---
 drivers/net/qlcnic/qlcnic_main.c    |    2 ++
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 65e9620..37df5f6 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -326,12 +326,12 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
 	    (adapter->pdev)->device;
 
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
-		return;
-
 	for (i = 0; diag_registers[i] != -1; i++)
 		regs_buff[i] = QLCRD32(adapter, diag_registers[i]);
 
+	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+		return;
+
 	regs_buff[i++] = 0xFFEFCDAB; /* Marker btw regs and ring count*/
 
 	regs_buff[i++] = 1; /* No. of tx ring */
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 9a98285..7259adc 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2051,7 +2051,9 @@ qlcnic_detach_work(struct work_struct *work)
 
 	qlcnic_down(adapter, netdev);
 
+	rtnl_lock();
 	qlcnic_detach(adapter);
+	rtnl_unlock();
 
 	status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
 
-- 
1.6.0.2

