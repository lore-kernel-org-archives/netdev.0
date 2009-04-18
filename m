From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/5] e1000e: indicate link down at load
Date: Fri, 17 Apr 2009 23:44:34 -0700
Message-ID: <20090418064433.4328.58288.stgit@localhost.localdomain>
References: <20090418064427.4328.45811.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:60884 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753935AbZDRGog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 02:44:36 -0400
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

Andy tested this for e1000e and confirmed it was working for him.

see thread: http://marc.info/?l=linux-netdev&m=123946479705636&w=2

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andy Lutomirski <amluto@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1693ed1..c0ff550 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3072,6 +3072,8 @@ static int e1000_open(struct net_device *netdev)
 	if (test_bit(__E1000_TESTING, &adapter->state))
 		return -EBUSY;
 
+	netif_carrier_off(netdev);
+
 	/* allocate transmit descriptors */
 	err = e1000e_setup_tx_resources(adapter);
 	if (err)
@@ -5037,15 +5039,14 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (!(adapter->flags & FLAG_HAS_AMT))
 		e1000_get_hw_control(adapter);
 
-	/* tell the stack to leave us alone until e1000_open() is called */
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
 	e1000_print_device_info(adapter);
 
 	return 0;

