From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] packet: move hw/sw timestamp extraction into a
 small helper
Date: Mon, 15 Apr 2013 12:12:31 -0400
Message-ID: <CA+FuTSeuUVPuf1paZgXQRr6W5YRJaPfWN57BsHtc2tG8qoS4iQ@mail.gmail.com>
References: <cover.1366022623.git.dborkman@redhat.com> <45719bcd37c3f11eea24c2a72c09abd9907a5072.1366022623.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:63204 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115Ab3DOQNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 12:13:06 -0400
Received: by mail-ie0-f175.google.com with SMTP id c12so6064051ieb.34
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:13:01 -0700 (PDT)
In-Reply-To: <45719bcd37c3f11eea24c2a72c09abd9907a5072.1366022623.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 7:41 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> This patch introduces a small helper function, that is used by AF_PACKET.
> Based on the flags that are passed, it extracts the packet timestamp in
> the receive path. This is merely a refactoring to remove some duplicate
> code in tpacket_rcv(), make it more readable, and to enable others to use
> this function as well.

Good idea. I noticed that while browsing the code over the weekend, too.

One question I have is whether the code warrants adding a static
inline to skbuff.h. Regular socket paths do not use the test, as they
return all timestamps together.

> Cc: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/linux/skbuff.h | 20 ++++++++++++++++++++
>  net/packet/af_packet.c | 38 ++++----------------------------------
>  2 files changed, 24 insertions(+), 34 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index e27d1c7..d0d436f 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -33,6 +33,7 @@
>  #include <linux/dma-mapping.h>
>  #include <linux/netdev_features.h>
>  #include <net/flow_keys.h>
> +#include <linux/net_tstamp.h>
>
>  /* Don't change this without changing skb_csum_unnecessary! */
>  #define CHECKSUM_NONE 0
> @@ -739,6 +740,25 @@ static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
>         return &skb_shinfo(skb)->hwtstamps;
>  }
>
> +static inline struct timespec skb_get_tstamp(struct sk_buff *skb,
> +                                            unsigned int flags)
> +{
> +       struct skb_shared_hwtstamps *ts = skb_hwtstamps(skb);
> +
> +       if ((flags & SOF_TIMESTAMPING_SYS_HARDWARE) && ts->syststamp.tv64)

Also, packet sockets use the flags these SOF_... constants passed from
userspace directly, but regular socket paths convert this into socket
flags SOCK_..., so this code is more packet socket specific than it
seems. See __sock_recv_timestamp. I'd keep the function in
net/packet/af_packet.c solely for this reason, or add a comment.

> +               return ktime_to_timespec(ts->syststamp);
> +       else if ((flags & SOF_TIMESTAMPING_RAW_HARDWARE) && ts->hwtstamp.tv64)
> +               return ktime_to_timespec(ts->hwtstamp);
> +       else if (skb->tstamp.tv64)
> +               return ktime_to_timespec(skb->tstamp);
> +       else {
> +               struct timespec tc;
> +
> +               getnstimeofday(&tc);
> +               return tc;
> +       }
> +}
> +
>  /**
>   *     skb_queue_empty - check if a queue is empty
>   *     @list: queue head
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 77d71f8..2a2a62e 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1681,9 +1681,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>         unsigned long status = TP_STATUS_USER;
>         unsigned short macoff, netoff, hdrlen;
>         struct sk_buff *copy_skb = NULL;
> -       struct timeval tv;
>         struct timespec ts;
> -       struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
>
>         if (skb->pkt_type == PACKET_LOOPBACK)
>                 goto drop;
> @@ -1767,24 +1765,16 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>
>         skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
>
> +       ts = skb_get_tstamp(skb, po->tp_tstamp);
> +
>         switch (po->tp_version) {
>         case TPACKET_V1:
>                 h.h1->tp_len = skb->len;
>                 h.h1->tp_snaplen = snaplen;
>                 h.h1->tp_mac = macoff;
>                 h.h1->tp_net = netoff;
> -               if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
> -                               && shhwtstamps->syststamp.tv64)
> -                       tv = ktime_to_timeval(shhwtstamps->syststamp);
> -               else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
> -                               && shhwtstamps->hwtstamp.tv64)
> -                       tv = ktime_to_timeval(shhwtstamps->hwtstamp);
> -               else if (skb->tstamp.tv64)
> -                       tv = ktime_to_timeval(skb->tstamp);
> -               else
> -                       do_gettimeofday(&tv);
> -               h.h1->tp_sec = tv.tv_sec;
> -               h.h1->tp_usec = tv.tv_usec;
> +               h.h1->tp_sec = ts.tv_sec;
> +               h.h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
>                 hdrlen = sizeof(*h.h1);
>                 break;
>         case TPACKET_V2:
> @@ -1792,16 +1782,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>                 h.h2->tp_snaplen = snaplen;
>                 h.h2->tp_mac = macoff;
>                 h.h2->tp_net = netoff;
> -               if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
> -                               && shhwtstamps->syststamp.tv64)
> -                       ts = ktime_to_timespec(shhwtstamps->syststamp);
> -               else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
> -                               && shhwtstamps->hwtstamp.tv64)
> -                       ts = ktime_to_timespec(shhwtstamps->hwtstamp);
> -               else if (skb->tstamp.tv64)
> -                       ts = ktime_to_timespec(skb->tstamp);
> -               else
> -                       getnstimeofday(&ts);
>                 h.h2->tp_sec = ts.tv_sec;
>                 h.h2->tp_nsec = ts.tv_nsec;
>                 if (vlan_tx_tag_present(skb)) {
> @@ -1822,16 +1802,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>                 h.h3->tp_snaplen = snaplen;
>                 h.h3->tp_mac = macoff;
>                 h.h3->tp_net = netoff;
> -               if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
> -                               && shhwtstamps->syststamp.tv64)
> -                       ts = ktime_to_timespec(shhwtstamps->syststamp);
> -               else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
> -                               && shhwtstamps->hwtstamp.tv64)
> -                       ts = ktime_to_timespec(shhwtstamps->hwtstamp);
> -               else if (skb->tstamp.tv64)
> -                       ts = ktime_to_timespec(skb->tstamp);
> -               else
> -                       getnstimeofday(&ts);
>                 h.h3->tp_sec  = ts.tv_sec;
>                 h.h3->tp_nsec = ts.tv_nsec;
>                 hdrlen = sizeof(*h.h3);
> --
> 1.7.11.7
>
