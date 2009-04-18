From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/5] igb: fix link down inital state
Date: Fri, 17 Apr 2009 23:44:32 -0700
Message-ID: <20090418064431.4328.77058.stgit@localhost.localdomain>
References: <20090418064427.4328.45811.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:49572 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753561AbZDRGoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 02:44:34 -0400
In-Reply-To: <20090418064427.4328.45811.stgit@localhost.localdomain>
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

 drivers/net/igb/igb_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 08c8014..ceaa585 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1442,15 +1442,14 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	 * driver. */
 	igb_get_hw_control(adapter);
 
-	/* tell the stack to leave us alone until igb_open() is called */
-	netif_carrier_off(netdev);
-	netif_tx_stop_all_queues(netdev);
-
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
 		goto err_register;
 
+	/* carrier off reporting is important to ethtool even BEFORE open */
+	netif_carrier_off(netdev);
+
 #ifdef CONFIG_IGB_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IGB_FLAG_DCA_ENABLED;
@@ -1699,6 +1698,8 @@ static int igb_open(struct net_device *netdev)
 	if (test_bit(__IGB_TESTING, &adapter->state))
 		return -EBUSY;
 
+	netif_carrier_off(netdev);
+
 	/* allocate transmit descriptors */
 	err = igb_setup_all_tx_resources(adapter);
 	if (err)

