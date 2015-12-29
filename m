From: <zyjzyj2000@gmail.com>
Subject: [PATCH 2/2] ixgbe: restrict synchronization of link_up and speed
Date: Tue, 29 Dec 2015 10:32:06 +0800
Message-ID: <1451356326-2919-3-git-send-email-zyjzyj2000@gmail.com>
References: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
 <1451356326-2919-1-git-send-email-zyjzyj2000@gmail.com>
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
Received: from mail5.windriver.com ([192.103.53.11]:46171 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037AbbL2CcP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2015 21:32:15 -0500
In-Reply-To: <1451356326-2919-1-git-send-email-zyjzyj2000@gmail.com>
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
