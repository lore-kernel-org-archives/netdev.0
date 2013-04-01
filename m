From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH 1/1] cbq: incorrect processing of high limits
Date: Mon, 01 Apr 2013 17:01:32 +0400
Message-ID: <5159852C.8060003@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2357 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756725Ab3DANC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Apr 2013 09:02:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

currently cbq works incorrectly for limits > 10% real link bandwidth,
and practically does not work for limits > 50% real link bandwidth.
Below are results of experiments taken on 1 Gbit link

 In shaper | Actual Result
-----------+---------------
  100M     | 108 Mbps
  200M     | 244 Mbps
  300M     | 412 Mbps
  500M     | 893 Mbps

This happen because of q->now changes incorrectly in cbq_dequeue():
when it is called before real end of packet transmitting,
L2T is greater than real time delay, q_now gets an extra boost
but never compensate it.

To fix this problem we prevent change of q->now until its synchronization
with real time.

Signed-off-by: Vasily Averin <vvs@openvz.org>
Reviewed-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/sched/sch_cbq.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 6aabd77..5b5c83a 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -962,8 +962,11 @@ cbq_dequeue(struct Qdisc *sch)
		cbq_update(q);
		if ((incr -= incr2) < 0)
			incr = 0;
+		q->now += incr;
+	} else {
+		if (now > q->now)
+			q->now = now;
	}
-	q->now += incr;
	q->now_rt = now;

	for (;;) {
--
1.7.5.4
