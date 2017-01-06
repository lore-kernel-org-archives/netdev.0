From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] igb: re-assign hw address pointer on reset after PCI error
Date: Fri,  6 Jan 2017 02:48:49 -0800
Message-ID: <20170106104852.10363-8-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:51441 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965747AbdAFKtY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:24 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>

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

Reported-by: Anthony H Thai <ahthai@us.ibm.com>
Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
Signed-off-by: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1e4bd84..82069bc 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7898,6 +7898,11 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
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
2.9.3
