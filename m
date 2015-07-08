From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 2/2] net: pktgen: kill the "Wait for kthread_stop" code in
	pktgen_thread_worker()
Date: Wed, 8 Jul 2015 21:42:13 +0200
Message-ID: <20150708194213.GA26555@redhat.com>
References: <20150708194154.GA26534@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Stancek <jstancek@redhat.com>,
	Marcelo Leitner <mleitner@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150708194154.GA26534@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pktgen_thread_worker() doesn't need to wait for kthread_stop(), it
can simply exit. Just pktgen_create_thread() and pg_net_exit() should
do get_task_struct()/put_task_struct(). kthread_stop(dead_thread) is
fine.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 net/core/pktgen.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 043ea18..8e0181a 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3489,15 +3489,6 @@ static int pktgen_thread_worker(void *arg)
 	pr_debug("%s removing thread\n", t->tsk->comm);
 	pktgen_rem_thread(t);
 
-	/* Wait for kthread_stop */
-	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (kthread_should_stop())
-			break;
-		schedule();
-	}
-	__set_current_state(TASK_RUNNING);
-
 	return 0;
 }
 
@@ -3689,6 +3680,7 @@ static int __net_init pktgen_create_thread(int cpu, struct pktgen_net *pn)
 	}
 
 	t->net = pn;
+	get_task_struct(p);
 	wake_up_process(p);
 	wait_for_completion(&t->start_done);
 
@@ -3811,6 +3803,7 @@ static void __net_exit pg_net_exit(struct net *net)
 		t = list_entry(q, struct pktgen_thread, th_list);
 		list_del(&t->th_list);
 		kthread_stop(t->tsk);
+		put_task_struct(t->tsk);
 		kfree(t);
 	}
 
-- 
1.5.5.1
