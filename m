From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH net v6 0/4] tg3: tx_pending fixes
Date: Thu,  4 Sep 2014 18:30:43 -0700
Message-ID: <1409880647-14887-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Extra info regarding patch 4:
This version of the series calls gso_segment() without NETIF_F_SG. This=
 avoids
the need for desc_cnt_est in tg3_tso_bug() as in previous versions of t=
his
patch series. Since Michael had previously raised concerns about gso_se=
gment
without SG, I ran some netperf throughput tests. I used a small patch t=
o force
tg3_tso_bug() to be called even when it is not needed [1].

root@linux-y64m:~# perf stat -r10 -ad netperf -H 192.168.9.30 -l60 -T 0=
,0 -t omni -- -d send

* original tg3_tso_bug() (ie. without patch 4/4)
  781=C2=B12 10^6bits/s
  6.60 cycle/bit
* gso_segment() without SG (current series)
  801.0=C2=B10.9 10^6bits/s
  5.79 cycle/bit
* gso_segment() with SG (alternate patch 4/4 [2])
  783=C2=B12 10^6bits/s
  7.25 cycle/bit

(For reference, with the original tg3_tso_bug() implementation but with=
out
forcing it to be called, the throughput I get is 822=C2=B11 10^6bits/s =
@ 3.82
cycle/bit with 0 invocations of tg3_tso_bug)

[1] fault injection patch

---
 drivers/net/ethernet/broadcom/tg3.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index cb77ae9..f9144dc 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -47,6 +47,7 @@
 #include <linux/ssb/ssb_driver_gige.h>
 #include <linux/hwmon.h>
 #include <linux/hwmon-sysfs.h>
+#include <linux/debugfs.h>
=20
 #include <net/checksum.h>
 #include <net/ip.h>
@@ -468,6 +469,27 @@ static const struct {
 #define TG3_NUM_TEST	ARRAY_SIZE(ethtool_test_keys)
=20
=20
+/* debugging stuff */
+static u32 tg3_do_mangle;
+static struct dentry *tg3_mangle_debugfs;
+
+static int __init tg3_mod_init(void)
+{
+	tg3_mangle_debugfs =3D debugfs_create_u32("tg3_do_mangle", S_IRUGO |
+						S_IWUSR, NULL,
+						&tg3_do_mangle);
+
+	return 0;
+}
+module_init(tg3_mod_init);
+
+static void __exit tg3_mod_exit(void)
+{
+	debugfs_remove(tg3_mangle_debugfs);
+}
+module_exit(tg3_mod_exit);
+/* --- */
+
 static void tg3_write32(struct tg3 *tp, u32 off, u32 val)
 {
 	writel(val, tp->regs + off);
@@ -8048,6 +8070,11 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 				would_hit_hwbug =3D 1;
 				break;
 			}
+
+			if (tg3_do_mangle > 0) {
+				would_hit_hwbug =3D 4;
+				break;
+			}
 		}
 	}
=20
--=20

[2] alternate patch 4

call gso_segment with SG (without removing it, actually)

---
 drivers/net/ethernet/broadcom/tg3.c | 80 +++++++++++++++++++++++++++--=
--------
 1 file changed, 59 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index ee93b51..1ecb393 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -205,6 +205,9 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS f=
lag, unsigned long *bits)
 /* minimum number of free TX descriptors required to wake up TX proces=
s */
 #define TG3_TX_WAKEUP_THRESH(tnapi)	max_t(u32, (tnapi)->tx_pending / 4=
, \
 					      MAX_SKB_FRAGS + 1)
+/* estimate a certain number of descriptors per gso segment */
+#define TG3_TX_DESC_PER_SEG(seg_nb)	((seg_nb) * 3)
+
 #define TG3_TX_BD_DMA_MAX_2K		2048
 #define TG3_TX_BD_DMA_MAX_4K		4096
=20
@@ -7852,6 +7855,8 @@ static int tigon3_dma_hwbug_workaround(struct tg3=
_napi *tnapi,
 }
