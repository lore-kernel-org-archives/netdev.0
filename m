From: Roman Kagan <rkagan@parallels.com>
Subject: [PATCH] e1000: save skb counts in TX to avoid cache misses
Date: Thu,  7 Jun 2012 16:49:56 +0400
Message-ID: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
Cc: Roman Kagan <rkagan@parallels.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Dean Nelson <dnelson@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Upstream commit 31c15a2f24ebdab14333d9bf5df49757842ae2ec with paths
adjusted to compensate for the drivers/net/ethernet/intel reorg in
dee1ad47f2ee75f5146d83ca757c1b7861c34c3b]

Author: Dean Nelson <dnelson@redhat.com>
Date:   Thu Aug 25 14:39:24 2011 +0000

    e1000: save skb counts in TX to avoid cache misses

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
    Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Roman Kagan <rkagan@parallels.com>
---
 drivers/net/e1000/e1000.h      |    2 ++
 drivers/net/e1000/e1000_main.c |   18 +++++++++---------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 8676899..2c71884 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -150,6 +150,8 @@ struct e1000_buffer {
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
+	unsigned int segs;
+	unsigned int bytecount;
 	u16 mapped_as_page;
 };
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 76e8af0..99525f9 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2798,7 +2798,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
 	unsigned int offset = 0, size, count = 0, i;
-	unsigned int f;
+	unsigned int f, bytecount, segs;
 
 	i = tx_ring->next_to_use;
 
@@ -2899,7 +2899,13 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
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
@@ -3573,14 +3579,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
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
-- 
1.7.10.2
