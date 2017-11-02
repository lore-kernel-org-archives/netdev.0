From: Christoph Paasch <cpaasch@apple.com>
Subject: Re: [PATCH net] tcp: Always cleanup skb before sending
Date: Wed, 01 Nov 2017 17:10:35 -0700
Message-ID: <20171102001035.GR44287@da0602a-dhcp105.apple.com>
References: <20171101211001.57901-1-cpaasch@apple.com>
 <CANn89iLv+0+A79-pNu8HZ2kBbyNt2ini2Zjbm++s9TT7mtOamw@mail.gmail.com>
 <1509573218.3828.54.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out7.apple.com ([17.151.62.29]:51585 "EHLO
        mail-in7.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932433AbdKBAKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 20:10:36 -0400
Content-disposition: inline
In-reply-to: <1509573218.3828.54.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/17 - 14:53:38, Eric Dumazet wrote:
> On Wed, 2017-11-01 at 14:32 -0700, Eric Dumazet wrote:
> > On Wed, Nov 1, 2017 at 2:10 PM, Christoph Paasch <cpaasch@apple.com> wrote:
> > > Since commit 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache
> > > line misses") IPCB/IP6CB is no more at the beginning of the tcp_skb_cb.
> > > This means that on the output path, we need to make sure that it has
> > > been correctly initialized to 0, as is done in tcp_transmit_skb.
> > >
> > > However, when going through the other code-path in TCP that can send an
> > > skb (e.g., through tcp_v6_send_synack), we end up in a situation where
> > > IP6CB has some of its fields set to unexpected values. Depending on the
> > > layout of tcp_skb_cb across the different kernel-versions this can be
> > > lastopt, flags,...
> > 
> > Or not use tcp_init_nondata_skb() on non fast clones, since it adds
> > unnecessary writes and clears.
> > 
> > tcp_make_synack() really has no business using tcp_init_nondata_skb()
> > and could simply set th->seq = htonl(tcp_rsk(req)->snt_isn);
> 
> Something like :
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 69cfdead0cb49e4365158048a0d1a9bbdd55fa83..5502abc5307f0ce1de610d4b70f3a59c4d5383c5 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -3399,13 +3399,8 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
>         tcp_ecn_make_synack(req, th);
>         th->source = htons(ireq->ir_num);
>         th->dest = ireq->ir_rmt_port;
> -       /* Setting of flags are superfluous here for callers (and ECE is
> -        * not even correctly set)
> -        */
> -       tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
> -                            TCPHDR_SYN | TCPHDR_ACK);
> -
> -       th->seq = htonl(TCP_SKB_CB(skb)->seq);
> +       skb->ip_summed = CHECKSUM_PARTIAL;
> +       th->seq = htonl(tcp_rsk(req)->snt_isn);
>         /* XXX data is queued and acked as is. No buffer/window check */
>         th->ack_seq = htonl(tcp_rsk(req)->rcv_nxt);

Yes, that looks good to me. Thanks!

But we still need to clean up the skb in tcp_v4_send_reset and
tcp_v4_send_ack, as the fields (e.g., tcp_skb_cb->seq) have been set when
coming from tcp_v4_rcv.


Christoph
