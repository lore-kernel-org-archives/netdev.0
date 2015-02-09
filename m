From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40evf: stop the watchdog for shutdown
Date: Mon,  9 Feb 2015 02:43:54 -0800
Message-ID: <1423478641-3138-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38701 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760568AbbBIKoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:06 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Stop the watchdog during shutdown. Failing to do this causes a log full
of admin queue errors and the occasional hang when the system is shut
down.

Change-ID: Ib2fd11213cca2fa589eb68577e86b1000c23c250
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 38126f5..8d8c201 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2213,12 +2213,18 @@ err:
 static void i40evf_shutdown(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev))
 		i40evf_close(netdev);
 
+	/* Prevent the watchdog from running. */
+	adapter->state = __I40EVF_REMOVE;
+	adapter->aq_required = 0;
+	adapter->aq_pending = 0;
+
 #ifdef CONFIG_PM
 	pci_save_state(pdev);
 
-- 
1.9.3
