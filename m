From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC] [PATCH] tcp_splice_read: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Mon, 2 Jun 2008 02:36:29 +0300
Message-ID: <200806020236.29735.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_9JzQIRBhfh6R50B"
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3547 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752696AbYFAXhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 19:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_9JzQIRBhfh6R50B
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch stops propagating SPLICE_F_NONBLOCK as O_NONBLOCK to the 
underlaying socket. It follows the man page semantic - or at least my 
interpretation. 

This approach also provides a simple solution to the splice transfer size 
problem. Say we have the following common sequence:

splice(socket, pipe);
splice(pipe, file);

Unless we specify SPLICE_F_NONBLOCK, we can't use arbitrarily large size 
transfers with the 1st splice since otherwise we will deadlock due to 
pipe "fullness".  But if we use SPLICE_F_NONBLOCK, the current implementation 
will make the underlying socket non-blocking and thus will force us use poll 
or other notification mechanism.

Choosing a splice transfer size so that we don't deadlock is tricky: we want 
to use a large value to improve performance (less system calls) and at the 
same time we need to stay under PIPE_BUFFERS packets. Fragmentation / MTU 
complicates this equation further.


tavi

--Boundary-00=_9JzQIRBhfh6R50B
Content-Type: text/x-diff
Content-Transfer-Encoding: 7bit

commit 48ca7b28c611d07db5bc48a6519385873e058e2c
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Sun Jun 1 22:27:36 2008 +0300

    tcp_splice_read: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
    
    This patch changes tcp_splice_read to the behavior implied by man 2
    splice: SPLICE_F_NONBLOCK - Do not block on I/O. This makes the splice
    pipe operations non-blocking, but splice() may nevertheless block
    because the file descriptors that are spliced to/from may block
    (unless they have the O_NONBLOCK flag set).
    
    Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 78c66b6..a21d599 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -569,7 +569,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 
 	lock_sock(sk);
 
-	timeo = sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);
+	timeo = sock_rcvtimeo(sk, sock->file->f_flags & O_NONBLOCK);
 	while (tss.len) {
 		ret = __tcp_splice_read(sk, &tss);
 		if (ret < 0)
@@ -577,10 +577,6 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
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
--Boundary-00=_9JzQIRBhfh6R50B--
