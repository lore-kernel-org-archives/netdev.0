From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] use after free in AF_ROSE
Date: Wed, 10 Dec 2003 10:08:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210100851.4b4a6927.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Ralf Baechle <ralf@linux-mips.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Doing multiple protocol testing and get crashes with simple socket/close
combo with AF_ROSE.  The problem is that it dereferences the socket in rose_release
after it has already been freed by rose_destroy_socket.

This patch fixes that problem, and also uses sock_put to handle the case where
rose_destroy_socket is called with sk_refcnt > 1 which might be possible
if data comes in during close.

The other X.25 like protocols don't have this problem (AX.25, X.25, Netrom)
had the same problem, but have been fixed already (in 2.6.0-test2)

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1533  -> 1.1534 
#	  net/rose/af_rose.c	1.34    -> 1.35   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/10	shemminger@osdl.org	1.1534
# Rose protocol use after free bug.
# --------------------------------------------
#
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	Wed Dec 10 09:47:02 2003
+++ b/net/rose/af_rose.c	Wed Dec 10 09:47:02 2003
@@ -359,7 +359,7 @@
 		sk->sk_timer.data     = (unsigned long)sk;
 		add_timer(&sk->sk_timer);
 	} else
-		sk_free(sk);
+		sock_put(sk);
 }
 
 /*
@@ -634,7 +634,6 @@
 	}
 
 	sock->sk = NULL;
-	sk->sk_socket = NULL;	/* Not used, but we should do this. **/
 
 	return 0;
 }
