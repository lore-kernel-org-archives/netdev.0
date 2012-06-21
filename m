From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
Date: Thu, 21 Jun 2012 15:19:26 +0300
Message-ID: <1340281166.15484.16.camel@lb-tlvb-dmitry>
References: <1339616716.22704.661.camel@edumazet-glaptop>
 <20120615.153049.103988387813257203.davem@davemloft.net>
 <504C9EFCA2D0054393414C9CB605C37F1CF19E@SJEXCHMB06.corp.ad.broadcom.com>
 <1340005136.7491.609.camel@edumazet-glaptop>
 <CA+yapKM+H0DHA_UotD7v5LRZfYUeanupxb4=r89+fVSTo-Ad4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"evansr@google.com" <evansr@google.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Merav Sicron" <meravs@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"willemb@google.com" <willemb@google.com>
To: "Tomas Hruby" <thruby@google.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1099 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757039Ab2FUMTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 08:19:37 -0400
In-Reply-To: <CA+yapKM+H0DHA_UotD7v5LRZfYUeanupxb4=r89+fVSTo-Ad4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 10:18 -0700, Tomas Hruby wrote:
> On Mon, Jun 18, 2012 at 12:38 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sat, 2012-06-16 at 07:40 +0000, Dmitry Kravkov wrote:
> >> Hi Eric and Tomas
> >>
> >> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> >> > owner@vger.kernel.org] On Behalf Of David Miller
> >> > Sent: Saturday, June 16, 2012 1:31 AM
> >> > To: eric.dumazet@gmail.com
> >> > Cc: netdev@vger.kernel.org; therbert@google.com; evansr@google.com;
> >> > Eilon Greenstein; Merav Sicron; Yaniv Rosner; willemb@google.com;
> >> > thruby@google.com
> >> > Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
> >> >
> >> > From: Eric Dumazet <eric.dumazet@gmail.com>
> >> > Date: Wed, 13 Jun 2012 21:45:16 +0200
> >> >
> >> > > From: Eric Dumazet <edumazet@google.com>
> >> > >
> >> > > There is a off by one error in the minimal number of BD in
> >> > > bnx2x_start_xmit() and bnx2x_tx_int() before stopping/resuming tx
> >> > queue.
> >> > >
> >> > > A full size GSO packet, with data included in skb->head really needs
> >> > > (MAX_SKB_FRAGS + 4) BDs, because of bnx2x_tx_split()
> >> > >
> >> > > This error triggers if BQL is disabled and heavy TCP transmit traffic
> >> > > occurs.
> >> > >
> >> > > bnx2x_tx_split() definitely can be called, remove a wrong comment.
> >> > >
> >> > > Reported-by: Tomas Hruby <thruby@google.com>
> >> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> >>
> >> Theoretically a can't see how we can reach the case with 4 BDs required apart of frags,
> >> Usually we need 2, when split invoked 3:
> >> 1.Start
> >> 2.Start(split)
> >> 3.Parsing
> >> + Frags
> >>
> >> Next pages descriptors and 2 extras for full indication are not counted as available.
> >>
> >> Practically I'm running the traffic for more then a day without hitting the panic.
> >>
> >> Can you describe the scenario you reproduced this in details? And which code has paniced?
> >
> > Thats pretty immediate.
> 
> yes
> 
> > Disable bql on your NIC.
> >
> > Say you have 4 queues :
> >
> > for q in 0 1 2 3
> > do
> >  echo max >/sys/class/net/eth0/queues/tx-$q/byte_queue_limits/limit_min
> > done
> >
> > Then start 40 netperf
> >
> > for i in `seq 1 40`
> > do
> >  netperf -H 192.168.1.4 &
> > done
> 
> this is enough in my case too, it is perfectly reproducible on
> different machines. Replacing +3 for +4 fixes the problem.

The crash happens with default configuration since
[4acb41903b2f99f3dffd4c3df9acc84ca5942cb2] "net/tcp: Fix tcp memory
limits initialization when !CONFIG_SYSCTL", but it can be hit by
increasing values of tcp_wmem even earlier.

