From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Fri, 26 Oct 2012 23:42:04 +0200
Message-ID: <1351287724.30380.35.camel@edumazet-glaptop>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
	 <alpine.LFD.2.00.1210262325480.2880@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62508 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964856Ab2JZVmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 17:42:09 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1261550eek.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 14:42:08 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1210262325480.2880@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-27 at 00:30 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Fri, 26 Oct 2012, Vijay Subramanian wrote:
> 
> > Elliott Hughes <enh@google.com> saw strange behavior when server socket was not
> > calling accept(). Client was receiving SYN-ACK back even when socket on server
> > side was not yet available. Eric noted server sockets kept resending SYN_ACKS
> > and further investigation revealed the following problem.
> > 
> > If server socket is slow to accept() connections, request_socks can represent
> > connections for which the three-way handshake is already done.  From client's
> > point of view, the connection is in ESTABLISHED state but on server side, socket
> > is not in accept_queue or ESTABLISHED state.  When the syn-ack timer expires,
> > because of the order in which tests are performed, server can retransmit the
> > synack repeatedly. Following patch prevents the server from retransmitting the
> > synack needlessly (and prevents client from replying with ack).  This reduces
> > traffic when server is slow to accept() connections.
> > 
> > If the server socket has received the third ack during connection establishment,
> > this is remembered in inet_rsk(req)->acked.  The request_sock will expire in
> > around 30 seconds and will be dropped if it does not move into accept_queue.
> > 
> > With help from Eric Dumazet.
> > 
> > Reported-by: Eric Dumazet <edumazet@google.com>
> > Acked-by: Neal Cardwell <ncardwell@google.com>
> > Tested-by: Neal Cardwell <ncardwell@google.com>
> > Acked-by: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> > ---
> > Changes from V1: Changed Reported-by tag and commit message. Added Acked-by and
> > Tested-by tags.
> > 
> > Ignoring "WARNING: line over 80 characters" in the interest of readability.
> > 
> >  net/ipv4/inet_connection_sock.c |    5 ++---
> >  1 files changed, 2 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> > index d34ce29..4e8e52e 100644
> > --- a/net/ipv4/inet_connection_sock.c
> > +++ b/net/ipv4/inet_connection_sock.c
> > @@ -598,9 +598,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
> >  					       &expire, &resend);
> >  				req->rsk_ops->syn_ack_timeout(parent, req);
> >  				if (!expire &&
> > -				    (!resend ||
> > -				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||
> > -				     inet_rsk(req)->acked)) {
> > +				    (!resend || inet_rsk(req)->acked ||
> 
> 	Wait a minute, this can cause problem at least
> for the TCP_DEFER_ACCEPT mode. It is supposed to timeout
> in SYN_RECV state if after silence period (no retransmissions)
> and some final retransmissions (until max_retries) client
> still does not send data - the request should be expired
> without notifying the listener.
> 
> 	So, the logic in syn_ack_recalc() was tuned to resend
> after the TCP_DEFER_ACCEPT period. This patch stops such
> resends after TCP_DEFER_ACCEPT period. May be the change
> should be in syn_ack_recalc() without hurting TCP_DEFER_ACCEPT?
> 
> 	Lets analyze the default case without TCP_DEFER_ACCEPT.
> 
> 	Think for protocols like SMTP where server sends
> welcome message. This patch stops SYN-ACK resends, client
> sends one ACK (which server drops) and enters EST state.
> Client is waiting for welcome message in EST state while
> server is waiting silently for ACK message to create child
> socket. No progress, may but timeout error in client.
> 
> 	Is the patch safe for such case? Is there a logic
> that creates child socket from request if the dropped ACK
> was the last message from client? It must not do it for
> TCP_DEFER_ACCEPT.


I see no impact with TCP_DEFER_ACCEPT handling.

TCP_DEFER_ACCEPT is quite different from this stuff

The 3WHS is completed, and the socket is ready.

But its not delivered to the accept() (listener) until we receive a DATA
frame (or defer timeout elapsed)

We dont resend SYNACK messages for them. We just wait the 4th packet.
