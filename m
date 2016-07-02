From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 1/2] net: pktgen: support injecting packets for
 qdisc testing
Date: Sat, 02 Jul 2016 14:12:54 -0700
Message-ID: <20160702211254.13884.81202.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36141 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcGBVNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 17:13:07 -0400
Received: by mail-pf0-f196.google.com with SMTP id i123so12907466pfg.3
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 14:13:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add another xmit_mode to pktgen to allow testing xmit functionality
of qdiscs. The new mode "queue_xmit" injects packets at
__dev_queue_xmit() so that qdisc is called.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/pktgen.c |   42 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f74ab9c..bbd118b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -213,6 +213,7 @@
 /* Xmit modes */
 #define M_START_XMIT		0	/* Default normal TX */
 #define M_NETIF_RECEIVE 	1	/* Inject packets into stack */
+#define M_QUEUE_XMIT		2	/* Inject packet into qdisc */
 
 /* If lock -- protects updating of if_list */
 #define   if_lock(t)           spin_lock(&(t->if_lock));
@@ -626,6 +627,8 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 
 	if (pkt_dev->xmit_mode == M_NETIF_RECEIVE)
 		seq_puts(seq, "     xmit_mode: netif_receive\n");
+	else if (pkt_dev->xmit_mode == M_QUEUE_XMIT)
+		seq_puts(seq, "     xmit_mode: xmit_queue\n");
 
 	seq_puts(seq, "     Flags: ");
 
@@ -1142,8 +1145,10 @@ static ssize_t pktgen_if_write(struct file *file,
 			return len;
 
 		i += len;
-		if ((value > 1) && (pkt_dev->xmit_mode == M_START_XMIT) &&
-		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
+		if ((value > 1) &&
+		    ((pkt_dev->xmit_mode == M_QUEUE_XMIT) ||
+		     ((pkt_dev->xmit_mode == M_START_XMIT) &&
+		     (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))))
 			return -ENOTSUPP;
 		pkt_dev->burst = value < 1 ? 1 : value;
 		sprintf(pg_result, "OK: burst=%d", pkt_dev->burst);
@@ -1198,6 +1203,9 @@ static ssize_t pktgen_if_write(struct file *file,
 			 * at module loading time
 			 */
 			pkt_dev->clone_skb = 0;
+		} else if (strcmp(f, "queue_xmit") == 0) {
+			pkt_dev->xmit_mode = M_QUEUE_XMIT;
+			pkt_dev->last_ok = 1;
 		} else {
 			sprintf(pg_result,
 				"xmit_mode -:%s:- unknown\nAvailable modes: %s",
@@ -3434,6 +3442,36 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 #endif
 		} while (--burst > 0);
 		goto out; /* Skips xmit_mode M_START_XMIT */
+	} else if (pkt_dev->xmit_mode == M_QUEUE_XMIT) {
+		local_bh_disable();
+		atomic_inc(&pkt_dev->skb->users);
+
+		ret = dev_queue_xmit(pkt_dev->skb);
+		switch (ret) {
+		case NET_XMIT_SUCCESS:
+			pkt_dev->sofar++;
+			pkt_dev->seq_num++;
+			pkt_dev->tx_bytes += pkt_dev->last_pkt_size;
+			break;
+		case NET_XMIT_DROP:
+		case NET_XMIT_CN:
+		/* These are all valid return codes for a qdisc but
+		 * indicate packets are being dropped or will likely
+		 * be dropped soon.
+		 */
+		case NETDEV_TX_BUSY:
+		/* qdisc may call dev_hard_start_xmit directly in cases
+		 * where no queues exist e.g. loopback device, virtual
+		 * devices, etc. In this case we need to handle
+		 * NETDEV_TX_ codes.
+		 */
+		default:
+			pkt_dev->errors++;
+			net_info_ratelimited("%s xmit error: %d\n",
+					     pkt_dev->odevname, ret);
+			break;
+		}
+		goto out;
 	}
 
 	txq = skb_get_tx_queue(odev, pkt_dev->skb);
