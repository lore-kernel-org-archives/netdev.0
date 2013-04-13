From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Sun, 14 Apr 2013 00:18:48 +0200
Message-ID: <5169D9C8.8010504@redhat.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com> <1365879412-9541-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paul.chavent@onera.fr, richardcochran@gmail.com,
	edumazet@google.com, daniel.borkmann@tik.ee.ethz.ch,
	xemul@parallels.com, ebiederm@xmission.com, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59243 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790Ab3DMWTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 18:19:39 -0400
In-Reply-To: <1365879412-9541-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/13/2013 08:56 PM, Willem de Bruijn wrote:
> When transmit timestamping is enabled at the socket level, have
> writes to a PACKET_TX_RING record a timestamp for the generated
> skbuffs. Tx timestamps are always looped to the application over
> the socket error queue.

Nitpick: if so, then this should go to net-next (subject line).

> The patch also loops software timestamps back into the ring.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>   net/core/skbuff.c      |  2 +-
>   net/packet/af_packet.c | 42 ++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 43 insertions(+), 1 deletion(-)
[...]
> +static void __packet_set_timestamp(struct packet_sock *po, void *frame,
> +				   ktime_t tstamp)
> +{
> +	struct tpacket_hdr *h1;
> +	struct tpacket2_hdr *h2;
> +	struct timespec ts;
> +
> +	if (!tstamp.tv64 || !sock_flag(&po->sk, SOCK_TIMESTAMPING_SOFTWARE))
> +		return;
> +
> +	ts = ktime_to_timespec(tstamp);
> +
> +	switch (po->tp_version) {
> +	case TPACKET_V1:
> +		h1 = frame;
> +		h1->tp_sec = ts.tv_sec;
> +		h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
> +
> +		flush_dcache_page(pgv_to_page(&h1->tp_sec));
> +		flush_dcache_page(pgv_to_page(&h1->tp_usec));

Hmm, not sure, but could we also flush the dcache only once?

> +		break;
> +	case TPACKET_V2:
> +		h2 = frame;
> +		h2->tp_sec = ts.tv_sec;
> +		h2->tp_nsec = ts.tv_nsec;
> +
> +		flush_dcache_page(pgv_to_page(&h2->tp_sec));
> +		flush_dcache_page(pgv_to_page(&h2->tp_nsec));
> +		break;
> +	case TPACKET_V3:
> +	default:
> +		WARN(1, "TPACKET version not supported.\n");
> +		BUG();
> +	}
> +
> +

Nitpick: one space too much.

> +	smp_wmb();
> +}
> +
>   static void *packet_lookup_frame(struct packet_sock *po,
>   		struct packet_ring_buffer *rb,
>   		unsigned int position,
> @@ -1900,6 +1939,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
>   		ph = skb_shinfo(skb)->destructor_arg;
>   		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
>   		atomic_dec(&po->tx_ring.pending);
> +		__packet_set_timestamp(po, ph, skb->tstamp);
>   		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
>   	}
>
> @@ -2119,6 +2159,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>   			}
>   		}
>
> +		sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
> +

Hmm, so in case nobody wants to use timestamping on TX (which might be the majority
of people), we have to go through those 3 additional if statements in sock_tx_timestamp()
each time? Shouldn't we rather make the TX_RING faster? ;-)

>   		skb->destructor = tpacket_destruct_skb;
>   		__packet_set_status(po, ph, TP_STATUS_SENDING);
>   		atomic_inc(&po->tx_ring.pending);
>
