From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/13) ddp - invert logic for clarity
Date: Fri, 29 Aug 2003 13:54:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829135427.21845e3c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It is a lot clearer to invert the logic used in the destroy_socket
so that it ends up as a positive expression, rather than a double negative.

The SOCK_DEAD is redundant and can be eliminated because it is always
set in the atalk_release() the only caller.

diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Fri Aug 29 11:02:41 2003
+++ b/net/appletalk/ddp.c	Fri Aug 29 11:02:41 2003
@@ -183,13 +183,12 @@
 {
 	struct sock *sk = (struct sock *)data;
 
-	if (!atomic_read(&sk->sk_wmem_alloc) &&
-	    !atomic_read(&sk->sk_rmem_alloc) && sock_flag(sk, SOCK_DEAD))
-		sock_put(sk);
-	else {
+	if (atomic_read(&sk->sk_wmem_alloc) ||
+	    atomic_read(&sk->sk_rmem_alloc)) {
 		sk->sk_timer.expires = jiffies + SOCK_DESTROY_TIME;
 		add_timer(&sk->sk_timer);
-	}
+	} else
+		sock_put(sk);
 }
 
 static inline void atalk_destroy_socket(struct sock *sk)
@@ -197,16 +196,15 @@
 	atalk_remove_socket(sk);
 	skb_queue_purge(&sk->sk_receive_queue);
 
-	if (!atomic_read(&sk->sk_wmem_alloc) &&
-	    !atomic_read(&sk->sk_rmem_alloc) && sock_flag(sk, SOCK_DEAD))
-		sock_put(sk);
-	else {
+	if (atomic_read(&sk->sk_wmem_alloc) ||
+	    atomic_read(&sk->sk_rmem_alloc)) {
 		init_timer(&sk->sk_timer);
 		sk->sk_timer.expires	= jiffies + SOCK_DESTROY_TIME;
 		sk->sk_timer.function	= atalk_destroy_timer;
 		sk->sk_timer.data	= (unsigned long)sk;
 		add_timer(&sk->sk_timer);
-	}
+	} else
+		sock_put(sk);
 }
 
 /**************************************************************************\
