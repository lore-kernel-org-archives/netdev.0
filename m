From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Increase snd/rcv buffers in pppoe
Date: 23 Feb 2004 00:47:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040222234750.GA78924@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
Date: Mon, 23 Feb 2004 00:47:50 +0100
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I noticed that a 64bit kernel only downloads half as fast over a PPPoE DSL
connection than a 32bit kernel on the same hardware. The reason seems
to be that PPPoE uses the default 64K snd/rcv buffers at socket creation.
The bigger sk_buff header size on the 64bit kernel pushed
the buffer into being too small and preventing good throughput.

This patch fixes it here. It simply doubles the buffers. There should
be only a few PPPoE sockets active so I don't think this is a problem.
The TX increase is probably not needed because upload speeds on DSL
are typically much slower than RX, but it also cannot hurt.

-Andi


diff -u linux-2.6.3-amd64/drivers/net/pppoe.c-o linux-2.6.3-amd64/drivers/net/pppoe.c
--- linux-2.6.3-amd64/drivers/net/pppoe.c-o	2004-02-19 23:28:07.000000000 +0100
+++ linux-2.6.3-amd64/drivers/net/pppoe.c	2004-02-24 22:02:17.000000000 +0100
@@ -506,6 +506,10 @@
 		goto out;
 
 	sock_init_data(sock, sk);
+
+	sk->sk_rcvbuf *= 2;
+	sk->sk_sndbuf *= 2;
+
 	sk_set_owner(sk, THIS_MODULE);
 	sock->state = SS_UNCONNECTED;
 	sock->ops   = &pppoe_ops;
