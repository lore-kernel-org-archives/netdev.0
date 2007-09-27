From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RTL8111 PCI Express Gigabit driver r8169 produces slow file transfers
Date: Thu, 27 Sep 2007 19:24:22 +0200
Message-ID: <20070927172422.GA4869@electric-eye.fr.zoreil.com>
References: <1190898841.7919.14.camel@BeeB1t>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Achim Frase <achim.frase@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44204 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756408AbXI0RZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 13:25:05 -0400
Content-Disposition: inline
In-Reply-To: <1190898841.7919.14.camel@BeeB1t>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Achim Frase <achim.frase@googlemail.com> :
> [...]
> but I hope you could help me.

Yes. Please try any of:
- current 2.6.23-git
- 2.6.23-rc8 + patch below

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b85ab4a..c921ec3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1228,7 +1228,10 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 		return;
 	}
 
-	/* phy config for RTL8169s mac_version C chip */
+	if ((tp->mac_version != RTL_GIGA_MAC_VER_02) &&
+	    (tp->mac_version != RTL_GIGA_MAC_VER_03))
+		return;
+
 	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
 	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
 	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
@@ -2567,6 +2570,15 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
+		/*
+		 * 8168 hack: TxPoll requests are lost when the Tx packets are
+		 * too close. Let's kick an extra TxPoll request when a burst
+		 * of start_xmit activity is detected (if it is not detected,
+		 * it is slow enough). -- FR
+		 */
+		smp_rmb();
+		if (tp->cur_tx != dirty_tx)
+			RTL_W8(TxPoll, NPQ);
 	}
 }
 
-- 
Ueimor
