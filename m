From: Robert Olsson <robert@herjulf.net>
Subject: [PATCH] pktgen node allocation
Date: Fri, 19 Mar 2010 09:44:30 +0100
Message-ID: <19363.14702.909265.380669@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@herjulf.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av9-1-sn2.hy.skanova.net ([81.228.8.179]:35985 "EHLO
	av9-1-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab0CSJFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 05:05:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi,
Here is patch to manipulate packet node allocation and implicitly 
how packets are DMA'd etc.

The flag NODE_ALLOC enables the function and numa_node_id();
when enabled it can also be explicitly controlled via a new 
node parameter

Tested this with 10 Intel 82599 ports w. TYAN S7025 E5520 CPU's.
Was able to TX/DMA ~80 Gbit/s to Ethernet wires.

Cheers
					--ro


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 4392381..c195fd0 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -169,7 +169,7 @@
 #include <asm/dma.h>
 #include <asm/div64.h>		/* do_div */
 
-#define VERSION 	"2.72"
+#define VERSION 	"2.73"
 #define IP_NAME_SZ 32
 #define MAX_MPLS_LABELS 16 /* This is the max label stack depth */
 #define MPLS_STACK_BOTTOM htonl(0x00000100)
@@ -190,6 +190,7 @@
 #define F_IPSEC_ON    (1<<12)	/* ipsec on for flows */
 #define F_QUEUE_MAP_RND (1<<13)	/* queue map Random */
 #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
+#define F_NODE          (1<<15)	/* Node memory alloc*/
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -372,6 +373,7 @@ struct pktgen_dev {
 
 	u16 queue_map_min;
 	u16 queue_map_max;
+	int node;               /* Memory node */
 
 #ifdef CONFIG_XFRM
 	__u8	ipsmode;		/* IPSEC mode (config) */
@@ -607,6 +609,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->traffic_class)
 		seq_printf(seq, "     traffic_class: 0x%02x\n", pkt_dev->traffic_class);
 
+	if (pkt_dev->node >= 0)
+		seq_printf(seq, "     node: %d\n", pkt_dev->node);
+
 	seq_printf(seq, "     Flags: ");
 
 	if (pkt_dev->flags & F_IPV6)
@@ -660,6 +665,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_SVID_RND)
 		seq_printf(seq, "SVID_RND  ");
 
+	if (pkt_dev->flags & F_NODE)
+		seq_printf(seq, "NODE_ALLOC  ");
+
 	seq_puts(seq, "\n");
 
 	/* not really stopped, more like last-running-at */
@@ -1074,6 +1082,21 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->dst_mac_count);
 		return count;
 	}
+	if (!strcmp(name, "node")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+		if (len < 0)
+			return len;
+
+		i += len;
+
+		if(node_possible(value)) {
+			pkt_dev->node = value;
+			sprintf(pg_result, "OK: node=%d", pkt_dev->node);
+		}
+		else
+			sprintf(pg_result, "ERROR: node not possible");
+		return count;
+	}
 	if (!strcmp(name, "flag")) {
 		char f[32];
 		memset(f, 0, 32);
@@ -1166,12 +1189,18 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "!IPV6") == 0)
 			pkt_dev->flags &= ~F_IPV6;
 
+		else if (strcmp(f, "NODE_ALLOC") == 0)
+			pkt_dev->flags |= F_NODE;
+
+		else if (strcmp(f, "!NODE_ALLOC") == 0)
+			pkt_dev->flags &= ~F_NODE;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
 				f,
 				"IPSRC_RND, IPDST_RND, UDPSRC_RND, UDPDST_RND, "
-				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ, IPSEC\n");
+				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ, IPSEC, NODE_ALLOC\n");
 			return count;
 		}
 		sprintf(pg_result, "OK: flags=0x%x", pkt_dev->flags);
@@ -2572,9 +2601,27 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	mod_cur_headers(pkt_dev);
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
-	skb = __netdev_alloc_skb(odev,
-				 pkt_dev->cur_pkt_size + 64
-				 + datalen + pkt_dev->pkt_overhead, GFP_NOWAIT);
+
+	if(pkt_dev->flags & F_NODE) {
+		int node;
+
+		if(pkt_dev->node >= 0)
+			node = pkt_dev->node;
+		else
+			node =  numa_node_id();
+
+		skb = __alloc_skb(NET_SKB_PAD + pkt_dev->cur_pkt_size + 64
+				  + datalen + pkt_dev->pkt_overhead, GFP_NOWAIT, 0, node);
+		if (likely(skb)) {
+			skb_reserve(skb, NET_SKB_PAD);
+			skb->dev = odev;
+		}
+	}
+	else
+	  skb = __netdev_alloc_skb(odev,
+				   pkt_dev->cur_pkt_size + 64
+				   + datalen + pkt_dev->pkt_overhead, GFP_NOWAIT);
+
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
@@ -3674,6 +3721,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->svlan_p = 0;
 	pkt_dev->svlan_cfi = 0;
 	pkt_dev->svlan_id = 0xffff;
+	pkt_dev->node = -1;
 
 	err = pktgen_setup_dev(pkt_dev, ifname);
 	if (err)

