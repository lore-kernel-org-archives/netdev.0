From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/5] AF_RXRPC: Make it possible to merely try to cancel timers
	and delayed work [try #3]
Date: Tue, 20 Mar 2007 19:59:14 +0000
Message-ID: <20070320195914.12853.96917.stgit@warthog.cambridge.redhat.com>
References: <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52635 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbXCTT74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 15:59:56 -0400
In-Reply-To: <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export try_to_del_timer_sync() for use by the RxRPC module.

Add a try_to_cancel_delayed_work() so that it is possible to merely attempt to
cancel a delayed work timer.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 include/linux/workqueue.h |   21 +++++++++++++++++++++
 kernel/timer.c            |    2 ++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 2a7b38d..40a61ae 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -204,4 +204,25 @@ static inline int cancel_delayed_work(struct delayed_work *work)
 	return ret;
 }
 
+/**
+ * try_to_cancel_delayed_work - Try to kill pending scheduled, delayed work
+ * @work: the work to cancel
+ *
+ * Try to kill off a pending schedule_delayed_work().
+ * - The timer may still be running afterwards, and if so, the work may still
+ *   be pending
+ * - Returns -1 if timer still active, 1 if timer removed, 0 if not scheduled
+ * - Can be called from the work routine; if it's still pending, just return
+ *   and it'll be called again.
+ */
+static inline int try_to_cancel_delayed_work(struct delayed_work *work)
+{
+	int ret;
+
+	ret = try_to_del_timer_sync(&work->timer);
+	if (ret > 0)
+		work_release(&work->work);
+	return ret;
+}
+
 #endif
diff --git a/kernel/timer.c b/kernel/timer.c
index 797cccb..447506a 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -505,6 +505,8 @@ out:
 	return ret;
 }
 
+EXPORT_SYMBOL(try_to_del_timer_sync);
+
 /**
  * del_timer_sync - deactivate a timer and wait for the handler to finish.
  * @timer: the timer to be deactivated

