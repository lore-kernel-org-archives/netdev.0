From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/4] e1000e: save skb counts in TX to avoid cache misses
Date: Fri, 23 Apr 2010 17:25:37 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004231719050.16806@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:1884 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab0DXAZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 20:25:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In e1000_tx_map, precompute number of segements and bytecounts which
are derived from fields in skb; these are stored in buffer_info.  When
cleaning tx in e1000_clean_tx_irq use the values in the associated
buffer_info for statistics counting, this eliminates cache misses
on skb fields.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 12648a1..d6da75b 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -188,6 +188,8 @@ struct e1000_buffer {
 			unsigned long time_stamp;
 			u16 length;
 			u16 next_to_watch;
+			unsigned int segs;
+			unsigned int bytecount;
 			u16 mapped_as_page;
 		};
 		/* Rx */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5f70c43..4f5034a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -646,14 +635,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 			cleaned = (i == eop);
 
 			if (cleaned) {
-				struct sk_buff *skb = buffer_info->skb;
-				unsigned int segs, bytecount;
-				segs = skb_shinfo(skb)->gso_segs ?: 1;
-				/* multiply data chunks by size of headers */
-				bytecount = ((segs - 1) * skb_headlen(skb)) +
-					    skb->len;
-				total_tx_packets += segs;
-				total_tx_bytes += bytecount;
+				total_tx_packets += buffer_info->segs;
+				total_tx_bytes += buffer_info->bytecount;
 			}
 
 			e1000_put_txbuf(adapter, buffer_info);
@@ -3906,7 +3889,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
 	unsigned int offset = 0, size, count = 0, i;
-	unsigned int f;
+	unsigned int f, bytecount, segs;
 
 	i = tx_ring->next_to_use;
 
@@ -3965,7 +3948,13 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		}
 	}
 
+	segs = skb_shinfo(skb)->gso_segs ?: 1;
+	/* multiply data chunks by size of headers */
+	bytecount = ((segs - 1) * skb_headlen(skb)) + skb->len;
+
 	tx_ring->buffer_info[i].skb = skb;
+	tx_ring->buffer_info[i].segs = segs;
+	tx_ring->buffer_info[i].bytecount = bytecount;
 	tx_ring->buffer_info[first].next_to_watch = i;
 
 	return count;
