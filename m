From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Fix use after free in AX.25
Date: Tue, 5 Aug 2003 14:56:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030805145658.1b3f194b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch is against 2.6.0-test2.  The problem is that the ax25_destroy_socket
function frees the socket buffer, but then ax25_release dereferences this causing
an OOPS.  To reproduce:
	modprobe ax25; ifconfig -a

Replaced sk_free with sock_put which will free if this is the last reference.

diff -urNp -X dontdiff net-2.5/net/ax25/af_ax25.c linux-2.5-net/net/ax25/af_ax25.c
--- net-2.5/net/ax25/af_ax25.c	2003-08-04 09:32:21.000000000 -0700
+++ linux-2.5-net/net/ax25/af_ax25.c	2003-08-05 14:34:21.000000000 -0700
@@ -349,7 +349,7 @@ void ax25_destroy_socket(ax25_cb *ax25)
 			ax25->timer.data     = (unsigned long)ax25;
 			add_timer(&ax25->timer);
 		} else {
-			sk_free(ax25->sk);
+			sock_put(ax25->sk);
 		}
 	} else {
 		ax25_free_cb(ax25);
@@ -944,15 +944,13 @@ static int ax25_release(struct socket *s
 		switch (ax25->state) {
 		case AX25_STATE_0:
 			ax25_disconnect(ax25, 0);
-			ax25_destroy_socket(ax25);
-			break;
+			goto drop;
 
 		case AX25_STATE_1:
 		case AX25_STATE_2:
 			ax25_send_control(ax25, AX25_DISC, AX25_POLLON, AX25_COMMAND);
 			ax25_disconnect(ax25, 0);
-			ax25_destroy_socket(ax25);
-			break;
+			goto drop;
 
 		case AX25_STATE_3:
 		case AX25_STATE_4:
@@ -995,13 +993,16 @@ static int ax25_release(struct socket *s
 		sk->sk_shutdown |= SEND_SHUTDOWN;
 		sk->sk_state_change(sk);
 		sock_set_flag(sk, SOCK_DEAD);
-		ax25_destroy_socket(ax25);
+		goto drop;
 	}
 
 	sock->sk   = NULL;
 	sk->sk_socket = NULL;	/* Not used, but we should do this */
 	release_sock(sk);
-
+	return 0;
+ drop:
+	release_sock(sk);
+	ax25_destroy_socket(ax25);
 	return 0;
 }
 
