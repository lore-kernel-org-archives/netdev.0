From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 2/4] sh_eth: Detach net device when stopping queue to
 resize DMA rings
Date: Thu, 22 Jan 2015 12:40:25 +0000
Message-ID: <1421930425.1222.287.camel@xylophone.i.decadent.org.uk>
References: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:40613 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbbAVMk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:40:26 -0500
In-Reply-To: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must only ever stop TX queues when they are full or the net device
is not 'ready' so far as the net core, and specifically the watchdog,
is concerned.  Otherwise, the watchdog may fire *immediately* if no
packets have been added to the queue in the last 5 seconds.

What's more, sh_eth_tx_timeout() will likely crash if called while
we're resizing the TX ring.

I could easily trigger this by running the loop:

   while ethtool -G eth0 rx 128 && ethtool -G eth0 rx 64; do echo -n .; done

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 69f9fff..0be16dd 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1968,6 +1968,7 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 		return -EINVAL;
 
 	if (netif_running(ndev)) {
+		netif_device_detach(ndev);
 		netif_tx_disable(ndev);
 		/* Disable interrupts by clearing the interrupt mask. */
 		sh_eth_write(ndev, 0x0000, EESIPR);
@@ -2001,7 +2002,7 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
 		/* Setting the Rx mode will start the Rx process. */
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
-		netif_wake_queue(ndev);
+		netif_device_attach(ndev);
 	}
 
 	return 0;
-- 
1.7.10.4
