From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH v2 3/3] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Thu, 21 Aug 2014 21:31:36 -0700
Message-ID: <1408681896.8268.7.camel@prashant>
References: <1408658240-6811-1-git-send-email-bpoirier@suse.de>
	 <1408658240-6811-3-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:18224 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831AbaHVEjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 00:39:40 -0400
In-Reply-To: <1408658240-6811-3-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-21 at 14:57 -0700, Benjamin Poirier wrote:
> In tg3_set_ringparam(), the tx_pending test to cover the cases where
> tg3_tso_bug() is entered has two problems
> 1) the check is only done for certain hardware whereas the workaround
> is now used more broadly. IOW, the check may not be performed when it
> is needed.
> 2) the check is too optimistic.
>=20
> For example, with a 5761 (SHORT_DMA_BUG), tg3_set_ringparam() skips o=
ver the
> "tx_pending <=3D (MAX_SKB_FRAGS * 3)" check because TSO_BUG is false.=
 Even if it
> did do the check, with a full sized skb, frag_cnt_est =3D 135 but the=
 check is
> for <=3D MAX_SKB_FRAGS * 3 (=3D 17 * 3 =3D 51). So the check is insuf=
ficient. This
> leads to the following situation: by setting, ex. tx_pending =3D 100,=
 there can
> be an skb that triggers tg3_tso_bug() and that is large enough to cau=
se
> tg3_tso_bug() to stop the queue even when it is empty. We then end up=
 with a
> netdev watchdog transmit timeout.
>=20
> Given that 1) some of the conditions tested for in tg3_tx_frag_set() =
apply
> regardless of the chipset flags and that 2) it is difficult to estima=
te ahead
> of time the max possible number of frames that a large skb may be spl=
it into
> by gso, we instead take the approach of adjusting dev->gso_max_segs a=
ccording
> to the requested tx_pending size.
>=20
> This puts us in the exceptional situation that a single skb that trig=
gers
> tg3_tso_bug() may require the entire tx ring. Usually the tx queue is=
 woken up
> when at least a quarter of it is available (TG3_TX_WAKEUP_THRESH) but=
 that
> would be insufficient now. To avoid useless wakeups, the tx queue wak=
e up
> threshold is made dynamic. Likewise, usually the tx queue is stopped =
as soon
> as an skb with max frags may overrun it. Since the skbs submitted fro=
m
> tg3_tso_bug() use a controlled number of descriptors, the tx queue st=
op
> threshold may be lowered.
>=20
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> ---
> Changes v1->v2
> * in tg3_set_ringparam(), reduce gso_max_segs further to budget 3 des=
criptors
>   per gso seg instead of only 1 as in v1
> * in tg3_tso_bug(), check that this estimation (3 desc/seg) holds, ot=
herwise
>   linearize some skbs as needed
> * in tg3_start_xmit(), make the queue stop threshold a parameter, for=
 the
>   reason explained in the commit description
>=20
> I was concerned that this last change, because of the extra call in t=
he
> default xmit path, may impact performance so I performed an rr latenc=
y test
> but I did not measure a significant impact. That test was with defaul=
t mtu and
> ring size.
>=20
> # perf stat -r10 -ad netperf -H 192.168.9.30 -l60 -T 0,0 -t omni -- -=
d rr
>=20
> * without patches
> 	rr values: 7039.63 6865.03 6939.21 6919.31 6931.88 6932.74 6925.1 69=
53.33 6868.43 6935.65
> 	sample size: 10
> 	mean: 6931.031
> 	standard deviation: 48.10918
> 	quantiles: 6865.03 6920.757 6932.31 6938.32 7039.63
> 	6930=C2=B150
>=20
>  Performance counter stats for 'netperf -H 192.168.9.30 -l60 -T 0,0 -=
t omni -- -d rr' (10 runs):
>=20
>      480643.024723 task-clock                #    8.001 CPUs utilized=
            ( +-  0.00% ) [100.00%]
>            855,136 context-switches          #    0.002 M/sec        =
            ( +-  0.23% ) [100.00%]
>                521 CPU-migrations            #    0.000 M/sec        =
            ( +-  6.49% ) [100.00%]
>                104 page-faults               #    0.000 M/sec        =
            ( +-  2.73% )
>    298,416,906,437 cycles                    #    0.621 GHz          =
            ( +-  4.08% ) [15.01%]
>    812,072,320,370 stalled-cycles-frontend   #  272.13% frontend cycl=
es idle     ( +-  1.89% ) [25.01%]
>    685,633,562,247 stalled-cycles-backend    #  229.76% backend  cycl=
es idle     ( +-  2.50% ) [35.00%]
>    117,665,891,888 instructions              #    0.39  insns per cyc=
le
>                                              #    6.90  stalled cycle=
s per insn  ( +-  2.22% ) [45.00%]
>     26,158,399,505 branches                  #   54.424 M/sec        =
            ( +-  2.10% ) [50.00%]
