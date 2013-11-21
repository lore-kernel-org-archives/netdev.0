From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Thu, 21 Nov 2013 01:44:30 +0100
Message-ID: <20131121004430.GX8581@1wt.eu>
References: <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <87li0kkhzx.fsf@natisbad.org>
 <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131119174323.GH913@1wt.eu>
 <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
 <20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org>
 <20131120215435.GT8581@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>, simon.guinot@sequanux.org,
 Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
 edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20131120215435.GT8581@1wt.eu>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Arnaud,

On Wed, Nov 20, 2013 at 10:54:35PM +0100, Willy Tarreau wrote:
> I'm currently trying to implement TX IRQ handling. I found the registers
> description in the neta driver that is provided in Marvell's LSP kernel
> that is shipped with some devices using their CPUs. This code is utterly
> broken (eg: splice fails with -EBADF) but I think the register descriptions
> could be trusted.
> 
> I'd rather have real IRQ handling than just relying on mvneta_poll(), so
> that we can use it for asymmetric traffic/routing/whatever.

OK it paid off. And very well :-)

I did it at once and it worked immediately. I generally don't like this
because I always fear that some bug was left there hidden in the code. I have
only tested it on the Mirabox, so I'll have to try on the OpenBlocks AX3-4 and
on the XP-GP board for some SMP stress tests.

I upgraded my Mirabox to latest Linus' git (commit 5527d151) and compared
with and without the patch.

  without :
      - need at least 12 streams to reach gigabit.
      - 60% of idle CPU remains at 1 Gbps
      - HTTP connection rate on empty objects is 9950 connections/s
      - cumulated outgoing traffic on two ports reaches 1.3 Gbps

  with the patch :
      - a single stream easily saturates the gigabit
      - 87% of idle CPU at 1 Gbps (12 streams, 90% idle at 1 stream)
      - HTTP connection rate on empty objects is 10250 connections/s
      - I saturate the two gig ports at 99% CPU, so 2 Gbps sustained output.

BTW I must say I was impressed to see that big an improvement in CPU
usage between 3.10 and 3.13, I suspect some of the Tx queue improvements
that Eric has done in between account for this.

I cut the patch in 3 parts :
   - one which reintroduces the hidden bits of the driver
   - one which replaces the timer with the IRQ
   - one which changes the default Tx coalesce from 16 to 4 packets
     (larger was preferred with the timer, but less is better now).

I'm attaching them, please test them on your device.

Note that this is *not* for inclusion at the moment as it has not been
tested on the SMP CPUs.

Cheers,
Willy


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-net-mvneta-add-missing-bit-descriptions-for-interrup.patch"

>From b77b32dbffdfffc6aa21fa230054e09e2a4cd227 Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Wed, 20 Nov 2013 23:58:30 +0100
Subject: net: mvneta: add missing bit descriptions for interrupt masks and
 causes

Marvell has not published the chip's datasheet yet, so it's very hard
to find the relevant bits to manipulate to change the IRQ behaviour.
Fortunately, these bits are described in the proprietary LSP patch set
which is publicly available here :

    http://www.plugcomputer.org/downloads/mirabox/

So let's put them back in the driver in order to reduce the burden of
current and future maintenance.

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 44 +++++++++++++++++++++++++++++++++--
 1 file changed, 42 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b8e232b..6630690 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -101,16 +101,56 @@
 #define      MVNETA_CPU_RXQ_ACCESS_ALL_MASK      0x000000ff
 #define      MVNETA_CPU_TXQ_ACCESS_ALL_MASK      0x0000ff00
 #define MVNETA_RXQ_TIME_COAL_REG(q)              (0x2580 + ((q) << 2))
+
+/* Exception Interrupt Port/Queue Cause register */
+
 #define MVNETA_INTR_NEW_CAUSE                    0x25a0
