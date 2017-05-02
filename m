From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next 4/7] net: add new control message for incoming
 HW-timestamped packets
Date: Tue, 2 May 2017 12:01:26 -0400
Message-ID: <CAF=yD-+QZ+wn2fWkH_YS-zWQNhx7U8uDhBoDiBFQiDT+PTywow@mail.gmail.com>
References: <20170502101103.30444-1-mlichvar@redhat.com> <20170502101103.30444-5-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36281 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751118AbdEBQCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 12:02:08 -0400
Received: by mail-io0-f193.google.com with SMTP id x86so31220558ioe.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 09:02:07 -0700 (PDT)
In-Reply-To: <20170502101103.30444-5-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 2, 2017 at 6:11 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
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
> independently from timestamping, it doesn't look like it would be very
> useful. With this option any performance impact is limited to hardware
> timestamping.
>
> Use dev_get_by_napi_id() to look up the device and its index. This
> limits the option to kernels with enabled CONFIG_NET_RX_BUSY_POLL and
> drivers using napi, but it should cover all current MAC drivers that
> support hardware timestamping.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
> ---
>  Documentation/networking/timestamping.txt |  8 ++++++++
>  include/uapi/asm-generic/socket.h         |  2 ++
>  include/uapi/linux/net_tstamp.h           |  9 ++++++++-
>  net/socket.c                              | 30 +++++++++++++++++++++++++++++-
>  4 files changed, 47 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
> index 96f5069..6c07e7c 100644
> --- a/Documentation/networking/timestamping.txt
> +++ b/Documentation/networking/timestamping.txt
> @@ -193,6 +193,14 @@ SOF_TIMESTAMPING_OPT_STATS:
>    the transmit timestamps, such as how long a certain block of
>    data was limited by peer's receiver window.
>
> +SOF_TIMESTAMPING_OPT_PKTINFO:
> +
> +  Enable the SCM_TIMESTAMPING_PKTINFO control message for incoming
> +  packets with hardware timestamps. The message contains struct
> +  scm_ts_pktinfo, which supplies the index of the real interface
> +  which received the packet and its length at layer 2. This option
> +  works only if CONFIG_NET_RX_BUSY_POLL is enabled.
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
> index 0749fb1..8fcae35 100644
> --- a/include/uapi/linux/net_tstamp.h
> +++ b/include/uapi/linux/net_tstamp.h
> @@ -26,8 +26,9 @@ enum {
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
> @@ -130,4 +131,10 @@ enum hwtstamp_rx_filters {
>         HWTSTAMP_FILTER_NTP_ALL,
>  };
>
> +/* SCM_TIMESTAMPING_PKTINFO control message */
> +struct scm_ts_pktinfo {
> +       int if_index;
> +       int pkt_length;
> +};

Use fixed width integer types across the ABI.

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
> +       if (ifindex == 0)
> +               return;

If the caller requests PKTINFO, it might be better to explicitly return
a structure with illegal value 0, than to silently skip the message if
no device can be found.
