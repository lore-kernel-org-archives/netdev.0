From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Sat, 27 Oct 2012 13:57:12 +0200
Message-ID: <1351339032.30380.222.camel@edumazet-glaptop>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53191 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab2J0L5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 07:57:17 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1417663eek.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 04:57:16 -0700 (PDT)
In-Reply-To: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 01:05 -0700, Vijay Subramanian wrote:
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
> +				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
>  					unsigned long timeo;
>  
>  					if (req->retrans++ == 0)


Part of the complexity of this is that req->retrans is the number of
timeouts, serving as the exponential backoff base.

Unfortunately we have a side effect because number of retransmits is
wrong for defer accept.

Here is what I suggest : upstream to net-next this patch we use at
Google :

Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Oct 2 02:21:12 2012 -0700

net-tcp: better retrans tracking for defer-accept

For passive TCP connections using TCP_DEFER_ACCEPT facility,
we incorrectly increment req->retrans each time timeout triggers
while no SYNACK is sent.

Decouple req->retrans field into two fields :

num_retrans : number of retransmit
num_timeout : number of timeouts

(retrans was renamed to make sure we didnt miss an occurrence)

introduce inet_rtx_syn_ack() helper to increment num_retrans
only if ->rtx_syn_ack() succeeded.

Use inet_rtx_syn_ack() from tcp_check_req() to increment num_retrans
when we re-send a SYNACK in answer to a SYN. Prior to this patch,
we were not counting these retransmits.

Change tcp_v[46]_rtx_synack() to increment TCP_MIB_RETRANSSEGS
only if a synack packet was successfuly queued.

Reported-by: Yuchung Cheng <ycheng@google.com>
    
Then, we could more easily address this silly SYNACK syndrom.

What do you think ?
