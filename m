From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH 2/2] sh_eth: fix wakeup event reporting from MagicPacket
Date: Wed,  1 Feb 2017 15:41:55 +0100
Message-ID: <20170201144155.17123-3-niklas.soderlund+renesas@ragnatech.se>
References: <20170201144155.17123-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:44078 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751103AbdBAOn1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 09:43:27 -0500
In-Reply-To: <20170201144155.17123-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a link change interrupt happens along side the MagicPacket interrupt
and the link change interrupt is ignored the interrupt handler will
return and the wakeup event is not register. Fix this by moving the
MagicPacket check before the link change check.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index f9134c818ac6ef53..54248775f227b062 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1605,6 +1605,8 @@ static void sh_eth_emac_interrupt(struct net_device *ndev)
 	sh_eth_write(ndev, felic_stat, ECSR);	/* clear int */
 	if (felic_stat & ECSR_ICD)
 		ndev->stats.tx_carrier_errors++;
+	if (felic_stat & ECSR_MPD)
+		pm_wakeup_event(&mdp->pdev->dev, 0);
 	if (felic_stat & ECSR_LCHNG) {
 		/* Link Changed */
 		if (mdp->cd->no_psr || mdp->no_ether_link)
@@ -1624,8 +1626,6 @@ static void sh_eth_emac_interrupt(struct net_device *ndev)
 			sh_eth_rcv_snd_enable(ndev);
 		}
 	}
-	if (felic_stat & ECSR_MPD)
-		pm_wakeup_event(&mdp->pdev->dev, 0);
 }
 
 /* error control function */
-- 
2.11.0