>        205,688,614 branch-misses             #    0.79% of all branch=
es          ( +-  0.78% ) [50.00%]
>     27,882,474,171 L1-dcache-loads           #   58.011 M/sec        =
            ( +-  1.98% ) [50.00%]
>        369,911,372 L1-dcache-load-misses     #    1.33% of all L1-dca=
che hits    ( +-  0.62% ) [50.00%]
>         76,240,847 LLC-loads                 #    0.159 M/sec        =
            ( +-  1.04% ) [40.00%]
>              3,220 LLC-load-misses           #    0.00% of all LL-cac=
he hits     ( +- 19.49% ) [ 5.00%]
>=20
>       60.074059340 seconds time elapsed                              =
            ( +-  0.00% )
>=20
> * with patches
> 	rr values: 6732.65 6920.1 6909.46 7032.41 6864.43 6897.6 6815.19 696=
7.83 6849.23 6929.52
> 	sample size: 10
> 	mean: 6891.842
> 	standard deviation: 82.91901
> 	quantiles: 6732.65 6853.03 6903.53 6927.165 7032.41
> 	6890=C2=B180
>=20
>  Performance counter stats for 'netperf -H 192.168.9.30 -l60 -T 0,0 -=
t omni -- -d rr' (10 runs):
>=20
>      480675.949728 task-clock                #    8.001 CPUs utilized=
            ( +-  0.01% ) [100.00%]
>            850,461 context-switches          #    0.002 M/sec        =
            ( +-  0.37% ) [100.00%]
>                564 CPU-migrations            #    0.000 M/sec        =
            ( +-  5.67% ) [100.00%]
>                417 page-faults               #    0.000 M/sec        =
            ( +- 76.04% )
>    287,019,442,295 cycles                    #    0.597 GHz          =
            ( +-  7.16% ) [15.01%]
>    828,198,830,689 stalled-cycles-frontend   #  288.55% frontend cycl=
es idle     ( +-  3.01% ) [25.01%]
>    718,230,307,166 stalled-cycles-backend    #  250.24% backend  cycl=
es idle     ( +-  3.53% ) [35.00%]
>    117,976,598,188 instructions              #    0.41  insns per cyc=
le
>                                              #    7.02  stalled cycle=
s per insn  ( +-  4.06% ) [45.00%]
>     26,715,853,108 branches                  #   55.580 M/sec        =
            ( +-  3.77% ) [50.00%]
>        198,787,673 branch-misses             #    0.74% of all branch=
es          ( +-  0.86% ) [50.00%]
>     28,416,922,166 L1-dcache-loads           #   59.119 M/sec        =
            ( +-  3.54% ) [50.00%]
>        367,613,007 L1-dcache-load-misses     #    1.29% of all L1-dca=
che hits    ( +-  0.47% ) [50.00%]
>         75,260,575 LLC-loads                 #    0.157 M/sec        =
            ( +-  2.24% ) [40.00%]
>              5,777 LLC-load-misses           #    0.01% of all LL-cac=
he hits     ( +- 36.03% ) [ 5.00%]
>=20
>       60.077898757 seconds time elapsed                              =
            ( +-  0.01% )
>=20
> I reproduced this bug using the same approach explained in patch 1.
> The bug reproduces with tx_pending <=3D 135
>=20
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 67 +++++++++++++++++++++++++++=
++--------
>  drivers/net/ethernet/broadcom/tg3.h |  1 +
>  2 files changed, 54 insertions(+), 14 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethern=
et/broadcom/tg3.c
> index 0cecd6d..c29f2e3 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -204,6 +204,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAG=
S flag, unsigned long *bits)
>  /* minimum number of free TX descriptors required to wake up TX proc=
ess */
>  #define TG3_TX_WAKEUP_THRESH(tnapi)	max_t(u32, (tnapi)->tx_pending /=
 4, \
