From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] pktgen: Add NOINIT option to leave packet data uninitialized
Date: Fri, 16 May 2014 12:34:01 +0200
Message-ID: <01eda9d1e9de457f72e0b48e22633c05cca5146f.1400236390.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38171 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756938AbaEPKeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 06:34:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memset() on the packet data is expensive and severely limiting
the pps throughput for large frame sizes.

Considering that pktgen requires root privileges to run it is safe
to introduce an option to optionally avoid the memset() and leave
the packet data uninitialized.

VM test results, 2 VCPU, 2 threads, pkt_size=9K:

    12.44%  -11.15%  [kernel.kallsyms]   [k] memset
     4.84%   +1.58%  [kernel.kallsyms]   [k] get_page_from_freelist

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 Documentation/networking/pktgen.txt |  3 +++
 net/core/pktgen.c                   | 16 ++++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 0e30c78..349b9d2 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -114,6 +114,8 @@ Examples:
                               UDPCSUM,
                               IPSEC # IPsec encapsulation (needs CONFIG_XFRM)
                               NODE_ALLOC # node specific memory allocation
+			      NOINIT # leave packet data uninitialized
+			             # (BEWARE! May expose kernel memory!)
 
  pgset spi SPI_VALUE     Set specific SA used to transform packet.
 
@@ -254,6 +256,7 @@ flag
   UDPCSUM
   IPSEC
   NODE_ALLOC
+  NOINIT
 
 dst_min
 dst_max
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 0304f98..8278df8 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -201,6 +201,7 @@
 #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
 #define F_NODE          (1<<15)	/* Node memory alloc*/
 #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
+#define F_NOINIT        (1<<17)	/* Keep packet data uninitialized */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -675,6 +676,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_NODE)
 		seq_printf(seq, "NODE_ALLOC  ");
 
+	if (pkt_dev->flags & F_NOINIT)
+		seq_puts(seq, "NOINIT  ");
+
 	seq_puts(seq, "\n");
 
 	/* not really stopped, more like last-running-at */
@@ -1242,6 +1246,12 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "!UDPCSUM") == 0)
 			pkt_dev->flags &= ~F_UDPCSUM;
 
+		else if (strcmp(f, "NOINIT") == 0)
+			pkt_dev->flags |= F_NOINIT;
+
+		else if (strcmp(f, "!NOINIT") == 0)
+			pkt_dev->flags &= ~F_NOINIT;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
@@ -2633,7 +2643,8 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 	datalen -= sizeof(*pgh);
 
 	if (pkt_dev->nfrags <= 0) {
-		memset(skb_put(skb, datalen), 0, datalen);
+		if (!(pkt_dev->flags & F_NOINIT))
+			memset(skb_put(skb, datalen), 0, datalen);
 	} else {
 		int frags = pkt_dev->nfrags;
 		int i, len;
@@ -2644,7 +2655,8 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 			frags = MAX_SKB_FRAGS;
 		len = datalen - frags * PAGE_SIZE;
 		if (len > 0) {
-			memset(skb_put(skb, len), 0, len);
+			if (!(pkt_dev->flags & F_NOINIT))
+				memset(skb_put(skb, len), 0, len);
 			datalen = frags * PAGE_SIZE;
 		}
 
-- 
1.8.3.1
