From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Fix X.25 use after free.
Date: Tue, 5 Aug 2003 15:01:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030805150110.0e2753ab.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Henner Eisen <eis@baty.hanse.de>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The conversion from cli/sti to locking in X.25 must not have been tested
on a real SMP with memory debugging enabled.  It OOPS right away if
I do:
	modprobe x25; ifconfig -a

The problem is that it dereferences the socket after it has already been
freed.  The fix for this is to make the call to sock_put, later in
x25_destroy_socket do the free.  Also, need a go to avoid references
in x25_release.

This patch is against 2.6.0-test2.
diff -urNp -X dontdiff net-2.5/net/x25/af_x25.c linux-2.5-net/net/x25/af_x25.c
--- net-2.5/net/x25/af_x25.c	2003-08-01 11:12:02.000000000 -0700
+++ linux-2.5-net/net/x25/af_x25.c	2003-08-05 12:14:42.000000000 -0700
@@ -350,8 +350,11 @@ void x25_destroy_socket(struct sock *sk)
 		sk->sk_timer.function = x25_destroy_timer;
 		sk->sk_timer.data     = (unsigned long)sk;
 		add_timer(&sk->sk_timer);
-	} else
-		sk_free(sk);
+	} else {
+		/* drop last reference so sock_put will free */
+		__sock_put(sk);
+	}
+
 	release_sock(sk);
 	sock_put(sk);
 }
@@ -553,7 +556,7 @@ static int x25_release(struct socket *so
 		case X25_STATE_2:
 			x25_disconnect(sk, 0, 0, 0);
 			x25_destroy_socket(sk);
-			break;
+			goto out;
 
 		case X25_STATE_1:
 		case X25_STATE_3:
