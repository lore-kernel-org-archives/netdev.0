From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] hrtimer: convert net::sched_cbq to the new hrtimer apis
Date: Sun, 7 Sep 2008 11:25:26 -0700
Message-ID: <20080907112526.47718231@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55003 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbYIGSZT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 14:25:19 -0400
Received: from c-71-193-193-226.hsd1.or.comcast.net ([71.193.193.226] helo=localhost.localdomain)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1KcOwn-0005Mj-6l
	for netdev@vger.kernel.org; Sun, 07 Sep 2008 18:25:17 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

as part of a rework of select/poll and hrtimers, I needed to make a slight
API adjustment to networking code; the patch for this is below.

Is it ok to carry this patch as part of the hrtimer tree?
(if not it's going to be .. interesting in terms of sequencing the
introduction of new apis versus this patch versus the rest)





>From ae2c9cc58e636751128a760a3b7a586abd0ff91b Mon Sep 17 00:00:00 2001
From: Arjan van de Ven <arjan@linux.intel.com>
Date: Mon, 1 Sep 2008 15:00:54 -0700
Subject: [PATCH] hrtimer: convert net::sched_cbq to the new hrtimer apis

In order to be able to do range hrtimers we need to use accessor functions
to the "expire" member of the hrtimer struct.
This patch converts sched_cbq to these accessors.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 net/sched/sch_cbq.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 8b06fa9..03e389e 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -545,9 +545,10 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 			expires = ktime_set(0, 0);
 			expires = ktime_add_ns(expires, PSCHED_US2NS(sched));
 			if (hrtimer_try_to_cancel(&q->delay_timer) &&
-			    ktime_to_ns(ktime_sub(q->delay_timer.expires,
-						  expires)) > 0)
-				q->delay_timer.expires = expires;
+			    ktime_to_ns(ktime_sub(
+					hrtimer_get_expires(&q->delay_timer),
+					expires)) > 0)
+				hrtimer_set_expires(&q->delay_timer, expires);
 			hrtimer_restart(&q->delay_timer);
 			cl->delayed = 1;
 			cl->xstats.overactions++;
-- 
1.5.5.1

