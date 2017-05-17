From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v3 net-next 4/7] net: add new control message for incoming
 HW-timestamped packets
Date: Wed, 17 May 2017 10:11:50 -0400
Message-ID: <CACSApvY=4DrURgQrx7AwFARO2Hbo63xXbq1ayUz_Rq9HuS5qmA@mail.gmail.com>
References: <20170516124425.6294-1-mlichvar@redhat.com> <20170516124425.6294-5-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:35074 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753987AbdEQOMb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 10:12:31 -0400
Received: by mail-it0-f49.google.com with SMTP id c15so81878248ith.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 07:12:31 -0700 (PDT)
In-Reply-To: <20170516124425.6294-5-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 8:44 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> Add SOF_TIMESTAMPING_OPT_PKTINFO option to request a new control message
> for incoming packets with hardware timestamps. It contains the index of
> the real interface which received the packet and the length of the
> packet at layer 2.
>
> The index is useful with bonding, bridges and other interfaces, where
> IP_PKTINFO doesn't allow applications to determine which PHC made the
> timestamp. With the L2 length (and link speed) it is possible to
> transpose preamble timestamps to trailer timestamps, which are used in
> the NTP protocol.
>
> While this information could be provided by two new socket options
> independently from timestamping, it doesn't look like they would be very
> useful. With this option any performance impact is limited to hardware
> timestamping.
>
> Use dev_get_by_napi_id() to get the device and its index. On kernels
> with disabled CONFIG_NET_RX_BUSY_POLL or drivers not using NAPI, a zero
> index will be returned in the control message.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
> ---
>  Documentation/networking/timestamping.txt |  9 +++++++++
>  include/uapi/asm-generic/socket.h         |  2 ++
>  include/uapi/linux/net_tstamp.h           | 10 +++++++++-
>  net/socket.c                              | 27 ++++++++++++++++++++++++++-
>  4 files changed, 46 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
> index 96f5069..600c6bf 100644
> --- a/Documentation/networking/timestamping.txt
> +++ b/Documentation/networking/timestamping.txt
> @@ -193,6 +193,15 @@ SOF_TIMESTAMPING_OPT_STATS:
>    the transmit timestamps, such as how long a certain block of
>    data was limited by peer's receiver window.
>
> +SOF_TIMESTAMPING_OPT_PKTINFO:
> +
> +  Enable the SCM_TIMESTAMPING_PKTINFO control message for incoming
> +  packets with hardware timestamps. The message contains struct
> +  scm_ts_pktinfo, which supplies the index of the real interface which
> +  received the packet and its length at layer 2. A valid (non-zero)
> +  interface index will be returned only if CONFIG_NET_RX_BUSY_POLL is
> +  enabled and the driver is using NAPI.
> +
>  New applications are encouraged to pass SOF_TIMESTAMPING_OPT_ID to
>  disambiguate timestamps and SOF_TIMESTAMPING_OPT_TSONLY to operate
>  regardless of the setting of sysctl net.core.tstamp_allow_data.
> diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
> index 2b48856..a5f6e81 100644
> --- a/include/uapi/asm-generic/socket.h
> +++ b/include/uapi/asm-generic/socket.h
> @@ -100,4 +100,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SCM_TIMESTAMPING_PKTINFO       58
> +
>  #endif /* __ASM_GENERIC_SOCKET_H */
> diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
> index 0749fb1..f2fb455 100644
> --- a/include/uapi/linux/net_tstamp.h
> +++ b/include/uapi/linux/net_tstamp.h
> @@ -9,6 +9,7 @@
>  #ifndef _NET_TIMESTAMPING_H
>  #define _NET_TIMESTAMPING_H
>
> +#include <linux/types.h>
>  #include <linux/socket.h>   /* for SO_TIMESTAMPING */
>
>  /* SO_TIMESTAMPING gets an integer bit field comprised of these values */
> @@ -26,8 +27,9 @@ enum {
>         SOF_TIMESTAMPING_OPT_CMSG = (1<<10),
>         SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
>         SOF_TIMESTAMPING_OPT_STATS = (1<<12),
> +       SOF_TIMESTAMPING_OPT_PKTINFO = (1<<13),
>
> -       SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_STATS,
> +       SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_PKTINFO,
>         SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
>                                  SOF_TIMESTAMPING_LAST
>  };
> @@ -130,4 +132,10 @@ enum hwtstamp_rx_filters {
>         HWTSTAMP_FILTER_NTP_ALL,
>  };
>
> +/* SCM_TIMESTAMPING_PKTINFO control message */
> +struct scm_ts_pktinfo {
> +       __u32 if_index;
> +       __u32 pkt_length;
> +};
> +

Given that this structure can change in the future, it might be worth
considering using TLVs (e.g., netlink attributes), similar to what
tcp_get_timestamping_opt_stats() does. This would simplify
adding/removing fields to/from the control message.

Thanks,
Soheil


>  #endif /* _NET_TIMESTAMPING_H */
> diff --git a/net/socket.c b/net/socket.c
> index c2564eb..ee1f4ec 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -662,6 +662,27 @@ static bool skb_is_err_queue(const struct sk_buff *skb)
>         return skb->pkt_type == PACKET_OUTGOING;
>  }
>
> +static void put_ts_pktinfo(struct msghdr *msg, struct sk_buff *skb)
> +{
> +       struct scm_ts_pktinfo ts_pktinfo;
> +       struct net_device *orig_dev;
> +       int ifindex = 0;
> +
> +       if (!skb_mac_header_was_set(skb))
> +               return;
> +
> +       rcu_read_lock();
> +       orig_dev = dev_get_by_napi_id(skb_napi_id(skb));
> +       if (orig_dev)
> +               ifindex = orig_dev->ifindex;
> +       rcu_read_unlock();
> +
> +       ts_pktinfo.if_index = ifindex;
> +       ts_pktinfo.pkt_length = skb->len - skb_mac_offset(skb);
> +       put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_PKTINFO,
> +                sizeof(ts_pktinfo), &ts_pktinfo);
> +}
> +
>  /*
>   * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
>   */
> @@ -699,8 +720,12 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>                 empty = 0;
>         if (shhwtstamps &&
>             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
> -           ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
> +           ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
>                 empty = 0;
> +               if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_PKTINFO) &&
> +                   !skb_is_err_queue(skb))
> +                       put_ts_pktinfo(msg, skb);
> +       }
>         if (!empty) {
>                 put_cmsg(msg, SOL_SOCKET,
>                          SCM_TIMESTAMPING, sizeof(tss), &tss);
> --
> 2.9.3
>
