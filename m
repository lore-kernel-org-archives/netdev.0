From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] fm10k: Fix error handling in the function fm10k_setup_tc for certain function calls
Date: Thu,  3 Dec 2015 16:29:38 -0800
Message-ID: <1449188994-64940-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Nick <xerofoify@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22000 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753997AbbLDA34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:56 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick <xerofoify@gmail.com>

This fixes the function fm10k_setup_tc to properly check if the
calls to either the function fm10k_init_queueing_scheme or the
function fm10k_mbx_request_irq fail by returning a error code to
signal that the call to either function has failed. Furthermore
if this arises exit immediately from the function fm10k_setup_tc
by returning the returned error code from the failed function call
to signal to the caller that setting up the tc on the device has
failed and the caller needs to handle this failed setup.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 639263d..96364c7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1149,6 +1149,7 @@ static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
 int fm10k_setup_tc(struct net_device *dev, u8 tc)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
+	int err;
 
 	/* Currently only the PF supports priority classes */
 	if (tc && (interface->hw.mac.type != fm10k_mac_pf))
@@ -1173,9 +1174,13 @@ int fm10k_setup_tc(struct net_device *dev, u8 tc)
 	netdev_reset_tc(dev);
 	netdev_set_num_tc(dev, tc);
 
-	fm10k_init_queueing_scheme(interface);
+	err = fm10k_init_queueing_scheme(interface);
+	if (err)
+		return err;
 
-	fm10k_mbx_request_irq(interface);
+	err = fm10k_mbx_request_irq(interface);
+	if (err)
+		return err;
 
 	if (netif_running(dev))
 		fm10k_open(dev);
-- 
2.5.0
