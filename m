From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/3] ixgbe: force to synchronize reporting "link on" and getting speed
Date: Wed, 30 Dec 2015 17:16:33 +0800
Message-ID: <1451466995-19015-2-git-send-email-zyjzyj2000@gmail.com>
References: <53C6554C-8692-4EF3-BF5D-7217D2C9FDA0@intel.com>
 <1451466995-19015-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <venkat.viswanathan@windriver.com>,
	<Boris.Shteinbock@windriver.com>, <Vincent.Bourg@windriver.com>
To: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<shannon.nelson@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <bruce.w.allan@intel.com>,
	<john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
	<intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64671 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbbL3JQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 04:16:40 -0500
In-Reply-To: <1451466995-19015-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@windriver.com>

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

Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index aed8d02..ace21b9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6426,6 +6426,21 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	if (netif_carrier_ok(netdev))
 		return;
 
+	/* In X540 NIC, there is a time span between reporting "link on"
+	 * and getting the speed and duplex. To a bonding driver in 802.3ad
+	 * mode, this time span will make it not work well if the time span
+	 * is big enough. To 82599_SFP NIC and other kinds of NICs, this
+	 * problem does not exist. As such, it is better for X540 to report
+	 * "link on" when the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
+	 * To other NICs, the link_up and link_speed are gotten at the same
+	 * time. To X540 NIC, there is a time span between link_up and
+	 * link_speed. As such, only continue if link_up and link_speed are
+	 * ready to X540 NIC.
+	 */
+	if (hw->mac.type == ixgbe_mac_X540)
+		if (link_speed == IXGBE_LINK_SPEED_UNKNOWN)
+			return;
+
 	adapter->flags2 &= ~IXGBE_FLAG2_SEARCH_FOR_SFP;
 
 	switch (hw->mac.type) {
-- 
1.7.9.5
