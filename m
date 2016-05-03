From: Jiri Slaby <jslaby@suse.cz>
Subject: [patch added to 3.12-stable] cpuset: Fix potential deadlock w/ set_mems_allowed
Date: Tue,  3 May 2016 17:47:48 +0200
Message-ID: <1462290468-14130-16-git-send-email-jslaby@suse.cz>
References: <1462290468-14130-1-git-send-email-jslaby@suse.cz>
Cc: John Stultz <john.stultz@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@kernel.org>, Jiri Slaby <jslaby@suse.cz>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43886 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933601AbcECPr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 11:47:57 -0400
In-Reply-To: <1462290468-14130-1-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Stultz <john.stultz@linaro.org>

This patch has been added to the 3.12 stable tree. If you have any
objections, please let us know.

===============

commit db751fe3ea6880ff5ac5abe60cb7b80deb5a4140 upstream.

After adding lockdep support to seqlock/seqcount structures,
I started seeing the following warning:

[    1.070907] ======================================================
[    1.072015] [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
[    1.073181] 3.11.0+ #67 Not tainted
[    1.073801] ------------------------------------------------------
[    1.074882] kworker/u4:2/708 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
[    1.076088]  (&p->mems_allowed_seq){+.+...}, at: [<ffffffff81187d7f>] new_slab+0x5f/0x280
[    1.077572]
[    1.077572] and this task is already holding:
[    1.078593]  (&(&q->__queue_lock)->rlock){..-...}, at: [<ffffffff81339f03>] blk_execute_rq_nowait+0x53/0xf0
[    1.080042] which would create a new lock dependency:
[    1.080042]  (&(&q->__queue_lock)->rlock){..-...} -> (&p->mems_allowed_seq){+.+...}
[    1.080042]
[    1.080042] but this new dependency connects a SOFTIRQ-irq-safe lock:
[    1.080042]  (&(&q->__queue_lock)->rlock){..-...}
[    1.080042] ... which became SOFTIRQ-irq-safe at:
[    1.080042]   [<ffffffff810ec179>] __lock_acquire+0x5b9/0x1db0
[    1.080042]   [<ffffffff810edfe5>] lock_acquire+0x95/0x130
[    1.080042]   [<ffffffff818968a1>] _raw_spin_lock+0x41/0x80
[    1.080042]   [<ffffffff81560c9e>] scsi_device_unbusy+0x7e/0xd0
[    1.080042]   [<ffffffff8155a612>] scsi_finish_command+0x32/0xf0
[    1.080042]   [<ffffffff81560e91>] scsi_softirq_done+0xa1/0x130
[    1.080042]   [<ffffffff8133b0f3>] blk_done_softirq+0x73/0x90
[    1.080042]   [<ffffffff81095dc0>] __do_softirq+0x110/0x2f0
[    1.080042]   [<ffffffff81095fcd>] run_ksoftirqd+0x2d/0x60
[    1.080042]   [<ffffffff810bc506>] smpboot_thread_fn+0x156/0x1e0
[    1.080042]   [<ffffffff810b3916>] kthread+0xd6/0xe0
[    1.080042]   [<ffffffff818980ac>] ret_from_fork+0x7c/0xb0
[    1.080042]
[    1.080042] to a SOFTIRQ-irq-unsafe lock:
[    1.080042]  (&p->mems_allowed_seq){+.+...}
[    1.080042] ... which became SOFTIRQ-irq-unsafe at:
[    1.080042] ...  [<ffffffff810ec1d3>] __lock_acquire+0x613/0x1db0
[    1.080042]   [<ffffffff810edfe5>] lock_acquire+0x95/0x130
[    1.080042]   [<ffffffff810b3df2>] kthreadd+0x82/0x180
[    1.080042]   [<ffffffff818980ac>] ret_from_fork+0x7c/0xb0
[    1.080042]
[    1.080042] other info that might help us debug this:
[    1.080042]
[    1.080042]  Possible interrupt unsafe locking scenario:
[    1.080042]
[    1.080042]        CPU0                    CPU1
[    1.080042]        ----                    ----
[    1.080042]   lock(&p->mems_allowed_seq);
[    1.080042]                                local_irq_disable();
[    1.080042]                                lock(&(&q->__queue_lock)->rlock);
[    1.080042]                                lock(&p->mems_allowed_seq);
[    1.080042]   <Interrupt>
[    1.080042]     lock(&(&q->__queue_lock)->rlock);
[    1.080042]
[    1.080042]  *** DEADLOCK ***

The issue stems from the kthreadd() function calling set_mems_allowed
with irqs enabled. While its possibly unlikely for the actual deadlock
to trigger, a fix is fairly simple: disable irqs before taking the
mems_allowed_seq lock.

Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Li Zefan <lizefan@huawei.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/1381186321-4906-4-git-send-email-john.stultz@linaro.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 include/linux/cpuset.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index a7ebb89ae9fb..ade2390ffe92 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -132,10 +132,14 @@ static inline bool read_mems_allowed_retry(unsigned int seq)
 
 static inline void set_mems_allowed(nodemask_t nodemask)
 {
+	unsigned long flags;
+
 	task_lock(current);
+	local_irq_save(flags);
 	write_seqcount_begin(&current->mems_allowed_seq);
 	current->mems_allowed = nodemask;
 	write_seqcount_end(&current->mems_allowed_seq);
+	local_irq_restore(flags);
 	task_unlock(current);
 }
 
-- 
2.8.2
