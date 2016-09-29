From: Miklos Szeredi <mszeredi@redhat.com>
Subject: [PATCH] af_unix: fix garbage collect vs. MSG_PEEK
Date: Thu, 29 Sep 2016 14:09:14 +0200
Message-ID: <1475150954-10152-1-git-send-email-mszeredi@redhat.com>
Cc: linux-kernel@vger.kernel.org, hannes@stressinduktion.org,
        kernel@kyup.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37031 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753830AbcI2MJS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 08:09:18 -0400
Received: by mail-wm0-f48.google.com with SMTP id b130so128352063wmc.0
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 05:09:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gc assumes that in-flight sockets that don't have an external ref can't
gain one while unix_gc_lock is held.  That is true because
unix_notinflight() will be called before detaching fds, which takes
unix_gc_lock.

Only MSG_PEEK was somehow overlooked.  That one also clones the fds, also
keeping them in the skb.  But through MSG_PEEK an external reference can
definitely be gained without ever touching unix_gc_lock.

This patch adds unix_gc_barrier() that waits for a garbage collect run to
finish (if there is one), before actually installing the peeked in-flight
files to file descriptors.  This prevents problems from a pure in-flight
socket having its buffers modified while the garbage collect is taking
place.

Signed-off-by: Miklos Szeredi <mszeredi@redhat.com>
Cc: <stable@vger.kernel.org>
---
 include/net/af_unix.h |  1 +
 net/unix/af_unix.c    | 15 +++++++++++++--
 net/unix/garbage.c    |  5 +++++
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index fd60eccb59a6..f73ce09da2b4 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -10,6 +10,7 @@ void unix_inflight(struct user_struct *user, struct file *fp);
 void unix_notinflight(struct user_struct *user, struct file *fp);
 void unix_gc(void);
 void wait_for_unix_gc(void);
+void unix_gc_barrier(void);
 struct sock *unix_get_socket(struct file *filp);
 struct sock *unix_peer_get(struct sock *);
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 8309687a56b0..cece344b41b8 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1550,6 +1550,17 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 	return max_level;
 }
 
+static void unix_peek_fds(struct scm_cookie *scm, struct sk_buff *skb)
+{
+	scm->fp = scm_fp_dup(UNIXCB(skb).fp);
+	/*
+	 * During garbage collection it is assumed that in-flight sockets don't
+	 * get a new external reference.  So we need to wait until current run
+	 * finishes.
+	 */
+	unix_gc_barrier();
+}
+
 static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool send_fds)
 {
 	int err = 0;
@@ -2182,7 +2193,7 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 		sk_peek_offset_fwd(sk, size);
 
 		if (UNIXCB(skb).fp)
-			scm.fp = scm_fp_dup(UNIXCB(skb).fp);
+			unix_peek_fds(&scm, skb);
 	}
 	err = (flags & MSG_TRUNC) ? skb->len - skip : size;
 
@@ -2422,7 +2433,7 @@ unlock:
 			/* It is questionable, see note in unix_dgram_recvmsg.
 			 */
 			if (UNIXCB(skb).fp)
-				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
+				unix_peek_fds(&scm, skb);
 
 			sk_peek_offset_fwd(sk, chunk);
 
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 6a0d48525fcf..d4fb6ff8024d 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -266,6 +266,11 @@ void wait_for_unix_gc(void)
 	wait_event(unix_gc_wait, gc_in_progress == false);
 }
 
+void unix_gc_barrier(void)
+{
+	spin_unlock_wait(&unix_gc_lock);
+}
+
 /* The external entry point: unix_gc() */
 void unix_gc(void)
 {
-- 
2.5.5
