From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/13) ddp socket orphan
Date: Fri, 29 Aug 2003 14:12:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829141228.6a35664c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes the problem caused by interrupting aecho causing an oops.
What happened was that the sock was detached from the user process
but sk->sk_sleep was still so when write data was freed it would
do a wakeup on a poisoned data.  The sk_state_change code that was
there isn't necessary, because we are in middle of release so no
user process can be waiting.  sock_orphan does the right thing
and sets SOCK_DEAD.  

This is similar to what some other protocols do.  But some will
have the same sk->sk_sleep problem...  

diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Fri Aug 29 13:32:35 2003
+++ b/net/appletalk/ddp.c	Fri Aug 29 13:32:35 2003
@@ -998,10 +998,7 @@
 	struct sock *sk = sock->sk;
 
 	if (sk) {
-		if (!sock_flag(sk, SOCK_DEAD)) {
-			sk->sk_state_change(sk);
-			sock_set_flag(sk, SOCK_DEAD);
-		}
+		sock_orphan(sk);
 		sock->sk = NULL;
 		atalk_destroy_socket(sk);
 	}