>  					      MAX_SKB_FRAGS + 1)
> +/* estimate a certain number of descriptors per gso segment */
> +#define TG3_TX_DESC_PER_SEG(seg_nb)	((seg_nb) * 3)
> +#define TG3_TX_SEG_PER_DESC(desc_nb)	((desc_nb) / 3)
> +
>  #define TG3_TX_BD_DMA_MAX_2K		2048
>  #define TG3_TX_BD_DMA_MAX_4K		4096
> =20
> @@ -6609,10 +6613,10 @@ static void tg3_tx(struct tg3_napi *tnapi)
>  	smp_mb();
> =20
>  	if (unlikely(netif_tx_queue_stopped(txq) &&
> -		     (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))) {
> +		     (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh))) {
>  		__netif_tx_lock(txq, smp_processor_id());
>  		if (netif_tx_queue_stopped(txq) &&
> -		    (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))
> +		    (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh))
>  			netif_tx_wake_queue(txq);
>  		__netif_tx_unlock(txq);
>  	}
> @@ -7830,6 +7834,8 @@ static int tigon3_dma_hwbug_workaround(struct t=
g3_napi *tnapi,
>  }
> =20
>  static netdev_tx_t tg3_start_xmit(struct sk_buff *, struct net_devic=
e *);
> +static netdev_tx_t __tg3_start_xmit(struct sk_buff *, struct net_dev=
ice *,
> +				    u32);
> =20
>  /* Use GSO to workaround all TSO packets that meet HW bug conditions
>   * indicated in tg3_tx_frag_set()
> @@ -7838,11 +7844,13 @@ static int tg3_tso_bug(struct tg3 *tp, struct=
 tg3_napi *tnapi,
>  		       struct netdev_queue *txq, struct sk_buff *skb)
>  {
>  	struct sk_buff *segs, *nskb;
> -	u32 frag_cnt_est =3D skb_shinfo(skb)->gso_segs * 3;
> +	unsigned int segs_remaining =3D skb_shinfo(skb)->gso_segs;
> +	u32 desc_cnt_est =3D TG3_TX_DESC_PER_SEG(segs_remaining);
> =20
> -	/* Estimate the number of fragments in the worst case */
> -	if (unlikely(tg3_tx_avail(tnapi) <=3D frag_cnt_est)) {
> +	if (unlikely(tg3_tx_avail(tnapi) <=3D desc_cnt_est)) {
>  		netif_tx_stop_queue(txq);
> +		tnapi->wakeup_thresh =3D desc_cnt_est;
> +		BUG_ON(tnapi->wakeup_thresh >=3D tnapi->tx_pending);
> =20
>  		/* netif_tx_stop_queue() must be done before checking
>  		 * checking tx index in tg3_tx_avail() below, because in
> @@ -7850,7 +7858,7 @@ static int tg3_tso_bug(struct tg3 *tp, struct t=
g3_napi *tnapi,
>  		 * netif_tx_queue_stopped().
>  		 */
>  		smp_mb();
> -		if (tg3_tx_avail(tnapi) <=3D frag_cnt_est)
> +		if (tg3_tx_avail(tnapi) <=3D tnapi->wakeup_thresh)
>  			return NETDEV_TX_BUSY;
> =20
>  		netif_tx_wake_queue(txq);
> @@ -7858,14 +7866,33 @@ static int tg3_tso_bug(struct tg3 *tp, struct=
 tg3_napi *tnapi,
> =20
>  	segs =3D skb_gso_segment(skb, tp->dev->features &
>  				    ~(NETIF_F_TSO | NETIF_F_TSO6));
> -	if (IS_ERR(segs) || !segs)
> +	if (IS_ERR_OR_NULL(segs))
>  		goto tg3_tso_bug_end;
> =20
>  	do {
> +		unsigned int desc_cnt =3D skb_shinfo(segs)->nr_frags + 1;
> +
>  		nskb =3D segs;
>  		segs =3D segs->next;
>  		nskb->next =3D NULL;
> -		tg3_start_xmit(nskb, tp->dev);
> +
> +		if (tg3_tx_avail(tnapi) <=3D segs_remaining - 1 + desc_cnt &&
> +		    skb_linearize(nskb)) {
> +			nskb->next =3D segs;
> +			segs =3D nskb;
> +			do {
> +				nskb =3D segs->next;
> +
> +				dev_kfree_skb_any(segs);
> +				segs =3D nskb;
> +			} while (segs);
If skb_linearize() fails need to increment the tp->tx_dropped count
> +			goto tg3_tso_bug_end;
> +		}
> +		segs_remaining--;
> +		if (segs_remaining)
> +			__tg3_start_xmit(nskb, tp->dev, segs_remaining);
To clarify passing segs_remaining will make sure the queue is never
stopped correct ?
> +		else
> +			tg3_start_xmit(nskb, tp->dev);
>  	} while (segs);
> =20
>  tg3_tso_bug_end:
> @@ -7877,6 +7904,12 @@ tg3_tso_bug_end:
>  /* hard_start_xmit for all devices */
>  static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_de=
vice *dev)
>  {
> +	return __tg3_start_xmit(skb, dev, MAX_SKB_FRAGS + 1);
> +}
> +
> +static netdev_tx_t __tg3_start_xmit(struct sk_buff *skb,
> +				    struct net_device *dev, u32 stop_thresh)
> +{
>  	struct tg3 *tp =3D netdev_priv(dev);
>  	u32 len, entry, base_flags, mss, vlan =3D 0;
>  	u32 budget;
> @@ -7905,12 +7938,17 @@ static netdev_tx_t tg3_start_xmit(struct sk_b=
uff *skb, struct net_device *dev)
>  	if (unlikely(budget <=3D (skb_shinfo(skb)->nr_frags + 1))) {
>  		if (!netif_tx_queue_stopped(txq)) {
>  			netif_tx_stop_queue(txq);
> +			tnapi->wakeup_thresh =3D TG3_TX_WAKEUP_THRESH(tnapi);
> =20
>  			/* This is a hard error, log it. */
>  			netdev_err(dev,
>  				   "BUG! Tx Ring full when queue awake!\n");
>  		}
> -		return NETDEV_TX_BUSY;
> +		smp_mb();
> +		if (tg3_tx_avail(tnapi) <=3D tnapi->wakeup_thresh)
> +			return NETDEV_TX_BUSY;
> +
> +		netif_tx_wake_queue(txq);
>  	}
> =20
>  	entry =3D tnapi->tx_prod;
> @@ -8087,8 +8125,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buf=
f *skb, struct net_device *dev)
>  	tw32_tx_mbox(tnapi->prodmbox, entry);
> =20
>  	tnapi->tx_prod =3D entry;
> -	if (unlikely(tg3_tx_avail(tnapi) <=3D (MAX_SKB_FRAGS + 1))) {
> +	if (unlikely(tg3_tx_avail(tnapi) <=3D stop_thresh)) {
>  		netif_tx_stop_queue(txq);
> +		tnapi->wakeup_thresh =3D TG3_TX_WAKEUP_THRESH(tnapi);
> =20
>  		/* netif_tx_stop_queue() must be done before checking
>  		 * checking tx index in tg3_tx_avail() below, because in
> @@ -8096,7 +8135,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buf=
f *skb, struct net_device *dev)
>  		 * netif_tx_queue_stopped().
>  		 */
>  		smp_mb();
> -		if (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi))
> +		if (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh)
>  			netif_tx_wake_queue(txq);
>  	}
> =20
> @@ -12319,9 +12358,7 @@ static int tg3_set_ringparam(struct net_devic=
e *dev, struct ethtool_ringparam *e
>  	if ((ering->rx_pending > tp->rx_std_ring_mask) ||
>  	    (ering->rx_jumbo_pending > tp->rx_jmb_ring_mask) ||
>  	    (ering->tx_pending > TG3_TX_RING_SIZE - 1) ||
> -	    (ering->tx_pending <=3D MAX_SKB_FRAGS + 1) ||
> -	    (tg3_flag(tp, TSO_BUG) &&
> -	     (ering->tx_pending <=3D (MAX_SKB_FRAGS * 3))))
> +	    (ering->tx_pending <=3D MAX_SKB_FRAGS + 1))
>  		return -EINVAL;
> =20
>  	if (netif_running(dev)) {
> @@ -12341,6 +12378,7 @@ static int tg3_set_ringparam(struct net_devic=
e *dev, struct ethtool_ringparam *e
>  	if (tg3_flag(tp, JUMBO_RING_ENABLE))
>  		tp->rx_jumbo_pending =3D ering->rx_jumbo_pending;
> =20
> +	dev->gso_max_segs =3D TG3_TX_SEG_PER_DESC(ering->tx_pending - 1);
>  	for (i =3D 0; i < tp->irq_max; i++)
>  		tp->napi[i].tx_pending =3D ering->tx_pending;
> =20
> @@ -17817,6 +17855,7 @@ static int tg3_init_one(struct pci_dev *pdev,
>  		else
>  			sndmbx +=3D 0xc;
>  	}
> +	dev->gso_max_segs =3D TG3_TX_SEG_PER_DESC(TG3_DEF_TX_RING_PENDING -=
 1);
> =20
>  	tg3_init_coal(tp);
> =20
> diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethern=
et/broadcom/tg3.h
> index 461acca..6a7e13d 100644
> --- a/drivers/net/ethernet/broadcom/tg3.h
> +++ b/drivers/net/ethernet/broadcom/tg3.h
> @@ -3006,6 +3006,7 @@ struct tg3_napi {
>  	u32				tx_pending;
>  	u32				last_tx_cons;
>  	u32				prodmbox;
> +	u32				wakeup_thresh;
>  	struct tg3_tx_buffer_desc	*tx_ring;
>  	struct tg3_tx_ring_info		*tx_buffers;
> =20
