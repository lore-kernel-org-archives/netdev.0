From: Ronny Meeus <ronny.meeus@gmail.com>
Subject: [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw ethernet
 socket interface
Date: Sat, 11 Jun 2011 07:04:09 +0200
Message-ID: <78567a0a1d2999f06d8f.1307768649@meeusr-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52155 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251Ab1GKToR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 15:44:17 -0400
Received: by wyg8 with SMTP id 8so2815799wyg.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 12:44:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was running a test: 1 application was sending raw Ethernet packets on a physical looped interface while a second application was receiving packets, so the latter application receives each packet 2 times (once while sending from the context of the first application and a second time while receiving from the hardware).
After some time, the test blocks due to a spinlock reentrance issue in af_packet. Both the sending application and the softIRQ receiving packets enter the spinlock code. After applying the patch below, the issue is resolved.

Signed-off-by: Ronny Meeus <ronny.meeus@gmail.com>

---
 net/packet/af_packet.c |  10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff -r ab5136256418 -r 78567a0a1d29 net/packet/af_packet.c
--- a/net/packet/af_packet.c	Fri Jun 10 20:31:07 2011 +0200
+++ b/net/packet/af_packet.c	Sat Jun 11 07:03:55 2011 +0200
@@ -618,11 +618,11 @@
 	/* drop conntrack reference */
 	nf_reset(skb);
 
-	spin_lock(&sk->sk_receive_queue.lock);
+	spin_lock_bh(&sk->sk_receive_queue.lock);
 	po->stats.tp_packets++;
 	skb->dropcount = atomic_read(&sk->sk_drops);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
-	spin_unlock(&sk->sk_receive_queue.lock);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	sk->sk_data_ready(sk, skb->len);
 	return 0;
 
@@ -718,7 +718,7 @@
 			snaplen = 0;
 	}
 
-	spin_lock(&sk->sk_receive_queue.lock);
+	spin_lock_bh(&sk->sk_receive_queue.lock);
 	h.raw = packet_current_frame(po, &po->rx_ring, TP_STATUS_KERNEL);
 	if (!h.raw)
 		goto ring_is_full;
@@ -730,7 +730,7 @@
 	}
 	if (!po->stats.tp_drops)
 		status &= ~TP_STATUS_LOSING;
-	spin_unlock(&sk->sk_receive_queue.lock);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
 
 	skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
 
@@ -816,7 +816,7 @@
 
 ring_is_full:
 	po->stats.tp_drops++;
-	spin_unlock(&sk->sk_receive_queue.lock);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
 
 	sk->sk_data_ready(sk, 0);
 	kfree_skb(copy_skb);
