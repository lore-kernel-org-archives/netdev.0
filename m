From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Tue, 29 May 2012 22:17:41 +0200
Message-ID: <1338322661.7747.17.camel@localhost>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <4FC3A465.4030203@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755114Ab2E2UST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 16:18:19 -0400
In-Reply-To: <4FC3A465.4030203@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-28 at 18:14 +0200, Christoph Paasch wrote:

> On 05/28/2012 01:52 PM, Jesper Dangaard Brouer wrote:
> > The following series is a RFC (Request For Comments) for implementing
> > a faster and parallel handling of TCP SYN connections, to mitigate SYN
> > flood attacks.  This is against DaveM's net (f0d1b3c2bc), as net-next
> > is closed, as DaveM has mentioned numerous times ;-)
> > 
> > Only IPv4 TCP is handled here. The IPv6 TCP code also need to be
> > updated, but I'll deal with that part after we have agreed on a
> > solution for IPv4 TCP.
> > 
> >  Patch 1/2: Is a cleanup, where I split out the SYN cookie handling
> >   from tcp_v4_conn_request() into tcp_v4_syn_conn_limit().
> > 
> >  Patch 2/2: Move tcp_v4_syn_conn_limit() outside bh_lock_sock() in
> >   tcp_v4_rcv().  I would like some input on, (1) if this safe without
> >   the lock, (2) if we need to do some sock lookup, before calling
> >   tcp_v4_syn_conn_limit() (Christoph Paasch
> >   <christoph.paasch@uclouvain.be> mentioned something about SYN
> >   retransmissions)
> 
> Concerning (1):
> I think, there are places where you may have troube because you don't
> hold the lock.
> E.g., in tcp_make_synack (called by tcp_v4_send_synack from your
> tcp_v4_syn_conn_limit) there is:
> 
> if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
> 	(req->window_clamp > tcp_full_space(sk) ||
> 	 req->window_clamp == 0))
> 	req->window_clamp = tcp_full_space(sk);
> 
> Thus, tcp_full_space(sk) may have different values between the check and
> setting req->window_clamp.

This should be simply solved by using a local stack variable, for
storing the result from tcp_full_space(sk).  Its likely that GCC already
does this behind our back.


> Concerning (2):
> 
> Imagine, a SYN coming in, when the reqsk-queue is not yet full. A
> request-sock will be added to the reqsk-queue. Then, a retransmission of
> this SYN comes in and the queue got full by the time. This time
> tcp_v4_syn_conn_limit will do syn-cookies and thus generate a different
> seq-number for the SYN/ACK.

I have addressed your issue, by checking the reqsk_queue in
tcp_v4_syn_conn_limit() before allocating a new req via
inet_reqsk_alloc().
If I find an existing reqsk, I choose to drop it, so the SYN cookie
SYN-ACK takes precedence, as the path/handling of the last ACK doesn't
find this reqsk. This is done under the lock.

Test results show that I can provoke the SYN retransmit situation, and
that performance is still very good. Func call inet_csk_search_req()
only sneaks up to a top 20 on perf report.

Patch on top of this patch:

[RFC PATCH 3/2] tcp: Detect SYN retransmits during SYN flood

 Check for existing connection request (reqsk) as this might
 be a retransmitted SYN which have gotten into the
 reqsk_queue.  If so, we choose to drop the reqsk, and use
 SYN cookies to restore the state later.

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7480fc2..e0c9ba3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1274,8 +1274,10 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
  */
 int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
 {
-       struct request_sock *req;
+       struct request_sock *req = NULL;
        struct inet_request_sock *ireq;
+       struct request_sock *exist_req;
+       struct request_sock **prev;
        struct tcp_options_received tmp_opt;
        __be32 saddr = ip_hdr(skb)->saddr;
        __be32 daddr = ip_hdr(skb)->daddr;
@@ -1303,6 +1305,22 @@ int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
        if (!tcp_syn_flood_action(sk, skb, "TCP"))
                goto drop; /* Not enabled, indicate drop, due to queue full */
 
+       /* Check for existing connection request (reqsk) as this might
+        *   be a retransmitted SYN which have gotten into the
+        *   reqsk_queue.  If so, we choose to drop the reqsk, and use
+        *   SYN cookies to restore the state later.
+        */
+       bh_lock_sock(sk);
+       exist_req = inet_csk_search_req(sk, &prev, tcp_hdr(skb)->source, saddr, daddr);
+       if (exist_req) { /* Drop existing reqsk */
+               if (TCP_SKB_CB(skb)->seq == tcp_rsk(exist_req)->rcv_isn)
+                       net_warn_ratelimited("Retransmitted SYN from %pI4"
+                                            " (orig reqsk dropped)", &saddr);
+
+               inet_csk_reqsk_queue_drop(sk, exist_req, prev);
+       }
+       bh_unlock_sock(sk);
+
        /* Allocate a request_sock */
        req = inet_reqsk_alloc(&tcp_request_sock_ops);
        if (!req) {



I'll post some V2 patches tomorrow, which integrates this changes in
patch 2/2.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
