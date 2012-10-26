From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Sat, 27 Oct 2012 00:30:01 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210262325480.2880@ja.ssi.bg>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56667 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965612Ab2JZVXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 17:23:54 -0400
In-Reply-To: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 26 Oct 2012, Vijay Subramanian wrote:

> Elliott Hughes <enh@google.com> saw strange behavior when server socket was not
> calling accept(). Client was receiving SYN-ACK back even when socket on server
> side was not yet available. Eric noted server sockets kept resending SYN_ACKS
> and further investigation revealed the following problem.
> 
> If server socket is slow to accept() connections, request_socks can represent
> connections for which the three-way handshake is already done.  From client's
> point of view, the connection is in ESTABLISHED state but on server side, socket
> is not in accept_queue or ESTABLISHED state.  When the syn-ack timer expires,
> because of the order in which tests are performed, server can retransmit the
> synack repeatedly. Following patch prevents the server from retransmitting the
> synack needlessly (and prevents client from replying with ack).  This reduces
> traffic when server is slow to accept() connections.
> 
> If the server socket has received the third ack during connection establishment,
> this is remembered in inet_rsk(req)->acked.  The request_sock will expire in
> around 30 seconds and will be dropped if it does not move into accept_queue.
> 
> With help from Eric Dumazet.
> 
> Reported-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Tested-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
> Changes from V1: Changed Reported-by tag and commit message. Added Acked-by and
> Tested-by tags.
> 
> Ignoring "WARNING: line over 80 characters" in the interest of readability.
> 
>  net/ipv4/inet_connection_sock.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index d34ce29..4e8e52e 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -598,9 +598,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
>  					       &expire, &resend);
>  				req->rsk_ops->syn_ack_timeout(parent, req);
>  				if (!expire &&
> -				    (!resend ||
> -				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||
> -				     inet_rsk(req)->acked)) {
> +				    (!resend || inet_rsk(req)->acked ||

	Wait a minute, this can cause problem at least
for the TCP_DEFER_ACCEPT mode. It is supposed to timeout
in SYN_RECV state if after silence period (no retransmissions)
and some final retransmissions (until max_retries) client
still does not send data - the request should be expired
without notifying the listener.

	So, the logic in syn_ack_recalc() was tuned to resend
after the TCP_DEFER_ACCEPT period. This patch stops such
resends after TCP_DEFER_ACCEPT period. May be the change
should be in syn_ack_recalc() without hurting TCP_DEFER_ACCEPT?

	Lets analyze the default case without TCP_DEFER_ACCEPT.

	Think for protocols like SMTP where server sends
welcome message. This patch stops SYN-ACK resends, client
sends one ACK (which server drops) and enters EST state.
Client is waiting for welcome message in EST state while
server is waiting silently for ACK message to create child
socket. No progress, may but timeout error in client.

	Is the patch safe for such case? Is there a logic
that creates child socket from request if the dropped ACK
was the last message from client? It must not do it for
TCP_DEFER_ACCEPT.

> +				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
>  					unsigned long timeo;
>  
>  					if (req->retrans++ == 0)
> -- 
> 1.7.0.4
> 
> --

Regards

--
Julian Anastasov <ja@ssi.bg>
