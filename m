From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH RFC] ixgbe: Module param "allow_any_sfp" for allowing
 unsupported SFP+ modules
Date: Thu, 19 Jan 2012 15:46:45 +0100
Message-ID: <1326984405.2795.91.camel@probook>
References: <1326886258.19261.25.camel@probook>
	 <20120118091351.000052fc@unknown>  <m3d3ag7ki8.fsf@ursa.amorsen.dk>
	 <1326925160.2795.45.camel@probook>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Ben Greear <greearb@candelatech.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>,
	David Lamparter <equinox@diac24.net>,
	Robert Bays <robert@herjulf.net>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:49953 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab2ASOqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 09:46:50 -0500
In-Reply-To: <1326925160.2795.45.camel@probook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Intel are limiting which SFP's can use in their NICs, due to support issues.
This restriction comes from an EEPROM setting IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP.
This is for example the case with the 10Gbit/s X520-DA2 NIC.

Add a module param "allow_any_sfp", which can override the EEPROM
setting, and allows any unsupported SFP+ module to be used.  When
doing so, print disclaimer of unsupported usage.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 7cf1e1f..2ccee6f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -32,6 +32,12 @@
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
+#define ALLOW_ANY_SFP_DEFAULT 0
+static unsigned int allow_any_sfp __read_mostly = ALLOW_ANY_SFP_DEFAULT;
+module_param(allow_any_sfp, uint, 0644);
+MODULE_PARM_DESC(allow_any_sfp,
+		 "Allow any SFP+ module, even if EEPROM disallow it");
+
 static void ixgbe_i2c_start(struct ixgbe_hw *hw);
 static void ixgbe_i2c_stop(struct ixgbe_hw *hw);
 static s32 ixgbe_clock_in_i2c_byte(struct ixgbe_hw *hw, u8 *data);
@@ -844,6 +850,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 	u8 cable_tech = 0;
 	u8 cable_spec = 0;
 	u16 enforce_sfp = 0;
+	struct ixgbe_adapter *adapter = NULL;
 
 	if (hw->mac.ops.get_media_type(hw) != ixgbe_media_type_fiber) {
 		hw->phy.sfp_type = ixgbe_sfp_type_not_present;
@@ -1068,9 +1075,19 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			if (hw->phy.type == ixgbe_phy_sfp_intel) {
 				status = 0;
 			} else {
-				hw_dbg(hw, "SFP+ module not supported\n");
-				hw->phy.type = ixgbe_phy_sfp_unsupported;
-				status = IXGBE_ERR_SFP_NOT_SUPPORTED;
+				adapter = hw->back; /* used by e_dev_err macro*/
+				e_dev_err(
+					"SFP+ module not supported by Intel\n");
+				if (allow_any_sfp) { /* modul param override */
+					e_dev_err(
+					"Continue WITHOUT support, SFP+ module "
+					"vendor OUI:0x%06X (enum phy.type:%d)\n",
+					vendor_oui >> 8, hw->phy.type);
+					status = 0;
+				} else {
+					hw->phy.type = ixgbe_phy_sfp_unsupported;
+					status = IXGBE_ERR_SFP_NOT_SUPPORTED;
+				}
 			}
 		} else {
 			status = 0;
