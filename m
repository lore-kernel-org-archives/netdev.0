From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/5] ixgb: fix link down initial state
Date: Fri, 17 Apr 2009 23:44:29 -0700
Message-ID: <20090418064429.4328.12425.stgit@localhost.localdomain>
References: <20090418064427.4328.45811.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:47113
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751949AbZDRGob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 02:44:31 -0400
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

in addition this driver appeared to need a netif_start_queue at
the end of open.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reported-by: Andrew Lutomirski <amluto@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 4a0826b..ff741ca 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -471,10 +471,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_register;
 
-	/* we're going to reset, so assume we have no link for now */
-
+	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
 
 	DPRINTK(PROBE, INFO, "Intel(R) PRO/10GbE Network Connection\n");
 	ixgb_check_options(adapter);
@@ -592,6 +590,8 @@ ixgb_open(struct net_device *netdev)
 	if (err)
 		goto err_setup_tx;
 
+	netif_carrier_off(netdev);
+
 	/* allocate receive descriptors */
 
 	err = ixgb_setup_rx_resources(adapter);
@@ -602,6 +602,8 @@ ixgb_open(struct net_device *netdev)
 	if (err)
 		goto err_up;
 
+	netif_start_queue(netdev);
+
 	return 0;
 
 err_up:

