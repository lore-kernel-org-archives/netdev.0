From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 2/5] packet: enable hardware tx timestamping on
 tpacket ring
Date: Tue, 23 Apr 2013 08:13:30 -0400
Message-ID: <CA+FuTSdUNu9suZz24GSzaeu70ioEhcCdXfDMc-z+_B0+_KgBqQ@mail.gmail.com>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com> <1366713572-11978-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Chavent <Paul.Chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:36029 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755730Ab3DWMOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 08:14:02 -0400
Received: by mail-ie0-f171.google.com with SMTP id e11so567404iej.30
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 05:14:01 -0700 (PDT)
In-Reply-To: <1366713572-11978-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 6:39 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Currently, we only have software timestamping for the TX ring buffer
> path, but this limitation stems rather from the implementation. By
> just reusing tpacket_get_timestamp(), we can also allow hardware
> timestamping just as in the RX path.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/packet/af_packet.c | 50 +++++++++++++++++++++++++-------------------------
>  1 file changed, 25 insertions(+), 25 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 1f792ab..e7892a4 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -339,14 +339,33 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
>         }
>  }
>
> +static bool tpacket_get_timestamp(struct sk_buff *skb, struct timespec *ts,
> +                                 unsigned int flags)
> +{
> +       struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> +
> +       if (shhwtstamps) {
> +               if ((flags & SOF_TIMESTAMPING_SYS_HARDWARE) &&
> +                   ktime_to_timespec_cond(shhwtstamps->syststamp, ts))
> +                       return true;
> +               if ((flags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
> +                   ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts))
> +                       return true;
> +       }
> +
> +       if (ktime_to_timespec_cond(skb->tstamp, ts))
> +               return true;
> +
> +       return false;
> +}
> +
>  static void __packet_set_timestamp(struct packet_sock *po, void *frame,
> -                                  ktime_t tstamp)
> +                                  struct sk_buff *skb)
>  {
>         union tpacket_uhdr h;
>         struct timespec ts;
>
> -       if (!ktime_to_timespec_cond(tstamp, &ts) ||
> -           !sock_flag(&po->sk, SOCK_TIMESTAMPING_SOFTWARE))
> +       if (!tpacket_get_timestamp(skb, &ts, po->tp_tstamp))
>                 return;
>
>         h.raw = frame;
> @@ -1688,26 +1707,6 @@ drop:
>         return 0;
>  }
>
> -static void tpacket_get_timestamp(struct sk_buff *skb, struct timespec *ts,
> -                                 unsigned int flags)
> -{
> -       struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> -
> -       if (shhwtstamps) {
> -               if ((flags & SOF_TIMESTAMPING_SYS_HARDWARE) &&
> -                   ktime_to_timespec_cond(shhwtstamps->syststamp, ts))
> -                       return;
> -               if ((flags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
> -                   ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts))
> -                       return;
> -       }
> -
> -       if (ktime_to_timespec_cond(skb->tstamp, ts))
> -               return;
> -
> -       getnstimeofday(ts);
> -}
> -
>  static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>                        struct packet_type *pt, struct net_device *orig_dev)
>  {
> @@ -1804,7 +1803,8 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>         spin_unlock(&sk->sk_receive_queue.lock);
>
>         skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
> -       tpacket_get_timestamp(skb, &ts, po->tp_tstamp);
> +       if (!tpacket_get_timestamp(skb, &ts, po->tp_tstamp))
> +               getnstimeofday(&ts);
>
>         switch (po->tp_version) {
>         case TPACKET_V1:
> @@ -1908,7 +1908,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
>                 ph = skb_shinfo(skb)->destructor_arg;
>                 BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
>                 atomic_dec(&po->tx_ring.pending);
> -               __packet_set_timestamp(po, ph, skb->tstamp);
> +               __packet_set_timestamp(po, ph, skb);
>                 __packet_set_status(po, ph, TP_STATUS_AVAILABLE);
>         }
>
> --
> 1.7.11.7
>
