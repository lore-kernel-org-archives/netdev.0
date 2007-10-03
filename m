From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: revert part of
	6dccd16b7c2703e8bbf8bca62b5cf248332afbe2
Date: Thu, 4 Oct 2007 00:42:50 +0200
Message-ID: <20071003224250.GA22366@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeti@welho.com,
	David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46634 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758517AbXJCWvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 18:51:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 8169/8110SC currently announces itself as:
[...]
eth0: RTL8169sc/8110sc at 0x........, ..:..:..:..:..:.., XID 18000000 IRQ ..
                                                             ^^^^^^^^
It uses RTL_GIGA_MAC_VER_05 and this part of the changeset can cut
its performance by a factor of 2~2.5 as reported by Timo.

(the driver includes code just before the hunk to write the ChipCmd
register when mac_version == RTL_GIGA_MAC_VER_0[1-4])

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Timo Jantunen <jeti@welho.com>
---
 drivers/net/r8169.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c921ec3..c76dd29 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1918,7 +1918,11 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	rtl_set_rx_max_size(ioaddr);
 
-	rtl_set_rx_tx_config_registers(tp);
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
+		rtl_set_rx_tx_config_registers(tp);
 
 	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
 
@@ -1941,6 +1945,14 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
+	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
+	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
+	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
+	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
+		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+		rtl_set_rx_tx_config_registers(tp);
+	}
+
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	/* Initially a 10 us delay. Turned it into a PCI commit. - FR */
@@ -1955,8 +1967,6 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	/* Enable all known interrupts by setting the interrupt mask. */
 	RTL_W16(IntrMask, tp->intr_event);
-
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
-- 
1.5.3.2

