From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: sctp should change socket state when
 shutdown is received
Date: Wed, 1 Jun 2016 18:40:32 -0300
Message-ID: <20160601214032.GB29509@localhost.localdomain>
References: <42953bb341d78d8b83dfccebb0beaa9387d8e1af.1464809925.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbcFAVkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 17:40:35 -0400
Content-Disposition: inline
In-Reply-To: <42953bb341d78d8b83dfccebb0beaa9387d8e1af.1464809925.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 02, 2016 at 03:38:45AM +0800, Xin Long wrote:
> Now sctp doesn't change socket state upon shutdown reception. It changes
> just the assoc state, even though it's a TCP-style socket.
> 
> For some cases, if we really need to check sk->sk_state, it's necessary to
> fix this issue, at least when we use ss or netstat to dump, we can get a
> more exact information.
> 
> As an improvement, we will change sk->sk_state when we change asoc->state
> to SHUTDOWN_RECEIVED, and also do it in sctp_shutdown to keep consistent with
> sctp_close.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/sm_sideeffect.c | 4 +++-
>  net/sctp/socket.c        | 5 ++++-
>  2 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index aa37122..12d4519 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -806,8 +806,10 @@ static void sctp_cmd_new_state(sctp_cmd_seq_t *cmds,
>  
>  		/* Set the RCV_SHUTDOWN flag when a SHUTDOWN is received. */
>  		if (sctp_state(asoc, SHUTDOWN_RECEIVED) &&
> -		    sctp_sstate(sk, ESTABLISHED))
> +		    sctp_sstate(sk, ESTABLISHED)) {
> +			sk->sk_state = SCTP_SS_CLOSING;
>  			sk->sk_shutdown |= RCV_SHUTDOWN;
> +		}
>  	}
>  
>  	if (sctp_state(asoc, COOKIE_WAIT)) {
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 67154b8..c20199a 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4193,6 +4193,7 @@ static void sctp_shutdown(struct sock *sk, int how)
>  		return;
>  
>  	if (how & SEND_SHUTDOWN) {
> +		sk->sk_state = SCTP_SS_CLOSING;
>  		ep = sctp_sk(sk)->ep;
>  		if (!list_empty(&ep->asocs)) {
>  			asoc = list_entry(ep->asocs.next,
> @@ -7564,8 +7565,10 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
>  	/* If the association on the newsk is already closed before accept()
>  	 * is called, set RCV_SHUTDOWN flag.
>  	 */
> -	if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP))
> +	if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP)) {
> +		newsk->sk_state = SCTP_SS_CLOSING;
                    ^^^^
>  		newsk->sk_shutdown |= RCV_SHUTDOWN;
> +	}
>  
>  	newsk->sk_state = SCTP_SS_ESTABLISHED;
                      ^^^^^
This will overwrite the above
Otherwise patch looks good to me

>  	release_sock(newsk);
> -- 
> 2.1.0
> 
