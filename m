From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH 1/3] tg3: Limit minimum tx queue wakeup threshold
Date: Thu, 21 Aug 2014 15:04:24 -0700
Message-ID: <20140821220424.GB7117@f1.synalogic.ca>
References: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
 <1408485647.7404.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408485647.7404.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/08/19 15:00, Michael Chan wrote:
> On Tue, 2014-08-19 at 11:52 -0700, Benjamin Poirier wrote:=20
> > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethe=
rnet/broadcom/tg3.c
> > index 3ac5d23..b11c0fd 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > @@ -202,7 +202,8 @@ static inline void _tg3_flag_clear(enum TG3_FLA=
GS flag, unsigned long *bits)
> >  #endif
> > =20
> >  /* minimum number of free TX descriptors required to wake up TX pr=
ocess */
> > -#define TG3_TX_WAKEUP_THRESH(tnapi)            ((tnapi)->tx_pendin=
g / 4)
> > +#define TG3_TX_WAKEUP_THRESH(tnapi)    max_t(u32, (tnapi)->tx_pend=
ing / 4, \
> > +                                             MAX_SKB_FRAGS + 1)
>=20
> I think we should precompute this and store it in something like
> tp->tx_wake_thresh.

I've tried this by adding the following patch at the end of the v2
series but I did not measure a significant latency improvement. Was
there another reason for the change?

Here are the performance results. The first set of numbers are the same
as those found in patch v2 3/3.

# perf stat -r10 -ad netperf -H 192.168.9.30 -l60 -T 0,0 -t omni -- -d =
rr

* with patches 1-3
	rr values: 6732.65 6920.1 6909.46 7032.41 6864.43 6897.6 6815.19 6967.=
83 6849.23 6929.52
	sample size: 10
	mean: 6891.842
	standard deviation: 82.91901
	quantiles: 6732.65 6853.03 6903.53 6927.165 7032.41
	6890=B180

 Performance counter stats for 'netperf -H 192.168.9.30 -l60 -T 0,0 -t =
omni -- -d rr' (10 runs):

     480675.949728 task-clock                #    8.001 CPUs utilized  =
          ( +-  0.01% ) [100.00%]
           850,461 context-switches          #    0.002 M/sec          =
          ( +-  0.37% ) [100.00%]
               564 CPU-migrations            #    0.000 M/sec          =
          ( +-  5.67% ) [100.00%]
               417 page-faults               #    0.000 M/sec          =
          ( +- 76.04% )
   287,019,442,295 cycles                    #    0.597 GHz            =
          ( +-  7.16% ) [15.01%]
   828,198,830,689 stalled-cycles-frontend   #  288.55% frontend cycles=
 idle     ( +-  3.01% ) [25.01%]
   718,230,307,166 stalled-cycles-backend    #  250.24% backend  cycles=
 idle     ( +-  3.53% ) [35.00%]
   117,976,598,188 instructions              #    0.41  insns per cycle
                                             #    7.02  stalled cycles =
per insn  ( +-  4.06% ) [45.00%]
    26,715,853,108 branches                  #   55.580 M/sec          =
          ( +-  3.77% ) [50.00%]
       198,787,673 branch-misses             #    0.74% of all branches=
          ( +-  0.86% ) [50.00%]
    28,416,922,166 L1-dcache-loads           #   59.119 M/sec          =
          ( +-  3.54% ) [50.00%]
       367,613,007 L1-dcache-load-misses     #    1.29% of all L1-dcach=
e hits    ( +-  0.47% ) [50.00%]
        75,260,575 LLC-loads                 #    0.157 M/sec          =
          ( +-  2.24% ) [40.00%]
             5,777 LLC-load-misses           #    0.01% of all LL-cache=
 hits     ( +- 36.03% ) [ 5.00%]

      60.077898757 seconds time elapsed                                =
          ( +-  0.01% )

* with patches 1-3 + tx_wake_thresh_def
	rr values: 6636.87 6874.05 6916.29 6961.68 6941.3 6841.44 6829.05 6806=
=2E55 6846.04 6958.39
	sample size: 10
	mean: 6861.166
	standard deviation: 96.67967
	quantiles: 6636.87 6832.148 6860.045 6935.048 6961.68
	6900=B1100

 Performance counter stats for 'netperf -H 192.168.9.30 -l60 -T 0,0 -t =
omni -- -d rr' (10 runs):

     480688.653656 task-clock                #    8.001 CPUs utilized  =
          ( +-  0.01% ) [100.00%]
           846,980 context-switches          #    0.002 M/sec          =
          ( +-  0.40% ) [100.00%]
               524 CPU-migrations            #    0.000 M/sec          =
          ( +- 11.82% ) [100.00%]
               420 page-faults               #    0.000 M/sec          =
          ( +- 75.31% )
   275,602,421,981 cycles                    #    0.573 GHz            =
          ( +-  3.23% ) [15.01%]
   806,335,406,844 stalled-cycles-frontend   #  292.57% frontend cycles=
 idle     ( +-  2.16% ) [25.01%]
   640,757,376,054 stalled-cycles-backend    #  232.49% backend  cycles=
 idle     ( +-  2.46% ) [35.00%]
   113,241,018,220 instructions              #    0.41  insns per cycle
                                             #    7.12  stalled cycles =
per insn  ( +-  1.93% ) [45.00%]
    25,479,064,973 branches                  #   53.005 M/sec          =
          ( +-  1.96% ) [50.00%]
       205,483,191 branch-misses             #    0.81% of all branches=
          ( +-  0.75% ) [50.00%]
    27,209,883,125 L1-dcache-loads           #   56.606 M/sec          =
          ( +-  1.87% ) [50.00%]
       361,721,478 L1-dcache-load-misses     #    1.33% of all L1-dcach=
e hits    ( +-  0.51% ) [50.00%]
        80,669,260 LLC-loads                 #    0.168 M/sec          =
          ( +-  1.01% ) [40.00%]
             8,846 LLC-load-misses           #    0.01% of all LL-cache=
 hits     ( +- 34.01% ) [ 5.00%]

      60.079761525 seconds time elapsed                                =
          ( +-  0.01% )

---
 drivers/net/ethernet/broadcom/tg3.c | 27 ++++++++++++++++-----------
 drivers/net/ethernet/broadcom/tg3.h |  5 +++--
 2 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index c29f2e3..81e390b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6478,10 +6478,11 @@ static void tg3_dump_state(struct tg3 *tp)
 			   tnapi->hw_status->idx[0].tx_consumer);
=20
 		netdev_err(tp->dev,
-		"%d: NAPI info [%08x:%08x:(%04x:%04x:%04x):%04x:(%04x:%04x:%04x:%04x=
)]\n",
+		"%d: NAPI info [%08x:%08x:(%04x:%04x:%04x:%04x):%04x:(%04x:%04x:%04x=
:%04x)]\n",
 			   i,
 			   tnapi->last_tag, tnapi->last_irq_tag,
 			   tnapi->tx_prod, tnapi->tx_cons, tnapi->tx_pending,
+			   tnapi->tx_wake_thresh_cur,
 			   tnapi->rx_rcb_ptr,
 			   tnapi->prodring.rx_std_prod_idx,
 			   tnapi->prodring.rx_std_cons_idx,
@@ -6613,10 +6614,10 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	smp_mb();
=20
 	if (unlikely(netif_tx_queue_stopped(txq) &&
-		     (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh))) {
+		     (tg3_tx_avail(tnapi) > tnapi->tx_wake_thresh_cur))) {
 		__netif_tx_lock(txq, smp_processor_id());
 		if (netif_tx_queue_stopped(txq) &&
-		    (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh))
+		    (tg3_tx_avail(tnapi) > tnapi->tx_wake_thresh_cur))
 			netif_tx_wake_queue(txq);
 		__netif_tx_unlock(txq);
 	}
