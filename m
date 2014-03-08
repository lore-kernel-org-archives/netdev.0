From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264
 dev_watchdog+0x276/0x280()
Date: Sat, 8 Mar 2014 13:35:28 +0100
Message-ID: <20140308123528.GA2052@electric-eye.fr.zoreil.com>
References: <530332B7.10909@gmail.com>
 <53043521.4060206@gmail.com>
 <5319059E.1010205@gmail.com>
 <5319F40F.4040304@gmail.com>
 <531A737E.4010200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Mailing-List fedora-kernel <kernel@lists.fedoraproject.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Josh Boyer <jwboyer@redhat.com>,
	"Justin M. Forbes" <jforbes@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	Thomas Haller <thaller@redhat.com>
To: poma <pomidorabelisima@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <531A737E.4010200@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(linux.nics@intel.com removed from the Cc: list)

poma <pomidorabelisima@gmail.com> :
[...]
> Francois, do you have this[1] patch applicable for the recent 'r8169.c'?
> 
> $ patch -p5 < r8169-xmit.patch
> patching file r8169.c
> Hunk #1 FAILED at 5870.
> Hunk #2 succeeded at 5540 with fuzz 2 (offset -482 lines).
> Hunk #3 succeeded at 5641 (offset -494 lines).
> 1 out of 3 hunks FAILED -- saving rejects to file r8169.c.rej
[...]
> [1] https://bugzilla.kernel.org/attachment.cgi?id=125961

It applies fine against b01d4e68933ec23e43b1046fa35d593cefcf37d1 but
a bug hides behind the 'start' variable. You may replace it with the
patch below. The "netif_info(..., "frags ..." debug statement is noisy
when enabled. Don't use it.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 91a67ae..b5c7810 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5811,7 +5811,7 @@ static void rtl8169_unmap_tx_skb(struct device *d, struct ring_info *tx_skb,
 
 	dma_unmap_single(d, le64_to_cpu(desc->addr), len, DMA_TO_DEVICE);
 
-	desc->opts1 = 0x00;
+	desc->opts1 &= cpu_to_le32(RingEnd);
 	desc->opts2 = 0x00;
 	desc->addr = 0x00;
 	tx_skb->len = 0;
@@ -5870,10 +5870,42 @@ static void rtl_reset_work(struct rtl8169_private *tp)
 	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 }
 
+static void rtl_desc_trace(struct rtl8169_private *tp, int start, u32 *data)
+{
+	netif_info(tp, drv, tp->dev,
+		   "%02x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
+		   start,
+		   data[ 0], data[ 4], data[ 8], data[12],
+		   data[16], data[20], data[24], data[28]);
+}
+
+static void rtl_tx_ring_trace(struct rtl8169_private *tp)
+{
+	int i, start = 0;
+
+	netif_info(tp, drv, tp->dev,
+		   "Tx dirty: %08x (%02x), Tx current: %08x (%02x)\n",
+		   tp->dirty_tx, tp->dirty_tx % NUM_TX_DESC,
+		   tp->cur_tx, tp->cur_tx % NUM_TX_DESC);
+
+	for (i = 0; i < NUM_TX_DESC / 8; i++) {
+		u32 *data = &tp->TxDescArray[start].opts1;
+		int j;
+
+		for (j = 0; j < 4; j++)
+			rtl_desc_trace(tp, start, data++);
+		netif_info(tp, drv, tp->dev, "\n");
+
+		start += 8;
+	}
+}
+
 static void rtl8169_tx_timeout(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
+	rtl_tx_ring_trace(tp);
+
 	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
@@ -6009,6 +6041,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	txd->addr = cpu_to_le64(mapping);
 
 	frags = rtl8169_xmit_frags(tp, skb, opts);
+	// netif_info(tp, drv, tp->dev, "frags: %d\n", frags);
 	if (frags < 0)
 		goto err_dma_1;
 	else if (frags)
@@ -6022,14 +6055,14 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	wmb();
+	tp->cur_tx += frags + 1;
+
+	smp_wmb();
 
 	/* Anti gcc 2.95.3 bugware (sic) */
 	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
 	txd->opts1 = cpu_to_le32(status);
 
-	tp->cur_tx += frags + 1;
-
 	wmb();
 
 	RTL_W8(TxPoll, NPQ);
@@ -6135,6 +6168,11 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		if (status & DescOwn)
 			break;
 
+		if (!status) {
+			netif_info(tp, tx_done, dev, "Tx miss: %03d\n", entry);
+			break;
+		}
+
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
@@ -6552,6 +6590,8 @@ static int rtl_open(struct net_device *dev)
 
 	rtl_hw_start(dev);
 
+	rtl_tx_ring_trace(tp);
+
 	netif_start_queue(dev);
 
 	rtl_unlock_work(tp);
