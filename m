From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Sat, 18 Apr 2009 18:04:24 +0900
Message-ID: <200904181804.AHC13042.VHFFOOJOFLSQMt@I-love.SAKURA.ne.jp>
References: <200904181704.FDC21361.FQLOFHOOSVFtMJ@I-love.SAKURA.ne.jp>
	<20090418.013538.126788034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090418.013538.126788034.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

David Miller wrote:
> RAW does not support those things, so doesn't need the locking.
I see. Thanks.

It is harmless to call lock_sock() for protocols which don't 
support global
socket memory accounting, isn't it?

I want to introduce a new LSM hook which is called after picking
 up a datagram. Below is a patch.

--- security-testing-2.6.git.orig/net/core/datagram.c
+++ security-testing-2.6.git/net/core/datagram.c
@@ -55,6 +55,7 @@
 #include <net/checksum.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
+#include <linux/security.h>
 
 /*
  *	Is a socket 'connection oriented' ?
@@ -179,8 +180,13 @@ struct sk_buff *__skb_recv_datagram(stru
 		}
 		spin_unlock_irqrestore(&sk->sk_receive_queue.
lock, cpu_flags);
 
-		if (skb)
+		if (skb) {
+			error = security_socket_post_recv_datagram(sk, skb,
+								   flags);
+			if (error)
+				goto force_dequeue;
 			return skb;
+		}
 
 		/* User doesn't want to wait */
 		error = -EAGAIN;
@@ -191,6 +197,19 @@ struct sk_buff *__skb_recv_datagram(stru
 
 	return NULL;
 
+force_dequeue:
+	if (flags & MSG_PEEK) {
+		unsigned long cpu_flags;
+		spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
+		if (skb == skb_peek(&sk->sk_receive_queue)) {
+			__skb_unlink(skb, &sk->sk_receive_queue);
+			atomic_dec(&skb->users);
+		}
+		spin_unlock_irqrestore(&sk->sk_receive_queue.
lock, cpu_flags);
+	}
+	lock_sock(sk);
+	skb_free_datagram(sk, skb);
+	release_sock(sk);
 no_packet:
 	*err = error;
 	return NULL;

If it is harmful to call lock_sock() for protocols which don't 
support global
socket memory accounting, I need to make lock_sock(sk);/release_
sock(sk); calls
conditional.

Regards.
