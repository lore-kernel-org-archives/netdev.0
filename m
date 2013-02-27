From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 2/4] sctp: fix association hangs due to reneging packets
 below the cumulative TSN ACK point
Date: Wed, 27 Feb 2013 08:52:38 -0500
Message-ID: <512E0FA6.6000603@gmail.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com> <1361889376-22171-3-git-send-email-lee.roberts@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Lee A. Roberts" <lee.roberts@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f170.google.com ([209.85.160.170]:44663 "EHLO
	mail-gh0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759904Ab3B0Nwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 08:52:41 -0500
Received: by mail-gh0-f170.google.com with SMTP id g14so61100ghb.1
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 05:52:40 -0800 (PST)
In-Reply-To: <1361889376-22171-3-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2013 09:36 AM, Lee A. Roberts wrote:
> From: "Lee A. Roberts" <lee.roberts@hp.com>
>
> Resolve SCTP association hangs observed during SCTP stress
> testing.  Observable symptoms include communications hangs
> with data being held in the association reassembly and/or lobby
> (ordering) queues.  Close examination of reassembly queue shows
> missing packets.
>
> In sctp_ulpq_renege_list(), do not renege packets below the
> cumulative TSN ACK point.
>
> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/ulpqueue.c |    9 +++++++--
>   1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
> index ada1746..63afddc 100644
> --- a/net/sctp/ulpqueue.c
> +++ b/net/sctp/ulpqueue.c
> @@ -969,11 +969,16 @@ static __u16 sctp_ulpq_renege_list(struct sctp_ulpq *ulpq,
>
>   	tsnmap = &ulpq->asoc->peer.tsn_map;
>
> -	while ((skb = __skb_dequeue_tail(list)) != NULL) {
> -		freed += skb_headlen(skb);
> +	while ((skb = skb_peek_tail(list)) != NULL) {
>   		event = sctp_skb2event(skb);
>   		tsn = event->tsn;
>
> +		/* Don't renege below the Cumulative TSN ACK Point. */
> +		if (TSN_lte(tsn, sctp_tsnmap_get_ctsn(tsnmap)))
> +			break;
> +
> +		__skb_unlink(skb, list);
> +		freed += skb_headlen(skb);
>   		sctp_ulpevent_free(event);
>   		sctp_tsnmap_renege(tsnmap, tsn);
>   		if (freed >= needed)
>