-#define      MVNETA_RX_INTR_MASK(nr_rxqs)        (((1 << nr_rxqs) - 1) << 8)
 #define MVNETA_INTR_NEW_MASK                     0x25a4
+
+/* bits  0..7  = TXQ SENT, one bit per queue.
+ * bits  8..15 = RXQ OCCUP, one bit per queue.
+ * bits 16..23 = RXQ FREE, one bit per queue.
+ * bit  29 = OLD_REG_SUM, see old reg ?
+ * bit  30 = TX_ERR_SUM, one bit for 4 ports
+ * bit  31 = MISC_SUM,   one bit for 4 ports
+ */
+#define      MVNETA_TX_INTR_MASK(nr_txqs)        (((1 << nr_txqs) - 1) << 0)
+#define      MVNETA_TX_INTR_MASK_ALL             (0xff << 0)
+#define      MVNETA_RX_INTR_MASK(nr_rxqs)        (((1 << nr_rxqs) - 1) << 8)
+#define      MVNETA_RX_INTR_MASK_ALL             (0xff << 8)
+
 #define MVNETA_INTR_OLD_CAUSE                    0x25a8
 #define MVNETA_INTR_OLD_MASK                     0x25ac
+
+/* Data Path Port/Queue Cause Register */
 #define MVNETA_INTR_MISC_CAUSE                   0x25b0
 #define MVNETA_INTR_MISC_MASK                    0x25b4
+
+#define      MVNETA_CAUSE_PHY_STATUS_CHANGE      BIT(0)
+#define      MVNETA_CAUSE_LINK_CHANGE            BIT(1)
+#define      MVNETA_CAUSE_PTP                    BIT(4)
+
+#define      MVNETA_CAUSE_INTERNAL_ADDR_ERR      BIT(7)
+#define      MVNETA_CAUSE_RX_OVERRUN             BIT(8)
+#define      MVNETA_CAUSE_RX_CRC_ERROR           BIT(9)
+#define      MVNETA_CAUSE_RX_LARGE_PKT           BIT(10)
+#define      MVNETA_CAUSE_TX_UNDERUN             BIT(11)
+#define      MVNETA_CAUSE_PRBS_ERR               BIT(12)
+#define      MVNETA_CAUSE_PSC_SYNC_CHANGE        BIT(13)
+#define      MVNETA_CAUSE_SERDES_SYNC_ERR        BIT(14)
+
+#define      MVNETA_CAUSE_BMU_ALLOC_ERR_SHIFT    16
+#define      MVNETA_CAUSE_BMU_ALLOC_ERR_ALL_MASK   (0xF << MVNETA_CAUSE_BMU_ALLOC_ERR_SHIFT)
+#define      MVNETA_CAUSE_BMU_ALLOC_ERR_MASK(pool) (1 << (MVNETA_CAUSE_BMU_ALLOC_ERR_SHIFT + (pool)))
+
+#define      MVNETA_CAUSE_TXQ_ERROR_SHIFT        24
+#define      MVNETA_CAUSE_TXQ_ERROR_ALL_MASK     (0xFF << MVNETA_CAUSE_TXQ_ERROR_SHIFT)
+#define      MVNETA_CAUSE_TXQ_ERROR_MASK(q)      (1 << (MVNETA_CAUSE_TXQ_ERROR_SHIFT + (q)))
+
 #define MVNETA_INTR_ENABLE                       0x25b8
 #define      MVNETA_TXQ_INTR_ENABLE_ALL_MASK     0x0000ff00
-#define      MVNETA_RXQ_INTR_ENABLE_ALL_MASK     0xff000000
+#define      MVNETA_RXQ_INTR_ENABLE_ALL_MASK     0xff000000  // note: neta says it's 0x000000FF
+
 #define MVNETA_RXQ_CMD                           0x2680
 #define      MVNETA_RXQ_DISABLE_SHIFT            8
 #define      MVNETA_RXQ_ENABLE_MASK              0x000000ff
