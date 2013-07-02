From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3] l2tp: do data sequence number handling in a separate
 func
Date: Tue, 02 Jul 2013 20:28:49 +0400
Message-ID: <51D2FFC1.70009@cogentembedded.com>
References: <1372759229-15178-1-git-send-email-jchapman@katalix.com> <1372759229-15178-2-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:39937 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267Ab3GBQ2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 12:28:55 -0400
Received: by mail-la0-f48.google.com with SMTP id lx15so5810692lab.35
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 09:28:53 -0700 (PDT)
In-Reply-To: <1372759229-15178-2-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02-07-2013 14:00, James Chapman wrote:

> This change moves some code handling data sequence numbers into a
> separate function to avoid too much indentation. This is to prepare
> for some changes to data sequence number handling in subsequent
> patches.

> Signed-off-by: James Chapman <jchapman@katalix.com>
> ---
>   net/l2tp/l2tp_core.c |   55 +++++++++++++++++++++++++++++++------------------
>   1 files changed, 35 insertions(+), 20 deletions(-)

> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 6984c3a..b2389fe 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -542,6 +542,39 @@ static inline int l2tp_verify_udp_checksum(struct sock *sk,
>   	return __skb_checksum_complete(skb);
>   }
>
> +/* If packet has sequence numbers, queue it if acceptable. Returns 0 if
> + * acceptable, else non-zero.
> + */
> +static int l2tp_recv_data_seq(struct l2tp_session *session, struct sk_buff *skb)
> +{
> +	if (session->reorder_timeout != 0) {
> +		/* Packet reordering enabled. Add skb to session's
> +		 * reorder queue, in order of ns.
> +		 */
> +		l2tp_recv_queue_skb(session, skb);
> +	} else {
> +		/* Packet reordering disabled. Discard out-of-sequence
> +		 * packets
> +		 */
> +		if (L2TP_SKB_CB(skb)->ns != session->nr) {
> +			atomic_long_inc(&session->stats.rx_seq_discards);
> +			l2tp_dbg(session, L2TP_MSG_SEQ,
> +				 "%s: oos pkt %u len %d discarded, "
> +				 "waiting for %u, reorder_q_len=%d\n",

    You shouldn't break the long message strings -- leave it as it was 
please.

WBR, Sergei
