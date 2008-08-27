From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [UPDATED PATCH] ixgbe: fix vlan filtering
Date: Tue, 26 Aug 2008 18:30:04 -0700
Message-ID: <20080827013004.5497.48208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, stable@kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:51130 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbYH0BaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 21:30:06 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2546560wfd.4
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 18:30:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

VLAN filtering is broken, due to reading the incorrect register for the VLAN filtering settings.  Fixed by reading/writing the correct register.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 34bca16..53f41b6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1636,16 +1636,17 @@ static void ixgbe_set_multi(struct net_device *netdev)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct dev_mc_list *mc_ptr;
 	u8 *mta_list;
-	u32 fctrl;
+	u32 fctrl, vlnctrl;
 	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
 
 	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
 
 	if (netdev->flags & IFF_PROMISC) {
 		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
-		fctrl &= ~IXGBE_VLNCTRL_VFE;
+		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
 	} else {
 		if (netdev->flags & IFF_ALLMULTI) {
 			fctrl |= IXGBE_FCTRL_MPE;
@@ -1653,10 +1654,11 @@ static void ixgbe_set_multi(struct net_device *netdev)
 		} else {
 			fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		}
-		fctrl |= IXGBE_VLNCTRL_VFE;
+		vlnctrl |= IXGBE_VLNCTRL_VFE;
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 
 	if (netdev->mc_count) {
 		mta_list = kcalloc(netdev->mc_count, ETH_ALEN, GFP_ATOMIC);

