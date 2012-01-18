From: Dean Nelson <dnelson@redhat.com>
Subject: [PATCH net-next] e1000: add dropped DMA receive enable back in for WoL
Date: Wed, 18 Jan 2012 10:46:34 -0500
Message-ID: <20120118154633.10215.19965.email-sent-by-dnelson@aqua>
Content-Type: text/x-diff; charset=us-ascii
Cc: Tobias Klausmann <klausman@schwarzvogel.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757959Ab2ARPqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 10:46:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d5bc77a223b0e9b9dfb002048d2b34a79e7d0b48 broke Wake-on-LAN by
inadvertently dropping the enabling of DMA receives.

Restore the enabling of DMA receives for WoL.

Reported-by: Tobias Klausmann <klausman@schwarzvogel.de>
Signed-off-by: Dean Nelson <dnelson@redhat.com>
Tested-by: Tobias Klausmann <klausman@schwarzvogel.de>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 669ca38..a855982 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4740,12 +4740,14 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		e1000_setup_rctl(adapter);
 		e1000_set_rx_mode(netdev);
 
+		rctl = er32(RCTL);
+
 		/* turn on all-multi mode if wake on multicast is enabled */
-		if (wufc & E1000_WUFC_MC) {
-			rctl = er32(RCTL);
+		if (wufc & E1000_WUFC_MC)
 			rctl |= E1000_RCTL_MPE;
-			ew32(RCTL, rctl);
-		}
+
+		/* enable receives in the hardware */
+		ew32(RCTL, rctl | E1000_RCTL_EN);
 
 		if (hw->mac_type >= e1000_82540) {
 			ctrl = er32(CTRL);
