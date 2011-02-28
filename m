From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH] net: fix multithreaded signal handling in unix recv routines
Date: Mon, 28 Feb 2011 14:50:55 +0000
Message-ID: <877hck43hs.fsf@sapphire.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>

The unix_dgram_recvmsg and unix_stream_recvmsg routines in
net/af_unix.c utilize mutex_lock(&u->readlock) calls in order to
serialize read operations of multiple threads on a single socket. This
implies that, if all n threads of a process block in an AF_UNIX recv
call trying to read data from the same socket, one of these threads
will be sleeping in state TASK_INTERRUPTIBLE and all others in state
TASK_UNINTERRUPTIBLE. Provided that a particular signal is supposed to
be handled by a signal handler defined by the process and that none of
this threads is blocking the signal, the complete_signal routine in
kernel/signal.c will select the 'first' such thread it happens to
encounter when deciding which thread to notify that a signal is
supposed to be handled and if this is one of the TASK_UNINTERRUPTIBLE
threads, the signal won't be handled until the one thread not blocking
on the u->readlock mutex is woken up because some data to process has
arrived (if this ever happens). The included patch fixes this by
changing mutex_lock to mutex_lock_interruptible and handling possible
error returns in the same way interruptions are handled by the actual
receive-code.

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>

---
diff -urp net-2.6/net/unix/af_unix.c net-2.6-patched//net/unix/af_unix.c
--- net-2.6/net/unix/af_unix.c	2011-02-16 22:19:43.338358559 +0000
+++ net-2.6-patched//net/unix/af_unix.c	2011-02-16 22:38:39.483543598 +0000
@@ -1724,7 +1724,11 @@ static int unix_dgram_recvmsg(struct kio
 
 	msg->msg_namelen = 0;
 
-	mutex_lock(&u->readlock);
+	err = mutex_lock_interruptible(&u->readlock);
+	if (err) {
+		err = sock_intr_errno(sock_rcvtimeo(sk, noblock));
+		goto out;
+	}
 
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb) {
@@ -1864,7 +1868,11 @@ static int unix_stream_recvmsg(struct ki
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 
-	mutex_lock(&u->readlock);
+	err = mutex_lock_interruptible(&u->readlock);
+	if (err) {
+		err = sock_intr_errno(timeo);
+		goto out;
+	}
 
 	do {
 		int chunk;
@@ -1895,11 +1903,12 @@ static int unix_stream_recvmsg(struct ki
 
 			timeo = unix_stream_data_wait(sk, timeo);
 
-			if (signal_pending(current)) {
+			if (signal_pending(current)
+			    ||  mutex_lock_interruptible(&u->readlock)) {
 				err = sock_intr_errno(timeo);
 				goto out;
 			}
-			mutex_lock(&u->readlock);
+
 			continue;
  unlock:
 			unix_state_unlock(sk);
