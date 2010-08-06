From: Andi Kleen <andi@firstfloor.org>
Subject: [RFC] [PATCH] Don't destroy TCP sockets twice
Date: Fri, 6 Aug 2010 13:05:11 +0200
Message-ID: <20100806110511.GA16448@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56601 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759365Ab0HFLFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 07:05:13 -0400
Received: from basil.firstfloor.org (p5B3C940C.dip0.t-ipconnect.de [91.60.148.12])
	by one.firstfloor.org (Postfix) with ESMTP id 4E4B91F08072
	for <netdev@vger.kernel.org>; Fri,  6 Aug 2010 13:05:12 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While working on something else I noticed that tcp_v4/6_destroy_sock()
can get called twice on a socket. This happens because when a reset or
similar happens tcp_done destroys the connection socket state, and 
then eventually when the socket is released it is destroyed again. 

Problem here is that the socket can actually still transmit packets
even after having been destroyed by tcp_done: this happens because
tcp_close is called after tcp_done, tcp_close calls tcp_send_fin which
then sends the FIN at least.

With my local modifications this lead to crashes (I destroyed some
additional state in destroy_sock that is needed for sending any
packets). But I think it's broken even without any changes: tcp_*_destroy
sock removes a lot of state, including MD5 state, congestion control
state and some others.

At least for MD5 it's easy to argue that the the FIN still needs this
state. I haven't tested that, but I think what will happen is that
you'll see FINs which are not MD5 signed after a reset (there is no
crash because zero MD5 state is ignored) There might be other similar
problems with congestion avoidance state and the FIN packet.

Overall it also seems inefficient to destroy twice.

The only thing in tcp_*_destroy sock that I think really needs to be
done is clearing the timers, but tcp_done does this already too.

So this patch changes tcp_done to not call inet_csk_destroy_sock()
and leave the destruction to the later final release or close.

The only drawback is that the buffers could be freed a bit later
for the RST case (e.g. when there is a reference to user space
it will wait for the user close), but that doesn't seem like a big 
issue.

I made this a RFC for now because it needs some more review.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6596b4f..f7cae15 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3171,8 +3171,6 @@ void tcp_done(struct sock *sk)
 
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_state_change(sk);
-	else
-		inet_csk_destroy_sock(sk);
 }
 EXPORT_SYMBOL_GPL(tcp_done);
 
