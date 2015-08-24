From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net] sctp: partial chunk should be drop without sending
 abort packet
Date: Mon, 24 Aug 2015 09:47:13 -0300
Message-ID: <20150824124713.GZ1097@localhost.localdomain>
References: <88918657d985bc0e55e64ca232dcd5f2b76b7cb4.1440410910.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475AbbHXMrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 08:47:15 -0400
Content-Disposition: inline
In-Reply-To: <88918657d985bc0e55e64ca232dcd5f2b76b7cb4.1440410910.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 06:08:30PM +0800, Xin Long wrote:
> as RFC 4960, 6.10 said, *if the receiver detects a partial chunk, it MUST drop
> the chunk*, we should not send the abort. but if we put this discard to inside
> state machine, it will send abort.
> 
> so we just drop the partial chunk there, never let this chunk go into the state
> machine.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---

This is basically reverting a chunk of Daniel's and Vlad's 26b87c788100
("net: sctp: fix remote memory pressure from excessive queueing") .
Isn't it going to re-introduce the initial issue then?


>  net/sctp/inqueue.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
> index 7e8a16c..a22ca57 100644
> --- a/net/sctp/inqueue.c
> +++ b/net/sctp/inqueue.c
> @@ -183,9 +183,9 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
>  		/* This is not a singleton */
>  		chunk->singleton = 0;
>  	} else if (chunk->chunk_end > skb_tail_pointer(chunk->skb)) {
> -		/* Discard inside state machine. */
> -		chunk->pdiscard = 1;
> -		chunk->chunk_end = skb_tail_pointer(chunk->skb);
> +		sctp_chunk_free(chunk);
> +		chunk = queue->in_progress = NULL;
> +		return NULL;
>  	} else {
>  		/* We are at the end of the packet, so mark the chunk
>  		 * in case we need to send a SACK.
> -- 
> 2.1.0
> 
