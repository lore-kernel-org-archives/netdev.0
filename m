From: Julian Anastasov <ja@ssi.bg>
Subject: TCP fixes for 2.2: forget sendmsg OOM, tcp_reset error_report
Date: Fri, 23 Aug 2002 09:53:53 +0000 (GMT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208230943280.1117-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <owner-netdev@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
List-Id: netdev.vger.kernel.org


	Hello,

	Below are two fixes useful for 2.2.22.

	The first fixes SIGIO issue with tcp_reset, stolen from
2.4 - we should send event on error.

	The second one fixes TCP sendmsg problem on OOM (broken
terminals, etc) - we should forget the old error (ENOMEM) and
not to fail with EFAULT.

--- v2.2.21/linux/net/ipv4/tcp_input.c	Sun Nov  4 10:16:16 2001
+++ linux/net/ipv4/tcp_input.c	Thu Aug 22 22:14:23 2002
@@ -296,7 +296,7 @@
 	}
 	sk->shutdown = SHUTDOWN_MASK;
 	if (!sk->dead) 
-		sk->state_change(sk);
+		sk->error_report(sk);
 }
 
 /* This tags the retransmission queue when SACKs arrive. */


--- v2.2.21/linux/net/ipv4/tcp.c	Sun Nov  4 10:16:16 2001
+++ linux/net/ipv4/tcp.c	Thu Aug 22 22:16:02 2002
@@ -940,6 +940,7 @@
 				if (!err) 
 					tcp_push_pending_frames(sk, tp);
 				wait_for_tcp_memory(sk, err);
+				err = 0;
 
 				/* If SACK's were formed or PMTU events happened,
 				 * we must find out about it.


Regards

--
Julian Anastasov <ja@ssi.bg>
