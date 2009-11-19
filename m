From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/6] e1000e: set flow control thresholds properly
	after enabling/disabling pause
Date: Thu, 19 Nov 2009 14:35:08 -0800
Message-ID: <20091119223508.29164.18162.stgit@localhost.localdomain>
References: <20091119223406.29164.22513.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:44867 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757395AbZKSWfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 17:35:18 -0500
In-Reply-To: <20091119223406.29164.22513.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When flow control (pause) parameters were changed via ethtool (i.e. enabled
or disabled), the newly calculated thresholds were not being written to the
device for non-fiber media.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 1bf4d2a..e82638e 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -327,10 +327,18 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 
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

