From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v4 4/5] sctp: Add ASCONF operation on the
 single-homed host
Date: Fri, 22 Apr 2011 12:10:25 +0800
Message-ID: <4DB0FFB1.3010006@cn.fujitsu.com>
References: <3BDA3586-6A7C-4305-9D41-F146575AC951@sfc.wide.ad.jp> <4DB0FD45.2050709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61429 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750730Ab1DVEKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2011 00:10:36 -0400
In-Reply-To: <4DB0FD45.2050709@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
> Since the sender MUST NOT use the  new IP address as a source for ANY SCTP
> packet except on  carrying an ASCONF Chunk. And ASCONF chunk can be bundled.
> How about this change. If so, you do not need change to sctp_outq_tail();
>
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 1c88c89..bd6cc9c 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -754,6 +754,13 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  	 */
>  
>  	list_for_each_entry_safe(chunk, tmp, &q->control_chunk_list, list) {
> +		/* RFC 5061, 5.3
> +		 * F1) This ...
> +		 */
> +		if (q->asoc->src_out_of_asoc_ok &&
> +		    chunk->chunk_hdr->type != SCTP_CID_ASCONF)

SCTP_CID_ASCONF_ACK should be also allowed, the peer may
send ASCONF to do the same thing at the same time.

> +			continue;
> +
>  		list_del_init(&chunk->list);
>  
>  		/* Pick the right transport to use. */
> @@ -881,6 +888,9 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  		}
>  	}
>  
> +	if (q->asoc->src_out_of_asoc_ok)
> +		goto sctp_flush_out;
> +
>  	/* Is it OK to send data chunks?  */
>  	switch (asoc->state) {
>  	case SCTP_STATE_COOKIE_ECHOED:
>
>
>
