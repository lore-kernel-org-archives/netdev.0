From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [RFC PATCH net-next] tcp: add NV congestion control
Date: Fri, 3 Jul 2015 16:30:01 -0400
Message-ID: <CADVnQykDpuO991cv43=1=A4mBJJD5pbE6paF3okXnZzeTOUs9g@mail.gmail.com>
References: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
	<CALx6S35pRq_Z32R3xWTj4PpQJ4YkC-MzxzeYb8+vH=cfTibwcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Yuchung Cheng <ycheng@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:32808 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755447AbbGCUaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 16:30:03 -0400
Received: by obpn3 with SMTP id n3so74795581obp.0
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 13:30:01 -0700 (PDT)
In-Reply-To: <CALx6S35pRq_Z32R3xWTj4PpQJ4YkC-MzxzeYb8+vH=cfTibwcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 48c3696..05e0da5 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -254,6 +254,10 @@ struct tcp_sock {
>         u32     lost_out;       /* Lost packets                 */
>         u32     sacked_out;     /* SACK'd packets                       */
>         u32     fackets_out;    /* FACK'd packets                       */
> +       u32     ack_in_flight;  /* This field is populated when new acks
> +                                * are received. It contains the number of
> +                                * bytes in flight when the last packet
> +                                * acked was sent. Used by tcp-nv. */

AFAICT the tcp_sock struct does not really need to grow to hold the
ack_in_flight field, because this field does not need to be remembered
between ACKs. I would recommend putting it in a small struct ("struct
ack_sample"?) that is allocated on the stack in tcp_ack() and passed
into the pkts_acked() function for congestion control modules that
want extra info beyond the number of packets ACKed and the RTT.

In fact it might be cleaner to put the number of packets ACKed and the
RTT in that struct as well, so in the future we don't have to modify
all the congestion control modules' pkts_acked() function
every time a new piece of info is provided by the core TCP stack.

>  /* This is what the send packet queuing engine uses to pass
>   * TCP per-packet control information to the transmission code.
>   * We also store the host-order sequence numbers in here too.
> - * This is 44 bytes if IPV6 is enabled.
> + * This is 48 bytes if IPV6 is enabled.
>   * If this grows please adjust skbuff.h:skbuff->cb[xxx] size appropriately.
>   */
>  struct tcp_skb_cb {
>         __u32           seq;            /* Starting sequence number     */
>         __u32           end_seq;        /* SEQ + FIN + SYN + datalen    */
> +       __u32           in_flight;      /* bytes in flight when this packet
> +                                        * was sent. */

AFAICT this patch would not require an increase in the size of sk_buff
cb[] if it were to take advantage of the fact that the tcp_skb_cb
header.h4 and header.h6 fields are only used in the packet reception
code path, and this in_flight field is only used on the transmit
side. So the in_flight field could be placed in a struct that is
itself placed in a union with the "header" union. Like this:

        union {
                struct {
                        /* bytes in flight when this packet was sent */
                        __u32 in_flight;
                } tx;   /* only used for outgoing skbs */

                union {
                        struct inet_skb_parm    h4;
#if IS_ENABLED(CONFIG_IPV6)
                        struct inet6_skb_parm   h6;
#endif
                } header;  /* only used for incoming skbs */
        };

That way the sender code can remember the in_flight value
without requiring any extra space. And in the future other
sender-side info could be stored in the "tx" struct, if needed.

neal
