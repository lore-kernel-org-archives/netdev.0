From: <zyjzyj2000@gmail.com>
Subject: [PATCH 2/3] ixgbe: restrict synchronization of link_up and speed
Date: Wed, 30 Dec 2015 17:16:34 +0800
Message-ID: <1451466995-19015-3-git-send-email-zyjzyj2000@gmail.com>
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
Received: from mail1.windriver.com ([147.11.146.13]:59986 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbbL3JQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 04:16:44 -0500
In-Reply-To: <1451466995-19015-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@windriver.com>

When the X540 NIC acts as a slave of some virtual NICs, it is very
important to synchronize link_up and link_speed, such as a bonding
driver in 802.3ad mode. When X540 NIC acts as an independent interface,
it is not necessary to synchronize link_up and link_speed. That is,
the time span between link_up and link_speed is acceptable.

Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ace21b9..1bb6056 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6436,8 +6436,15 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	 * time. To X540 NIC, there is a time span between link_up and
 	 * link_speed. As such, only continue if link_up and link_speed are
 	 * ready to X540 NIC.
+	 * The time span between link_up and link_speed is very important
+	 * when the X540 NIC acts as a slave in some virtual NICs, such as
+	 * a bonding driver in 802.3ad mode. When X540 NIC acts as an
+	 * independent interface, it is not necessary to synchronize link_up
+	 * and link_speed.
+	 * In the end, not continue if (X540 NIC && SLAVE && link_speed UNKNOWN)
 	 */
-	if (hw->mac.type == ixgbe_mac_X540)
+	if ((hw->mac.type == ixgbe_mac_X540) &&
+	    (netdev->flags & IFF_SLAVE))
 		if (link_speed == IXGBE_LINK_SPEED_UNKNOWN)
 			return;
 
-- 
1.7.9.5