@@ -7849,8 +7850,8 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3=
_napi *tnapi,
=20
 	if (unlikely(tg3_tx_avail(tnapi) <=3D desc_cnt_est)) {
 		netif_tx_stop_queue(txq);
-		tnapi->wakeup_thresh =3D desc_cnt_est;
-		BUG_ON(tnapi->wakeup_thresh >=3D tnapi->tx_pending);
+		tnapi->tx_wake_thresh_cur =3D desc_cnt_est;
+		BUG_ON(tnapi->tx_wake_thresh_cur >=3D tnapi->tx_pending);
=20
 		/* netif_tx_stop_queue() must be done before checking
 		 * checking tx index in tg3_tx_avail() below, because in
@@ -7858,7 +7859,7 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3=
_napi *tnapi,
 		 * netif_tx_queue_stopped().
 		 */
 		smp_mb();
-		if (tg3_tx_avail(tnapi) <=3D tnapi->wakeup_thresh)
+		if (tg3_tx_avail(tnapi) <=3D tnapi->tx_wake_thresh_cur)
 			return NETDEV_TX_BUSY;
=20
 		netif_tx_wake_queue(txq);
@@ -7938,14 +7939,14 @@ static netdev_tx_t __tg3_start_xmit(struct sk_b=
uff *skb,
 	if (unlikely(budget <=3D (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_tx_queue_stopped(txq)) {
 			netif_tx_stop_queue(txq);
-			tnapi->wakeup_thresh =3D TG3_TX_WAKEUP_THRESH(tnapi);
+			tnapi->tx_wake_thresh_cur =3D tnapi->tx_wake_thresh_def;
=20
 			/* This is a hard error, log it. */
 			netdev_err(dev,
 				   "BUG! Tx Ring full when queue awake!\n");
 		}
 		smp_mb();
-		if (tg3_tx_avail(tnapi) <=3D tnapi->wakeup_thresh)
+		if (tg3_tx_avail(tnapi) <=3D tnapi->tx_wake_thresh_cur)
 			return NETDEV_TX_BUSY;
=20
 		netif_tx_wake_queue(txq);
@@ -8127,7 +8128,7 @@ static netdev_tx_t __tg3_start_xmit(struct sk_buf=
f *skb,
 	tnapi->tx_prod =3D entry;
 	if (unlikely(tg3_tx_avail(tnapi) <=3D stop_thresh)) {
 		netif_tx_stop_queue(txq);
-		tnapi->wakeup_thresh =3D TG3_TX_WAKEUP_THRESH(tnapi);
+		tnapi->tx_wake_thresh_cur =3D tnapi->tx_wake_thresh_def;
=20
 		/* netif_tx_stop_queue() must be done before checking
 		 * checking tx index in tg3_tx_avail() below, because in
@@ -8135,7 +8136,7 @@ static netdev_tx_t __tg3_start_xmit(struct sk_buf=
f *skb,
 		 * netif_tx_queue_stopped().
 		 */
 		smp_mb();
-		if (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh)
+		if (tg3_tx_avail(tnapi) > tnapi->tx_wake_thresh_cur)
 			netif_tx_wake_queue(txq);
 	}
=20
@@ -12379,8 +12380,11 @@ static int tg3_set_ringparam(struct net_device=
 *dev, struct ethtool_ringparam *e
 		tp->rx_jumbo_pending =3D ering->rx_jumbo_pending;
=20
 	dev->gso_max_segs =3D TG3_TX_SEG_PER_DESC(ering->tx_pending - 1);
-	for (i =3D 0; i < tp->irq_max; i++)
+	for (i =3D 0; i < tp->irq_max; i++) {
 		tp->napi[i].tx_pending =3D ering->tx_pending;
+		tp->napi[i].tx_wake_thresh_def =3D
+			TG3_TX_WAKEUP_THRESH(&tp->napi[i]);
+	}
=20
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
@@ -17820,6 +17824,7 @@ static int tg3_init_one(struct pci_dev *pdev,
=20
 		tnapi->tp =3D tp;
 		tnapi->tx_pending =3D TG3_DEF_TX_RING_PENDING;
+		tnapi->tx_wake_thresh_def =3D TG3_TX_WAKEUP_THRESH(tnapi);
=20
 		tnapi->int_mbox =3D intmbx;
 		if (i <=3D 4)
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet=
/broadcom/tg3.h
index 6a7e13d..44a21cb 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3004,11 +3004,12 @@ struct tg3_napi {
 	u32				tx_prod	____cacheline_aligned;
 	u32				tx_cons;
 	u32				tx_pending;
-	u32				last_tx_cons;
 	u32				prodmbox;
-	u32				wakeup_thresh;
+	u32				tx_wake_thresh_cur;
+	u32				tx_wake_thresh_def;
 	struct tg3_tx_buffer_desc	*tx_ring;
 	struct tg3_tx_ring_info		*tx_buffers;
+	u32				last_tx_cons;
=20
 	dma_addr_t			status_mapping;
 	dma_addr_t			rx_rcb_mapping;
