From: David Miller <davem@davemloft.net>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Tue, 12 Aug 2008 18:15:49 -0700 (PDT)
Message-ID: <20080812.181549.229367205.davem@davemloft.net>
References: <48A23137.2010107@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@robur.slu.se
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51407
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751664AbYHMBPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 21:15:47 -0400
In-Reply-To: <48A23137.2010107@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Tue, 12 Aug 2008 20:56:23 -0400

>      pkt_sched: Schedule qdiscs instead of netdev_queue.

While I'm waiting for your beforehand profile data,
here is a stab in the dark patch which might fix
the problem.

Robert, this could explain some of the things in the
multiqueue testing profile you sent me a week or so
ago.

Let me know how well it works:

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 6affcfa..720cae6 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -89,7 +89,10 @@ extern void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
-	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
+	struct netdev_queue *txq = q->dev_queue;
+
+	if (!netif_tx_queue_stopped(txq) &&
+	    !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
 		__qdisc_run(q);
 }
 
