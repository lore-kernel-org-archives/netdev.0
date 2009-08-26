From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Wed, 26 Aug 2009 23:59:56 +0200
Message-ID: <20090826215956.GA5148@ami.dom.local>
References: <200908251518.00762.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:38473 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbZHZWAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 18:00:33 -0400
Received: by bwz22 with SMTP id 22so508494bwz.18
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 15:00:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200908251518.00762.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote, On 08/25/2009 02:18 PM:
...
> Just maybe good idea in next kernels to document this or handle overflow, that 
> it will give warning in kernel. Otherwise user will have non-functional qdisc 
> that will not pass traffic.

OK, if this patch works for you send your Tested-by, please.

Thanks,
Jarek P.
---------------->
pkt_sched: Warn on tokens overflow in tbf_dequeue

After recent change of scheduling resolution some "extreme" configs
can cause token overflows with stalls. This patch warns when tokens
were negative before accounting for a packet length.

Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_tbf.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index e22dfe8..ef191c4 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -191,6 +191,12 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 			return skb;
 		}
 
+		if (unlikely((long)(toks + L2T(q, len)) < 0 ||
+			     (long)(ptoks + L2T_P(q, len) < 0)))
+			if (net_ratelimit())
+				pr_warning("tbf: tokens overflow;"
+					   " fix limits.\n");
+
 		qdisc_watchdog_schedule(&q->watchdog,
 					now + max_t(long, -toks, -ptoks));
 
