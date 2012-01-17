From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] add netconsole support for xen-netfront
Date: Tue, 17 Jan 2012 16:51:00 -0500
Message-ID: <20120117215100.GA25367@phenom.dumpdata.com>
References: <1326271956-25565-1-git-send-email-zhenzhong.duan@oracle.com>
 <20120112141745.GA7685@phenom.dumpdata.com>
 <1326452769.17210.331.camel@zakaz.uk.xensource.com>
 <4F15EB3E.3060700@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Zhenzhong Duan <zhenzhong.duan@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gurudas.pai@oracle.com" <gurudas.pai@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>
To: Tina Yang <tina.yang@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F15EB3E.3060700@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2012 at 01:42:22PM -0800, Tina Yang wrote:
> On 1/13/2012 3:06 AM, Ian Campbell wrote:
> >On Thu, 2012-01-12 at 14:17 +0000, Konrad Rzeszutek Wilk wrote:
> >>On Wed, Jan 11, 2012 at 04:52:36PM +0800, Zhenzhong Duan wrote:
> >>>add polling interface to xen-netfront device to support netconsole
> >>>
> >>Ian, any thoughts on the spinlock changes?
> >What are they for?
> When I did this patch back in 2008, both netconsole and netdump
> were supported.  Spin_lock w/o irqsave and irqrestore would cause
> netdump hang due to the unexpected change of the irq status.

Hm, that might have been due to the bug that was lurking in there since
2.6.27: d198d499148a0c64a41b3aba9e7dd43772832b91 "xen: x86_32: do not enable iterrupts when returning from exception in interrupt context"

> Although netdump is now obsolete, I think it's always a good practice
> to preserve caller's irq status as we had a very bad experience
> chasing a similar problem caused by such a irq change in RDS

Did you find the culprit of it? Was there a patch for that in the
upstream kernel?

> in the not too long ago past.

OK, it sounds like it was issues in the past but might not be the
case anymore.

Could please re-test it without that spinlock irqsave patch using
the upstream kernel (or just UEK2 since it is an 3.0 type kernel).

Thanks.

