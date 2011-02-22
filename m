From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 3/3] net/r8169: fix RTL8168DP issue
Date: Tue, 22 Feb 2011 17:26:22 +0800
Message-ID: <1298366782-1508-5-git-send-email-hayeswang@realtek.com>
References: <1298366782-1508-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298366782-1508-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the RTL8111DP turn off the power when DASH is enabled.
Fix RTL_GIGA_MAC_VER_27 don't wait tx finish before reset.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 336ba94..ef2133b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2869,8 +2869,11 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	     (tp->mac_version == RTL_GIGA_MAC_VER_28)) &&
+	    (ocp_read(tp, 0x0f, 0x0010) & 0x00008000)) {
 		return;
+	}
 
 	if (((tp->mac_version == RTL_GIGA_MAC_VER_23) ||
 	     (tp->mac_version == RTL_GIGA_MAC_VER_24)) &&
@@ -2892,6 +2895,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
+	case RTL_GIGA_MAC_VER_27:
+	case RTL_GIGA_MAC_VER_28:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
 	}
@@ -2901,12 +2906,17 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	     (tp->mac_version == RTL_GIGA_MAC_VER_28)) &&
+	    (ocp_read(tp, 0x0f, 0x0010) & 0x00008000)) {
 		return;
+	}
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
+	case RTL_GIGA_MAC_VER_27:
+	case RTL_GIGA_MAC_VER_28:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
 	}
@@ -3319,7 +3329,8 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	/* Disable interrupts */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_28) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28) {
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
 
-- 
1.7.3.2
