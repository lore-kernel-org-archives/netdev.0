From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 5/6] e1000e: delay second read of PHY_STATUS register
	on failure of first read
Date: Wed, 01 Jul 2009 16:28:50 -0700
Message-ID: <20090701232850.20555.69711.stgit@localhost.localdomain>
References: <20090701232731.20555.63487.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:54430 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752640AbZGAX3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 19:29:03 -0400
In-Reply-To: <20090701232731.20555.63487.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Some PHYs may require two reads of the PHY_STATUS register to determine the
link status.  If the PHY is being accessed by another thread it is possible
the first read could timeout and fail.  In this case, put a delay in so
the second read will pick up the correct link status.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/phy.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index d845394..994401f 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1531,7 +1531,12 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 		 */
 		ret_val = e1e_rphy(hw, PHY_STATUS, &phy_status);
 		if (ret_val)
-			break;
+			/*
+			 * If the first read fails, another entity may have
+			 * ownership of the resources, wait and try again to
+			 * see if they have relinquished the resources yet.
+			 */
+			udelay(usec_interval);
 		ret_val = e1e_rphy(hw, PHY_STATUS, &phy_status);
 		if (ret_val)
 			break;

