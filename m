From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 1/4] netxen: cache msi register offset
Date: Sat,  9 May 2009 01:02:27 -0700
Message-ID: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48106 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751298AbZEIICa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 04:02:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Store msi target status register offset in adapter struct.
This avoids contention on msi_tgt_status table from interrupt
hadlers of different pci function.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    3 +++
 drivers/net/netxen/netxen_nic_main.c |    4 +++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 9350c86..ab11c2b 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1257,6 +1257,9 @@ struct netxen_adapter {
 	u32 irq;
 	u32 temp;
 
+	u32 msi_tgt_status;
+	u32 resv4;
+
 	struct netxen_adapter_stats stats;
 
 	struct netxen_recv_context recv_ctx;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 83dadfd..edb4bcd 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -525,6 +525,8 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 request_msi:
 		if (use_msi && !pci_enable_msi(pdev)) {
 			adapter->flags |= NETXEN_NIC_MSI_ENABLED;
+			adapter->msi_tgt_status =
+				msi_tgt_status[adapter->ahw.pci_func];
 			dev_info(&pdev->dev, "using msi interrupts\n");
 		} else
 			dev_info(&pdev->dev, "using legacy interrupts\n");
@@ -1701,7 +1703,7 @@ static irqreturn_t netxen_msi_intr(int irq, void *data)
 
 	/* clear interrupt */
 	adapter->pci_write_immediate(adapter,
-			msi_tgt_status[adapter->ahw.pci_func], 0xffffffff);
+			adapter->msi_tgt_status, 0xffffffff);
 
 	napi_schedule(&sds_ring->napi);
 	return IRQ_HANDLED;
-- 
1.6.0.2

