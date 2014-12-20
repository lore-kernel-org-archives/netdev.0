From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/4] net: Detect drivers that reschedule NAPI and exhaust budget
Date: Sun, 21 Dec 2014 07:16:22 +1100
Message-ID: <E1Y2QRq-0001pW-Tn@gondolin.me.apana.org.au>
References: <20141220201453.GA6924@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60328 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaLTUQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 15:16:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
interrupt masking in NAPI) required drivers to leave poll_list
empty if the entire budget is consumed.

We have already had two broken drivers so let's add a check for
this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index f7c4f4e..4a9c424 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4602,6 +4602,15 @@ static int napi_poll(struct napi_struct *n, struct list_head *repoll)
 		napi_gro_flush(n, HZ >= 1000);
 	}
 
+	/* Some drivers may have called napi_schedule
+	 * prior to exhausting their budget.
+	 */
+	if (unlikely(!list_empty(&n->poll_list))) {
+		pr_warn_once("%s: Budget exhausted after napi rescheduled\n",
+			     n->dev ? n->dev->name : "backlog");
+		goto out_unlock;
+	}
+
 	list_add_tail(&n->poll_list, repoll);
 
 out_unlock:
