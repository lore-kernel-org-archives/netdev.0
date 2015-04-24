From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH] net/tg3: Release IRQs on permanent error
Date: Fri, 24 Apr 2015 15:22:23 +1000
Message-ID: <1429852943-28953-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, prashant@broadcom.com, mchan@broadcom.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:52796 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496AbbDXFX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 01:23:29 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 24 Apr 2015 15:23:26 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id D64DC2BB0040
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 15:23:22 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3O5NEgM655808
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 15:23:22 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3O5Mm23001659
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 15:22:48 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When having permanent EEH error, the PCI device will be removed
from the system. For this case, we shouldn't set pcierr_recovery
to true wrongly, which blocks the driver to release the allocated
interrupts and their handlers. Eventually, we can't disable MSI
or MSIx successfully because of the MSI or MSIx interrupts still
have associated interrupt actions, which is turned into following
stack dump.

Oops: Exception in kernel mode, sig: 5 [#1]
        :
[c0000000003b76a8] .free_msi_irqs+0x80/0x1a0 (unreliable)
[c00000000039f388] .pci_remove_bus_device+0x98/0x110
[c0000000000790f4] .pcibios_remove_pci_devices+0x9c/0x128
[c000000000077b98] .handle_eeh_events+0x2d8/0x4b0
[c0000000000782d0] .eeh_event_handler+0x130/0x1c0
[c000000000022bd4] .kernel_thread+0x54/0x70

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 1270b18..069952f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -18129,7 +18129,9 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 
 	rtnl_lock();
 
-	tp->pcierr_recovery = true;
+	/* We needn't recover from permanent error */
+	if (state == pci_channel_io_frozen)
+		tp->pcierr_recovery = true;
 
 	/* We probably don't have netdev yet */
 	if (!netdev || !netif_running(netdev))
-- 
2.1.0
