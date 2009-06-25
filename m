From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH v2 1/2] ucc_geth: Fix half-duplex operation for
	non-MII/RMII interfaces
Date: Thu, 25 Jun 2009 05:02:32 +0400
Message-ID: <20090625010232.GA28590@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:6627 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752203AbZFYBDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 21:03:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the half-duplex operation seems to not work reliably for
RGMII PHY interfaces. It takes about 10 minutes to boot NFS rootfs
using 10/half link, following symptoms were observed:

  ucc_geth: QE UCC Gigabit Ethernet Controller
  ucc_geth: UCC1 at 0xe0082000 (irq = 32)
  [...]
  Sending DHCP and RARP requests .
  PHY: mdio@e0082120:07 - Link is Up - 10/Half
  ., OK
  [...]
  Looking up port of RPC 100003/2 on 10.0.0.2
  Looking up port of RPC 100005/1 on 10.0.0.2
  VFS: Mounted root (nfs filesystem) readonly on device 0:13.
  Freeing unused kernel memory: 204k init
  eth0: no IPv6 routers present
  nfs: server 10.0.0.2 not responding, still trying
  nfs: server 10.0.0.2 not responding, still trying
  nfs: server 10.0.0.2 not responding, still trying
  nfs: server 10.0.0.2 OK
  nfs: server 10.0.0.2 OK
  nfs: server 10.0.0.2 not responding, still trying
  [... few minutes of OK/not responding flood ...]

The statistic shows that there are indeed some errors:

  # ethtool -S eth0 | grep -v ": 0"
  NIC statistics:
       tx-64-frames: 42
       tx-65-127-frames: 9
       tx-128-255-frames: 4768
       rx-64-frames: 41
       rx-65-127-frames: 260
       rx-128-255-frames: 2679
       tx-bytes-ok: 859634
       tx-multicast-frames: 5
       tx-broadcast-frames: 7
       rx-frames: 8333
       rx-bytes-ok: 8039364
       rx-bytes-all: 8039364
       stats-counter-mask: 4294901760
       tx-single-collision: 324
       tx-multiple-collision: 47
       tx-late-collsion: 604
       tx-aborted-frames: 604
       tx-frames-ok: 4967
       tx-256-511-frames: 3
       tx-512-1023-frames: 79
       tx-1024-1518-frames: 71
       rx-256-511-frames: 37
       rx-512-1023-frames: 73
       rx-1024-1518-frames: 5243

According to current QEIWRM (Rev. 2 5/2009), FDX bit can be 0 for
RGMII(10/100) modes, while MPC8568ERM (Rev. C 02/2007) spec says
that cleared FDX bit is permitted for MII/RMII modes only.

The symptoms above were seen on MPC8569E-MDS boards, so QEIWRM is
clearly wrong, and this patch completely cures the problems above.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 464df03..0c26a59 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1469,12 +1469,18 @@ static void adjust_link(struct net_device *dev)
 	if (phydev->link) {
 		u32 tempval = in_be32(&ug_regs->maccfg2);
 		u32 upsmr = in_be32(&uf_regs->upsmr);
+		phy_interface_t phyi = ugeth->phy_interface;
+
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != ugeth->oldduplex) {
 			new_state = 1;
-			if (!(phydev->duplex))
-				tempval &= ~(MACCFG2_FDX);
+			if (!phydev->duplex &&
+					(phyi == PHY_INTERFACE_MODE_MII ||
+					 phyi == PHY_INTERFACE_MODE_RMII ||
+					 (phyi == PHY_INTERFACE_MODE_GMII &&
+					  phydev->speed < 1000)))
+				tempval &= ~MACCFG2_FDX;
 			else
 				tempval |= MACCFG2_FDX;
 			ugeth->oldduplex = phydev->duplex;
-- 
1.6.3.1

