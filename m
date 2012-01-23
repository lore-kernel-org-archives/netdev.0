From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] add netconsole support for xen-netfront
Date: Mon, 23 Jan 2012 13:24:43 -0500
Message-ID: <20120123182443.GA22963@phenom.dumpdata.com>
References: <1326271956-25565-1-git-send-email-zhenzhong.duan@oracle.com>
 <20120112141745.GA7685@phenom.dumpdata.com>
 <1326452769.17210.331.camel@zakaz.uk.xensource.com>
 <4F15EB3E.3060700@oracle.com>
 <20120117215100.GA25367@phenom.dumpdata.com>
 <4F160113.1030503@oracle.com>
 <1326877176.29475.37.camel@dagon.hellion.org.uk>
 <4F173467.90106@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Zhenzhong Duan <zhenzhong.duan@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gurudas.pai@oracle.com" <gurudas.pai@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>
To: Tina Yang <tina.yang@oracle.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F173467.90106@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2012 at 01:06:47PM -0800, Tina Yang wrote:
> On 1/18/2012 12:59 AM, Ian Campbell wrote:
> >On Tue, 2012-01-17 at 23:15 +0000, Tina Yang wrote:
> >>On 1/17/2012 1:51 PM, Konrad Rzeszutek Wilk wrote:
> >>>On Tue, Jan 17, 2012 at 01:42:22PM -0800, Tina Yang wrote:
> >>>>On 1/13/2012 3:06 AM, Ian Campbell wrote:
> >>>>Although netdump is now obsolete, I think it's always a good practice
> >>>>to preserve caller's irq status as we had a very bad experience
> >>>>chasing a similar problem caused by such a irq change in RDS
> >>>Did you find the culprit of it? Was there a patch for that in the
> >>>upstream kernel?
> >>Yes.  It has nothing to do with net drivers but same cause
> >>elsewhere in the kernel.
> >I didn't think start_xmit could be called with interrupts disabled or
> >from interrupt context but perhaps I am wrong about that or perhaps
> >netconsole changes things?
> Netdump does call it with interrupt disabled and hang because of
> it in 2.6.9 as I remember it.  And you are right, netconsole has
> undergone changes from time to time, which also can change
> this specification.
> >
> >Right, Documentation/networking/netdevices.txt states that start_xmit
> >can be called with interrupts disabled by netconsole and therefore using
> >the irqsave/restore locking in this function is, AFAICT, correct.

Ok, so let me update the git commit description to include this.

I am listed as the maintainer but I would have thought that it should
go through David?

David, should it go through you or should I stick it in my tree? Here
is the patch with a better git description.

>From 1c265b7946f222ab6a5aac5245a0ab84618772c8 Mon Sep 17 00:00:00 2001
From: Zhenzhong Duan <zhenzhong.duan@oracle.com>
Date: Thu, 12 Jan 2012 10:18:29 +0800
Subject: [PATCH] xen/netfront: add netconsole support.

add polling interface to xen-netfront device to support netconsole

This patch also alters the spin_lock usage to use irqsave variant.
Documentation/networking/netdevices.txt states that start_xmit
can be called with interrupts disabled by netconsole and therefore using
the irqsave/restore locking in this function is looks correct.

Signed-off-by: Tina.Yang <tina.yang@oracle.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Signed-off-by: Zhenzhong.Duan <zhenzhong.duan@oracle.com>
Tested-by: gurudas.pai <gurudas.pai@oracle.com>
[v1: Copy-n-pasted Ian Campbell comments]
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/net/xen-netfront.c |   57 ++++++++++++++++++++++++++-----------------
 1 files changed, 34 insertions(+), 23 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d29365a..5a4b5df 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -478,6 +478,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int frags = skb_shinfo(skb)->nr_frags;
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
+	unsigned long flags;
 
 	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
 	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
@@ -487,12 +488,12 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 	}
 
-	spin_lock_irq(&np->tx_lock);
+	spin_lock_irqsave(&np->tx_lock, flags);
 
 	if (unlikely(!netif_carrier_ok(dev) ||
 		     (frags > 1 && !xennet_can_sg(dev)) ||
 		     netif_needs_gso(skb, netif_skb_features(skb)))) {
-		spin_unlock_irq(&np->tx_lock);
+		spin_unlock_irqrestore(&np->tx_lock, flags);
 		goto drop;
 	}
 
@@ -561,7 +562,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!netfront_tx_slot_available(np))
 		netif_stop_queue(dev);
 
-	spin_unlock_irq(&np->tx_lock);
+	spin_unlock_irqrestore(&np->tx_lock, flags);
 
 	return NETDEV_TX_OK;
 
@@ -1176,6 +1177,33 @@ static int xennet_set_features(struct net_device *dev, u32 features)
 	return 0;
 }
 
+static irqreturn_t xennet_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct netfront_info *np = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&np->tx_lock, flags);
+
+	if (likely(netif_carrier_ok(dev))) {
+		xennet_tx_buf_gc(dev);
+		/* Under tx_lock: protects access to rx shared-ring indexes. */
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+			napi_schedule(&np->napi);
+	}
+
+	spin_unlock_irqrestore(&np->tx_lock, flags);
+
+	return IRQ_HANDLED;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void xennet_poll_controller(struct net_device *dev)
+{
+	xennet_interrupt(0, dev);
+}
+#endif
+
 static const struct net_device_ops xennet_netdev_ops = {
 	.ndo_open            = xennet_open,
 	.ndo_uninit          = xennet_uninit,
@@ -1186,6 +1214,9 @@ static const struct net_device_ops xennet_netdev_ops = {
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_fix_features    = xennet_fix_features,
 	.ndo_set_features    = xennet_set_features,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = xennet_poll_controller,
+#endif
 };
 
 static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev)
@@ -1388,26 +1419,6 @@ static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
 	return 0;
 }
 
-static irqreturn_t xennet_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-	struct netfront_info *np = netdev_priv(dev);
-	unsigned long flags;
-
-	spin_lock_irqsave(&np->tx_lock, flags);
-
-	if (likely(netif_carrier_ok(dev))) {
-		xennet_tx_buf_gc(dev);
-		/* Under tx_lock: protects access to rx shared-ring indexes. */
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			napi_schedule(&np->napi);
-	}
-
-	spin_unlock_irqrestore(&np->tx_lock, flags);
-
-	return IRQ_HANDLED;
-}
-
 static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 {
 	struct xen_netif_tx_sring *txs;
-- 
1.7.7.5
