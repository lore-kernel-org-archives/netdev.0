From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] i40evf: add MAC address filter in open, not init
Date: Mon, 13 Jul 2015 02:08:34 -0700
Message-ID: <1436778517-16254-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28267 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbbGMJIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 05:08:48 -0400
In-Reply-To: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

During close, all of the MAC filters are cleared, so the driver would be
unable to receive unicast packets after being closed and reopened.

Add the adapter's "hardware" MAC address filter in open, not init. This
ensures that the correct filter is present each time.

Change-ID: I51a11e9c1200139dab6f66a5353bd38c7d26f875
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 07f6052..526cc8d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1858,6 +1858,7 @@ static int i40evf_open(struct net_device *netdev)
 	if (err)
 		goto err_req_irq;
 
+	i40evf_add_filter(adapter, adapter->hw.mac.addr);
 	i40evf_configure(adapter);
 
 	err = i40evf_up_complete(adapter);
@@ -1998,7 +1999,6 @@ static void i40evf_init_task(struct work_struct *work)
 						      struct i40evf_adapter,
 						      init_task.work);
 	struct net_device *netdev = adapter->netdev;
-	struct i40evf_mac_filter *f;
 	struct i40e_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	int i, err, bufsz;
@@ -2132,16 +2132,6 @@ static void i40evf_init_task(struct work_struct *work)
 	ether_addr_copy(netdev->dev_addr, adapter->hw.mac.addr);
 	ether_addr_copy(netdev->perm_addr, adapter->hw.mac.addr);
 
-	f = kzalloc(sizeof(*f), GFP_ATOMIC);
-	if (!f)
-		goto err_sw_init;
-
-	ether_addr_copy(f->macaddr, adapter->hw.mac.addr);
-	f->add = true;
-	adapter->aq_required |= I40EVF_FLAG_AQ_ADD_MAC_FILTER;
-
-	list_add(&f->list, &adapter->mac_filter_list);
-
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &i40evf_watchdog_timer;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
-- 
2.4.3
