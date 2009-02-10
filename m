From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/4] e1000e: Disable dynamic clock gating for 82571
	per si errata.
Date: Tue, 10 Feb 2009 14:51:41 -0800
Message-ID: <20090210225141.32208.12725.stgit@lost.foo-projects.org>
References: <20090210225116.32208.78338.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	dave graham <david.graham@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:49695 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754749AbZBJWwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 17:52:07 -0500
In-Reply-To: <20090210225116.32208.78338.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dave graham <david.graham@intel.com>

82571 and 82572 Errata #13 documents that the Si feature DMA Dynamic
Clock Gating should be disabled, and identifies the workaround of
disabling the feature by EEPROM setting. EEPROM versions that do not
include the recommended workaround have been found in the field, and so
some customers remain at risk. Because the feature DMA Dynamic clock
Gating can be disabled by directly setting the appropriate bit in the
E1000_CTRL_EXT register, this patch overrides the EEPROM setting, and
force-disables the feature.

Signed-off-by: dave graham <david.graham@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |   12 ++++++++++++
 drivers/net/e1000e/defines.h |    1 +
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 0890162..25f6bc9 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -980,6 +980,18 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 		reg |= E1000_PBA_ECC_CORR_EN;
 		ew32(PBA_ECC, reg);
 	}
+	/*
+	 * Workaround for hardware errata.
+	 * Ensure that DMA Dynamic Clock gating is disabled on 82571 and 82572
+	 */
+
+        if ((hw->mac.type == e1000_82571) ||
+           (hw->mac.type == e1000_82572)) {
+                reg = er32(CTRL_EXT);
+                reg &= ~E1000_CTRL_EXT_DMA_DYN_CLK_EN;
+                ew32(CTRL_EXT, reg);
+        }
+
 
 	/* PCI-Ex Control Registers */
 	if (hw->mac.type == e1000_82574) {
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index e6caf29..243aa49 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -69,6 +69,7 @@
 #define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Definable Pin 7 */
 #define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
 #define E1000_CTRL_EXT_RO_DIS    0x00020000 /* Relaxed Ordering disable */
+#define E1000_CTRL_EXT_DMA_DYN_CLK_EN 0x00080000 /* DMA Dynamic Clock Gating */
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
 #define E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
 #define E1000_CTRL_EXT_EIAME          0x01000000

