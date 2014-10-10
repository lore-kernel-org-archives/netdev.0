From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 2/3] net: sctp: fix panic on duplicate ASCONF chunks
Date: Fri, 10 Oct 2014 11:39:54 -0400
Message-ID: <20141010153954.GE19499@hmsreliant.think-freely.org>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com>
 <1412888133-833-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39680 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbaJJPkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 11:40:03 -0400
Content-Disposition: inline
In-Reply-To: <1412888133-833-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2014 at 10:55:32PM +0200, Daniel Borkmann wrote:
> When receiving a e.g. semi-good formed connection scan in the
> form of ...
> 
>   -------------- INIT[ASCONF; ASCONF_ACK] ------------->
>   <----------- INIT-ACK[ASCONF; ASCONF_ACK] ------------
>   -------------------- COOKIE-ECHO -------------------->
>   <-------------------- COOKIE-ACK ---------------------
>   ---------------- ASCONF_a; ASCONF_b ----------------->
> 
> ... where ASCONF_a equals ASCONF_b chunk (at least both serials
> need to be equal), we panic an SCTP server!
> 
> The problem is that good-formed ASCONF chunks that we reply with
> ASCONF_ACK chunks are cached per serial. Thus, when we receive a
> same ASCONF chunk twice (e.g. through a lost ASCONF_ACK), we do
> not need to process them again on the server side (that was the
> idea, also proposed in the RFC). Instead, we know it was cached
> and we just resend the cached chunk instead. So far, so good.
> 
> Where things get nasty is in SCTP's side effect interpreter, that
> is, sctp_cmd_interpreter():
> 
> While incoming ASCONF_a (chunk = event_arg) is being marked
> !end_of_packet and !singleton, and we have an association context,
> we do not flush the outqueue the first time after processing the
> ASCONF_ACK singleton chunk via SCTP_CMD_REPLY. Instead, we keep it
> queued up, although we set local_cork to 1. Commit 2e3216cd54b1
> changed the precedence, so that as long as we get bundled, incoming
> chunks we try possible bundling on outgoing queue as well. Before
> this commit, we would just flush the output queue.
> 
> Now, while ASCONF_a's ASCONF_ACK sits in the corked outq, we
> continue to process the same ASCONF_b chunk from the packet. As
> we have cached the previous ASCONF_ACK, we find it, grab it and
> do another SCTP_CMD_REPLY command on it. So, effectively, we rip
> the chunk->list pointers and requeue the same ASCONF_ACK chunk
> another time. Since we process ASCONF_b, it's correctly marked
> with end_of_packet and we enforce an uncork, and thus flush, thus
> crashing the kernel.
> 
> Fix it by testing if the ASCONF_ACK is currently pending and if
> that is the case, do not requeue it. When flushing the output
> queue we may relink the chunk for preparing an outgoing packet,
> but eventually unlink it when it's copied into the skb right
> before transmission.
> 
> Joint work with Vlad Yasevich.
> 
> Fixes: 2e3216cd54b1 ("sctp: Follow security requirement of responding with 1 packet")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> ---
>  include/net/sctp/sctp.h | 5 +++++
>  net/sctp/associola.c    | 2 ++
>  2 files changed, 7 insertions(+)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 9fbd856..856f01c 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -426,6 +426,11 @@ static inline void sctp_assoc_pending_pmtu(struct sock *sk, struct sctp_associat
>  	asoc->pmtu_pending = 0;
>  }
>  
> +static inline bool sctp_chunk_pending(const struct sctp_chunk *chunk)
> +{
> +	return !list_empty(&chunk->list);
> +}
> +
>  /* Walk through a list of TLV parameters.  Don't trust the
>   * individual parameter lengths and instead depend on
>   * the chunk length to indicate when to stop.  Make sure
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index a88b852..f791edd 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1668,6 +1668,8 @@ struct sctp_chunk *sctp_assoc_lookup_asconf_ack(
>  	 * ack chunk whose serial number matches that of the request.
>  	 */
>  	list_for_each_entry(ack, &asoc->asconf_ack_list, transmitted_list) {
> +		if (sctp_chunk_pending(ack))
> +			continue;
>  		if (ack->subh.addip_hdr->serial == serial) {
>  			sctp_chunk_hold(ack);
>  			return ack;
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Is it worth adding a WARN_ON, to indicate that two ASCONF chunks have been
received with duplicate serials?

Neil
