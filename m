From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] e1000e: Driver workaround for IPv6 Header Extension Erratum.
Date: Thu,  3 May 2012 02:56:27 -0700
Message-ID: <1336038992-3144-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64596 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab2ECJ4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:35 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Previously, IPv6 extension header parsing was disabled for all devices
supported by e1000e when using packet split mode. However, as per a
silicon errata, only certain devices need this restriction and will need
to disable IPv6 extension header parsing for all modes.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    8 ++++++++
 drivers/net/ethernet/intel/e1000e/82571.c       |   10 ++++++++++
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |    7 +++++++
 drivers/net/ethernet/intel/e1000e/netdev.c      |    9 +--------
 4 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 66f9877..4dd18a1 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -944,6 +944,14 @@ static void e1000_initialize_hw_bits_80003es2lan(struct e1000_hw *hw)
 	else
 		reg |= (1 << 28);
 	ew32(TARC(1), reg);
+
+	/*
+	 * Disable IPv6 extension header parsing because some malformed
+	 * IPv6 headers can hang the Rx.
+	 */
+	reg = er32(RFCTL);
+	reg |= (E1000_RFCTL_IPV6_EX_DIS | E1000_RFCTL_NEW_IPV6_EXT_DIS);
+	ew32(RFCTL, reg);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 7b02e87..98632f4 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1279,6 +1279,16 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 		ew32(CTRL_EXT, reg);
 	}
 
+	/*
+	 * Disable IPv6 extension header parsing because some malformed
+	 * IPv6 headers can hang the Rx.
+	 */
+	if (hw->mac.type <= e1000_82573) {
+		reg = er32(RFCTL);
+		reg |= (E1000_RFCTL_IPV6_EX_DIS | E1000_RFCTL_NEW_IPV6_EXT_DIS);
+		ew32(RFCTL, reg);
+	}
+
 	/* PCI-Ex Control Registers */
 	switch (hw->mac.type) {
 	case e1000_82574:
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index c58ed26..dfff441 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -3468,6 +3468,13 @@ static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw)
 	 */
 	reg = er32(RFCTL);
 	reg |= (E1000_RFCTL_NFSW_DIS | E1000_RFCTL_NFSR_DIS);
+
+	/*
+	 * Disable IPv6 extension header parsing because some malformed
+	 * IPv6 headers can hang the Rx.
+	 */
+	if (hw->mac.type == e1000_ich8lan)
+		reg |= (E1000_RFCTL_IPV6_EX_DIS | E1000_RFCTL_NEW_IPV6_EXT_DIS);
 	ew32(RFCTL, reg);
 }
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e86b524..ab4505c 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2939,6 +2939,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	/* Enable Extended Status in all Receive Descriptors */
 	rfctl = er32(RFCTL);
 	rfctl |= E1000_RFCTL_EXTEN;
+	ew32(RFCTL, rfctl);
 
 	/*
 	 * 82571 and greater support packet-split where the protocol
@@ -2964,13 +2965,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	if (adapter->rx_ps_pages) {
 		u32 psrctl = 0;
 
-		/*
-		 * disable packet split support for IPv6 extension headers,
-		 * because some malformed IPv6 headers can hang the Rx
-		 */
-		rfctl |= (E1000_RFCTL_IPV6_EX_DIS |
-			  E1000_RFCTL_NEW_IPV6_EXT_DIS);
-
 		/* Enable Packet split descriptors */
 		rctl |= E1000_RCTL_DTYP_PS;
 
@@ -3009,7 +3003,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		 */
 	}
 
-	ew32(RFCTL, rfctl);
 	ew32(RCTL, rctl);
 	/* just started the receive unit, no need to restart */
 	adapter->flags &= ~FLAG_RX_RESTART_NOW;
-- 
1.7.7.6
