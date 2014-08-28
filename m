From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] pktgen: add flag NO_TIMESTAMP to disable timestamping
Date: Thu, 28 Aug 2014 18:14:47 +0200
Message-ID: <20140828161447.6652.59388.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Robert Olsson <robert@herjulf.se>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbaH1Qno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2014 12:43:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Then testing the TX limits of the stack, then it is useful to
be-able to disable the do_gettimeofday() timetamping on every packet.

This implements a pktgen flag NO_TIMESTAMP which will disable this
call to do_gettimeofday().

The performance change on (my system E5-2695) with skb_clone=0, goes
from TX 2,423,751 pps to 2,567,165 pps with flag NO_TIMESTAMP. Thus,
the cost of do_gettimeofday() or saving is approx 23 nanosec.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/core/pktgen.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 83e2b4b..d9acc16 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -202,6 +202,7 @@
 #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
 #define F_NODE          (1<<15)	/* Node memory alloc*/
 #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
+#define F_NO_TIMESTAMP  (1<<17)	/* Don't timestamp packets (default TS) */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -638,6 +639,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_UDPCSUM)
 		seq_puts(seq, "UDPCSUM  ");
 
+	if (pkt_dev->flags & F_NO_TIMESTAMP)
+		seq_puts(seq, "NO_TIMESTAMP  ");
+
 	if (pkt_dev->flags & F_MPLS_RND)
 		seq_puts(seq,  "MPLS_RND  ");
 
@@ -1243,6 +1247,9 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "!UDPCSUM") == 0)
 			pkt_dev->flags &= ~F_UDPCSUM;
 
+		else if (strcmp(f, "NO_TIMESTAMP") == 0)
+			pkt_dev->flags |= F_NO_TIMESTAMP;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
@@ -1251,6 +1258,7 @@ static ssize_t pktgen_if_write(struct file *file,
 				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, "
 				"MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ, "
 				"QUEUE_MAP_RND, QUEUE_MAP_CPU, UDPCSUM, "
+				"NO_TIMESTAMP, "
 #ifdef CONFIG_XFRM
 				"IPSEC, "
 #endif
@@ -2685,9 +2693,14 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 	pgh->pgh_magic = htonl(PKTGEN_MAGIC);
 	pgh->seq_num = htonl(pkt_dev->seq_num);
 
-	do_gettimeofday(&timestamp);
-	pgh->tv_sec = htonl(timestamp.tv_sec);
-	pgh->tv_usec = htonl(timestamp.tv_usec);
+	if (pkt_dev->flags & F_NO_TIMESTAMP) {
+		pgh->tv_sec = 0;
+		pgh->tv_usec = 0;
+	} else {
+		do_gettimeofday(&timestamp);
+		pgh->tv_sec = htonl(timestamp.tv_sec);
+		pgh->tv_usec = htonl(timestamp.tv_usec);
+	}
 }
 
 static struct sk_buff *pktgen_alloc_skb(struct net_device *dev,
