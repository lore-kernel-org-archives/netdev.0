From: Andre Detsch <adetsch@br.ibm.com>
Subject: [PATCH] e100: Fix napi_enable BUG_ON when recovering from EEH error
Date: Fri, 5 Jun 2009 17:04:25 -0300
Message-ID: <200906051704.25753.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:41098 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755329AbZFEUEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 16:04:53 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp05.br.ibm.com (8.13.1/8.13.1) with ESMTP id n55K31cP030403
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 17:03:01 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n55L47UH3969076
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 18:04:07 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n55K4rJr026832
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 17:04:53 -0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state)) was being hit
during e100 EEH recovery. The problem source was a napi_enable
call being made during e100_io_error_detected. Napi should remain
disabled after e100_down, and only be reenabled when the interface
is recovered.

This patch also updates e100_io_error_detected in order to make
it similar to the current versions of the error_detected callback
in drivers such as e1000e and ixgbe.

Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
---
 drivers/net/e100.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 0f9ee13..0c37dd9 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2822,12 +2822,13 @@ static pci_ers_result_t e100_io_error_detected(struct pci_dev *pdev, pci_channel
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-	/* Similar to calling e100_down(), but avoids adapter I/O. */
-	e100_close(netdev);
-
-	/* Detach; put netif into a state similar to hotplug unplug. */
-	napi_enable(&nic->napi);
 	netif_device_detach(netdev);
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	if (netif_running(netdev))
+		e100_down(nic);
 	pci_disable_device(pdev);
 
 	/* Request a slot reset. */
-- 
1.6.0.2

