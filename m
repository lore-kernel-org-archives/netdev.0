From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH RFC] gianfar: Do not call skb recycling with disabled IRQs
Date: Thu, 5 Nov 2009 20:53:16 +0300
Message-ID: <20091105175316.GA27099@oksana.dev.rtsoft.ru>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
	<E1N62ti-0003iS-K2@jdl.com>
	<20091105142028.GB17171@oksana.dev.rtsoft.ru>
	<E1N63WM-0003xK-PN@jdl.com> <E1N64UY-00049g-Hb@jdl.com>
	<20091105165738.GA31923@oksana.dev.rtsoft.ru>
	<9F4C7D19E8361D4C94921B95BE08B81B950713@zin33exm22.fsl.freescale.net>
	<E1N66Jp-0004Y0-8Q@jdl.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gopalpet-B05799 <B05799@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Fleming Andy-AFLEMING <afleming@freescale.com>,
	Jason Wessel <jason.wessel@windriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jon Loeliger <jdl@jdl.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <E1N66Jp-0004Y0-8Q@jdl.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 05, 2009 at 11:40:21AM -0600, Jon Loeliger wrote:
[...]
> > >+			netif_tx_lock_bh(priv->ndev);
> > 
> > Will this not lead to locking all the tx queues even though at this
> > point we are working on a "particular queue" ?
> 
> Similar but different question:  What version is this patch based upon?
> I can't find:
> 
>     > >index 197b358..a0ae604 100644
> 
> My search of 2.6.31 up through current linux head (v2.6.32-rc6-26-g91d3f9b)
> and benh's current head (94a8d5caba74211ec76dac80fc6e2d5c391530df) do not
> have a version of this code with separate txqueues.
> 
> I confess I'm not too familiar with the history here, so I don't know
> if that feature is in flux, or came, or went, or what.

Sorry for not mentioning, it's based on

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
+ compiler/sparse warnings fixes that I sent yesterday.

> That boils down to:  I can't directly apply your patch, but I could
> hand-fudge its intent, but only on a single tx queue variant.

Here is the patch on top of the Linus' git tree, if you haven't
already 'back-ported' the previous patch.

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 5bf31f1..5dca99c 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1274,7 +1274,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 lstatus;
 	int i;
 	u32 bufaddr;
-	unsigned long flags;
 	unsigned int nr_frags, length;
 
 	base = priv->tx_bd_base;
@@ -1298,14 +1297,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* total number of fragments in the SKB */
 	nr_frags = skb_shinfo(skb)->nr_frags;
 
-	spin_lock_irqsave(&priv->txlock, flags);
-
 	/* check if there is space to queue this packet */
 	if ((nr_frags+1) > priv->num_txbdfree) {
 		/* no space, stop the queue */
 		netif_stop_queue(dev);
 		dev->stats.tx_fifo_errors++;
-		spin_unlock_irqrestore(&priv->txlock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1403,9 +1399,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Tell the DMA to go go go */
 	gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
 
-	/* Unlock priv */
-	spin_unlock_irqrestore(&priv->txlock, flags);
-
 	return NETDEV_TX_OK;
 }
 
@@ -1915,17 +1908,14 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	struct net_device *dev = priv->ndev;
 	int tx_cleaned = 0;
 	int rx_cleaned = 0;
-	unsigned long flags;
 
 	/* Clear IEVENT, so interrupts aren't called again
 	 * because of the packets that have already arrived */
 	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
 
-	/* If we fail to get the lock, don't bother with the TX BDs */
-	if (spin_trylock_irqsave(&priv->txlock, flags)) {
-		tx_cleaned = gfar_clean_tx_ring(dev);
-		spin_unlock_irqrestore(&priv->txlock, flags);
-	}
+	netif_tx_lock_bh(priv->ndev);
+	tx_cleaned = gfar_clean_tx_ring(dev);
+	netif_tx_unlock_bh(priv->ndev);
 
 	rx_cleaned = gfar_clean_rx_ring(dev, budget);
 

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