-- 
1.7.12.1


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-net-mvneta-replace-Tx-timer-with-a-real-interrupt.patch"

>From 741bc1bfccbfe33cebaceb2e854539946e8ec9fa Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Wed, 20 Nov 2013 19:47:11 +0100
Subject: net: mvneta: replace Tx timer with a real interrupt

Right now the mvneta driver doesn't handle Tx IRQ, and solely relies on a
timer to flush Tx descriptors. This causes jerky output traffic with bursts
and pauses, making it difficult to reach line rate with very few streams.

It seems that this feature was inherited from the original driver but
nothing there mentions any reason for not using the interrupt instead,
which the chip supports.

Thus, this patch enables Tx interrupts and removes the timer. It does the
two at once because it's not really possible to make the two mechanisms
coexist, so a split patch doesn't make sense.

First tests performed on a Mirabox (Armada 370) show that much less CPU
is used when sending traffic. One reason might be that we now call the
mvneta_tx_done_gbe() with a mask indicating which queues have been done
instead of looping over all of them.

The results are quite good, a single TCP stream is now capable of saturating
a gigabit link, while a minimum of 12 concurrent streams are needed without
the patch. At 1 Gbps with 12 concurrent streams, 60% of the CPU remains idle
without the patch, and it grows to 87% with the patch. The connection rate
has also increased from 9950 to 10150 connections per second (HTTP requests
of empty objects).

Signed-off-by: Willy Tarreau <w@1wt.eu>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Arnaud Ebalard <arno@natisbad.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 71 ++++++-----------------------------
 1 file changed, 12 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 6630690..def32a8 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -216,9 +216,6 @@
 #define MVNETA_RX_COAL_PKTS		32
 #define MVNETA_RX_COAL_USEC		100
 
-/* Timer */
-#define MVNETA_TX_DONE_TIMER_PERIOD	10
-
 /* Napi polling weight */
 #define MVNETA_RX_POLL_WEIGHT		64
 
@@ -272,16 +269,11 @@ struct mvneta_port {
 	void __iomem *base;
 	struct mvneta_rx_queue *rxqs;
 	struct mvneta_tx_queue *txqs;
-	struct timer_list tx_done_timer;
 	struct net_device *dev;
 
 	u32 cause_rx_tx;
 	struct napi_struct napi;
 
-	/* Flags */
-	unsigned long flags;
-#define MVNETA_F_TX_DONE_TIMER_BIT  0
-
 	/* Napi weight */
 	int weight;
 
@@ -1140,17 +1132,6 @@ static void mvneta_tx_done_pkts_coal_set(struct mvneta_port *pp,
 	txq->done_pkts_coal = value;
 }
 
-/* Trigger tx done timer in MVNETA_TX_DONE_TIMER_PERIOD msecs */
-static void mvneta_add_tx_done_timer(struct mvneta_port *pp)
-{
-	if (test_and_set_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags) == 0) {
-		pp->tx_done_timer.expires = jiffies +
-			msecs_to_jiffies(MVNETA_TX_DONE_TIMER_PERIOD);
-		add_timer(&pp->tx_done_timer);
-	}
-}
-
-
 /* Handle rx descriptor fill by setting buf_cookie and buf_phys_addr */
 static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
 				u32 phys_addr, u32 cookie)
@@ -1632,15 +1613,6 @@ out:
 		dev_kfree_skb_any(skb);
 	}
 
-	if (txq->count >= MVNETA_TXDONE_COAL_PKTS)
-		mvneta_txq_done(pp, txq);
-
-	/* If after calling mvneta_txq_done, count equals
-	 * frags, we need to set the timer
-	 */
-	if (txq->count == frags && frags > 0)
-		mvneta_add_tx_done_timer(pp);
-
 	return NETDEV_TX_OK;
 }
 
@@ -1916,14 +1888,22 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 
 	/* Read cause register */
 	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
