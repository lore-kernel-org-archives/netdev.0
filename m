From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-2.6] ixgbe: fix panic when shutting down system with
	WoL enabled
Date: Wed, 16 Jun 2010 16:01:03 -0400
Message-ID: <20100616200102.GP7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976Ab0FPUBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 16:01:05 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o5GK1426025142
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 16:01:04 -0400
Received: from gospo.usersys.redhat.com (gospo.rdu.redhat.com [10.11.228.52])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id o5GK137x029694
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 16:01:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch added to 2.6.34:

	commit 5f6c01819979afbfec7e0b15fe52371b8eed87e8
	Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
	Date:   Wed Apr 14 16:04:23 2010 -0700

	    ixgbe: fix bug with vlan strip in promsic mode

among other things added a function called ixgbe_vlan_filter_enable.
This new function wants to access and set some rx_ring parameters, but
adapter->rx_ring has already been freed.  This simply moves the free
until after the access and makes __ixgbe_shutdown look more like
ixgbe_remove.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/ixgbe/ixgbe_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ce30c62..e237748 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5195,7 +5195,6 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		ixgbe_free_all_tx_resources(adapter);
 		ixgbe_free_all_rx_resources(adapter);
 	}
-	ixgbe_clear_interrupt_scheme(adapter);
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
@@ -5230,6 +5229,8 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 	*enable_wake = !!wufc;
 
+	ixgbe_clear_interrupt_scheme(adapter);
+
 	ixgbe_release_hw_control(adapter);
 
 	pci_disable_device(pdev);
-- 
1.6.2.5

