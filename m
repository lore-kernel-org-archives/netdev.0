From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [RFC PATCH] af_unix: fix entry locking in unix_dgram_recvmsg
Date: Sun, 29 Nov 2015 20:59:57 +0000
Message-ID: <87h9k41pyq.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:50685 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752268AbbK2VAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 16:00:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will probably earn me a reputation as the most single-minded
monomaniac on this planet (insofar there's still anything to earn in
this respect) but this issue has been irking me "ever since".

NB: This is somewhat loser formatted than a proper patch submission in
order to explain the background of the issue. I'd split that up in two
proper patches and do some code cleanups (move/ change the
__skb_recv_dgram comment) if there was a chance to get this accepted.

The following little program doesn't work on Linux as the documentation
says it should:

------
#include <sys/signal.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define SERVER_ADDR	"\0nonblocked-forever"

int main(void)
{
    struct sockaddr_un sun;
    int sk, dummy;
    
    sun.sun_family = AF_UNIX;
    memcpy(sun.sun_path, SERVER_ADDR, sizeof(SERVER_ADDR));
    sk = socket(AF_UNIX, SOCK_DGRAM, 0);
    bind(sk, (struct sockaddr *)&sun, sizeof(sun));

    if (fork() == 0) {
	sleep(5);
	recv(sk, &dummy, sizeof(dummy), MSG_DONTWAIT);
	kill(getppid(), SIGTERM);

	_exit(0);
    }

    read(sk, &dummy, sizeof(dummy));
    return 0;
}
-------

It should sleep for 5s and then terminate but instead, it blocks until
either a message is received on the socket or the process terminated by
a signal. The reason for this is that the blocking read goes to sleep
'forerver' in the kernel with the u->readlock mutex held while the later
non-blocking read blocks on this mutex until the first read releases it.
Insofar I understand the comment in this code block correctly,

        err = mutex_lock_interruptible(&u->readlock);
        if (unlikely(err)) {
                /* recvmsg() in non blocking mode is supposed to return -EAGAIN
                 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
                 */
                err = noblock ? -EAGAIN : -ERESTARTSYS;
                goto out;
        }

setting a receive timeout for an AF_UNIX datagram socket also doesn't
work as intended because of this: In case of n readers with the same
timeout, the nth reader will end up blocking n times the timeout.

Somewhat annoyingly, this program works as it should:

-------
#include <sys/signal.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define SERVER_ADDR	"\0working"

int main(void)
{
    struct sockaddr_un sun;
    int sk, ska, dummy;
    
    sun.sun_family = AF_UNIX;
    memcpy(sun.sun_path, SERVER_ADDR, sizeof(SERVER_ADDR));
    sk = socket(AF_UNIX, SOCK_STREAM, 0);
    bind(sk, (struct sockaddr *)&sun, sizeof(sun));
    listen(sk, 10);

    if (fork() == 0) {
	ska = socket(AF_UNIX, SOCK_STREAM, 0);
	connect(ska, (struct sockaddr *)&sun, sizeof(sun));
	read(ska, &dummy, sizeof(dummy));

	_exit(0);
    }

    ska = accept(sk, NULL, 0);

    if (fork() == 0) {
	sleep(5);
	recv(ska, &dummy, sizeof(dummy), MSG_DONTWAIT);
	kill(getppid(), SIGTERM);

	_exit(0);
    }

    read(ska, &dummy, sizeof(dummy));
    return 0;
}
--------

because the SOCK_STREAM receive code releases the mutex before going to
sleep.

Even more annoyingly, the UNIX(*) equivalent of the first program works
(in case a filesystem name is used instead of the 'abstract' one) on
both FreeBSD and Solaris (or did work some time last year when some
people with access to such systems kindly tested this).

---------
#include <fcntl.h>
#include <sys/signal.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <unistd.h>

#define SERVER_ADDR	"\0nonblocked-forever"

int main(void)
{
    struct sockaddr_un sun;
    pid_t pid;
    int sk, dummy;
    
    sun.sun_family = AF_UNIX;
    memcpy(sun.sun_path, SERVER_ADDR, sizeof(SERVER_ADDR));
    sk = socket(AF_UNIX, SOCK_DGRAM, 0);
    bind(sk, (struct sockaddr *)&sun, sizeof(sun));

    if ((pid = fork()) == 0) {
	read(sk, &dummy, sizeof(dummy));
	_exit(0);
    }

    sleep(5);
    
    fcntl(sk, F_SETFL, fcntl(sk, F_GETFL) | O_NONBLOCK);
    read(sk, &dummy, sizeof(dummy));
    kill(pid, SIGTERM);
    wait(NULL);
    
    return 0;
}
---------