=20
 static netdev_tx_t tg3_start_xmit(struct sk_buff *, struct net_device =
*);
+static netdev_tx_t __tg3_start_xmit(struct sk_buff *, struct net_devic=
e *,
+				    u32);
=20
 /* Returns true if the queue has been stopped. Note that it may have b=
een
  * restarted since.
@@ -7888,27 +7893,56 @@ static inline bool tg3_maybe_stop_txq(struct tg=
3_napi *tnapi,
 static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 		       struct netdev_queue *txq, struct sk_buff *skb)
 {
-	struct sk_buff *segs, *nskb;
-	u32 frag_cnt_est =3D skb_shinfo(skb)->gso_segs * 3;
+	unsigned int segs_remaining =3D skb_shinfo(skb)->gso_segs;
+	u32 desc_cnt_est =3D TG3_TX_DESC_PER_SEG(segs_remaining);
=20
-	/* Estimate the number of fragments in the worst case */
-	tg3_maybe_stop_txq(tnapi, txq, frag_cnt_est, frag_cnt_est);
-	if (netif_tx_queue_stopped(txq))
-		return NETDEV_TX_BUSY;
+	if (unlikely(tg3_tx_avail(tnapi) <=3D desc_cnt_est)) {
+		if (!skb_is_nonlinear(skb) || skb_linearize(skb))
+			goto tg3_tso_bug_drop;
+		tg3_start_xmit(skb, tp->dev);
+	} else {
+		struct sk_buff *segs, *nskb;
=20
-	segs =3D skb_gso_segment(skb, tp->dev->features &
-				    ~(NETIF_F_TSO | NETIF_F_TSO6));
-	if (IS_ERR(segs) || !segs)
-		goto tg3_tso_bug_end;
+		segs =3D skb_gso_segment(skb, tp->dev->features &
+				       ~(NETIF_F_TSO | NETIF_F_TSO6));
+		if (IS_ERR(segs) || !segs)
+			goto tg3_tso_bug_drop;
=20
-	do {
-		nskb =3D segs;
-		segs =3D segs->next;
-		nskb->next =3D NULL;
-		tg3_start_xmit(nskb, tp->dev);
-	} while (segs);
+		do {
+			unsigned int desc_cnt =3D skb_shinfo(segs)->nr_frags + 1;
+
+			nskb =3D segs;
+			segs =3D segs->next;
+			nskb->next =3D NULL;
+
+			if (tg3_tx_avail(tnapi) <=3D segs_remaining - 1 +
+			    desc_cnt && skb_linearize(nskb)) {
+				nskb->next =3D segs;
+				segs =3D nskb;
+				do {
+					nskb =3D segs->next;
+
+					dev_kfree_skb_any(segs);
+					segs =3D nskb;
+				} while (segs);
+				tg3_maybe_stop_txq(tnapi, txq, MAX_SKB_FRAGS + 1,
+						   TG3_TX_WAKEUP_THRESH(tnapi));
+
+				goto tg3_tso_bug_drop;
+			}
+			if (--segs_remaining)
+				__tg3_start_xmit(nskb, tp->dev, segs_remaining);
+			else
+				tg3_start_xmit(nskb, tp->dev);
+		} while (segs);
=20
-tg3_tso_bug_end:
+		dev_kfree_skb_any(skb);
+	}
+
+	return NETDEV_TX_OK;
+
+tg3_tso_bug_drop:
+	tp->tx_dropped++;
 	dev_kfree_skb_any(skb);
=20
 	return NETDEV_TX_OK;
@@ -7917,6 +7951,12 @@ tg3_tso_bug_end:
 /* hard_start_xmit for all devices */
 static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_devi=
ce *dev)
 {
+	return __tg3_start_xmit(skb, dev, MAX_SKB_FRAGS + 1);
+}
+
+static netdev_tx_t __tg3_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev, u32 stop_thresh)
+{
 	struct tg3 *tp =3D netdev_priv(dev);
 	u32 len, entry, base_flags, mss, vlan =3D 0;
 	u32 budget;
@@ -8129,7 +8169,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff =
*skb, struct net_device *dev)
 	tw32_tx_mbox(tnapi->prodmbox, entry);
=20
 	tnapi->tx_prod =3D entry;
-	tg3_maybe_stop_txq(tnapi, txq, MAX_SKB_FRAGS + 1,
+	tg3_maybe_stop_txq(tnapi, txq, stop_thresh,
 			   TG3_TX_WAKEUP_THRESH(tnapi));
=20
 	mmiowb();
@@ -12363,9 +12403,7 @@ static int tg3_set_ringparam(struct net_device =
*dev, struct ethtool_ringparam *e
 	if ((ering->rx_pending > tp->rx_std_ring_mask) ||
 	    (ering->rx_jumbo_pending > tp->rx_jmb_ring_mask) ||
 	    (ering->tx_pending > TG3_TX_RING_SIZE - 1) ||
-	    (ering->tx_pending <=3D MAX_SKB_FRAGS + 1) ||
-	    (tg3_flag(tp, TSO_BUG) &&
-	     (ering->tx_pending <=3D (MAX_SKB_FRAGS * 3))))
+	    (ering->tx_pending <=3D MAX_SKB_FRAGS + 1))
 		return -EINVAL;
=20
 	if (netif_running(dev)) {
--=20
