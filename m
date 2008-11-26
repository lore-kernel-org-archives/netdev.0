From: dann frazier <dannf@dannf.org>
Subject: [PATCH] Fix soft lockups/OOM issues w/ unix garbage collector
Date: Wed, 26 Nov 2008 10:04:02 -0700
Message-ID: <20081126170401.GC30297@ldl.fc.hp.com>
References: <20081120220326.GE24416@ldl.fc.hp.com> <20081125231712.GA30297@ldl.fc.hp.com> <20081125.211913.114802735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eteo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:4074 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbYKZREG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 12:04:06 -0500
Content-Disposition: inline
In-Reply-To: <20081125.211913.114802735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an implementation of David Miller's suggested fix in:
  https://bugzilla.redhat.com/show_bug.cgi?id=470201

It has been updated to use wait_event() instead of
wait_event_interruptible().

Paraphrasing the description from the above report, it makes sendmsg()
block while UNIX garbage collection is in progress. This avoids a
situation where child processes continue to queue new FDs over a
AF_UNIX socket to a parent which is in the exit path and running
garbage collection on these FDs. This contention can result in soft
lockups and oom-killing of unrelated processes.

Signed-off-by: dann frazier <dannf@hp.com>
--
 include/net/af_unix.h |    1 +
 net/unix/af_unix.c    |    2 ++
 net/unix/garbage.c    |   13 ++++++++++---
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index c29ff1d..1614d78 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -9,6 +9,7 @@
 extern void unix_inflight(struct file *fp);
 extern void unix_notinflight(struct file *fp);
 extern void unix_gc(void);
+extern void wait_for_unix_gc(void);
 
 #define UNIX_HASH_SIZE	256
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index eb90f77..66d5ac4 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1343,6 +1343,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
+	wait_for_unix_gc();
 	err = scm_send(sock, msg, siocb->scm);
 	if (err < 0)
 		return err;
@@ -1493,6 +1494,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
+	wait_for_unix_gc();
 	err = scm_send(sock, msg, siocb->scm);
 	if (err < 0)
 		return err;
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 6d4a9a8..abb3ab3 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -80,6 +80,7 @@
 #include <linux/file.h>
 #include <linux/proc_fs.h>
 #include <linux/mutex.h>
+#include <linux/wait.h>
 
 #include <net/sock.h>
 #include <net/af_unix.h>
@@ -91,6 +92,7 @@
 static LIST_HEAD(gc_inflight_list);
 static LIST_HEAD(gc_candidates);
 static DEFINE_SPINLOCK(unix_gc_lock);
+static DECLARE_WAIT_QUEUE_HEAD(unix_gc_wait);
 
 unsigned int unix_tot_inflight;
 
@@ -266,12 +268,16 @@ static void inc_inflight_move_tail(struct unix_sock *u)
 		list_move_tail(&u->link, &gc_candidates);
 }
 
-/* The external entry point: unix_gc() */
+static bool gc_in_progress = false;
 
-void unix_gc(void)
+void wait_for_unix_gc(void)
 {
-	static bool gc_in_progress = false;
+	wait_event(unix_gc_wait, gc_in_progress == false);
+}
 
+/* The external entry point: unix_gc() */
+void unix_gc(void)
+{
 	struct unix_sock *u;
 	struct unix_sock *next;
 	struct sk_buff_head hitlist;
@@ -376,6 +382,7 @@ void unix_gc(void)
 	/* All candidates should have been detached by now. */
 	BUG_ON(!list_empty(&gc_candidates));
 	gc_in_progress = false;
+	wake_up(&unix_gc_wait);
 
  out:
 	spin_unlock(&unix_gc_lock);