In order to fix this, I propose to split the __skb_recv_datagram routine
into two, one __skb_try_recv_datagram executing the receive logic and
another __skb_wait_for_more_packets (identical to the existing wait
routine). __skb_recv_datagram can then be reimplemented using these two
helper routines and the code in unix_dgram_recvmsg can use a similar
loop but with releasing the readlock as appropriate while still
retaining the "single function with actual datagram receive logic"
property.

This could also help other future protocols which also need to use locks
for protecting access to some per-socket state information the
core/datagram.c code is unaware of.

Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---

Patch is against 4.4.0-rc1-net.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4355129..dce91ac 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2788,6 +2788,12 @@ static inline void skb_frag_list_init(struct sk_buff *skb)
 #define skb_walk_frags(skb, iter)	\
 	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
 
+
+int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
+				const struct sk_buff *skb);
+struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned flags,
+					int *peeked, int *off, int *err,
+					struct sk_buff **last);
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 				    int *peeked, int *off, int *err);
 struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 617088a..8a859b3 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -83,8 +83,8 @@ static int receiver_wake_function(wait_queue_t *wait, unsigned int mode, int syn
 /*
  * Wait for the last received packet to be different from skb
  */
-static int wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
-				 const struct sk_buff *skb)
+int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
+				const struct sk_buff *skb)
 {
 	int error;
 	DEFINE_WAIT_FUNC(wait, receiver_wake_function);
@@ -130,6 +130,7 @@ out_noerr:
 	error = 1;
 	goto out;
 }
+EXPORT_SYMBOL(__skb_wait_for_more_packets);
 
 static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
 {
@@ -160,44 +161,13 @@ done:
 	return skb;
 }
 
-/**
- *	__skb_recv_datagram - Receive a datagram skbuff
- *	@sk: socket
- *	@flags: MSG_ flags
- *	@peeked: returns non-zero if this packet has been seen before
- *	@off: an offset in bytes to peek skb from. Returns an offset
- *	      within an skb where data actually starts
- *	@err: error code returned
- *
- *	Get a datagram skbuff, understands the peeking, nonblocking wakeups
- *	and possible races. This replaces identical code in packet, raw and
- *	udp, as well as the IPX AX.25 and Appletalk. It also finally fixes
- *	the long standing peek and read race for datagram sockets. If you
- *	alter this routine remember it must be re-entrant.
- *
- *	This function will lock the socket if a skb is returned, so the caller
- *	needs to unlock the socket in that case (usually by calling
- *	skb_free_datagram)
- *
- *	* It does not lock socket since today. This function is
- *	* free of race conditions. This measure should/can improve
- *	* significantly datagram socket latencies at high loads,
- *	* when data copying to user space takes lots of time.
- *	* (BTW I've just killed the last cli() in IP/IPv6/core/netlink/packet
- *	*  8) Great win.)
- *	*			                    --ANK (980729)
- *
- *	The order of the tests when we find no data waiting are specified
- *	quite explicitly by POSIX 1003.1g, don't change them without having
- *	the standard around please.
- */
-struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
-				    int *peeked, int *off, int *err)
+struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
+					int *peeked, int *off, int *err,
+					struct sk_buff **last)
 {
 	struct sk_buff_head *queue = &sk->sk_receive_queue;
-	struct sk_buff *skb, *last;
+	struct sk_buff *skb;
 	unsigned long cpu_flags;
-	long timeo;
 	/*
 	 * Caller is allowed not to check sk->sk_err before skb_recv_datagram()
 	 */
@@ -206,8 +176,6 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 	if (error)
 		goto no_packet;
 
-	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
-
 	do {
 		/* Again only user level code calls this function, so nothing
 		 * interrupt level will suddenly eat the receive_queue.
@@ -217,10 +185,10 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 		 */
 		int _off = *off;
 
-		last = (struct sk_buff *)queue;
+		*last = (struct sk_buff *)queue;
 		spin_lock_irqsave(&queue->lock, cpu_flags);
 		skb_queue_walk(queue, skb) {
-			last = skb;
+			*last = skb;
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
 				if (_off >= skb->len && (skb->len || _off ||
@@ -231,8 +199,11 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 
 				skb = skb_set_peeked(skb);
 				error = PTR_ERR(skb);
-				if (IS_ERR(skb))
-					goto unlock_err;
+				if (IS_ERR(skb)) {
+					spin_unlock_irqrestore(&queue->lock,
+							       cpu_flags);
+					goto no_packet;
+				}
 
 				atomic_inc(&skb->users);
 			} else
@@ -242,25 +213,69 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 			*off = _off;
 			return skb;
 		}
+
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
+	} while (sk_can_busy_loop(sk) &&
+		 sk_busy_loop(sk, flags & MSG_DONTWAIT));
 
-		if (sk_can_busy_loop(sk) &&
-		    sk_busy_loop(sk, flags & MSG_DONTWAIT))
-			continue;
+	error = -EAGAIN;
 
-		/* User doesn't want to wait */
-		error = -EAGAIN;
-		if (!timeo)
-			goto no_packet;
+no_packet:
+	*err = error;
+	return NULL;
+}
+EXPORT_SYMBOL(__skb_try_recv_datagram);
 
-	} while (!wait_for_more_packets(sk, err, &timeo, last));
+/**
+ *	__skb_recv_datagram - Receive a datagram skbuff
+ *	@sk: socket
+ *	@flags: MSG_ flags
+ *	@peeked: returns non-zero if this packet has been seen before
+ *	@off: an offset in bytes to peek skb from. Returns an offset
+ *	      within an skb where data actually starts
+ *	@err: error code returned
+ *
+ *	Get a datagram skbuff, understands the peeking, nonblocking wakeups
+ *	and possible races. This replaces identical code in packet, raw and
+ *	udp, as well as the IPX AX.25 and Appletalk. It also finally fixes
+ *	the long standing peek and read race for datagram sockets. If you
+ *	alter this routine remember it must be re-entrant.
+ *
+ *	This function will lock the socket if a skb is returned, so the caller
+ *	needs to unlock the socket in that case (usually by calling
+ *	skb_free_datagram)
+ *
+ *	* It does not lock socket since today. This function is
+ *	* free of race conditions. This measure should/can improve
+ *	* significantly datagram socket latencies at high loads,
+ *	* when data copying to user space takes lots of time.
+ *	* (BTW I've just killed the last cli() in IP/IPv6/core/netlink/packet
+ *	*  8) Great win.)
+ *	*			                    --ANK (980729)
+ *
+ *	The order of the tests when we find no data waiting are specified
+ *	quite explicitly by POSIX 1003.1g, don't change them without having
+ *	the standard around please.
+ */
+struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
+				    int *peeked, int *off, int *err)
+{
+	struct sk_buff *skb, *last;
+	long timeo;
 
-	return NULL;
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	last = NULL;
+
+	do {
+		skb = __skb_try_recv_datagram(sk, flags, peeked, off, err,
+					      &last);
+		if (skb)
+			return skb;
+
+		if (!timeo || *err != -EAGAIN)
+			break;
+	} while (!__skb_wait_for_more_packets(sk, err, &timeo, last));
 
-unlock_err:
-	spin_unlock_irqrestore(&queue->lock, cpu_flags);
-no_packet:
-	*err = error;
 	return NULL;
 }
 EXPORT_SYMBOL(__skb_recv_datagram);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4e95bdf..6f253ee 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2026,8 +2026,8 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
