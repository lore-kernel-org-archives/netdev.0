From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/3] ucc_geth: Fix hangs after switching from full to half
 duplex
Date: Thu, 10 Sep 2009 06:01:45 +0400
Message-ID: <20090910020145.GC31083@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Timur Tabi <timur@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:26237 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754872AbZIJCBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 22:01:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPC8360 QE UCC ethernet controllers hang when changing link duplex
under a load (a bit of NFS activity is enough).

  PHY: mdio@e0102120:00 - Link is Up - 1000/Full
  sh-3.00# ethtool -s eth0 speed 100 duplex half autoneg off
  PHY: mdio@e0102120:00 - Link is Down
  PHY: mdio@e0102120:00 - Link is Up - 100/Half
  NETDEV WATCHDOG: eth0 (ucc_geth): transmit queue 0 timed out
  ------------[ cut here ]------------
  Badness at c01fcbd0 [verbose debug info unavailable]
  NIP: c01fcbd0 LR: c01fcbd0 CTR: c0194e44
  ...

The cure is to disable the controller before changing speed/duplex
and enable it afterwards.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 2a2c973..9ad9015 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1631,9 +1631,13 @@ static void adjust_link(struct net_device *dev)
 			ugeth->oldspeed = phydev->speed;
 		}
 
+		ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
+
 		out_be32(&ug_regs->maccfg2, tempval);
 		out_be32(&uf_regs->upsmr, upsmr);
 
+		ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
+
 		if (!ugeth->oldlink) {
 			new_state = 1;
 			ugeth->oldlink = 1;
-- 
1.6.3.3
