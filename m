From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v1 net-next 3/6] net: add new control message for incoming
 HW-timestamped packets
Date: Wed, 26 Apr 2017 19:34:49 -0400
Message-ID: <CAF=yD-+XKGnGASVN4+W2u2A7CBqS9CRN2Jkvx6UoPQQ6jLpMkQ@mail.gmail.com>
References: <20170426145035.25846-1-mlichvar@redhat.com> <20170426145035.25846-4-mlichvar@redhat.com>
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
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34200 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032745AbdDZXfb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:35:31 -0400
Received: by mail-oi0-f65.google.com with SMTP id y11so3857223oie.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:35:30 -0700 (PDT)
In-Reply-To: <20170426145035.25846-4-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 1b3317c..0a78f7f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -160,6 +160,7 @@ static int netif_rx_internal(struct sk_buff *skb);
>  static int call_netdevice_notifiers_info(unsigned long val,
>                                          struct net_device *dev,
>                                          struct netdev_notifier_info *info);
> +static struct napi_struct *napi_by_id(unsigned int napi_id);
>
>  /*
>   * The @dev_base_head list is protected by @dev_base_lock and the rtnl
> @@ -863,6 +864,23 @@ struct net_device *dev_get_by_index(struct net *net, int ifindex)
>  }
>  EXPORT_SYMBOL(dev_get_by_index);
>
> +struct net_device *dev_get_by_napi_id(unsigned int napi_id)
> +{
> +       struct net_device *dev = NULL;
> +       struct napi_struct *napi;
> +
> +       rcu_read_lock();
> +
> +       napi = napi_by_id(napi_id);
> +       if (napi)
> +               dev = napi->dev;
> +
> +       rcu_read_unlock();
> +
> +       return dev;
> +}
> +EXPORT_SYMBOL(dev_get_by_napi_id);

Returning dev without holding a reference is not safe. You'll probably
have to call this with rcu_read_lock held instead.

Also, this generic napi function should probably be in a separate patch.

> diff --git a/net/socket.c b/net/socket.c
> index c2564eb..5ea5f29 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -662,6 +662,26 @@ static bool skb_is_err_queue(const struct sk_buff *skb)
>         return skb->pkt_type == PACKET_OUTGOING;
>  }
>
> +static void put_ts_pktinfo(struct msghdr *msg, struct sk_buff *skb)
> +{
> +#ifdef CONFIG_NET_RX_BUSY_POLL

Let's limit the ifdef scope to napi code. Perhaps we need an skb_get_napi_id
helper that returns 0 if the feature is not compiled in.

> +       struct scm_ts_pktinfo ts_pktinfo;
> +       struct net_device *orig_dev;
> +
> +       if (skb->napi_id < MIN_NAPI_ID || !skb_mac_header_was_set(skb))
> +               return;

This MIN_NAPI_ID check can be moved into dev_get_by_napi_id.

>  /*
>   * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
>   */
> @@ -699,8 +719,12 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>                 empty = 0;
>         if (shhwtstamps &&
>             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&

This information is also informative with software timestamps.

And getting the real iif is definitely useful outside timestamps. An
alternative approach is to add versioning to IP_PKTINFO with a new
setsockopt IP_PKTINFO_VERSION plus a new struct in_pktinfo_v2
that extends in_pktinfo. Just a thought.
