From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] ixgbe: force to synchronize reporting "link on" and getting speed and duplex
Date: Wed, 23 Dec 2015 14:46:45 +0800
Message-ID: <1450853205-27133-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <venkat.viswanathan@windriver.com>,
	<Boris.Shteinbock@windriver.com>, <Vincent.Bourg@windriver.com>
To: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<shannon.nelson@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <bruce.w.allan@intel.com>,
	<john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
	<intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52952 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933064AbbLWGqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 01:46:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

In X540 NIC, there is a time span between reporting "link on" and
getting the speed and duplex. To a bonding driver in 802.3ad mode,
this time span will make it not work well if the time span is big
enough. The big time span will make bonding driver change the state of
the slave device to up while the speed and duplex of the slave device
can not be gotten. Later the bonding driver will not have change to
get the speed and duplex of the slave device. The speed and duplex of
the slave device are important to a bonding driver in 802.3ad mode.

To 82599_SFP NIC and other kinds of NICs, this problem does
not exist. As such, it is necessary for X540 to report"link on" when
the link speed is not IXGBE_LINK_SPEED_UNKNOWN.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index aed8d02..cb9d310 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6479,7 +6479,21 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	       (flow_rx ? "RX" :
 	       (flow_tx ? "TX" : "None"))));
 
-	netif_carrier_on(netdev);
+	/*
+	 * In X540 NIC, there is a time span between reporting "link on"
+	 * and getting the speed and duplex. To a bonding driver in 802.3ad
+	 * mode, this time span will make it not work well if the time span
+	 * is big enough. To 82599_SFP NIC and other kinds of NICs, this
+	 * problem does not exist. As such, it is better for X540 to report
+	 * "link on" when the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
+	 */
+	if ((hw->mac.type == ixgbe_mac_X540) &&
+	    (link_speed != IXGBE_LINK_SPEED_UNKNOWN)) {
+		netif_carrier_on(netdev);
+	} else {
+		netif_carrier_on(netdev);
+	}
+
 	ixgbe_check_vf_rate_limit(adapter);
 
 	/* enable transmits */
-- 
1.7.9.5
