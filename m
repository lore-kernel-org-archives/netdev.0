From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: tipc timeout handling.
Date: Fri, 16 May 2014 10:42:53 -0300
Message-ID: <20140516134253.GD4223@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39411 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933601AbaEPNnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 09:43:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jon, Allan,

	While working on a fix for the per recvmmsg syscall timeout
handling I found this issue, can you take a look if this is acceptable?

Thanks,

- Arnaldo

commit 592bb2a330427750d323b1362bf0822db1695e29
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Fri May 16 10:33:02 2014 -0300

    tipc: Don't reset the timeout when restarting
    
    As it may then take longer than what the user specified using
    setsockopt(SO_RCVTIMEO).
    
    Cc: Allan Stephens <allan.stephens@windriver.com>
    Cc: David Miller <davem@davemloft.net>
    To: Jon Maloy <jon.maloy@ericsson.com>,
    Link: http://lkml.kernel.org/n/tip-@git.kernel.org
    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3f9912f87d0d..083c672a2a39 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -984,10 +984,11 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 	return 0;
 }
 
-static int tipc_wait_for_rcvmsg(struct socket *sock, long timeo)
+static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	DEFINE_WAIT(wait);
+	long timeo = *timeop;
 	int err;
 
 	for (;;) {
@@ -1012,6 +1013,7 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long timeo)
 			break;
 	}
 	finish_wait(sk_sleep(sk), &wait);
+	*timeop = timeo;
 	return err;
 }
 
@@ -1055,7 +1057,7 @@ static int tipc_recvmsg(struct kiocb *iocb, struct socket *sock,
 restart:
 
 	/* Look for a message in receive queue; wait if necessary */
-	res = tipc_wait_for_rcvmsg(sock, timeo);
+	res = tipc_wait_for_rcvmsg(sock, &timeo);
 	if (res)
 		goto exit;
 
@@ -1153,7 +1155,7 @@ static int tipc_recv_stream(struct kiocb *iocb, struct socket *sock,
 
 restart:
 	/* Look for a message in receive queue; wait if necessary */
-	res = tipc_wait_for_rcvmsg(sock, timeo);
+	res = tipc_wait_for_rcvmsg(sock, &timeo);
 	if (res)
 		goto exit;
 
