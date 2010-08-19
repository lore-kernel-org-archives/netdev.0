From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 05/20] ixgbe: move configuration of the MTQC
	register into it's own function
Date: Thu, 19 Aug 2010 16:34:50 -0700
Message-ID: <20100819233447.10335.56588.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:56619 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731Ab0HSXfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:35:09 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch moves the configuration of the MTQC register into it's own
function call similar to ixgbe_setup_mrqc.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   73 ++++++++++++++++++++++------------------
 1 files changed, 40 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5d90f69..c4e4207 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2424,6 +2424,45 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	e_info(hw, "Legacy interrupt IVAR setup done\n");
 }
 
+static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 rttdcs;
+	u32 mask;
+
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return;
+
+	/* disable the arbiter while setting MTQC */
+	rttdcs = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
+	rttdcs |= IXGBE_RTTDCS_ARBDIS;
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
+
+	/* set transmit pool layout */
+	mask = (IXGBE_FLAG_SRIOV_ENABLED | IXGBE_FLAG_DCB_ENABLED);
+	switch (adapter->flags & mask) {
+
+	case (IXGBE_FLAG_SRIOV_ENABLED):
+		IXGBE_WRITE_REG(hw, IXGBE_MTQC,
+				(IXGBE_MTQC_VT_ENA | IXGBE_MTQC_64VF));
+		break;
+
+	case (IXGBE_FLAG_DCB_ENABLED):
+		/* We enable 8 traffic classes, DCB only */
+		IXGBE_WRITE_REG(hw, IXGBE_MTQC,
+			      (IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ));
+		break;
+
+	default:
+		IXGBE_WRITE_REG(hw, IXGBE_MTQC, IXGBE_MTQC_64Q_1PB);
+		break;
+	}
+
+	/* re-enable the arbiter */
+	rttdcs &= ~IXGBE_RTTDCS_ARBDIS;
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
+}
+
 /**
  * ixgbe_configure_tx - Configure 8259x Transmit Unit after Reset
  * @adapter: board private structure
@@ -2475,39 +2514,7 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		}
 	}
 
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		u32 rttdcs;
-		u32 mask;
-
-		/* disable the arbiter while setting MTQC */
-		rttdcs = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
-		rttdcs |= IXGBE_RTTDCS_ARBDIS;
-		IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
-
-		/* set transmit pool layout */
-		mask = (IXGBE_FLAG_SRIOV_ENABLED | IXGBE_FLAG_DCB_ENABLED);
-		switch (adapter->flags & mask) {
-
-		case (IXGBE_FLAG_SRIOV_ENABLED):
-			IXGBE_WRITE_REG(hw, IXGBE_MTQC,
-					(IXGBE_MTQC_VT_ENA | IXGBE_MTQC_64VF));
-			break;
-
-		case (IXGBE_FLAG_DCB_ENABLED):
-			/* We enable 8 traffic classes, DCB only */
-			IXGBE_WRITE_REG(hw, IXGBE_MTQC,
-				      (IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ));
-			break;
-
-		default:
-			IXGBE_WRITE_REG(hw, IXGBE_MTQC, IXGBE_MTQC_64Q_1PB);
-			break;
-		}
-
-		/* re-eable the arbiter */
-		rttdcs &= ~IXGBE_RTTDCS_ARBDIS;
-		IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
-	}
+	ixgbe_setup_mtqc(adapter);
 }
 
 #define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT 2

