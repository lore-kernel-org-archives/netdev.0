From: Corinna Vinschen <vinschen@redhat.com>
Subject: [PATCH v2] r8169: Don't claim WoL works if LanWake flag is not set
Date: Wed,  9 Dec 2015 11:43:46 +0100
Message-ID: <1449657826-4461-1-git-send-email-vinschen@redhat.com>
References: <1449655730-3328-1-git-send-email-vinschen@redhat.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Corinna Vinschen <vinschen@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:35442 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbbLIKnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 05:43:50 -0500
In-Reply-To: <1449655730-3328-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[v2 adds missing text to the patch comment]

The __rtl8169_get_wol function returns the state of the various WoL
method bits (MagicPaket, Unicast, etc.).  While the PMEnable bit is
tested at entry, the function doesn't check the LanWake flag.  Even if
any one of the WoL bits is set, WoL is deactivated as a whole if LanWake
isn't set.  The return value from __rtl8169_get_wol doesn't reflect
that.

Unfortunately BIOS exist (HP T620) which set the MagicPaket bit to 1 but
the LanWake flag to 0 when switching on WoL in the BIOS.  On those machines,
ethtool wrongly claims that WoL via MagicPaket is activated while in fact
it isn't, unless you explicitely called, e.g, `ethtool -s <IF> wol g'.

This patch is supposed to fix this behaviour.  If LanWake is 0, the
function now returns 0.  Thus ethtool correctly reports "Wake-on: d".

The patch is against Dave's net-next tree.


Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 79ef799..813ad2b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1705,6 +1705,10 @@ static u32 __rtl8169_get_wol(struct rtl8169_private *tp)
 	if (!(options & PMEnable))
 		return 0;
 
+	options = RTL_R8(Config5);
+	if (!(options & LanWake))
+		return 0;
+
 	options = RTL_R8(Config3);
 	if (options & LinkUp)
 		wolopts |= WAKE_PHY;
-- 
2.1.0
