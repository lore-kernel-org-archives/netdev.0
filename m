From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] e1000e: WoL does not work on 82577/82578 with
	manageability enabled
Date: Fri, 14 Aug 2009 17:35:33 -0700
Message-ID: <20090815003524.2335.3107.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:46252
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754157AbZHOAft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 20:35:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

With manageability (Intel AMT) enabled via BIOS, PHY wakeup does not get
configured on newer parts which use PHY wakeup vs. MAC wakeup which causes
WoL to not work.  The driver should configure PHY wakeup whether or not
manageability is enabled.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 63415bb..58e22fc 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4538,8 +4538,7 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		/* Allow time for pending master requests to run */
 		e1000e_disable_pcie_master(&adapter->hw);
 
-		if ((adapter->flags2 & FLAG2_HAS_PHY_WAKEUP) &&
-		    !(hw->mac.ops.check_mng_mode(hw))) {
+		if (adapter->flags2 & FLAG2_HAS_PHY_WAKEUP) {
 			/* enable wakeup by the PHY */
 			retval = e1000_init_phy_wakeup(adapter, wufc);
 			if (retval)
@@ -4557,7 +4556,8 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	*enable_wake = !!wufc;
 
 	/* make sure adapter isn't asleep if manageability is enabled */
-	if (adapter->flags & FLAG_MNG_PT_ENABLED)
+	if ((adapter->flags & FLAG_MNG_PT_ENABLED) ||
+	    (hw->mac.ops.check_mng_mode(hw)))
 		*enable_wake = true;
 
 	if (adapter->hw.phy.type == e1000_phy_igp_3)

