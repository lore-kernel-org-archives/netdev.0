From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000e: flow control doesn't re-enable
Date: Wed, 28 Oct 2009 21:28:30 -0700
Message-ID: <20091029042829.16444.58687.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:42180 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751119AbZJ2EcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 00:32:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When changing flow control (pause) parameters, the flow control thresholds
(i.e. when to send XON/XOFF frames) may not be setup correctly on parts
with copper media.  Call the existing e1000_set_fc_watermarks()
function to set these thresholds.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index a70999b..0364b91 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -335,10 +335,18 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 
 		hw->fc.current_mode = hw->fc.requested_mode;
 
-		retval = ((hw->phy.media_type == e1000_media_type_fiber) ?
-			  hw->mac.ops.setup_link(hw) : e1000e_force_mac_fc(hw));
+		if (hw->phy.media_type == e1000_media_type_fiber) {
+			retval = hw->mac.ops.setup_link(hw);
+			/* implicit goto out */
+		} else {
+			retval = e1000e_force_mac_fc(hw);
+			if (retval)
+				goto out;
+			e1000e_set_fc_watermarks(hw);
+		}
 	}
 
+out:
 	clear_bit(__E1000_RESETTING, &adapter->state);
 	return retval;
 }

