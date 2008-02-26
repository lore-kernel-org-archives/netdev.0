From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 26 Feb 2008 21:00:33 +0100
Message-ID: <20080226200033.GA6550@ami.dom.local>
References: <47C402A2.8040401@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:1965 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764761AbYBZT52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 14:57:28 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1403805ugc.16
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 11:57:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47C402A2.8040401@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman wrote, On 02/26/2008 01:14 PM:
...
> Luckily, I'm in the lab where my two borrowed servers are today so I 
> have access to their consoles. Hopefully I'll be able to find out why 
> there are hanging. Btw, they don't hang if I disable irqs around the 
> ppp_input() call.

Maybe you've found the same, or there is some other reason yet, but
IMHO this locking break around ppp_input() is wrong. Probably there
is needed more advanced solution, but this should fix the problem if
it really exists (isn't there possible a race e.g. between receive
from socket and from network card?).

Jarek P.
---

 drivers/net/pppol2tp.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index e0b072d..7c6fcb9 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -363,18 +363,17 @@ out:
 	spin_unlock(&session->reorder_q.lock);
 }
 
-/* Dequeue a single skb.
+/* Requeue a single skb.
  */
-static void pppol2tp_recv_dequeue_skb(struct pppol2tp_session *session, struct sk_buff *skb)
+static void pppol2tp_recv_requeue_skb(struct pppol2tp_session *session, struct sk_buff *skb)
 {
 	struct pppol2tp_tunnel *tunnel = session->tunnel;
 	int length = PPPOL2TP_SKB_CB(skb)->length;
 	struct sock *session_sock = NULL;
 
-	/* We're about to requeue the skb, so unlink it and return resources
+	/* We're about to requeue the skb, so return resources
 	 * to its current owner (a socket receive buffer).
 	 */
-	skb_unlink(skb, &session->reorder_q);
 	skb_orphan(skb);
 
 	tunnel->stats.rx_packets++;
@@ -436,14 +435,14 @@ static void pppol2tp_recv_dequeue_skb(struct pppol2tp_session *session, struct s
 static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
 {
 	struct sk_buff *skb;
-	struct sk_buff *tmp;
 
 	/* If the pkt at the head of the queue has the nr that we
 	 * expect to send up next, dequeue it and any other
 	 * in-sequence packets behind it.
 	 */
+again:
 	spin_lock(&session->reorder_q.lock);
-	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
+	skb_queue_walk(&session->reorder_q, skb) {
 		if (time_after(jiffies, PPPOL2TP_SKB_CB(skb)->expires)) {
 			session->stats.rx_seq_discards++;
 			session->stats.rx_errors++;
@@ -469,9 +468,10 @@ static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
 				goto out;
 			}
 		}
+		__skb_unlink(skb, &session->reorder_q);
 		spin_unlock(&session->reorder_q.lock);
-		pppol2tp_recv_dequeue_skb(session, skb);
-		spin_lock(&session->reorder_q.lock);
+		pppol2tp_recv_requeue_skb(session, skb);
+		goto again;
 	}
 
 out:
