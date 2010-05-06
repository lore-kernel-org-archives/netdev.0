From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/4] e1000e: save skb counts in TX to avoid cache
	misses
Date: Wed, 05 May 2010 17:02:27 -0700
Message-ID: <20100506000221.8042.64794.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Tom Herbert <therbert@google.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:35901
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751349Ab0EFACr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 20:02:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

In e1000_tx_map, precompute number of segements and bytecounts which
are derived from fields in skb; these are stored in buffer_info.  When
cleaning tx in e1000_clean_tx_irq use the values in the associated
buffer_info for statistics counting, this eliminates cache misses
on skb fields.

Signed-off-by: Tom Herbert <therbert@google.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h  |    2 ++
 drivers/net/e1000e/netdev.c |   18 +++++++++---------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 906c4da..c0b3db4 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -189,6 +189,8 @@ struct e1000_buffer {
 			unsigned long time_stamp;
 			u16 length;
 			u16 next_to_watch;
+			unsigned int segs;
+			unsigned int bytecount;
 			u16 mapped_as_page;
 		};
 		/* Rx */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0a16465..1eb9b59 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1001,14 +1001,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
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
@@ -4277,7 +4271,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
 	unsigned int offset = 0, size, count = 0, i;
-	unsigned int f;
+	unsigned int f, bytecount, segs;
 
 	i = tx_ring->next_to_use;
 
@@ -4337,7 +4331,13 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
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

