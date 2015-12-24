From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] ixgbe: force to synchronize reporting "link on" and getting speed
Date: Thu, 24 Dec 2015 11:12:32 +0800
Message-ID: <1450926752-11392-2-git-send-email-zyjzyj2000@gmail.com>
References: <1450868046.3316.11.camel@intel.com>
 <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
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
Received: from mail5.windriver.com ([192.103.53.11]:50544 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243AbbLXDMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 22:12:34 -0500
In-Reply-To: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yzhu1 <yzhu1@windriver.com>

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

Signed-off-by: yzhu1 <yzhu1@windriver.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index aed8d02..2b58a33 100644
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
