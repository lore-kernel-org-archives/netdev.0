From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 9 Jan 2007 13:05:41 -0700
Message-ID: <20070109200541.GA27089@xyzzy.farnsworth.org>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com> <20070109092602.GC1703@ff.dom.local> <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com> <20070109130220.GA4060@ff.dom.local> <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:4361 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932378AbXAIUMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 15:12:23 -0500
To: Thibaut VARENE <T-Bone@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 06:44:49PM +0100, Thibaut VARENE wrote:
> On 1/9/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> >On Tue, Jan 09, 2007 at 11:27:59AM +0100, Thibaut VARENE wrote:
> >...
> >> I suspected both and changed both the disk and the ram for quality
> >> parts, that I tested afterwards. Both passed thorough tests.
> >>
> >> Finally, using the other NIC on the box (a VIA Rhine II, 100Mbps),
> >> works absolutely fine.
> >
> >If you are not tired, I'd suggest two more tests:
> 
> I volunteered to help :)

Thank you Thibaut.  Please try the following patch:

From: Dale Farnsworth <dale@farnsworth.org>

Reserve one unused descriptor in the TX ring
to facilitate testing for when the ring is full.

---

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

 drivers/net/mv643xx_eth.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 9997081..72f82ba 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -289,7 +289,7 @@ static void mv643xx_eth_tx_timeout_task(
 	eth_port_reset(mp->port_num);
 	eth_port_start(dev);
 
-	if (mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
+	if (mp->tx_ring_size - mp->tx_desc_count > MAX_DESCS_PER_SKB)
 		netif_wake_queue(dev);
 }
 
@@ -356,7 +356,7 @@ static void mv643xx_eth_free_completed_t
 	struct mv643xx_private *mp = netdev_priv(dev);
 
 	if (mv643xx_eth_free_tx_descs(dev, 0) &&
-	    mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
+	    mp->tx_ring_size - mp->tx_desc_count > MAX_DESCS_PER_SKB)
 		netif_wake_queue(dev);
 }
 
@@ -536,7 +536,7 @@ static irqreturn_t mv643xx_eth_int_handl
 						   ETH_TX_QUEUES_ENABLED);
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
-				if (mp->tx_ring_size - mp->tx_desc_count >=
+				if (mp->tx_ring_size - mp->tx_desc_count >
 							MAX_DESCS_PER_SKB)
 					netif_wake_queue(dev);
 			}
@@ -1194,7 +1194,7 @@ static int mv643xx_eth_start_xmit(struct
 	BUG_ON(netif_queue_stopped(dev));
 	BUG_ON(skb == NULL);
 
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
+	if (mp->tx_ring_size - mp->tx_desc_count <= MAX_DESCS_PER_SKB) {
 		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
 		netif_stop_queue(dev);
 		return 1;
@@ -1216,7 +1216,7 @@ static int mv643xx_eth_start_xmit(struct
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB)
+	if (mp->tx_ring_size - mp->tx_desc_count <= MAX_DESCS_PER_SKB)
 		netif_stop_queue(dev);
 
 	spin_unlock_irqrestore(&mp->lock, flags);
