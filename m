From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] e1000e: Fix EEE in S5 w/ Runtime PM enabled
Date: Fri, 25 Jul 2014 21:45:21 -0700
Message-ID: <1406349922-9883-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13529 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbaGZEpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:32 -0400
In-Reply-To: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <david.m.ertman@intel.com>

The process of shutting down the system causes a call to the close PM
callback.  The reset in close causes a loss of link, and the resultant
LSC interrupt causes the Runtime PM idle callback to be called.  The
check for link (while link is down) in the idle callback is wiping the
information about the EEE ability of the link partner.  The information is
still gone when the PHY is powered back up in the shutdown flow.  This
causes EEE in S5 to fail when Runtime PM is active.

Save the link partner's EEE ability in the idle callback so that a Runtime
PM event will not cause a loss of this information.

Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index fe3e42a..1ce0d74 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6357,9 +6357,14 @@ static int e1000e_pm_runtime_idle(struct device *dev)
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	u16 eee_lp;
 
-	if (!e1000e_has_link(adapter))
+	eee_lp = adapter->hw.dev_spec.ich8lan.eee_lp_ability;
+
+	if (!e1000e_has_link(adapter)) {
+		adapter->hw.dev_spec.ich8lan.eee_lp_ability = eee_lp;
 		pm_schedule_suspend(dev, 5 * MSEC_PER_SEC);
+	}
 
 	return -EBUSY;
 }
-- 
1.9.3
