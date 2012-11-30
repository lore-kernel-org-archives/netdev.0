From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: verify length provided in heartbeat information
 parameter
Date: Fri, 30 Nov 2012 12:34:12 -0500
Message-ID: <50B8EE14.7050804@gmail.com>
References: <20121130121627.GG30697@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:55810 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288Ab2K3ReT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:34:19 -0500
In-Reply-To: <20121130121627.GG30697@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2012 07:16 AM, Thomas Graf wrote:
> If the variable parameter length provided in the mandatory
> heartbeat information parameter exceeds the calculated payload
> length the packet has been corrupted. Reply with a parameter
> length protocol violation message.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/sm_statefuns.c | 10 ++++++++--
>   1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index b6adef8..e92079d 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -1055,6 +1055,7 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
>   				    void *arg,
>   				    sctp_cmd_seq_t *commands)
>   {
> +	sctp_paramhdr_t *param_hdr;
>   	struct sctp_chunk *chunk = arg;
>   	struct sctp_chunk *reply;
>   	size_t paylen = 0;
> @@ -1072,12 +1073,17 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
>   	 * Information field copied from the received HEARTBEAT chunk.
>   	 */
>   	chunk->subh.hb_hdr = (sctp_heartbeathdr_t *) chunk->skb->data;
> +	param_hdr = (sctp_paramhdr_t *) chunk->subh.hb_hdr;
>   	paylen = ntohs(chunk->chunk_hdr->length) - sizeof(sctp_chunkhdr_t);
> +
> +	if (ntohs(param_hdr->length) > paylen)
> +		return sctp_sf_violation_paramlen(net, ep, asoc, type, arg,
> +						  param_hdr, commands);
> +
>   	if (!pskb_pull(chunk->skb, paylen))
>   		goto nomem;
>
> -	reply = sctp_make_heartbeat_ack(asoc, chunk,
> -					chunk->subh.hb_hdr, paylen);
> +	reply = sctp_make_heartbeat_ack(asoc, chunk, param_hdr, paylen);
>   	if (!reply)
>   		goto nomem;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
