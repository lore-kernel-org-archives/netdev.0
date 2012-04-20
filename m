From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH 1/2] workqueue: Catch more locking problems with flush_work()
Date: Fri, 20 Apr 2012 16:15:01 -0700
Message-ID: <4F91EDF5.6020003@codeaurora.org>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org> <20120419152841.GA10553@google.com> <4F905521.9020901@codeaurora.org> <20120420173529.GD32324@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Dooks <ben-linux@fluff.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:37458 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756574Ab2DTXPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 19:15:02 -0400
In-Reply-To: <20120420173529.GD32324@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/2012 10:35 AM, Tejun Heo wrote:
>
> All that's necessary is acquiring and releasing work->lockdep_map.
> There's no need to nest start_flush_work() inside it.  Without
> nesting, there's nothing to worry about ABBA lockdeps.

Yes I see. This patch should work then?

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 5abf42f..038cf64 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2506,6 +2506,9 @@ bool flush_work(struct work_struct *work)
 {
        struct wq_barrier barr;

+       lock_map_acquire(&work->lockdep_map);
+       lock_map_release(&work->lockdep_map);
+
        if (start_flush_work(work, &barr, true)) {
                wait_for_completion(&barr.done);
                destroy_work_on_stack(&barr.work);


-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
