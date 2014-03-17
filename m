From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 2/2] exit: move check_stack_usage() to the end of do_exit()
Date: Mon, 17 Mar 2014 19:05:10 +0100
Message-ID: <20140317180510.GC15708@redhat.com>
References: <531DEEA6.4090808@totakura.in> <531E111A.8040207@hurleysoftware.com> <20140313170622.GA31206@redhat.com> <5321F113.7090000@hurleysoftware.com> <53230FE5.9020204@hurleysoftware.com> <20140314192346.GA14823@redhat.com> <53236662.3020707@hurleysoftware.com> <20140314210456.GA19032@redhat.com> <53244C61.5090508@hurleysoftware.com> <20140317180416.GA15708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sree Harsha Totakura <sreeharsha@totakura.in>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>
To: Peter Hurley <peter@hurleysoftware.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932530AbaCQSFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 14:05:50 -0400
Content-Disposition: inline
In-Reply-To: <20140317180416.GA15708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not clear why check_stack_usage() is called so early and
thus it never checks the stack usage in, say, exit_notify() or
flush_ptrace_hw_breakpoint() or other functions which are only
called by do_exit().

Move the callsite down to the last preempt_disable/schedule.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 kernel/exit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 5d5b472..6d1f245 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -788,7 +788,6 @@ void do_exit(long code)
 		disassociate_ctty(1);
 	exit_task_namespaces(tsk);
 	exit_task_work(tsk);
-	check_stack_usage();
 	exit_thread();
 
 	/*
@@ -842,6 +841,7 @@ void do_exit(long code)
 
 	validate_creds_for_do_exit(tsk);
 
+	check_stack_usage();
 	preempt_disable();
 	if (tsk->nr_dirtied)
 		__this_cpu_add(dirty_throttle_leaks, tsk->nr_dirtied);
-- 
1.5.5.1
