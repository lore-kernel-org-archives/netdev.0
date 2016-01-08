From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH] net: pktgen: support injecting packets for qdisc testing
Date: Thu, 07 Jan 2016 18:09:08 -0800
Message-ID: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34343 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721AbcAHCJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 21:09:33 -0500
Received: by mail-pf0-f178.google.com with SMTP id q63so2266364pfb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 18:09:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add another xmit_mode to pktgen to allow testing xmit functionality
of qdiscs. The new mode "queue_xmit" injects packets at
__dev_queue_xmit() so that qdisc is called.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 Documentation/networking/pktgen.txt |    2 +-
 net/core/pktgen.c                   |   43 +++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index f4be85e..aca62e2 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -365,7 +365,7 @@ flowlen
 rate
 ratep
 
-xmit_mode <start_xmit|netif_receive>
+xmit_mode <start_xmit|netif_receive|queue_xmit>
 
 vlan_cfi
 vlan_id
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2be1444..a86bda5 100644
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
 
@@ -1198,6 +1201,8 @@ static ssize_t pktgen_if_write(struct file *file,
 			 * at module loading time
 			 */
 			pkt_dev->clone_skb = 0;
+		} else if (strcmp(f, "queue_xmit") == 0) {
+			pkt_dev->xmit_mode = M_QUEUE_XMIT;
 		} else {
 			sprintf(pg_result,
 				"xmit_mode -:%s:- unknown\nAvailable modes: %s",
@@ -3432,6 +3437,44 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 #endif
 		} while (--burst > 0);
 		goto out; /* Skips xmit_mode M_START_XMIT */
+	} else if (pkt_dev->xmit_mode == M_QUEUE_XMIT) {
+		atomic_add(burst, &pkt_dev->skb->users);
+		local_bh_disable();
+
+		do {
+			ret = dev_queue_xmit(pkt_dev->skb);
+			switch (ret) {
+			case NET_XMIT_SUCCESS:
+			case NET_XMIT_DROP:
+			case NET_XMIT_CN:
+			case NET_XMIT_POLICED:
+			/* These are all valid return codes for a qdisc so
+			 * unlike start_xmit report this as successful
+			 * transactions. I expect testers will be also be
+			 * reviewing qdisc stats for more details.
+			 */
+				pkt_dev->last_ok = 1;
+				pkt_dev->sofar++;
+				pkt_dev->seq_num++;
+				pkt_dev->tx_bytes += pkt_dev->last_pkt_size;
+				break;
+			case NETDEV_TX_LOCKED:
+			case NETDEV_TX_BUSY:
+			/* qdisc may call dev_hard_start_xmit directly in cases
+			 * where no queues exist e.g. loopback device, virtual
+			 * devices, etc. In this case we need to handle
+			 * NETDEV_TX_ codes.
+			 */
+				pkt_dev->errors++;
+				break;
+			default:
+				net_info_ratelimited("%s xmit error: %d\n",
+						     pkt_dev->odevname, ret);
+				pkt_dev->errors++;
+				break;
+			}
+		} while (--burst > 0);
+		goto out;
 	}
 
 	txq = skb_get_tx_queue(odev, pkt_dev->skb);