-		MVNETA_RX_INTR_MASK(rxq_number);
+		(MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+
+	/* Release Tx descriptors */
+	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
+		int tx_todo = 0;
+
+		mvneta_tx_done_gbe(pp, (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL), &tx_todo);
+		cause_rx_tx &= ~MVNETA_TX_INTR_MASK_ALL;
+	}
 
 	/* For the case where the last mvneta_poll did not process all
 	 * RX packets
 	 */
 	cause_rx_tx |= pp->cause_rx_tx;
 	if (rxq_number > 1) {
-		while ((cause_rx_tx != 0) && (budget > 0)) {
+		while ((cause_rx_tx & MVNETA_RX_INTR_MASK_ALL) && (budget > 0)) {
 			int count;
 			struct mvneta_rx_queue *rxq;
 			/* get rx queue number from cause_rx_tx */
@@ -1955,7 +1935,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		local_irq_save(flags);
 		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-			    MVNETA_RX_INTR_MASK(rxq_number));
+			    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
 		local_irq_restore(flags);
 	}
 
@@ -1963,26 +1943,6 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	return rx_done;
 }
 
-/* tx done timer callback */
-static void mvneta_tx_done_timer_callback(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *)data;
-	struct mvneta_port *pp = netdev_priv(dev);
-	int tx_done = 0, tx_todo = 0;
-
-	if (!netif_running(dev))
-		return ;
-
-	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
-
-	tx_done = mvneta_tx_done_gbe(pp,
-				     (((1 << txq_number) - 1) &
-				      MVNETA_CAUSE_TXQ_SENT_DESC_ALL_MASK),
-				     &tx_todo);
-	if (tx_todo > 0)
-		mvneta_add_tx_done_timer(pp);
-}
-
 /* Handle rxq fill: allocates rxq skbs; called when initializing a port */
 static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
 			   int num)
@@ -2232,7 +2192,7 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 
 	/* Unmask interrupts */
 	mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-		    MVNETA_RX_INTR_MASK(rxq_number));
+		    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
 
 	phy_start(pp->phy_dev);
 	netif_tx_start_all_queues(pp->dev);
@@ -2518,8 +2478,6 @@ static int mvneta_stop(struct net_device *dev)
 	free_irq(dev->irq, pp);
 	mvneta_cleanup_rxqs(pp);
 	mvneta_cleanup_txqs(pp);
-	del_timer(&pp->tx_done_timer);
-	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
 
 	return 0;
 }
@@ -2868,11 +2826,6 @@ static int mvneta_probe(struct platform_device *pdev)
 		}
 	}
 
-	pp->tx_done_timer.data = (unsigned long)dev;
-	pp->tx_done_timer.function = mvneta_tx_done_timer_callback;
-	init_timer(&pp->tx_done_timer);
-	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
-
 	pp->tx_ring_size = MVNETA_MAX_TXD;
 	pp->rx_ring_size = MVNETA_MAX_RXD;
 
-- 
1.7.12.1


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0003-net-mvneta-reduce-Tx-coalesce-from-16-to-4-packets.patch"

>From 04a4891c4f9a77052e5aea7d2ade25a3f8da5436 Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Thu, 21 Nov 2013 00:13:06 +0100
Subject: net: mvneta: reduce Tx coalesce from 16 to 4 packets

I'm getting slightly better performance with a smaller Tx coalesce setting,
both with large and short packets. Since it was used differently with the
timer, it is possible that the previous value was more suited for use with
a slow timer.

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index def32a8..d188828 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -212,7 +212,7 @@
 /* Various constants */
 
 /* Coalescing */
-#define MVNETA_TXDONE_COAL_PKTS		16
+#define MVNETA_TXDONE_COAL_PKTS		4
 #define MVNETA_RX_COAL_PKTS		32
 #define MVNETA_RX_COAL_USEC		100
 
-- 
1.7.12.1


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--Q68bSM7Ycu6FN28Q--
