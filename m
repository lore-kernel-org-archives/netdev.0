From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/11) netrom - fix use after free in close
Date: Wed, 13 Aug 2003 15:48:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813154852.45704d29.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netrom would oops if one did:
	modprobe netrom
	ifconfig -a

because the code in destroy was freeing the socket then release_sock was
called. 

diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Wed Aug 13 15:33:26 2003
+++ b/net/netrom/af_netrom.c	Wed Aug 13 15:33:26 2003
@@ -516,6 +516,7 @@
 
 	if (sk == NULL) return 0;
 
+	sock_hold(sk);
 	lock_sock(sk);
 	nr = nr_sk(sk);
 
@@ -551,6 +552,7 @@
 
 	sock->sk   = NULL;	
 	release_sock(sk);
+	sock_put(sk);
 
 	return 0;
 }
