From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/7] r8169: Config1 is read-only on 8168c and later.
Date: Tue, 17 Apr 2012 12:59:35 +0200
Message-ID: <851e60221926a53344b4227879858bef841b0477.1334660032.git.romieu@fr.zoreil.com>
References: <1334660032.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37859 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754688Ab2DQLE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 07:04:26 -0400
In-Reply-To: <1334660032.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested by Hayes.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 71393ea..9b0b00b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1396,7 +1396,6 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 		u16 reg;
 		u8  mask;
 	} cfg[] = {
-		{ WAKE_ANY,   Config1, PMEnable },
 		{ WAKE_PHY,   Config3, LinkUp },
 		{ WAKE_MAGIC, Config3, MagicPacket },
 		{ WAKE_UCAST, Config5, UWF },
@@ -1404,16 +1403,28 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 		{ WAKE_MCAST, Config5, MWF },
 		{ WAKE_ANY,   Config5, LanWake }
 	};
+	u8 options;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
 	for (i = 0; i < ARRAY_SIZE(cfg); i++) {
-		u8 options = RTL_R8(cfg[i].reg) & ~cfg[i].mask;
+		options = RTL_R8(cfg[i].reg) & ~cfg[i].mask;
 		if (wolopts & cfg[i].opt)
 			options |= cfg[i].mask;
 		RTL_W8(cfg[i].reg, options);
 	}
 
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_01 ... RTL_GIGA_MAC_VER_17:
+		options = RTL_R8(Config1) & ~PMEnable;
+		if (wolopts)
+			options |= PMEnable;
+		RTL_W8(Config1, options);
+		break;
+	default:
+		break;
+	}
+
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 }
 
-- 
1.7.7.6
