From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix the condition passed to sk_wait_event()
Date: Sun, 03 Oct 2010 20:42:42 -0700 (PDT)
Message-ID: <20101003.204242.71124568.davem@davemloft.net>
References: <316201.7438.qm@web53706.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tomer_iisc@yahoo.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <316201.7438.qm@web53706.mail.re2.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nagendra Tomar <tomer_iisc@yahoo.com>
Date: Sun, 3 Oct 2010 02:45:06 -0700 (PDT)

> This patch fixes the condition (3rd arg) passed to sk_wait_event() in 
> sk_stream_wait_memory(). The incorrect check in sk_stream_wait_memory() 
> causes the following soft lockup in tcp_sendmsg() when the global tcp 
> memory pool has exhausted. 
 ...
> What is happening is, that the sk_wait_event() condition passed from
> sk_stream_wait_memory() evaluates to true for the case of tcp global memory
> exhaustion. This is because both sk_stream_memory_free() and vm_wait are true
> which causes sk_wait_event() to *not* call schedule_timeout(). 
> Hence sk_stream_wait_memory() returns immediately to the caller w/o sleeping.
> This causes the caller to again try allocation, which again fails and again
> calls sk_stream_wait_memory(), and so on.
> 
> 
> Signed-off-by: Nagendra Singh Tomar <tomer_iisc@yahoo.com>

Applied, thanks.

This bug was introduced by the following commit, which I made
a note of in the commit message for the fix:

--------------------
commit c1cbe4b7ad0bc4b1d98ea708a3fecb7362aa4088
Author: Benjamin LaHaise <benjamin.c.lahaise@intel.com>
Date:   Tue Dec 13 23:22:19 2005 -0800

    [NET]: Avoid atomic xchg() for non-error case
    
    It also looks like there were 2 places where the test on sk_err was
    missing from the event wait logic (in sk_stream_wait_connect and
    sk_stream_wait_memory), while the rest of the sock_error() users look
    to be doing the right thing.  This version of the patch fixes those,
    and cleans up a few places that were testing ->sk_err directly.
    
    Signed-off-by: Benjamin LaHaise <benjamin.c.lahaise@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/sock.h b/include/net/sock.h
index 982b4ec..0fbae85 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1166,7 +1166,10 @@ static inline int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
  
 static inline int sock_error(struct sock *sk)
 {
-	int err = xchg(&sk->sk_err, 0);
+	int err;
+	if (likely(!sk->sk_err))
+		return 0;
+	err = xchg(&sk->sk_err, 0);
 	return -err;
 }
 
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index ea616e3..fb031fe 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -287,10 +287,9 @@ int bt_sock_wait_state(struct sock *sk, int state, unsigned long timeo)
 		timeo = schedule_timeout(timeo);
 		lock_sock(sk);
 
-		if (sk->sk_err) {
-			err = sock_error(sk);
+		err = sock_error(sk);
+		if (err)
 			break;
-		}
 	}
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk->sk_sleep, &wait);
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index e3bb11c..95f33cc 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -767,8 +767,9 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 
 	BT_DBG("sock %p, sk %p", sock, sk);
 
-	if (sk->sk_err)
-		return sock_error(sk);
+	err = sock_error(sk);
+	if (err)
+		return err;
 
 	if (msg->msg_flags & MSG_OOB)
 		return -EOPNOTSUPP;
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 9cb00dc..6481814 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -637,8 +637,9 @@ static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	BT_DBG("sock %p, sk %p", sock, sk);
 
-	if (sk->sk_err)
-		return sock_error(sk);
+	err = sock_error(sk);
+	if (err)
+		return err;
 
 	if (msg->msg_flags & MSG_OOB)
 		return -EOPNOTSUPP;
diff --git a/net/core/stream.c b/net/core/stream.c
index 15bfd03..35e2525 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -55,8 +55,9 @@ int sk_stream_wait_connect(struct sock *sk, long *timeo_p)
 	int done;
 
 	do {
-		if (sk->sk_err)
-			return sock_error(sk);
+		int err = sock_error(sk);
+		if (err)
+			return err;
 		if ((1 << sk->sk_state) & ~(TCPF_SYN_SENT | TCPF_SYN_RECV))
 			return -EPIPE;
 		if (!*timeo_p)
@@ -67,6 +68,7 @@ int sk_stream_wait_connect(struct sock *sk, long *timeo_p)
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		sk->sk_write_pending++;
 		done = sk_wait_event(sk, timeo_p,
+				     !sk->sk_err &&
 				     !((1 << sk->sk_state) & 
 				       ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
 		finish_wait(sk->sk_sleep, &wait);
@@ -137,7 +139,9 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		sk->sk_write_pending++;
-		sk_wait_event(sk, &current_timeo, sk_stream_memory_free(sk) &&
+		sk_wait_event(sk, &current_timeo, !sk->sk_err && 
+						  !(sk->sk_shutdown & SEND_SHUTDOWN) &&
+						  sk_stream_memory_free(sk) &&
 						  vm_wait);
 		sk->sk_write_pending--;
 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 6f92f9c..f121f7d 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1438,8 +1438,9 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 			/*
 			 *	POSIX 1003.1g mandates this order.
 			 */
-			if (sk->sk_err)
-				ret = sock_error(sk);
+			ret = sock_error(sk);
+			if (ret)
+				break;
 			else if (sk->sk_shutdown & RCV_SHUTDOWN)
 				;
 			else if (noblock)
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c3f0b07..b6d3df5 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -566,10 +566,9 @@ static int llc_wait_data(struct sock *sk, long timeo)
 		/*
 		 * POSIX 1003.1g mandates this order.
 		 */
-		if (sk->sk_err) {
-			rc = sock_error(sk);
+		rc = sock_error(sk);
+		if (rc)
 			break;
-		}
 		rc = 0;
 		if (sk->sk_shutdown & RCV_SHUTDOWN)
 			break;
