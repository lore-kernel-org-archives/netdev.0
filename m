From: Dean Nelson <dnelson@redhat.com>
Subject: [PATCH net-next-2.6] e1000: save skb counts in TX to avoid cache misses
Date: Thu, 25 Aug 2011 20:39:24 -0400
Message-ID: <20110826003923.4083.24862.email-sent-by-dnelson@localhost6.localdomain6>
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org, Jeff Kirshier <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24672 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292Ab1HZAj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 20:39:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Virtual Machines with emulated e1000 network adapter running on Parallels'
server were seeing kernel panics due to the e1000 driver dereferencing an
unexpected NULL pointer retrieved from buffer_info->skb.

The problem has been addressed for the e1000e driver, but not for the e1000.
Since the two drivers share similar code in the affected area, a port of the
following e1000e driver commit solves the issue for the e1000 driver:

commit 9ed318d546a29d7a591dbe648fd1a2efe3be1180
Author: Tom Herbert <therbert@google.com>
Date:   Wed May 5 14:02:27 2010 +0000

    e1000e: save skb counts in TX to avoid cache misses

    In e1000_tx_map, precompute number of segements and bytecounts which
    are derived from fields in skb; these are stored in buffer_info.  When
    cleaning tx in e1000_clean_tx_irq use the values in the associated
    buffer_info for statistics counting, this eliminates cache misses
    on skb fields.


Signed-off-by: Dean Nelson <dnelson@redhat.com>

---
This patch (backported to RHEL6.2) was verified by Dmitry Skorodumov to solve
Parallels' reported problem.

 drivers/net/ethernet/intel/e1000/e1000.h      |    2 ++
 drivers/net/ethernet/intel/e1000/e1000_main.c |   18 +++++++++---------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 24f41da..4ea87b1 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -150,6 +150,8 @@ struct e1000_buffer {
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
+	unsigned int segs;
+	unsigned int bytecount;
 	u16 mapped_as_page;
 };
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 7c280e5..4a32c15 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2848,7 +2848,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
 	unsigned int offset = 0, size, count = 0, i;
-	unsigned int f;
+	unsigned int f, bytecount, segs;
 
 	i = tx_ring->next_to_use;
 
@@ -2949,7 +2949,13 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
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
@@ -3623,14 +3629,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			cleaned = (i == eop);
 
 			if (cleaned) {
-				struct sk_buff *skb = buffer_info->skb;
-				unsigned int segs, bytecount;
-				segs = skb_shinfo(skb)->gso_segs ?: 1;
-				/* multiply data chunks by size of headers */
-				bytecount = ((segs - 1) * skb_headlen(skb)) +
-				            skb->len;
-				total_tx_packets += segs;
-				total_tx_bytes += bytecount;
+				total_tx_packets += buffer_info->segs;
+				total_tx_bytes += buffer_info->bytecount;
 			}
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->upper.data = 0;
