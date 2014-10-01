From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next] net: pktgen: packet bursting via skb->xmit_more
Date: Tue, 30 Sep 2014 17:53:21 -0700
Message-ID: <1412124801-32096-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:38371 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaJAAxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 20:53:34 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so115721pde.0
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 17:53:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch demonstrates the effect of delaying update of HW tailptr.
(based on earlier patch by Jesper)

burst=1 is the default. It sends one packet with xmit_more=false
burst=2 sends one packet with xmit_more=true and
        2nd copy of the same packet with xmit_more=false
burst=3 sends two copies of the same packet with xmit_more=true and
        3rd copy with xmit_more=false

Performance with ixgbe (usec 30):
burst=1  tx:9.2 Mpps
burst=2  tx:13.5 Mpps
burst=3  tx:14.5 Mpps full 10G line rate

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

v1 -> v2:
- simplified burst counting logic (suggested by Eric)
- re-tested on ixgbe, mlx4, bnx2x

RFC -> v1:
- added netif_xmit_frozen_or_drv_stopped() check, since bnx2x
  stops the queue and returns TX_OK (suggested by Eric)
- read pkt_dev->burst once to avoid races (suggested by Eric)
- changed 'int burst' to 'unsigned int burst'
- updated doc
- tested on ixgbe, mlx4, bnx2x

Comparing to Jesper patch this one amortizes the cost
of spin_lock and atomic_inc by doing HARD_TX_LOCK and
atomic_add(N) once across N packets.

 Documentation/networking/pktgen.txt |    3 +++
 net/core/pktgen.c                   |   26 ++++++++++++++++++++++++--
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 0dffc6e37902..6915c6b27869 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -99,6 +99,9 @@ Examples:
 
  pgset "clone_skb 1"     sets the number of copies of the same packet
  pgset "clone_skb 0"     use single SKB for all transmits
+ pgset "burst 8"         uses xmit_more API to queue 8 copies of the same
+                         packet and update HW tx queue tail pointer once.
+                         "burst 1" is the default
  pgset "pkt_size 9014"   sets packet size to 9014
  pgset "frags 5"         packet will consist of 5 fragments
  pgset "count 200000"    sets number of packets to send, set to zero
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 5c728aaf8d6c..443256bdcddc 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -387,6 +387,7 @@ struct pktgen_dev {
 	u16 queue_map_min;
 	u16 queue_map_max;
 	__u32 skb_priority;	/* skb priority field */
+	unsigned int burst;	/* number of duplicated packets to burst */
 	int node;               /* Memory node */
 
 #ifdef CONFIG_XFRM
@@ -613,6 +614,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->traffic_class)
 		seq_printf(seq, "     traffic_class: 0x%02x\n", pkt_dev->traffic_class);
 
+	if (pkt_dev->burst > 1)
+		seq_printf(seq, "     burst: %d\n", pkt_dev->burst);
+
 	if (pkt_dev->node >= 0)
 		seq_printf(seq, "     node: %d\n", pkt_dev->node);
 
@@ -1124,6 +1128,16 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->dst_mac_count);
 		return count;
 	}
+	if (!strcmp(name, "burst")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+		if (len < 0)
+			return len;
+
+		i += len;
+		pkt_dev->burst = value < 1 ? 1 : value;
+		sprintf(pg_result, "OK: burst=%d", pkt_dev->burst);
+		return count;
+	}
 	if (!strcmp(name, "node")) {
 		len = num_arg(&user_buffer[i], 10, &value);
 		if (len < 0)
@@ -3297,6 +3311,7 @@ static void pktgen_wait_for_skb(struct pktgen_dev *pkt_dev)
 
 static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
+	unsigned int burst = ACCESS_ONCE(pkt_dev->burst);
 	struct net_device *odev = pkt_dev->odev;
 	struct netdev_queue *txq;
 	int ret;
@@ -3347,8 +3362,10 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->last_ok = 0;
 		goto unlock;
 	}
-	atomic_inc(&(pkt_dev->skb->users));
-	ret = netdev_start_xmit(pkt_dev->skb, odev, txq, false);
+	atomic_add(burst, &pkt_dev->skb->users);
+
+xmit_more:
+	ret = netdev_start_xmit(pkt_dev->skb, odev, txq, --burst > 0);
 
 	switch (ret) {
 	case NETDEV_TX_OK:
@@ -3356,6 +3373,8 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->sofar++;
 		pkt_dev->seq_num++;
 		pkt_dev->tx_bytes += pkt_dev->last_pkt_size;
+		if (burst > 0 && !netif_xmit_frozen_or_drv_stopped(txq))
+			goto xmit_more;
 		break;
 	case NET_XMIT_DROP:
 	case NET_XMIT_CN:
@@ -3374,6 +3393,8 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		atomic_dec(&(pkt_dev->skb->users));
 		pkt_dev->last_ok = 0;
 	}
+	if (unlikely(burst))
+		atomic_sub(burst, &pkt_dev->skb->users);
 unlock:
 	HARD_TX_UNLOCK(odev, txq);
 
@@ -3572,6 +3593,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->svlan_p = 0;
 	pkt_dev->svlan_cfi = 0;
 	pkt_dev->svlan_id = 0xffff;
+	pkt_dev->burst = 1;
 	pkt_dev->node = -1;
 
 	err = pktgen_setup_dev(t->net, pkt_dev, ifname);
-- 
1.7.9.5
