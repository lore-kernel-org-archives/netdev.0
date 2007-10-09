From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 19:43:43 -0700 (PDT)
Message-ID: <20071008.194343.52093065.davem@davemloft.net>
References: <20071008.184126.124062865.davem@davemloft.net>
	<20071009020115.GA14635@gondor.apana.org.au>
	<20071009020318.GA14708@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jeff@garzik.org, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, gaagaan@gmail.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, shemminger@linux-foundation.org,
	kaber@trash.net, sri@us.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009020318.GA14708@gondor.apana.org.au>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 9 Oct 2007 10:03:18 +0800

> On Tue, Oct 09, 2007 at 10:01:15AM +0800, Herbert Xu wrote:
> > On Mon, Oct 08, 2007 at 06:41:26PM -0700, David Miller wrote:
> > >
> > > I also want to point out another issue.  Any argument wrt. reordering
> > > is specious at best because right now reordering from qdisc to device
> > > happens anyways.
> > 
> > This is not true.
> > 
> > If your device has a qdisc at all, then you will end up in the
> > function qdisc_restart, where we release the queue lock only
> > after acquiring the TX lock.
> > 
> > So right now this path does not create any reordering.
> 
> Argh! Someone's just broken this.  I think we should restore
> the original behaviour.

Right, that's Jamal's recent patch.  It looked funny to me too.

I think we can't make this change, the acquisition of the device
transmit lock before we release the qdisc is the only thing that
prevents reordering between qdisc and device.

Otherwise all of the prioritization is pretty much for nothing as
I described in another email today.

Jamal, I'm pretty sure we have to revert this, you can't change the
locking in this way.

commit 41843197b17bdfb1f97af0a87c06d24c1620ba90
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Tue Sep 25 19:27:13 2007 -0700

    [NET_SCHED]: explict hold dev tx lock
    
    For N cpus, with full throttle traffic on all N CPUs, funneling traffic
    to the same ethernet device, the devices queue lock is contended by all
    N CPUs constantly. The TX lock is only contended by a max of 2 CPUS.
    In the current mode of operation, after all the work of entering the
    dequeue region, we may endup aborting the path if we are unable to get
    the tx lock and go back to contend for the queue lock. As N goes up,
    this gets worse.
    
    The changes in this patch result in a small increase in performance
    with a 4CPU (2xdual-core) with no irq binding. Both e1000 and tg3
    showed similar behavior;
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e970e8e..95ae119 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -134,34 +134,19 @@ static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
-	unsigned lockless;
 	int ret;
 
 	/* Dequeue packet */
 	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
 		return 0;
 
-	/*
-	 * When the driver has LLTX set, it does its own locking in
-	 * start_xmit. These checks are worth it because even uncongested
-	 * locks can be quite expensive. The driver can do a trylock, as
-	 * is being done here; in case of lock contention it should return
-	 * NETDEV_TX_LOCKED and the packet will be requeued.
-	 */
-	lockless = (dev->features & NETIF_F_LLTX);
-
-	if (!lockless && !netif_tx_trylock(dev)) {
-		/* Another CPU grabbed the driver tx lock */
-		return handle_dev_cpu_collision(skb, dev, q);
-	}
 
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
+	HARD_TX_LOCK(dev, smp_processor_id());
 	ret = dev_hard_start_xmit(skb, dev);
-
-	if (!lockless)
-		netif_tx_unlock(dev);
+	HARD_TX_UNLOCK(dev);
 
 	spin_lock(&dev->queue_lock);
 	q = dev->qdisc;
