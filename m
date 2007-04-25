From: David Howells <dhowells@redhat.com>
Subject: [PATCH 02/16] cancel_delayed_work: use del_timer() instead of
	del_timer_sync() [try #4]
Date: Wed, 25 Apr 2007 16:49:07 +0100
Message-ID: <20070425154907.26581.85907.stgit@warthog.cambridge.redhat.com>
References: <20070425154854.26581.97692.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031099AbXDYPtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 11:49:42 -0400
In-Reply-To: <20070425154854.26581.97692.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

del_timer_sync() buys nothing for cancel_delayed_work(), but it is less
efficient since it locks the timer unconditionally, and may wait for the
completion of the delayed_work_timer_fn().

cancel_delayed_work() == 0 means:

	before this patch:
		work->func may still be running or queued

	after this patch:
		work->func may still be running or queued, or
		delayed_work_timer_fn->__queue_work() in progress.

		The latter doesn't differ from the caller's POV,
		delayed_work_timer_fn() is called with _PENDING
		bit set.

cancel_delayed_work() == 1 with this patch adds a new possibility:

	delayed_work->work was cancelled, but delayed_work_timer_fn
	is still running (this is only possible for the re-arming
	works on single-threaded workqueue).

	In this case the timer was re-started by work->func(), nobody
	else can do this. This in turn means that delayed_work_timer_fn
	has already passed __queue_work() (and wont't touch delayed_work)
	because nobody else can queue delayed_work->work.

Signed-off-by: Oleg Nesterov <oleg@tv-sign.ru>
Signed-Off-By: David Howells <dhowells@redhat.com>
---

 include/linux/workqueue.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 2a7b38d..b8abfc7 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -191,14 +191,15 @@ int execute_in_process_context(work_func_t fn, struct execute_work *);
 
 /*
  * Kill off a pending schedule_delayed_work().  Note that the work callback
- * function may still be running on return from cancel_delayed_work().  Run
- * flush_scheduled_work() to wait on it.
+ * function may still be running on return from cancel_delayed_work(), unless
+ * it returns 1 and the work doesn't re-arm itself. Run flush_workqueue() or
+ * cancel_work_sync() to wait on it.
  */
 static inline int cancel_delayed_work(struct delayed_work *work)
 {
 	int ret;
 
-	ret = del_timer_sync(&work->timer);
+	ret = del_timer(&work->timer);
 	if (ret)
 		work_release(&work->work);
 	return ret;

