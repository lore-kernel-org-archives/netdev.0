From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'r8169-for-jeff-20070919' branch
Date: Wed, 19 Sep 2007 21:56:06 +0200
Message-ID: <20070919195606.GA3871@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	David Gundersen <gundy@iinet.net.au>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Sylvain Le Gall <sylvain@le-gall.net>,
	Roel.Teuwen@advalvas.be
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54361 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbXIST7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 15:59:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'r8169-for-jeff-20070919' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169-for-jeff-20070919

to get the fixes below.

Distance from 'linux-2.6.git' (a88a8eff1e6e32d3288986a9d36c6a449c032d3a)
------------------------------------------------------------------------

d78ae2dcc2acebb9a1048278f47f762c069db75c
65d916d95314566f426cc40ff0f17b754a773b0b

Diffstat
--------

 drivers/net/r8169.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

Shortlog
--------

Edward Hsu (1):
      r8169: correct phy parameters for the 8110SC

Francois Romieu (1):
      r8169: workaround against ignored TxPoll writes (8168)

Patch
-----

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
