From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH] pktgen: skb bursting via skb->xmit_more API
Date: Wed, 27 Aug 2014 23:13:00 +0200
Message-ID: <20140827211300.26976.52104.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965327AbaH0VN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 17:13:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just demonstrates the effect of delaying the HW tailptr,
the skb->xmit_more API should likely have some wrappers.

One issue is the possible need to flush/write the tailptr on
the exit path... marked with FIXME.

Let me demonstrate the performance effect of bulking packet with pktgen.

These results is a **single** CPU pktgen TX via script:
 https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen02_burst.sh

Cmdline args:
 ./pktgen02_burst.sh -i eth5 -d 192.168.21.4 -m 00:12:c0:80:1d:54 -b $skb_burst

Special case skb_burst=1 does not burst, but activates the
skb_burst_count++ and writing to skb->xmit_more.

Performance
 skb_burst=0  tx:5614370 pps
 skb_burst=1  tx:5571279 pps ( -1.38 ns (worse))
 skb_burst=2  tx:6942821 pps ( 35.46 ns)
 skb_burst=3  tx:7556214 pps ( 11.69 ns)
 skb_burst=4  tx:7740632 pps ( 3.15 ns)
 skb_burst=5  tx:7972489 pps ( 3.76 ns)
 skb_burst=6  tx:8129856 pps ( 2.43 ns)
 skb_burst=7  tx:8281671 pps ( 2.25 ns)
 skb_burst=8  tx:8383790 pps ( 1.47 ns)
 skb_burst=9  tx:8451248 pps ( 0.95 ns)
 skb_burst=10 tx:8503571 pps ( 0.73 ns)
 skb_burst=16 tx:8745878 pps ( 3.26 ns)
 skb_burst=24 tx:8871629 pps ( 1.62 ns)
 skb_burst=32 tx:8945166 pps ( 0.93 ns)

skb_burst=(0 vs 32) improvement:
 (1/5614370*10^9)-(1/8945166*10^9) = 66.32 ns
  + 3330796 pps
---

 net/core/pktgen.c |   34 +++++++++++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 83e2b4b..ac5f7c4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -269,6 +269,8 @@ struct pktgen_dev {
 
 	__u64 allocated_skbs;
 	__u32 clone_count;
+
+	int skb_burst_count;	/* counter for skb_burst */
 	int last_ok;		/* Was last skb sent?
 				 * Or a failed transmit of some sort?
 				 * This will keep sequence numbers in order
@@ -386,6 +388,9 @@ struct pktgen_dev {
 	u16 queue_map_min;
 	u16 queue_map_max;
 	__u32 skb_priority;	/* skb priority field */
+	int skb_burst;		/* Bursting SKBs by delaying HW
+				 * tailptr via skb->xmit_more
+				 */
 	int node;               /* Memory node */
 
 #ifdef CONFIG_XFRM
@@ -612,6 +617,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->traffic_class)
 		seq_printf(seq, "     traffic_class: 0x%02x\n", pkt_dev->traffic_class);
 
+	if (pkt_dev->skb_burst)
+		seq_printf(seq, "     skb_burst: %d\n", pkt_dev->skb_burst);
+
 	if (pkt_dev->node >= 0)
 		seq_printf(seq, "     node: %d\n", pkt_dev->node);
 
@@ -1120,6 +1128,16 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->dst_mac_count);
 		return count;
 	}
+	if (!strcmp(name, "skb_burst")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+		if (len < 0)
+			return len;
+
+		i += len;
+		pkt_dev->skb_burst = value;
+		sprintf(pg_result, "OK: skb_burst=%d", pkt_dev->skb_burst);
+		return count;
+	}
 	if (!strcmp(name, "node")) {
 		len = num_arg(&user_buffer[i], 10, &value);
 		if (len < 0)
@@ -3165,6 +3183,7 @@ static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 		return -EINVAL;
 	}
 
+	// FIXME: Possibly missing a tailptr flush here...
 	pkt_dev->running = 0;
 	kfree_skb(pkt_dev->skb);
 	pkt_dev->skb = NULL;
@@ -3327,6 +3346,16 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	queue_map = skb_get_queue_mapping(pkt_dev->skb);
 	txq = netdev_get_tx_queue(odev, queue_map);
 
+	/* Do HW level bursting via skb->xmit_more */
+	if (pkt_dev->skb_burst > 0) {
+		if (pkt_dev->skb_burst_count++ < pkt_dev->skb_burst) {
+			pkt_dev->skb->xmit_more = 1;
+		} else {
+			pkt_dev->skb->xmit_more = 0;
+			pkt_dev->skb_burst_count = 1;
+		}
+	}
+
 	local_bh_disable();
 
 	HARD_TX_LOCK(odev, txq, smp_processor_id());
@@ -3337,7 +3366,8 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		goto unlock;
 	}
 	atomic_inc(&(pkt_dev->skb->users));
-	ret = netdev_start_xmit(pkt_dev->skb, odev);
+	ret =  odev->netdev_ops->ndo_start_xmit(pkt_dev->skb, odev);
+	//ret = netdev_start_xmit(pkt_dev->skb, odev);
 
 	switch (ret) {
 	case NETDEV_TX_OK:
@@ -3562,6 +3592,8 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->svlan_p = 0;
 	pkt_dev->svlan_cfi = 0;
 	pkt_dev->svlan_id = 0xffff;
+	pkt_dev->skb_burst = 0;
+	pkt_dev->skb_burst_count = 1;
 	pkt_dev->node = -1;
 
 	err = pktgen_setup_dev(t->net, pkt_dev, ifname);
