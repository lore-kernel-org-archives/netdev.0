From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2] af_unix: conditionally use freezable blocking calls in read
Date: Thu, 17 Nov 2016 15:55:26 -0800
Message-ID: <1479426926-28197-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Tejun Heo <tj@kernel.org>, Colin Cross <ccross@android.com>,
        "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34469 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbcKQXzq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 18:55:46 -0500
Received: by mail-pf0-f193.google.com with SMTP id y68so12326348pfb.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 15:55:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2b15af6f95 ("af_unix: use freezable blocking calls in read")
converts schedule_timeout() to its freezable version, it was probably
correct at that time, but later, commit 2b514574f7e8
("net: af_unix: implement splice for stream af_unix sockets") breaks
the strong requirement for a freezable sleep, according to
commit 0f9548ca1091:

    We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
    deadlock if the lock is later acquired in the suspend or hibernate path
    (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
    cgroup_freezer if a lock is held inside a frozen cgroup that is later
    acquired by a process outside that group.

The pipe_lock is still held at that point.

So use freezable version only for the recvmsg call path, avoid impact for
Android.

Fixes: 2b514574f7e8 ("net: af_unix: implement splice for stream af_unix sockets")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Colin Cross <ccross@android.com>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/unix/af_unix.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5d1c14a..2358f26 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2199,7 +2199,8 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
  *	Sleep until more data has arrived. But check for races..
  */
 static long unix_stream_data_wait(struct sock *sk, long timeo,
-				  struct sk_buff *last, unsigned int last_len)
+				  struct sk_buff *last, unsigned int last_len,
+				  bool freezable)
 {
 	struct sk_buff *tail;
 	DEFINE_WAIT(wait);
@@ -2220,7 +2221,10 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 
 		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		unix_state_unlock(sk);
-		timeo = freezable_schedule_timeout(timeo);
+		if (freezable)
+			timeo = freezable_schedule_timeout(timeo);
+		else
+			timeo = schedule_timeout(timeo);
 		unix_state_lock(sk);
 
 		if (sock_flag(sk, SOCK_DEAD))
@@ -2250,7 +2254,8 @@ struct unix_stream_read_state {
 	unsigned int splice_flags;
 };
 
-static int unix_stream_read_generic(struct unix_stream_read_state *state)
+static int unix_stream_read_generic(struct unix_stream_read_state *state,
+				    bool freezable)
 {
 	struct scm_cookie scm;
 	struct socket *sock = state->socket;
@@ -2330,7 +2335,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 			mutex_unlock(&u->iolock);
 
 			timeo = unix_stream_data_wait(sk, timeo, last,
-						      last_len);
+						      last_len, freezable);
 
 			if (signal_pending(current)) {
 				err = sock_intr_errno(timeo);
@@ -2472,7 +2477,7 @@ static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
 		.flags = flags
 	};
 
-	return unix_stream_read_generic(&state);
+	return unix_stream_read_generic(&state, true);
 }
 
 static int unix_stream_splice_actor(struct sk_buff *skb,
@@ -2503,7 +2508,7 @@ static ssize_t unix_stream_splice_read(struct socket *sock,  loff_t *ppos,
 	    flags & SPLICE_F_NONBLOCK)
 		state.flags = MSG_DONTWAIT;
 
-	return unix_stream_read_generic(&state);
+	return unix_stream_read_generic(&state, false);
 }
 
 static int unix_shutdown(struct socket *sock, int mode)
-- 
2.1.0
