From: Wayne Badger <badger@yahoo-inc.com>
Subject: TCP_DEFER_ACCEPT wakes up without data
Date: Wed, 4 Jun 2014 19:14:30 -0500
Message-ID: <538FB666.9050303@yahoo-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mrout2-b.corp.bf1.yahoo.com ([98.139.253.105]:40545 "EHLO
	mrout2-b.corp.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932305AbaFEA03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 20:26:29 -0400
Received: from BF1-EX10-CAHT14.y.corp.yahoo.com (bf1-ex10-caht14.corp.bf1.yahoo.com [10.74.226.58])
	by mrout2-b.corp.bf1.yahoo.com (8.14.4/8.14.4/y.out) with ESMTP id s550EVQ3091963
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 4 Jun 2014 17:14:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to revisit the current state of TCP_DEFER_ACCEPT.  I know
that it has been discussed in the past and the discussion about 4.5
years ago led to commit d1b99ba41d6c5aa1ed2fc634323449dd656899e9 (tcp:
accept socket after TCP_DEFER_ACCEPT period) being introduced which
changed the semantics of TCP_DEFER_ACCEPT.

Prior to commit d1b99ba41d, the open request was never queued to the
listener for accepting if no data was ever received.  After the commit,
the open request is queued to the listener upon receipt of an ACK from
the retransmitted SYN-ACK, which is sent TCP_DEFER_ACCEPT seconds
(which value is provided in the TCP_DEFER_ACCEPT setsockopt) after the
3-way handshake occurs (with appropriate rounding up to account for the
geometric rexmit algorithm).

The tcp(7) man page says that the listener is awakened _only_ when data
arrives on the socket.  We prefer this behavior because it reduces
memory (minisock vs. sock) and scheduling/context switch overhead.  When
no data is ever sent by the client, letting the kernel dispose of the
open request is more efficient than letting the listener dispose of it.
Is there a way to get this behavior with a recent kernel that I have not
discovered?

This discussion is not just academic.  We constantly receive dataless
connection requests from clients.  On some machines, we have seen these
types of connections comprise up to 20% of our connections.  With the
current TCP_DEFER_ACCEPT behavior, apache creates many threads that end
up just waiting for data, timing out, and then closing the connection.
We can increase the TCP_DEFER_ACCEPT value, but that means that we are
just consuming kernel resources for longer than we want and end up
having apache close the connection anyway.

A few questions.

If the new behavior was desired at the time of the commit, why was the
existing TCP_DEFER_ACCEPT behavior changed instead of just adding a new
sockopt that implements the new behavior?  Why was the tcp(7) man page
not modified to describe the new behavior?

I propose the following patch to regain the tcp(7) semantics.  The patch
resolves dataless connections in one of two ways.  After the initial
timeout, a SYN-ACK is retransmitted and if a bare ACK is received, then
a RST is sent to the client and the connection is immediately dropped.
If nothing is received from the client, then the connection is silently
dropped after another rexmit timeout (the next one in the geometric
sequence).

I understand that the patch is incomplete.  For example, it doesn't
handle syncookies but I wanted to initiate the discussion.

Thanks,
Wayne

--- tcp_minisocks.c     2014-05-01 15:53:47.000000000 -0500
+++ tcp_minisocks.c.new 2014-05-16 16:08:59.000000000 -0500
@@ -672,12 +672,31 @@ struct sock *tcp_check_req(struct sock *
        if (fastopen)
                return sk;
 
-       /* While TCP_DEFER_ACCEPT is active, drop bare ACK. */
-       if (req->num_timeout < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
-           TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
-               inet_rsk(req)->acked = 1;
-               NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDEFERACCEPTDROP);
-               return NULL;
+       if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept) {
+               /* While TCP_DEFER_ACCEPT is active, drop bare ACK.
+                * Send a RST and drop the connection if the timer has expired.
+                */
+               if (TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
+                       if (req->retrans < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept) {
+                               inet_rsk(req)->acked = 1;
+                               NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDEFERACCEPTDROP);
+                       } else {
+                               req->rsk_ops->send_reset(sk, skb);
+                               inet_csk_reqsk_queue_drop(sk, req, prev);
+                       }
+                       return NULL;
+               }
+
+               /* Make a finished and dataless TCP_DEFER_ACCEPT connection
+                * request "disappear" without instantiating the socket or
+                * bothering user space.
+                */
+               if ((TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 2) &&
+                   (tcp_flag_word(th) & TCP_FLAG_FIN)) {
+                       req->rsk_ops->send_reset(sk, skb);
+                       inet_csk_reqsk_queue_drop(sk, req, prev);
+                       return NULL;
+               }
        }
 
        /* OK, ACK is valid, create big socket and
