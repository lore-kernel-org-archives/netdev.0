From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v2] net: sctp: test if association is dead in sctp_wake_up_waiters
Date: Wed, 09 Apr 2014 08:55:07 -0400
Message-ID: <5345432B.40100@gmail.com>
References: <de3e98e644dde7dcaea9a952de38eb32a2959eeb.1396999714.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:65452 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597AbaDIMzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 08:55:10 -0400
In-Reply-To: <de3e98e644dde7dcaea9a952de38eb32a2959eeb.1396999714.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2014 07:32 PM, Daniel Borkmann wrote:
> In function sctp_wake_up_waiters(), we need to involve a test
> if the association is declared dead. If so, we don't have any
> reference to a possible sibling association anymore and need
> to invoke sctp_write_space() instead and normally walk the
> socket's associations and notify them of new wmem space. The
> reason for special casing is that, otherwise, we could run
> into the following issue:
> 
> sctp_association_free()
> `-> list_del(&asoc->asocs)         <-- poisons list pointer
>     asoc->base.dead = true
>     sctp_outq_free(&asoc->outqueue)
>     `-> __sctp_outq_teardown()
>      `-> sctp_chunk_free()
>       `-> consume_skb()
>        `-> sctp_wfree()
>         `-> sctp_wake_up_waiters() <-- dereferences poisoned pointers
>                                        if asoc->ep->sndbuf_policy=0
> 
> Therefore, only walk the list in an 'optimized' way if we find
> that the current association is still active. We could also use
> list_del_init() in addition when we call sctp_association_free(),
> but as Vlad suggests, we want to trap such bugs and thus leave
> it poisoned as is. Stress-testing seems fine now.
> 
> Fixes: cd253f9f357d ("net: sctp: wake up all assocs if sndbuf policy is per socket")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad
> ---
>  v1->v2:
>   - leave list_del()
> 
>  net/sctp/socket.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 5f83a6a..270d5bd 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6604,6 +6604,12 @@ static void sctp_wake_up_waiters(struct sock *sk,
>  	if (asoc->ep->sndbuf_policy)
>  		return __sctp_write_space(asoc);
>  
> +	/* If association goes down and is just flushing its
> +	 * outq, then just normally notify others.
> +	 */
> +	if (asoc->base.dead)
> +		return sctp_write_space(sk);
> +
>  	/* Accounting for the sndbuf space is per socket, so we
>  	 * need to wake up others, try to be fair and in case of
>  	 * other associations, let them have a go first instead
> 
