From: akpm@osdl.org
Subject: [patch 05/10] netpoll: fix NAPI polling race on SMP
Date: Mon, 24 Jan 2005 18:57:12 -0800
Message-ID: <200501250257.j0P2vel20262@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, mpm@selenic.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Matt Mackall <mpm@selenic.com>

This avoids a nasty NAPI race by checking that work was actually scheduled
for the CPU netpoll is running on and pulls the NAPI-specific code out into
a separate function.

Original idea from Jeff Moyer
Tested by Andrew Tridgell

Signed-off-by: Matt Mackall <mpm@selenic.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/core/netpoll.c |   41 +++++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 16 deletions(-)

diff -puN net/core/netpoll.c~netpoll-fix-napi-polling-race-on-smp net/core/netpoll.c
--- 25/net/core/netpoll.c~netpoll-fix-napi-polling-race-on-smp	2005-01-24 18:55:47.325102328 -0800
+++ 25-akpm/net/core/netpoll.c	2005-01-24 18:55:47.329101720 -0800
@@ -65,27 +65,25 @@ static int checksum_udp(struct sk_buff *
 	return csum_fold(skb_checksum(skb, 0, skb->len, skb->csum));
 }
 
-void netpoll_poll(struct netpoll *np)
+/*
+ * Check whether delayed processing was scheduled for our current CPU,
+ * and then manually invoke NAPI polling to pump data off the card.
+ *
+ * In cases where there is bi-directional communications, reading only
+ * one message at a time can lead to packets being dropped by the
+ * network adapter, forcing superfluous retries and possibly timeouts.
+ * Thus, we set our budget to greater than 1.
+ */
+static void poll_napi(struct netpoll *np)
 {
-	/*
-	 * In cases where there is bi-directional communications, reading
-	 * only one message at a time can lead to packets being dropped by
-	 * the network adapter, forcing superfluous retries and possibly
-	 * timeouts.  Thus, we set our budget to a more reasonable value.
-	 */
 	int budget = 16;
 	unsigned long flags;
+	struct softnet_data *queue;
 
-	if(!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
-		return;
-
-	/* Process pending work on NIC */
-	np->dev->poll_controller(np->dev);
-
-	/* If scheduling is stopped, tickle NAPI bits */
 	spin_lock_irqsave(&netpoll_poll_lock, flags);
-	if (np->dev->poll &&
-	    test_bit(__LINK_STATE_RX_SCHED, &np->dev->state)) {
+	queue = &__get_cpu_var(softnet_data);
+	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
+	    !list_empty(&queue->poll_list)) {
 		np->dev->netpoll_rx |= NETPOLL_RX_DROP;
 		atomic_inc(&trapped);
 
@@ -95,6 +93,17 @@ void netpoll_poll(struct netpoll *np)
 		np->dev->netpoll_rx &= ~NETPOLL_RX_DROP;
 	}
 	spin_unlock_irqrestore(&netpoll_poll_lock, flags);
+}
+
+void netpoll_poll(struct netpoll *np)
+{
+	if(!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
+		return;
+
+	/* Process pending work on NIC */
+	np->dev->poll_controller(np->dev);
+	if (np->dev->poll)
+		poll_napi(np);
 
 	zap_completion_queue();
 }
_
