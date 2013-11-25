From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] via-velocity: fix netif_receive_skb use in irq
 disabled section.
Date: Tue, 26 Nov 2013 00:40:58 +0100
Message-ID: <20131125234058.GA12566@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Alex A. Schmidt" <aaschmidt1@gmail.com>,
	Michele Baldessari <michele@acksyn.org>,
	Jamie Heilman <jamie@audible.transient.net>,
	Julia Lawall <Julia.Lawall@lip6.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57806 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab3KYXlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 18:41:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2fdac010bdcf10a30711b6924612dfc40daf19b8 ("via-velocity.c: update napi
implementation") overlooked an irq disabling spinlock when the Rx part
of the NAPI poll handler was converted from netif_rx to netif_receive_skb.

NAPI Rx processing can be taken out of the locked section with a pair of
napi_{disable / enable} since it only races with the MTU change function.

An heavier rework of the NAPI locking would be able to perform NAPI Tx
before Rx where I simply removed one of velocity_tx_srv calls.

References: https://bugzilla.redhat.com/show_bug.cgi?id=1022733
Fixes: 2fdac010bdcf (via-velocity.c: update napi implementation)
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Alex A. Schmidt <aaschmidt1@gmail.com>
Cc: Jamie Heilman <jamie@audible.transient.net>
Cc: Michele Baldessari <michele@acksyn.org>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>
---

 It is relevant for stable 3.11.x and 3.12.y.

 drivers/net/ethernet/via/via-velocity.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index d022bf9..ad61d26 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2172,16 +2172,13 @@ static int velocity_poll(struct napi_struct *napi, int budget)
 	unsigned int rx_done;
 	unsigned long flags;
 
-	spin_lock_irqsave(&vptr->lock, flags);
 	/*
 	 * Do rx and tx twice for performance (taken from the VIA
 	 * out-of-tree driver).
 	 */
-	rx_done = velocity_rx_srv(vptr, budget / 2);
-	velocity_tx_srv(vptr);
-	rx_done += velocity_rx_srv(vptr, budget - rx_done);
+	rx_done = velocity_rx_srv(vptr, budget);
+	spin_lock_irqsave(&vptr->lock, flags);
 	velocity_tx_srv(vptr);
-
 	/* If budget not fully consumed, exit the polling mode */
 	if (rx_done < budget) {
 		napi_complete(napi);
@@ -2342,6 +2339,8 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 		if (ret < 0)
 			goto out_free_tmp_vptr_1;
 
+		napi_disable(&vptr->napi);
+
 		spin_lock_irqsave(&vptr->lock, flags);
 
 		netif_stop_queue(dev);
@@ -2362,6 +2361,8 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 
 		velocity_give_many_rx_descs(vptr);
 
+		napi_enable(&vptr->napi);
+
 		mac_enable_int(vptr->mac_regs);
 		netif_start_queue(dev);
 
-- 
1.8.3.1
