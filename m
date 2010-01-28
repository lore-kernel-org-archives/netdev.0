From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: if ixgbe_copy_dcb_cfg is going to fail
	learn about it early
Date: Wed, 27 Jan 2010 18:38:06 -0800
Message-ID: <20100128023805.19441.23796.stgit@localhost.localdomain>
References: <20100128023717.19441.27328.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:52528
	"EHLO qmta06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755808Ab0A1Ci0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 21:38:26 -0500
In-Reply-To: <20100128023717.19441.27328.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Call ixgbe_copy_dcb_cfg() earlier in the ixgbe_dcbnl_set_all() so that
we can learn if this is going to fail as early as possible.  Previously,
ixgbe_down or ixgbe_close were being called before this check and the
IXGBE_RESETTING bit was being set and cleared.  Worse if this failed
the corresponding ixgbe_up/ndo_open would not called.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 383e799..dd4883f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -341,6 +341,12 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	if (!adapter->dcb_set_bitmap)
 		return DCB_NO_HW_CHG;
 
+	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
+				 adapter->ring_feature[RING_F_DCB].indices);
+
+	if (ret)
+		return DCB_NO_HW_CHG;
+
 	/*
 	 * Only take down the adapter if the configuration change
 	 * requires a reset.
@@ -359,14 +365,6 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		}
 	}
 
-	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
-				 adapter->ring_feature[RING_F_DCB].indices);
-	if (ret) {
-		if (adapter->dcb_set_bitmap & BIT_RESETLINK)
-			clear_bit(__IXGBE_RESETTING, &adapter->state);
-		return DCB_NO_HW_CHG;
-	}
-
 	if (adapter->dcb_cfg.pfc_mode_enable) {
 		if ((adapter->hw.mac.type != ixgbe_mac_82598EB) &&
 			(adapter->hw.fc.current_mode != ixgbe_fc_pfc))

