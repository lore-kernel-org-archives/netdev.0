From: Jeff Garzik <jeff@garzik.org>
Subject: [git patch] net driver fix
Date: Fri, 5 Oct 2007 14:20:56 -0400
Message-ID: <20071005182056.GA17548@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:60446 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755855AbXJESU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 14:20:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix a rather large performance regression.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/r8169.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

Francois Romieu (1):
      r8169: revert part of 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2

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
