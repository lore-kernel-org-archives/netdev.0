From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'r8169-for-jeff-20070914' branch
Date: Fri, 14 Sep 2007 22:47:31 +0200
Message-ID: <20070914204731.GA26189@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	David Gundersen <gundy@iinet.net.au>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38542 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754588AbXINUuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 16:50:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'r8169-for-jeff-20070914' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169-for-jeff-20070914

to get the fixes below.

Distance from 'netdev-2.6/upstream' (18d256761aa268fd2fb113c4fd26c400431f1dc1)
------------------------------------------------------------------------------

ec580a20c4bec3a011972a49cf5c20fc4502f9d1
c8e51194b1979d08c43bc2f6cf6087cd3dd93fb6

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
index a2a541d..de6d5fd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1225,7 +1225,10 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
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
@@ -2563,6 +2566,15 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
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
