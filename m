From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000e: Fix for offline diag test failure at
	first call
Date: Fri, 15 Oct 2010 20:35:31 -0700
Message-ID: <20101016033452.2174.51928.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:34537 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752663Ab0JPDfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 23:35:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Move link test call to later in the offline sequence, move the
restore settings block to afterwards and add another reset to ensure
the hardware is in a known state afterwards.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index b7f15b3..8984d16 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1717,13 +1717,6 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		e_info("offline testing starting\n");
 
-		/*
-		 * Link test performed before hardware reset so autoneg doesn't
-		 * interfere with test result
-		 */
-		if (e1000_link_test(adapter, &data[4]))
-			eth_test->flags |= ETH_TEST_FL_FAILED;
-
 		if (if_running)
 			/* indicate we're in test mode */
 			dev_close(netdev);
@@ -1747,15 +1740,19 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (e1000_loopback_test(adapter, &data[3]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
+		/* force this routine to wait until autoneg complete/timeout */
+		adapter->hw.phy.autoneg_wait_to_complete = 1;
+		e1000e_reset(adapter);
+		adapter->hw.phy.autoneg_wait_to_complete = 0;
+
+		if (e1000_link_test(adapter, &data[4]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
 		/* restore speed, duplex, autoneg settings */
 		adapter->hw.phy.autoneg_advertised = autoneg_advertised;
 		adapter->hw.mac.forced_speed_duplex = forced_speed_duplex;
 		adapter->hw.mac.autoneg = autoneg;
-
-		/* force this routine to wait until autoneg complete/timeout */
-		adapter->hw.phy.autoneg_wait_to_complete = 1;
 		e1000e_reset(adapter);
-		adapter->hw.phy.autoneg_wait_to_complete = 0;
 
 		clear_bit(__E1000_TESTING, &adapter->state);
 		if (if_running)

