From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] net: Rearrange loop in net_rx_action
Date: Sun, 21 Dec 2014 07:16:25 +1100
Message-ID: <E1Y2QRt-0001qq-Lp@gondolin.me.apana.org.au>
References: <20141220201453.GA6924@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40380 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaLTUQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 15:16:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch rearranges the loop in net_rx_action to reduce the
amount of jumping back and forth when reading the code.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |   26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 22b0fb2..dd565a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4631,9 +4631,15 @@ static void net_rx_action(struct softirq_action *h)
 	list_splice_init(&sd->poll_list, &list);
 	local_irq_enable();
 
-	while (!list_empty(&list)) {
+	for (;;) {
 		struct napi_struct *n;
 
+		if (list_empty(&list)) {
+			if (!sd_has_rps_ipi_waiting(sd) && list_empty(&repoll))
+				return;
+			break;
+		}
+
 		n = list_first_entry(&list, struct napi_struct, poll_list);
 		budget -= napi_poll(n, &repoll);
 
@@ -4641,15 +4647,13 @@ static void net_rx_action(struct softirq_action *h)
 		 * Allow this to run for 2 jiffies since which will allow
 		 * an average latency of 1.5/HZ.
 		 */
-		if (unlikely(budget <= 0 || time_after_eq(jiffies, time_limit)))
-			goto softnet_break;
+		if (unlikely(budget <= 0 ||
+			     time_after_eq(jiffies, time_limit))) {
+			sd->time_squeeze++;
+			break;
+		}
 	}
 
-	if (!sd_has_rps_ipi_waiting(sd) &&
-	    list_empty(&list) &&
-	    list_empty(&repoll))
-		return;
-out:
 	local_irq_disable();
 
 	list_splice_tail_init(&sd->poll_list, &list);
@@ -4659,12 +4663,6 @@ out:
 		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 
 	net_rps_action_and_irq_enable(sd);
-
-	return;
-
-softnet_break:
-	sd->time_squeeze++;
-	goto out;
 }
 
 struct netdev_adjacent {
