From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Thu, 17 Jul 2008 16:33:49 +0300
Message-ID: <200807171633.49791.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_9o0fI22l6Bbv13m"
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4390 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756086AbYGQNf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 09:35:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_9o0fI22l6Bbv13m
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



--Boundary-00=_9o0fI22l6Bbv13m
Content-Type: text/plain;
  charset="us-ascii";
  name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="x"

commit 11134aa8499b6fd67569e8fd21bde6fc481898d1
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Thu Jul 17 16:25:23 2008 +0300

    tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
    
    This patch changes tcp_splice_read to the behavior implied by man 2
    splice:
    
         SPLICE_F_NONBLOCK - Do not block on I/O. This makes the splice
         pipe operations non-blocking, but splice() may nevertheless block
         because the file descriptors that are spliced to/from may block
         (unless they have the O_NONBLOCK flag set).
    
    This approach also provides a simple solution to the splice
    transfer size problem. Say we have the following common sequence:
    
         splice(socket, pipe);
         splice(pipe, file);
    
    Unless we specify SPLICE_F_NONBLOCK, we can't use arbitrarily large
    transfer sizes with the 1st splice since otherwise we will deadlock
    due to pipe being full.  But if we use SPLICE_F_NONBLOCK, the current
    implementation will make the underlying socket non-blocking and thus
    will force us use poll or other async I/O notification mechanism.
    
    Choosing a splice transfer size that won't deadlock is not trivial: we
    need to stay under PIPE_BUFFERS packets and since packets can have
    arbitrary sizes we will need to be conservative and use a small
    transfer size. That can degrade performance due to excessive system
    calls.
    
    Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 56a133c..cc5082b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -570,7 +570,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 
 	lock_sock(sk);
 
-	timeo = sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);
+	timeo = sock_rcvtimeo(sk, sock->file->f_flags & O_NONBLOCK);
 	while (tss.len) {
 		ret = __tcp_splice_read(sk, &tss);
 		if (ret < 0)
@@ -578,10 +578,6 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 		else if (!ret) {
 			if (spliced)
 				break;
-			if (flags & SPLICE_F_NONBLOCK) {
-				ret = -EAGAIN;
-				break;
-			}
 			if (sock_flag(sk, SOCK_DONE))
 				break;
 			if (sk->sk_err) {

--Boundary-00=_9o0fI22l6Bbv13m--
