From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] ixgbe: fix panic when shutting down system with
	WoL enabled
Date: Tue, 29 Jun 2010 21:28:12 -0700
Message-ID: <20100630042739.8925.24962.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:33368
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750978Ab0F3E2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 00:28:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

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
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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

