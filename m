From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Sat, 20 Apr 2013 14:33:54 +0200
Message-ID: <51728B32.4040200@redhat.com>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com> <1366408317-16432-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, paul.chavent@onera.fr,
	richardcochran@gmail.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755074Ab3DTMeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 08:34:21 -0400
In-Reply-To: <1366408317-16432-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2013 11:51 PM, Willem de Bruijn wrote:
> v1->v2:
> - move sock_tx_timestamp near other sk reads (warm cacheline)
> - remove duplicate flush_dcache_page
> - enable hardware timestamps reporting using the error queue (not ring)
> - use new ktime_to_timespec_cond API

Nitpick: probably this should rather go below the "---" line, so that this
will not show up in the commit message.

> When transmit timestamping is enabled at the socket level, record a
> timestamp on packets written to a PACKET_TX_RING. Tx timestamps are
> always looped to the application over the socket error queue. Software
> timestamps are also written back into the packet frame header in the
> packet ring.
>
> Reported-by: Paul Chavent <paul.chavent@onera.fr>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>   net/core/skbuff.c      | 12 ++++++------
>   net/packet/af_packet.c | 33 +++++++++++++++++++++++++++++++++
>   2 files changed, 39 insertions(+), 6 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 898cf5c..af9185d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3327,12 +3327,8 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>   	if (!sk)
>   		return;
>
> -	skb = skb_clone(orig_skb, GFP_ATOMIC);
> -	if (!skb)
> -		return;
> -
>   	if (hwtstamps) {
> -		*skb_hwtstamps(skb) =
> +		*skb_hwtstamps(orig_skb) =
>   			*hwtstamps;
>   	} else {
>   		/*
> @@ -3340,9 +3336,13 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>   		 * so keep the shared tx_flags and only
>   		 * store software time stamp
>   		 */
> -		skb->tstamp = ktime_get_real();
> +		orig_skb->tstamp = ktime_get_real();
>   	}
>
> +	skb = skb_clone(orig_skb, GFP_ATOMIC);
> +	if (!skb)
> +		return;
> +
>   	serr = SKB_EXT_ERR(skb);
>   	memset(serr, 0, sizeof(*serr));
>   	serr->ee.ee_errno = ENOMSG;
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 7e387ff..ec8ea27 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -339,6 +339,37 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
>   	}
>   }
>
> +static void __packet_set_timestamp(struct packet_sock *po, void *frame,
> +				   ktime_t tstamp)
> +{
> +	union tpacket_uhdr h;
> +	struct timespec ts;
> +
> +	if (!ktime_to_timespec_cond(tstamp, &ts) ||
> +	    !sock_flag(&po->sk, SOCK_TIMESTAMPING_SOFTWARE))
> +		return;

If we currently have the po->tp_tstamp member that was introduced for the RX_RING
part only, using it if possible for the TX_RING part as well would be good, at
least cleaner. Also the documentation [1] should receive a status update on this
feature, otherwise only Paul will use this feature and nobody else.

Not an expert in timestamping, but why can't we also allow hw timestamps but have
to use sw only? Would it be possible to reuse the tpacket_get_timestamp() function
that got recently introduced for this (while keeping sock_tx_timestamp() below on
TX path)?

Thanks.

  [1] Documentation/networking/packet_mmap.txt

> +	h.raw = frame;
> +	switch (po->tp_version) {
> +	case TPACKET_V1:
> +		h.h1->tp_sec = ts.tv_sec;
> +		h.h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
> +		break;
> +	case TPACKET_V2:
> +		h.h2->tp_sec = ts.tv_sec;
> +		h.h2->tp_nsec = ts.tv_nsec;
> +		break;
> +	case TPACKET_V3:
> +	default:
> +		WARN(1, "TPACKET version not supported.\n");
> +		BUG();
> +	}
> +
> +	/* one flush is safe, as both fields always lie on the same cacheline */
> +	flush_dcache_page(pgv_to_page(&h.h1->tp_sec));
> +	smp_wmb();
> +}
> +
>   static void *packet_lookup_frame(struct packet_sock *po,
>   		struct packet_ring_buffer *rb,
>   		unsigned int position,
> @@ -1877,6 +1908,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
>   		ph = skb_shinfo(skb)->destructor_arg;
>   		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
>   		atomic_dec(&po->tx_ring.pending);
> +		__packet_set_timestamp(po, ph, skb->tstamp);
>   		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
>   	}
>
> @@ -1900,6 +1932,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>   	skb->dev = dev;
>   	skb->priority = po->sk.sk_priority;
>   	skb->mark = po->sk.sk_mark;
> +	sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
>   	skb_shinfo(skb)->destructor_arg = ph.raw;
>
>   	switch (po->tp_version) {
>
