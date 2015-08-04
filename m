From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH] net: pktgen: don't abuse current->state in
	pktgen_thread_worker()
Date: Tue, 4 Aug 2015 18:33:34 +0200
Message-ID: <20150804163334.GA31842@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Jan Stancek <jstancek@redhat.com>,
	Jesper Brouer <brouer@redhat.com>,
	Marcelo Leitner <mleitner@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Huang Ying <ying.huang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 1fbe4b46caca "net: pktgen: kill the Wait for kthread_stop
code in pktgen_thread_worker()" removed (in particular) the final
__set_current_state(TASK_RUNNING) and I didn't notice the previous
set_current_state(TASK_INTERRUPTIBLE). This triggers the warning
in __might_sleep() after return.

Afaics, we can simply remove both set_current_state()'s, and we
could do this a long ago right after ef87979c273a2 "pktgen: better
scheduler friendliness" which changed pktgen_thread_worker() to
use wait_event_interruptible_timeout().

Reported-by: Huang Ying <ying.huang@intel.com>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 net/core/pktgen.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8e0181a..6717684 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3432,8 +3432,6 @@ static int pktgen_thread_worker(void *arg)
 
 	set_freezable();
 
-	__set_current_state(TASK_RUNNING);
-
 	while (!kthread_should_stop()) {
 		pkt_dev = next_to_run(t);
 
@@ -3478,7 +3476,6 @@ static int pktgen_thread_worker(void *arg)
 
 		try_to_freeze();
 	}
-	set_current_state(TASK_INTERRUPTIBLE);
 
 	pr_debug("%s stopping all device\n", t->tsk->comm);
 	pktgen_stop(t);
-- 
1.5.5.1
