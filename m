From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] gianfar: Fix half-duplex operation for non-MII/RMII
	interfaces
Date: Wed, 24 Jun 2009 22:27:34 +0400
Message-ID: <20090624182734.GA14306@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:5921 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751633AbZFXS2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 14:28:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that gianfar driver has the same problem[1] that I
just fixed for ucc_geth.

NFS boot using 10/half link takes about 10 minutes to complete:

  eth0: Gianfar Ethernet Controller Version 1.2, 00:11:22:33:44:55
  eth0: Running with NAPI enabled
  eth0: 256/256 RX/TX BD ring size
  [...]
  Sending DHCP requests .
  PHY: mdio@e0024520:02 - Link is Up - 10/Half
  ., OK
  [...]
  Looking up port of RPC 100003/2 on 10.0.0.2
  Looking up port of RPC 100005/1 on 10.0.0.2
  VFS: Mounted root (nfs filesystem) readonly on device 0:11.
  Freeing unused kernel memory: 188k init
  nfs: server 10.0.0.2 not responding, still trying
  nfs: server 10.0.0.2 OK
  nfs: server 10.0.0.2 not responding, still trying
  nfs: server 10.0.0.2 not responding, still trying
  nfs: server 10.0.0.2 not responding, still trying
  [... few minutes of OK/not responding flood ...]

And just as with ucc_geth, statistic shows errors:

  # ethtool -S eth0 | grep -v ": 0"
  NIC statistics:
       rx-dropped-by-kernel: 2
       tx-rx-64-frames: 49
       tx-rx-65-127-frames: 1270
       tx-rx-128-255-frames: 9992
       tx-rx-256-511-frames: 75
       tx-rx-512-1023-frames: 142
       tx-rx-1024-1518-frames: 8828
       rx-bytes: 13299414
       rx-packets: 13122
       rx-jabber-frames: 9
       tx-byte-counter: 1284847
       tx-packets: 8115
       tx-broadcast-packets: 3
       tx-deferral-packets: 43
       tx-single-collision-packets: 15
       tx-multiple-collision-packets: 301
       tx-late-collision-packets: 872
       tx-total-collision: 999
       tx-undersize-frames: 6

The symptoms were observed on MPC8379E-RDB boards (eTSEC). Although
I didn't find where documentation forbids clearing Full Duplex bit
for non-MII/RMII modes, it's pretty distinct that the bit should be
set.

It's no wonder though, QE Ethernet and TSEC are pretty similar.

[1] http://lists.ozlabs.org/pipermail/linuxppc-dev/2009-June/073631.html

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 8741bb0..15dbffa 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1984,13 +1984,16 @@ static void adjust_link(struct net_device *dev)
 	if (phydev->link) {
 		u32 tempval = gfar_read(&regs->maccfg2);
 		u32 ecntrl = gfar_read(&regs->ecntrl);
+		phy_interface_t phyi = phydev->interface;
 
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = 1;
-			if (!(phydev->duplex))
-				tempval &= ~(MACCFG2_FULL_DUPLEX);
+			if (!phydev->duplex &&
+					(phyi == PHY_INTERFACE_MODE_MII ||
+					 phyi == PHY_INTERFACE_MODE_RMII))
+				tempval &= ~MACCFG2_FULL_DUPLEX;
 			else
 				tempval |= MACCFG2_FULL_DUPLEX;
 
-- 
1.6.3.1