We want to submit a semantic patch into net-next once the two branches are
merged, but the original patch from Eric needs to go -stable.

Thanks.

From: Dmitry Kravkov <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: reservation for NEXT tx BDs

Commit [4acb41903b2f99f3dffd4c3df9acc84ca5942cb2]
net/tcp: Fix tcp memory limits initialization when !CONFIG_SYSCTL
provided new default value for tcp_wmem, since heavy tcp
traffic may cause the TSO packet to consume 20 BDs + 1 for next page
descriptor.
Eric has fixed the reservation in
[bc14786a100cc6a81cd060e8031ec481241b418c]
 bnx2x: fix panic when TX ring is full, this patch provides some
inline explanation for magic numbers are used and fixes condition for
statistics increment in a similar way.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |   15 +++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    9 +++++----
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 7de8241..be75f45 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -616,6 +616,21 @@ struct bnx2x_fastpath {
 #define TX_BD(x)		((x) & MAX_TX_BD)
 #define TX_BD_POFF(x)		((x) & MAX_TX_DESC_CNT)
 
+/* how many NEXT PAGE descriptors may packet occupy */
+#define NEXT_CNT_PER_TX_PKT(bds)	\
+				(((bds) + MAX_TX_DESC_CNT - 1) / \
+				 MAX_TX_DESC_CNT * NEXT_PAGE_TX_DESC_CNT)
+/* max pure data/headers BDs per tx packet:
+ * START_BD		- describes packed
+ * START_BD(splitted)	- includes unpaged data segment for GSO
+ * PARSING_BD		- for TSO and CSUM data
+ * Frag BDs		- decribes pages for frags
+ */
+#define MAX_BDS_PER_TX_PKT	(MAX_SKB_FRAGS + 3)
+/* max BDs per tx packet including next pages */
+#define MAX_DESC_PER_TX_PKT	(MAX_BDS_PER_TX_PKT + \
+				 NEXT_CNT_PER_TX_PKT(MAX_BDS_PER_TX_PKT))
+
 /* The RX BD ring is special, each bd is 8 bytes but the last one is 16 */
 #define NUM_RX_RINGS		8
 #define RX_DESC_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_rx_bd))
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8098eea..c4928ea 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -190,7 +190,7 @@ int bnx2x_tx_int(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata)
 
 		if ((netif_tx_queue_stopped(txq)) &&
 		    (bp->state == BNX2X_STATE_OPEN) &&
-		    (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 4))
+		    (bnx2x_tx_avail(bp, txdata) >= MAX_DESC_PER_TX_PKT))
 			netif_tx_wake_queue(txq);
 
 		__netif_tx_unlock(txq);
@@ -2894,7 +2894,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   txdata->cid, fp_index, txdata_index, txdata, fp); */
 
 	if (unlikely(bnx2x_tx_avail(bp, txdata) <
-		     (skb_shinfo(skb)->nr_frags + 3))) {
+			skb_shinfo(skb)->nr_frags + 3 +
+			NEXT_CNT_PER_TX_PKT(MAX_BDS_PER_TX_PKT))) {
 		fp->eth_q_stats.driver_xoff++;
 		netif_tx_stop_queue(txq);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
@@ -3169,7 +3170,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	txdata->tx_bd_prod += nbd;
 
-	if (unlikely(bnx2x_tx_avail(bp, txdata) < MAX_SKB_FRAGS + 4)) {
+	if (unlikely(bnx2x_tx_avail(bp, txdata) < MAX_DESC_PER_TX_PKT)) {
 		netif_tx_stop_queue(txq);
 
 		/* paired memory barrier is in bnx2x_tx_int(), we have to keep
@@ -3178,7 +3179,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		smp_mb();
 
 		fp->eth_q_stats.driver_xoff++;
-		if (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 4)
+		if (bnx2x_tx_avail(bp, txdata) >= MAX_DESC_PER_TX_PKT)
 			netif_tx_wake_queue(txq);
 	}
 	txdata->tx_pkt++;
-- 
1.7.7.2





> T.
> 
