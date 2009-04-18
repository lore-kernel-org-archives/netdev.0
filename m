From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/5] ixgbe: fix link down initial state
Date: Fri, 17 Apr 2009 23:44:27 -0700
Message-ID: <20090418064427.4328.45811.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:60639
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751053AbZDRGo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 02:44:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As reported by Andrew Lutomirski <amluto@gmail.com>

All the intel wired ethernet drivers were calling netif_carrier_off
and netif_stop_queue (or variants) before calling register_netdevice

This is incorrect behavior as was pointed out by davem, and causes
ifconfig and friends to report a strange state before first link
after the driver was loaded, since without a netif_carrier_off, the stack
assumes carrier_on, but before register_netdev, netlink messages are not
sent out telling link state.

This apparently confused *some* versions of networkmanager.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reported-by: Andrew Lutomirski <amluto@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0d9a3ac..d5d9589 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3459,6 +3459,8 @@ static int ixgbe_open(struct net_device *netdev)
 	if (test_bit(__IXGBE_TESTING, &adapter->state))
 		return -EBUSY;
 
+	netif_carrier_off(netdev);
+
 	/* allocate transmit descriptors */
 	err = ixgbe_setup_all_tx_resources(adapter);
 	if (err)
@@ -4772,13 +4774,14 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* reset the hardware with the new settings */
 	hw->mac.ops.start_hw(hw);
 
-	netif_carrier_off(netdev);
-
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
 		goto err_register;
 
+	/* carrier off reporting is important to ethtool even BEFORE open */
+	netif_carrier_off(netdev);
+
 #ifdef CONFIG_IXGBE_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;

