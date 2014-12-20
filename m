From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] net: Always poll at least one device in net_rx_action
Date: Sun, 21 Dec 2014 07:16:24 +1100
Message-ID: <E1Y2QRs-0001q5-6u@gondolin.me.apana.org.au>
References: <20141220201453.GA6924@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42076 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbaLTUQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 15:16:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should only perform the softnet_break check after we have polled
at least one device in net_rx_action.  Otherwise a zero or negative
setting of netdev_budget can lock up the whole system.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4a9c424..22b0fb2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4634,16 +4634,15 @@ static void net_rx_action(struct softirq_action *h)
 	while (!list_empty(&list)) {
 		struct napi_struct *n;
 
+		n = list_first_entry(&list, struct napi_struct, poll_list);
+		budget -= napi_poll(n, &repoll);
+
 		/* If softirq window is exhausted then punt.
 		 * Allow this to run for 2 jiffies since which will allow
 		 * an average latency of 1.5/HZ.
 		 */
 		if (unlikely(budget <= 0 || time_after_eq(jiffies, time_limit)))
 			goto softnet_break;
-
-
-		n = list_first_entry(&list, struct napi_struct, poll_list);
-		budget -= napi_poll(n, &repoll);
 	}
 
 	if (!sd_has_rps_ipi_waiting(sd) &&
