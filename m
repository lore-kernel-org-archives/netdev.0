From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] neigh: reduce arp latency
Date: Tue, 09 Aug 2011 17:40:34 +0200
Message-ID: <1312904434.2371.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59843 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab1HIPkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 11:40:37 -0400
Received: by wyg24 with SMTP id 24so78785wyg.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 08:40:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the artificial HZ latency on arp resolution.

Instead of firing a timer in one jiffy (up to 10 ms if HZ=100), lets
send the ARP message immediately.

Before patch :

# arp -d 192.168.20.108 ; ping -c 3 192.168.20.108
PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
64 bytes from 192.168.20.108: icmp_seq=1 ttl=64 time=9.91 ms
64 bytes from 192.168.20.108: icmp_seq=2 ttl=64 time=0.065 ms
64 bytes from 192.168.20.108: icmp_seq=3 ttl=64 time=0.061 ms

After patch :

$ arp -d 192.168.20.108 ; ping -c 3 192.168.20.108
PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
64 bytes from 192.168.20.108: icmp_seq=1 ttl=64 time=0.152 ms
64 bytes from 192.168.20.108: icmp_seq=2 ttl=64 time=0.064 ms
64 bytes from 192.168.20.108: icmp_seq=3 ttl=64 time=0.074 ms

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/neighbour.c |   32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8fab9b0..d99f908 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -844,6 +844,19 @@ static void neigh_invalidate(struct neighbour *neigh)
 	skb_queue_purge(&neigh->arp_queue);
 }
 
+static void neigh_probe(struct neighbour *neigh)
+	__releases(neigh->lock)
+{
+	struct sk_buff *skb = skb_peek(&neigh->arp_queue);
+	/* keep skb alive even if arp_queue overflows */
+	if (skb)
+		skb = skb_copy(skb, GFP_ATOMIC);
+	write_unlock(&neigh->lock);
+	neigh->ops->solicit(neigh, skb);
+	atomic_inc(&neigh->probes);
+	kfree_skb(skb);
+}
+
 /* Called when a timer expires for a neighbour entry. */
 
 static void neigh_timer_handler(unsigned long arg)
@@ -920,14 +933,7 @@ static void neigh_timer_handler(unsigned long arg)
 			neigh_hold(neigh);
 	}
 	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
-		struct sk_buff *skb = skb_peek(&neigh->arp_queue);
-		/* keep skb alive even if arp_queue overflows */
-		if (skb)
-			skb = skb_copy(skb, GFP_ATOMIC);
-		write_unlock(&neigh->lock);
-		neigh->ops->solicit(neigh, skb);
-		atomic_inc(&neigh->probes);
-		kfree_skb(skb);
+		neigh_probe(neigh);
 	} else {
 out:
 		write_unlock(&neigh->lock);
@@ -943,6 +949,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
 	int rc;
 	unsigned long now;
+	bool immediate_probe = false;
 
 	write_lock_bh(&neigh->lock);
 
@@ -957,7 +964,8 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 			atomic_set(&neigh->probes, neigh->parms->ucast_probes);
 			neigh->nud_state     = NUD_INCOMPLETE;
 			neigh->updated = jiffies;
-			neigh_add_timer(neigh, now + 1);
+			neigh_add_timer(neigh, now + HZ);
+			immediate_probe = true;
 		} else {
 			neigh->nud_state = NUD_FAILED;
 			neigh->updated = jiffies;
@@ -989,7 +997,11 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 		rc = 1;
 	}
 out_unlock_bh:
-	write_unlock_bh(&neigh->lock);
+	if (immediate_probe)
+		neigh_probe(neigh);
+	else
+		write_unlock(&neigh->lock);
+	local_bh_enable();
 	return rc;
 }
 EXPORT_SYMBOL(__neigh_event_send);


