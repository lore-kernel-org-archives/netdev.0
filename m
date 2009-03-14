From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 09/11] ixgbe: Two small fixes for 82599 when bringing
	the device down and for WoL
Date: Sat, 14 Mar 2009 01:15:10 -0700
Message-ID: <20090314081510.4687.80930.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:41852
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753570AbZCNIPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:15:32 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The Tx DMA unit should be disabled when bringing the device down.  Also,
the KX4 device with 82599 supports WoL, so we should clear the Wake Up
Status (WUS) after a PCIe slot reset.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8821c5f..ef0b99a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2558,6 +2558,11 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j),
 		                (txdctl & ~IXGBE_TXDCTL_ENABLE));
 	}
+	/* Disable the Tx DMA engine on 82599 */
+	if (hw->mac.type == ixgbe_mac_82599EB)
+		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL,
+		                (IXGBE_READ_REG(hw, IXGBE_DMATXCTL) &
+		                 ~IXGBE_DMATXCTL_TE));
 
 	netif_carrier_off(netdev);
 
@@ -4795,7 +4800,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 
 		ixgbe_reset(adapter);
-
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_WUS, ~0);
 		result = PCI_ERS_RESULT_RECOVERED;
 	}
 

