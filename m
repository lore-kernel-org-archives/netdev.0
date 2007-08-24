From: John Heffner <jheffner@psc.edu>
Subject: Re: Problem with implementation of TCP_DEFER_ACCEPT?
Date: Fri, 24 Aug 2007 00:40:14 -0400
Message-ID: <46CE612E.60208@psc.edu>
References: <1187914105.26866.41.camel@bagoas.tjworld.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070708020609040304080601"
Cc: netdev@vger.kernel.org
To: TJ <linux@tjworld.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:62531 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbXHXEkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 00:40:23 -0400
In-Reply-To: <1187914105.26866.41.camel@bagoas.tjworld.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070708020609040304080601
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

TJ wrote:
> client SYN > server LISTENING
> client < SYN ACK server SYN_RECEIVED (time-out 3s)
>                  server: inet_rsk(req)->acked = 1
> 
> client ACK > server (discarded)
> 
> client < SYN ACK (DUP) server (time-out 6s)
> client ACK (DUP) > server (discarded)
> 
> client < SYN ACK (DUP) server (time-out 12s)
> client ACK (DUP) > server (discarded)
> 
> client < SYN ACK (DUP) server (time-out 24s)
> client ACK (DUP) > server (discarded)
> 
> client < SYN ACK (DUP) server (time-out 48s)
> client ACK (DUP) > server (discarded)
> 
> client < SYN ACK (DUP) server (time-out 96s)
> client ACK (DUP) > server (discarded)
> 
> server: half-open socket closed.
> 
> With each client ACK being dropped by the kernel's TCP_DEFER_ACCEPT
> mechanism eventually the handshake fails after the 'SYN ACK' retries and
> time-outs expire.
> 
> There is a case for arguing the kernel should be operating in an
> enhanced handshaking mode when TCP_DEFER_ACCEPT is enabled, not an
> alternative mode, and therefore should accept *both* RFC 793 and
> TCP_DEFER_ACCEPT. I've been unable to find a specification or RFC for
> implementing TCP_DEFER_ACCEPT aka BSD's SO_ACCEPTFILTER to give me firm
> guidance.
> 
> It seems incorrect to penalise a client that is trying to complete the
> handshake according to the RFC 793 specification, especially as the
> client has no way of knowing ahead of time whether or not the server is
> operating deferred accept.

Interesting problem.  TCP_DEFER_ACCEPT does not conform to any standard 
I'm aware of.  (In fact, I'd say it's in violation of RFC 793.)  The 
implementation does exactly what it claims, though -- it "allows a 
listener to be awakened only  when  data  arrives  on  the  socket."

I think a more useful spec might have been "allows a listener to be 
awakened only when data arrives on the socket, unless the specified 
timeout has expired."  Once the timeout expires, it should process the 
embryonic connection as if TCP_DEFER_ACCEPT is not set.  Unfortunately, 
I don't think we can retroactively change this definition, as an 
application might depend on data being available and do a non-blocking 
read() after the accept(), expecting data to be there.  Is this worth 
trying to fix?

Also, a listen socket with a backlog and TCP_DEFER_ACCEPT will have reqs 
sit in the backlog for the full defer timeout, even if they've received 
data, which is not really the right thing to do.

I've attached a patch implementing this suggestion (compile tested only 
-- I think I got the logic right but it's late ;).  Kind of ugly, and 
uses up a bit in struct inet_request_sock.  Maybe can be done better...

   -John

--------------070708020609040304080601
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="tcp_defer_accept.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_defer_accept.patch"

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 62daf21..f9f64a5 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -72,7 +72,8 @@ struct inet_request_sock {
 				sack_ok	   : 1,
 				wscale_ok  : 1,
 				ecn_ok	   : 1,
-				acked	   : 1;
+				acked	   : 1,
+				deferred   : 1;
 	struct ip_options	*opt;
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 185c7ec..cad2490 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -978,6 +978,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->snd_wscale = rx_opt->snd_wscale;
 	ireq->wscale_ok = rx_opt->wscale_ok;
 	ireq->acked = 0;
+	ireq->deferred = 0;
 	ireq->ecn_ok = 0;
 	ireq->rmt_port = tcp_hdr(skb)->source;
 }
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index fbe7714..1207fb8 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -444,9 +444,6 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		}
 	}
 
-	if (queue->rskq_defer_accept)
-		max_retries = queue->rskq_defer_accept;
-
 	budget = 2 * (lopt->nr_table_entries / (timeout / interval));
 	i = lopt->clock_hand;
 
@@ -455,7 +452,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
 				if ((req->retrans < thresh ||
-				     (inet_rsk(req)->acked && req->retrans < max_retries))
+				     (inet_rsk(req)->acked && req->retrans < max_retries) ||
+				     (inet_rsk(req)->deferred && req->retrans <
+				      queue->rskq_defer_accept + max_retries))
 				    && !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {
 					unsigned long timeo;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index a12b08f..c4867f3 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -637,8 +637,10 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 
 		/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
 		if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
-		    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
-			inet_rsk(req)->acked = 1;
+		    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1 &&
+		    !inet_rsk(req)->acked && req->retrans <
+		    inet_csk(sk)->icsk_accept_queue.rskq_defer_accept) {
+			inet_rsk(req)->deferred = 1;
 			return NULL;
 		}
 
@@ -686,6 +688,9 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 	listen_overflow:
 		if (!sysctl_tcp_abort_on_overflow) {
 			inet_rsk(req)->acked = 1;
+			/* If deferred, ACK must contain data.  Shortcut defer. */
+			if (inet_rsk(req)->deferred)
+				req->retrans = inet_csk(sk)->icsk_accept_queue.rskq_defer_accept;
 			return NULL;
 		}
 

--------------070708020609040304080601--
