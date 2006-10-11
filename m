From: Jean Delvare <khali@linux-fr.org>
Subject: [PATCH] e1000: Real time packets and bytes statistics
Date: Wed, 11 Oct 2006 13:35:57 +0200
Message-ID: <20061011133557.8a404e24.khali@linux-fr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-103-wednesday.noc.nerim.net ([62.4.17.103]:50951 "EHLO
	mallaury.nerim.net") by vger.kernel.org with ESMTP id S932083AbWJKLf5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 07:35:57 -0400
Received: from arrakis.delvare (jdelvare.pck.nerim.net [62.212.121.182])
	by mallaury.nerim.net (Postfix) with SMTP id 08FD44F3E1
	for <netdev@vger.kernel.org>; Wed, 11 Oct 2006 13:35:47 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch is posted for review and comments.

Let the e1000 driver report the most important statistics (rx/tx_bytes
and rx/tx_packets) in real time, rather than every other second. This
is similar to what the e100 driver is doing.

The current asynchronous statistics refresh model makes it impossible
to monitor the network traffic with an interval which isn't a multiple
of 2 seconds. For example, an interval of 5 seconds would result in a
sawtooth diagram (+20%, -20%) for a constant transfer rate. With a 1
second interval it's even worse (0, 200%) of course. This has been
annoying users for years, but was never actually fixed:

LKML thread "e1000 statistics timer", August 2003:
  http://lkml.org/lkml/2003/8/2/127
Bug filled against SUSE LINUX 9.0 Professional, September 2003:
  https://bugzilla.novell.com/show_bug.cgi?id=46464
  (access is restricted, sorry about that)
LKML thread "minor e1000 bug", December 2003:
  http://marc.theaimsgroup.com/?t=107190957000001
Bug filled against Ubuntu Dapper Drake, August 2006:
  https://launchpad.net/distros/ubuntu/+source/linux-source-2.6.15/+bug/55989
Kernel bug #6986, August 2006:
  http://bugzilla.kernel.org/show_bug.cgi?id=6986

rx/tx_bytes will show slightly lower values than before, because the
hardware appears to include the 4-byte ethernet frame CRC into the
frame length, while the driver doesn't. It's probably OK as the
e100, 3c59x and 8139too drivers don't include it either.

I additionally noted a difference of 6 bytes on some TX frames, which
I am not able to explain. It's probably small and rare enough not to
be considered a problem, but if someone can explain it, I would be
grateful.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
---
 drivers/net/e1000/e1000_main.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

--- linux-2.6.19-rc1.orig/drivers/net/e1000/e1000_main.c	2006-10-11 10:53:49.000000000 +0200
+++ linux-2.6.19-rc1/drivers/net/e1000/e1000_main.c	2006-10-11 11:34:41.000000000 +0200
@@ -3118,6 +3118,8 @@
 	               e1000_tx_map(adapter, tx_ring, skb, first,
 	                            max_per_txd, nr_frags, mss));
 
+	adapter->net_stats.tx_packets++;
+	adapter->net_stats.tx_bytes += skb->len;
 	netdev->trans_start = jiffies;
 
 	/* Make sure there is space in the ring for the next send. */
@@ -3384,10 +3386,8 @@
 
 	/* Fill out the OS statistics structure */
 
-	adapter->net_stats.rx_packets = adapter->stats.gprc;
-	adapter->net_stats.tx_packets = adapter->stats.gptc;
-	adapter->net_stats.rx_bytes = adapter->stats.gorcl;
-	adapter->net_stats.tx_bytes = adapter->stats.gotcl;
+	/* rx/tx_packets and rx/tx_bytes are computed in real time by
+	   the driver */
 	adapter->net_stats.multicast = adapter->stats.mprc;
 	adapter->net_stats.collisions = adapter->stats.colc;
 
@@ -3833,6 +3833,7 @@
 				  ((uint32_t)(rx_desc->errors) << 24),
 				  le16_to_cpu(rx_desc->csum), skb);
 
+		length = skb->len;	/* Save actual length for stats */
 		skb->protocol = eth_type_trans(skb, netdev);
 #ifdef CONFIG_E1000_NAPI
 		if (unlikely(adapter->vlgrp &&
@@ -3853,6 +3854,8 @@
 			netif_rx(skb);
 		}
 #endif /* CONFIG_E1000_NAPI */
+		adapter->net_stats.rx_packets++;
+		adapter->net_stats.rx_bytes += length;
 		netdev->last_rx = jiffies;
 
 next_desc:
@@ -4009,6 +4012,7 @@
 copydone:
 		e1000_rx_checksum(adapter, staterr,
 				  le16_to_cpu(rx_desc->wb.lower.hi_dword.csum_ip.csum), skb);
+		length = skb->len;	/* Save actual length for stats */
 		skb->protocol = eth_type_trans(skb, netdev);
 
 		if (likely(rx_desc->wb.upper.header_status &
@@ -4031,6 +4035,8 @@
 			netif_rx(skb);
 		}
 #endif /* CONFIG_E1000_NAPI */
+		adapter->net_stats.rx_packets++;
+		adapter->net_stats.rx_bytes += length;
 		netdev->last_rx = jiffies;
 
 next_desc:

Thanks,
-- 
Jean Delvare
