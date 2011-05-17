From: prasanna.panchamukhi@riverbed.com
Subject: [PATCH] e100: Fix race condition in e100_down() while testing
Date: Tue, 17 May 2011 15:20:25 -0700
Message-ID: <1305670825-13603-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	prasanna.panchamukhi@riverbed.com
To: bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.riverbed.com ([208.70.196.44]:61327 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756583Ab1EQWUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 18:20:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race condition between e100_down() and e100_diag_test().
During device testing e100_diag_test() ends up calling e100_up()/e100_down()
even while the driver is already in e100_down().
This patch fixes the above race condition by changing
e100_up()/e100_down() to dev_open() and dev_close().
Also fixes the race between e100_open() and e100_diag_test().

Signed-off-by: Prasanna S. Panchamukh <prasanna.panchamukhi@riverbed.com>
---
 drivers/net/e100.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index b0aa9e6..abbf229 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -425,6 +425,10 @@ enum cb_command {
 	cb_el     = 0x8000,
 };
 
+enum e100_state_t {
+	__E100_TESTING
+};
+
 struct rfd {
 	__le16 status;
 	__le16 command;
@@ -623,6 +627,7 @@ struct nic {
 	__le16 eeprom[256];
 	spinlock_t mdio_lock;
 	const struct firmware *fw;
+	unsigned long state;
 };
 
 static inline void e100_write_flush(struct nic *nic)
@@ -2570,8 +2575,10 @@ static void e100_diag_test(struct net_device *netdev,
 {
 	struct ethtool_cmd cmd;
 	struct nic *nic = netdev_priv(netdev);
+	int if_running = netif_running(netdev);
 	int i, err;
 
+	set_bit(__E100_TESTING, &nic->state);
 	memset(data, 0, E100_TEST_LEN * sizeof(u64));
 	data[0] = !mii_link_ok(&nic->mii);
 	data[1] = e100_eeprom_load(nic);
@@ -2580,8 +2587,9 @@ static void e100_diag_test(struct net_device *netdev,
 		/* save speed, duplex & autoneg settings */
 		err = mii_ethtool_gset(&nic->mii, &cmd);
 
-		if (netif_running(netdev))
-			e100_down(nic);
+		if (if_running)
+			/* indicate we're in test mode */
+			dev_open(netdev);
 		data[2] = e100_self_test(nic);
 		data[3] = e100_loopback_test(nic, lb_mac);
 		data[4] = e100_loopback_test(nic, lb_phy);
@@ -2589,12 +2597,13 @@ static void e100_diag_test(struct net_device *netdev,
 		/* restore speed, duplex & autoneg settings */
 		err = mii_ethtool_sset(&nic->mii, &cmd);
 
-		if (netif_running(netdev))
-			e100_up(nic);
+		if (if_running)
+			dev_open(netdev);
 	}
 	for (i = 0; i < E100_TEST_LEN; i++)
 		test->flags |= data[i] ? ETH_TEST_FL_FAILED : 0;
 
+	clear_bit(__E100_TESTING, &nic->state);
 	msleep_interruptible(4 * 1000);
 }
 
@@ -2724,6 +2733,10 @@ static int e100_open(struct net_device *netdev)
 	struct nic *nic = netdev_priv(netdev);
 	int err = 0;
 
+	/* disallow open during testing */
+	if (test_bit(__E100_TESTING, &nic->state))
+		return -EBUSY;
+
 	netif_carrier_off(netdev);
 	if ((err = e100_up(nic)))
 		netif_err(nic, ifup, nic->netdev, "Cannot open interface, aborting\n");
-- 
1.7.0.4

