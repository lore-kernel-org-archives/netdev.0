From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/3] ucc_geth: Don't needlessly change MAC settings in
 adjust_link()
Date: Thu, 24 Dec 2009 18:31:20 +0300
Message-ID: <20091224153120.GC1206@oksana.dev.rtsoft.ru>
References: <20091224153034.GA32535@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:50372 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756191AbZLXPbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 10:31:22 -0500
Content-Disposition: inline
In-Reply-To: <20091224153034.GA32535@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If PHY doesn't have an IRQ, phylib would poll for link changes, and
would call adjust_link() every second. In that case we disable and
enable the controller every second.

Let's better check if there is actually anything changed, and, if so,
change the MAC settings.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 7fff4c5..41ad2f3 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1651,25 +1651,28 @@ static void adjust_link(struct net_device *dev)
 			ugeth->oldspeed = phydev->speed;
 		}
 
-		/*
-		 * To change the MAC configuration we need to disable the
-		 * controller. To do so, we have to either grab ugeth->lock,
-		 * which is a bad idea since 'graceful stop' commands might
-		 * take quite a while, or we can quiesce driver's activity.
-		 */
-		ugeth_quiesce(ugeth);
-		ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
-
-		out_be32(&ug_regs->maccfg2, tempval);
-		out_be32(&uf_regs->upsmr, upsmr);
-
-		ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
-		ugeth_activate(ugeth);
-
 		if (!ugeth->oldlink) {
 			new_state = 1;
 			ugeth->oldlink = 1;
 		}
+
+		if (new_state) {
+			/*
+			 * To change the MAC configuration we need to disable
+			 * the controller. To do so, we have to either grab
+			 * ugeth->lock, which is a bad idea since 'graceful
+			 * stop' commands might take quite a while, or we can
+			 * quiesce driver's activity.
+			 */
+			ugeth_quiesce(ugeth);
+			ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
+
+			out_be32(&ug_regs->maccfg2, tempval);
+			out_be32(&uf_regs->upsmr, upsmr);
+
+			ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
+			ugeth_activate(ugeth);
+		}
 	} else if (ugeth->oldlink) {
 			new_state = 1;
 			ugeth->oldlink = 0;
-- 
1.6.3.3
