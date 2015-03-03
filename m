From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Tue, 03 Mar 2015 05:42:22 -0800
Message-ID: <1425390142.5130.173.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>
	 <1425389399.5130.169.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Felipe Balbi <balbi@ti.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425389399.5130.169.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 05:29 -0800, Eric Dumazet wrote:
> On Tue, 2015-03-03 at 12:45 +0100, Nicolas Schichan wrote:
> > In case there was some tx buffer reclaimed and not enough rx packets
> > to consume the whole budget, napi_complete would not be called and
> > interrupts would be kept disabled, effectively resulting in the
> > network core never to call the poll callback again and no rx/tx
> > interrupts to be fired either.
> > 
> > Fix that by only accounting the rx work done in the poll callback.
> > 
> > Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> > ---
> 
> This looks better, thanks.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Note that the way bcm_enet_tx_reclaim() is written, it can livelock on
> SMP hosts :
> 
> CPU 1,2,3,...  keep queuing packets via ndo_start_xmit()
> 
> CPU 0 is looping forever in bcm_enet_tx_reclaim() draining queue and
> freeing skbs.
> 
> To avoid that, I would take priv->tx_lock only once, or add a limit on
> the number of skbs that can be drained per round.

Something like this (untested) patch

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 21206d33b638..9e8e83865e52 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -429,29 +429,23 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
  */
 static int bcm_enet_tx_reclaim(struct net_device *dev, int force)
 {
-	struct bcm_enet_priv *priv;
-	int released;
+	struct bcm_enet_priv *priv = netdev_priv(dev);
+	int released = 0;
 
-	priv = netdev_priv(dev);
-	released = 0;
+	spin_lock(&priv->tx_lock);
 
 	while (priv->tx_desc_count < priv->tx_ring_size) {
 		struct bcm_enet_desc *desc;
 		struct sk_buff *skb;
 
-		/* We run in a bh and fight against start_xmit, which
-		 * is called with bh disabled  */
-		spin_lock(&priv->tx_lock);
-
 		desc = &priv->tx_desc_cpu[priv->tx_dirty_desc];
 
-		if (!force && (desc->len_stat & DMADESC_OWNER_MASK)) {
-			spin_unlock(&priv->tx_lock);
+		if (!force && (desc->len_stat & DMADESC_OWNER_MASK))
 			break;
-		}
 
 		/* ensure other field of the descriptor were not read
-		 * before we checked ownership */
+		 * before we checked ownership
+		 */
 		rmb();
 
 		skb = priv->tx_skb[priv->tx_dirty_desc];
@@ -464,8 +458,6 @@ static int bcm_enet_tx_reclaim(struct net_device *dev, int force)
 			priv->tx_dirty_desc = 0;
 		priv->tx_desc_count++;
 
-		spin_unlock(&priv->tx_lock);
-
 		if (desc->len_stat & DMADESC_UNDER_MASK)
 			dev->stats.tx_errors++;
 
@@ -476,6 +468,8 @@ static int bcm_enet_tx_reclaim(struct net_device *dev, int force)
 	if (netif_queue_stopped(dev) && released)
 		netif_wake_queue(dev);
 
+	spin_unlock(&priv->tx_lock);
+
 	return released;
 }
 