-	int noblock = flags & MSG_DONTWAIT;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *last;
+	long timeo;
 	int err;
 	int peeked, skip;
 
@@ -2035,26 +2035,32 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 	if (flags&MSG_OOB)
 		goto out;
 
-	err = mutex_lock_interruptible(&u->readlock);
-	if (unlikely(err)) {
-		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
-		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
-		 */
-		err = noblock ? -EAGAIN : -ERESTARTSYS;
-		goto out;
-	}
+	last = NULL; /* not really necessary */
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 
-	skip = sk_peek_offset(sk, flags);
+	do {
+		mutex_lock(&u->readlock);
 
-	skb = __skb_recv_datagram(sk, flags, &peeked, &skip, &err);
-	if (!skb) {
+		skip = sk_peek_offset(sk, flags);
+		skb = __skb_try_recv_datagram(sk, flags, &peeked, &skip, &err,
+					      &last);
+		if (skb)
+			break;
+
+		mutex_unlock(&u->readlock);
+
+		if (!(timeo && err == -EAGAIN))
+			break;
+	} while (!__skb_wait_for_more_packets(sk, &err, &timeo, last));
+
+	if (!skb) { /* implies readlock unlocked */
 		unix_state_lock(sk);
 		/* Signal EOF on disconnected non-blocking SEQPACKET socket. */
 		if (sk->sk_type == SOCK_SEQPACKET && err == -EAGAIN &&
 		    (sk->sk_shutdown & RCV_SHUTDOWN))
 			err = 0;
 		unix_state_unlock(sk);
-		goto out_unlock;
+		goto out;
 	}
 
 	wake_up_interruptible_sync_poll(&u->peer_wait,
@@ -2110,7 +2116,6 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 
 out_free:
 	skb_free_datagram(sk, skb);
-out_unlock:
 	mutex_unlock(&u->readlock);
 out:
 	return err;
