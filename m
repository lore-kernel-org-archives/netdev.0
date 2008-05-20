From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/4] pktgen: make sure that pktgen_thread_worker has been executed
Date: Tue, 20 May 2008 13:59:47 +0400
Message-ID: <1211277589-8565-2-git-send-email-den@openvz.org>
References: <1211277589-8565-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	Patrick McHardy <kaber@trash.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Ben Greear <greearb@candelatech.com>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31132 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765063AbYETKAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 06:00:41 -0400
In-Reply-To: <1211277589-8565-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following courruption can happen during pktgen stop:
list_del corruption. prev->next should be ffff81007e8a5e70, but was 6b6b6b6b6b6b6b6b
kernel BUG at lib/list_debug.c:67!
      :pktgen:pktgen_thread_worker+0x374/0x10b0
      ? autoremove_wake_function+0x0/0x40
      ? _spin_unlock_irqrestore+0x42/0x80
      ? :pktgen:pktgen_thread_worker+0x0/0x10b0
      kthread+0x4d/0x80
      child_rip+0xa/0x12
      ? restore_args+0x0/0x30
      ? kthread+0x0/0x80
      ? child_rip+0x0/0x12
RIP  list_del+0x48/0x70

The problem is that pktgen_thread_worker can not be executed if kthread_stop
has been called too early. Insert a completion on the normal initialization
path to make sure that pktgen_thread_worker will gain the control for sure.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Robert Olsson <robert.olsson@its.uu.se>
Cc: Ben Greear <greearb@candelatech.com>
Acked-by: Alexey Dobriyan <adobriyan@openvz.org>
---
 net/core/pktgen.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8dca211..fdf5377 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -390,6 +390,7 @@ struct pktgen_thread {
 	int cpu;
 
 	wait_queue_head_t queue;
+	struct completion start_done;
 };
 
 #define REMOVE 1
@@ -3414,6 +3415,7 @@ static int pktgen_thread_worker(void *arg)
 	BUG_ON(smp_processor_id() != cpu);
 
 	init_waitqueue_head(&t->queue);
+	complete(&t->start_done);
 
 	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n", cpu, task_pid_nr(current));
 
@@ -3615,6 +3617,7 @@ static int __init pktgen_create_thread(int cpu)
 	INIT_LIST_HEAD(&t->if_list);
 
 	list_add_tail(&t->th_list, &pktgen_threads);
+	init_completion(&t->start_done);
 
 	p = kthread_create(pktgen_thread_worker, t, "kpktgend_%d", cpu);
 	if (IS_ERR(p)) {
@@ -3639,6 +3642,7 @@ static int __init pktgen_create_thread(int cpu)
 	}
 
 	wake_up_process(p);
+	wait_for_completion(&t->start_done);
 
 	return 0;
 }
-- 
1.5.3.rc5