> >At a guess they are a necessary consequence of the new calling context.
> >However not all the drivers I looked at which supported netpool were
> >using the irqsave variants in this context so I guess it must be some
> >secondary effect.
> >
> >Anyway, the upshot is that I think the changelog needs to explain the
> >rationale for the locking change.
> >
> >Ian.
> >
> >>>Signed-off-by: Tina.Yang<tina.yang@oracle.com>
> >>>Cc: Konrad Rzeszutek Wilk<konrad.wilk@oracle.com>
> >>>Cc: Jeremy Fitzhardinge<jeremy@goop.org>
> >>>Signed-off-by: Zhenzhong.Duan<zhenzhong.duan@oracle.com>
> >>>Tested-by: gurudas.pai<gurudas.pai@oracle.com>
> >>>---
> >>>  drivers/net/xen-netfront.c |   57 ++++++++++++++++++++++++++-----------------
> >>>  1 files changed, 34 insertions(+), 23 deletions(-)
> >>>
> >>>diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> >>>index fa67905..db638b4 100644
> >>>--- a/drivers/net/xen-netfront.c
> >>>+++ b/drivers/net/xen-netfront.c
> >>>@@ -489,6 +489,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>>  	int frags = skb_shinfo(skb)->nr_frags;
> >>>  	unsigned int offset = offset_in_page(data);
> >>>  	unsigned int len = skb_headlen(skb);
> >>>+	unsigned long flags;
> >>>
> >>>  	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
> >>>  	if (unlikely(frags>  MAX_SKB_FRAGS + 1)) {
> >>>@@ -498,12 +499,12 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>>  		goto drop;
> >>>  	}
> >>>
> >>>-	spin_lock_irq(&np->tx_lock);
> >>>+	spin_lock_irqsave(&np->tx_lock, flags);
> >>>
> >>>  	if (unlikely(!netif_carrier_ok(dev) ||
> >>>  		     (frags>  1&&  !xennet_can_sg(dev)) ||
> >>>  		     netif_needs_gso(skb, netif_skb_features(skb)))) {
> >>>-		spin_unlock_irq(&np->tx_lock);
> >>>+		spin_unlock_irqrestore(&np->tx_lock, flags);
> >>>  		goto drop;
> >>>  	}
> >>>
> >>>@@ -574,7 +575,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>>  	if (!netfront_tx_slot_available(np))
> >>>  		netif_stop_queue(dev);
> >>>
> >>>-	spin_unlock_irq(&np->tx_lock);
> >>>+	spin_unlock_irqrestore(&np->tx_lock, flags);
> >>>
> >>>  	return NETDEV_TX_OK;
> >>>
> >>>@@ -1228,6 +1229,33 @@ static int xennet_set_features(struct net_device *dev,
> >>>  	return 0;
> >>>  }
> >>>
> >>>+static irqreturn_t xennet_interrupt(int irq, void *dev_id)
> >>>+{
> >>>+	struct net_device *dev = dev_id;
> >>>+	struct netfront_info *np = netdev_priv(dev);
> >>>+	unsigned long flags;
> >>>+
> >>>+	spin_lock_irqsave(&np->tx_lock, flags);
> >>>+
> >>>+	if (likely(netif_carrier_ok(dev))) {
> >>>+		xennet_tx_buf_gc(dev);
> >>>+		/* Under tx_lock: protects access to rx shared-ring indexes. */
> >>>+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
> >>>+			napi_schedule(&np->napi);
> >>>+	}
> >>>+
> >>>+	spin_unlock_irqrestore(&np->tx_lock, flags);
> >>>+
> >>>+	return IRQ_HANDLED;
> >>>+}
> >>>+
> >>>+#ifdef CONFIG_NET_POLL_CONTROLLER
> >>>+static void xennet_poll_controller(struct net_device *dev)
> >>>+{
> >>>+	xennet_interrupt(0, dev);
> >>>+}
> >>>+#endif
> >>>+
> >>>  static const struct net_device_ops xennet_netdev_ops = {
> >>>  	.ndo_open            = xennet_open,
> >>>  	.ndo_uninit          = xennet_uninit,
> >>>@@ -1239,6 +1267,9 @@ static const struct net_device_ops xennet_netdev_ops = {
> >>>  	.ndo_validate_addr   = eth_validate_addr,
> >>>  	.ndo_fix_features    = xennet_fix_features,
> >>>  	.ndo_set_features    = xennet_set_features,
> >>>+#ifdef CONFIG_NET_POLL_CONTROLLER
> >>>+	.ndo_poll_controller = xennet_poll_controller,
> >>>+#endif
> >>>  };
> >>>
> >>>  static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev)
> >>>@@ -1448,26 +1479,6 @@ static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
> >>>  	return 0;
> >>>  }
> >>>
> >>>-static irqreturn_t xennet_interrupt(int irq, void *dev_id)
> >>>-{
> >>>-	struct net_device *dev = dev_id;
> >>>-	struct netfront_info *np = netdev_priv(dev);
> >>>-	unsigned long flags;
> >>>-
> >>>-	spin_lock_irqsave(&np->tx_lock, flags);
> >>>-
> >>>-	if (likely(netif_carrier_ok(dev))) {
> >>>-		xennet_tx_buf_gc(dev);
> >>>-		/* Under tx_lock: protects access to rx shared-ring indexes. */
> >>>-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
> >>>-			napi_schedule(&np->napi);
> >>>-	}
> >>>-
> >>>-	spin_unlock_irqrestore(&np->tx_lock, flags);
> >>>-
> >>>-	return IRQ_HANDLED;
> >>>-}
> >>>-
> >>>  static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
> >>>  {
> >>>  	struct xen_netif_tx_sring *txs;
> >>>-- 
> >>>1.7.3
> >
