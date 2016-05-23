From: Shuyu Wei <wsy2220@gmail.com>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Mon, 23 May 2016 19:36:09 +0800
Message-ID: <20160523113609.GA21019@debian-dorm>
References: <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
 <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm>
 <5740E82F.8040903@gmx.de>
 <20160522091742.GA8681@debian-dorm>
 <57419853.9050701@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, wxt@rock-chips.com,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, al.kochet@gmail.com
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:35024 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbcEWLgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 07:36:19 -0400
Received: by mail-qg0-f65.google.com with SMTP id t106so3522242qgt.2
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 04:36:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57419853.9050701@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2016 at 01:30:27PM +0200, Lino Sanfilippo wrote:
> 
> Thanks for testing. However that extra check for skb not being NULL should not be
> necessary if the code were correct. The changes I suggested were all about having
> skb and info consistent with txbd_curr.
> But I just realized that there is still a big flaw in the last changes. While
> tx() looks correct now (we first set up the descriptor and assign the skb and _then_
> advance txbd_curr) tx_clean still is not:
> 
> We _first_ have to read tx_curr and _then_ read the corresponding descriptor and its skb.
> (The last patch implemented just the reverse - and thus wrong - order, first get skb and 
> descriptor and then read tx_curr).
> 
> So the patch below hopefully handles also tx_clean correctly. Could you please do once more a test
> with this one?

Hi Lino, 
This patch worked after a whole night of stress testing.

> > 
> > After further test, my patch to barrier timestamp() didn't work.
> > Just like the original code in the tree, the emac still got stuck under
> > high load, even if I changed the smp_wmb() to dma_wmb(). So the original
> > code do have race somewhere.
> 
> So to make this clear: with the current code in net-next you still see a problem (lockup), right?
Yes, I mean the mainline kernel, which should be the same as net-next.


> > ... and why Francois' fix worked. Please be patient with me :-).
> 
> So which fix(es) exactly work for you and solve your lockup issue?
I mean the patch below, starting this thread.

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a3a9392..df3dfef 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -153,9 +153,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &ndev->stats;
-	unsigned int i;
 
-	for (i = 0; i < TX_BD_NUM; i++) {
+	while (priv->txbd_dirty != priv->txbd_curr) {
 		unsigned int *txbd_dirty = &priv->txbd_dirty;
 		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
 		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
@@ -685,13 +684,15 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	wmb();
 
 	skb_tx_timestamp(skb);
+	priv->tx_buff[*txbd_curr].skb = skb;
+
+	dma_wmb();
 
 	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
 	/* Make sure info word is set */
 	wmb();
 
-	priv->tx_buff[*txbd_curr].skb = skb;
 
 	/* Increment index to point to the next BD */
 	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
