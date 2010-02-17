From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 13/18] igb: move gso_segs into buffer_info
	structure
Date: Wed, 17 Feb 2010 03:04:37 -0800
Message-ID: <20100217110436.17723.11162.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:42821 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755223Ab0BQLEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:04:55 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This change moves gso_segs into the buffer_info structure to avoid
a possible cache line miss in clean_tx_irq.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    1 +
 drivers/net/igb/igb_main.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 8f07bc0..7854b66 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -141,6 +141,7 @@ struct igb_buffer {
 			u16 length;
 			u16 next_to_watch;
 			u16 mapped_as_page;
+			u16 gso_segs;
 		};
 		/* RX */
 		struct {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a1fe581..91c123f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3641,6 +3641,7 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 	}
 
 	tx_ring->buffer_info[i].skb = skb;
+	tx_ring->buffer_info[i].gso_segs = skb_shinfo(skb)->gso_segs ?: 1;
 	tx_ring->buffer_info[first].next_to_watch = i;
 
 	return ++count;
@@ -5032,7 +5033,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 			if (skb) {
 				unsigned int segs, bytecount;
 				/* gso_segs is currently only valid for tcp */
-				segs = skb_shinfo(skb)->gso_segs ?: 1;
+				segs = buffer_info->gso_segs;
 				/* multiply data chunks by size of headers */
 				bytecount = ((segs - 1) * skb_headlen(skb)) +
 					    skb->len;

