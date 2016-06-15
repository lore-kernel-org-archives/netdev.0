From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 3/5] sched/preempt: cond_resched_softirq() must check for softirq
Date: Wed, 15 Jun 2016 15:42:04 +0200
Message-ID: <5e046ef45554b053d22e76809a8faf546c3c0720.1465996447.git.pabeni@redhat.com>
References: <cover.1465996447.git.pabeni@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380AbcFONmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 09:42:52 -0400
In-Reply-To: <cover.1465996447.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently cond_resched_softirq() fails to reschedule if there
are pending softirq but no other running process. This happens
i.e. when receiving an interrupt with local bh disabled.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 kernel/sched/core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 7f2cae4..788625f 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4837,7 +4837,8 @@ int __sched __cond_resched_softirq(void)
 {
 	BUG_ON(!in_softirq());
 
-	if (should_resched(SOFTIRQ_DISABLE_OFFSET)) {
+	if (should_resched(SOFTIRQ_DISABLE_OFFSET) ||
+	    local_softirq_pending()) {
 		local_bh_enable();
 		preempt_schedule_common();
 		local_bh_disable();
-- 
1.8.3.1
