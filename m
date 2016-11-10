From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net v2] igb: re-assign hw address pointer on reset after PCI error
Date: Thu, 10 Nov 2016 16:46:43 -0200
Message-ID: <1478803603-30306-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: jeffrey.t.kirsher@intel.com, gpiccoli@linux.vnet.ibm.com,
        netdev@vger.kernel.org, alexander.duyck@gmail.com,
        todd.fujinaka@intel.com
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38387 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755817AbcKJSqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 13:46:49 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAAIdCXb001641
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 13:46:48 -0500
Received: from e24smtp03.br.ibm.com (e24smtp03.br.ibm.com [32.104.18.24])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26msh70b7r-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 13:46:48 -0500
Received: from localhost
        by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Thu, 10 Nov 2016 16:46:46 -0200
Received: from d24relay04.br.ibm.com (d24relay04.br.ibm.com [9.18.232.146])
        by d24dlp01.br.ibm.com (Postfix) with ESMTP id 2C1A13520074
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 13:46:16 -0500 (EST)
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
        by d24relay04.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAAIkiJj40042670
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 16:46:44 -0200
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
        by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAAIkhfC007109
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 16:46:44 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever the igb driver detects the result of a read operation returns
a value composed only by F's (like 0xFFFFFFFF), it will detach the
net_device, clear the hw_addr pointer and warn to the user that adapter's
link is lost - those steps happen on igb_rd32().

In case a PCI error happens on Power architecture, there's a recovery
mechanism called EEH, that will reset the PCI slot and call driver's
handlers to reset the adapter and network functionality as well.

We observed that once hw_addr is NULL after the error is detected on
igb_rd32(), it's never assigned back, so in the process of resetting
the network functionality we got a NULL pointer dereference in both
igb_configure_tx_ring() and igb_configure_rx_ring(). In order to avoid
such bug, this patch re-assigns the hw_addr value in the slot_reset
handler.

Reported-by: Anthony H. Thai <ahthai@us.ibm.com>
Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index edc9a6a..136ee9e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7878,6 +7878,11 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
 		pci_enable_wake(pdev, PCI_D3hot, 0);
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 
+		/* In case of PCI error, adapter lose its HW address
+		 * so we should re-assign it here.
+		 */
+		hw->hw_addr = adapter->io_addr;
+
 		igb_reset(adapter);
 		wr32(E1000_WUS, ~0);
 		result = PCI_ERS_RESULT_RECOVERED;
-- 
2.1.0
