From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] sctp: partial chunk should be drop without sending
 abort packet
Date: Mon, 24 Aug 2015 14:01:30 -0400
Message-ID: <55DB5BFA.3020405@gmail.com>
References: <88918657d985bc0e55e64ca232dcd5f2b76b7cb4.1440410910.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34225 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbbHXSBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 14:01:33 -0400
Received: by qkfh127 with SMTP id h127so79526308qkf.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 11:01:32 -0700 (PDT)
In-Reply-To: <88918657d985bc0e55e64ca232dcd5f2b76b7cb4.1440410910.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2015 06:08 AM, Xin Long wrote:
> as RFC 4960, 6.10 said, *if the receiver detects a partial chunk, it MUST drop
> the chunk*, we should not send the abort. but if we put this discard to inside
> state machine, it will send abort.
> 

Actually, silently dropping this is _very_ bad.  There reason is that you've already
processed the leading chunks and may have potentially queued a response...  Now, you
reach the end of the packet and find that the last chunk is partial.  You end up
dropping the packet, but still handing the responses.  This actually lead to some very
interesting issues we were seeing.

It is better to terminate the association in this case.

-vlad

> so we just drop the partial chunk there, never let this chunk go into the state
> machine.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
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
> 
