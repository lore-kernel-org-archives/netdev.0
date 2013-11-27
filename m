From: David Chang <dchang@suse.com>
Subject: [PATCH net] r8169: check ALDPS bit and disable it if enabled for the 8168g
Date: Wed, 27 Nov 2013 15:48:36 +0800
Message-ID: <1385538516-32104-1-git-send-email-dchang@suse.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>, jlee@suse.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:47363 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab3K0IKB (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:0:0>);
	Wed, 27 Nov 2013 03:10:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Windows driver will enable ALDPS function, but linux driver and firmware
do not have any configuration related to ALDPS function for 8168g.
So restart system to linux and remove the NIC cable, LAN enter ALDPS,
then LAN RX will be disabled.

This issue can be easily reproduced on dual boot windows and linux
system with RTL_GIGA_MAC_VER_40 chip.

Realtek said, ALDPS function can be disabled by configuring to PHY,
switch to page 0x0A43, reg0x10 bit2=0.

Signed-off-by: David Chang <dchang@suse.com>
---
 drivers/net/ethernet/realtek/r8169.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7993875..c737f0e 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3465,6 +3465,11 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x14, 0x9065);
 	rtl_writephy(tp, 0x14, 0x1065);
 
+	/* Check ALDPS bit, disable it if enabled */
+	rtl_writephy(tp, 0x1f, 0x0a43);
+	if (rtl_readphy(tp, 0x10) & 0x0004)
+		rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0004);
+
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-- 
1.8.1.4
