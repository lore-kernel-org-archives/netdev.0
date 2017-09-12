From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Mon, 11 Sep 2017 20:12:19 -0700
Message-ID: <CALx6S35sM1CDrFuNE+L59Op_wKTRpATLAdRJafihr0mB9+vQ8g@mail.gmail.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:38877 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751022AbdILDMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 23:12:20 -0400
Received: by mail-qk0-f194.google.com with SMTP id c69so6517697qke.5
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 20:12:20 -0700 (PDT)
In-Reply-To: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 4:27 PM, Sridhar Samudrala
<sridhar.samudrala@intel.com> wrote:
> This patch introduces a new socket option SO_SYMMETRIC_QUEUES that can be used
> to enable symmetric tx and rx queues on a socket.
>
> This option is specifically useful for epoll based multi threaded workloads
> where each thread handles packets received on a single RX queue . In this model,
> we have noticed that it helps to send the packets on the same TX queue
> corresponding to the queue-pair associated with the RX queue specifically when
> busy poll is enabled with epoll().
>
> Two new fields are added to struct sock_common to cache the last rx ifindex and
> the rx queue in the receive path of an SKB. __netdev_pick_tx() returns the cached
> rx queue when this option is enabled and the TX is happening on the same device.
>
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---
>  include/net/request_sock.h        |  1 +
>  include/net/sock.h                | 17 +++++++++++++++++
>  include/uapi/asm-generic/socket.h |  2 ++
>  net/core/dev.c                    |  8 +++++++-
>  net/core/sock.c                   | 10 ++++++++++
>  net/ipv4/tcp_input.c              |  1 +
>  net/ipv4/tcp_ipv4.c               |  1 +
>  net/ipv4/tcp_minisocks.c          |  1 +
>  8 files changed, 40 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
> index 23e2205..c3bc12e 100644
> --- a/include/net/request_sock.h
> +++ b/include/net/request_sock.h
> @@ -100,6 +100,7 @@ static inline struct sock *req_to_sk(struct request_sock *req)
>         req_to_sk(req)->sk_prot = sk_listener->sk_prot;
>         sk_node_init(&req_to_sk(req)->sk_node);
>         sk_tx_queue_clear(req_to_sk(req));
> +       req_to_sk(req)->sk_symmetric_queues = sk_listener->sk_symmetric_queues;
>         req->saved_syn = NULL;
>         refcount_set(&req->rsk_refcnt, 0);
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 03a3625..3421809 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -138,11 +138,14 @@ void SOCK_DEBUG(const struct sock *sk, const char *msg, ...)
>   *     @skc_node: main hash linkage for various protocol lookup tables
>   *     @skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
>   *     @skc_tx_queue_mapping: tx queue number for this connection
> + *     @skc_rx_queue_mapping: rx queue number for this connection
> + *     @skc_rx_ifindex: rx ifindex for this connection
>   *     @skc_flags: place holder for sk_flags
>   *             %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
>   *             %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
>   *     @skc_incoming_cpu: record/match cpu processing incoming packets
>   *     @skc_refcnt: reference count
> + *     @skc_symmetric_queues: symmetric tx/rx queues
>   *
>   *     This is the minimal network layer representation of sockets, the header
>   *     for struct sock and struct inet_timewait_sock.
> @@ -177,6 +180,7 @@ struct sock_common {
>         unsigned char           skc_reuseport:1;
>         unsigned char           skc_ipv6only:1;
>         unsigned char           skc_net_refcnt:1;
> +       unsigned char           skc_symmetric_queues:1;
>         int                     skc_bound_dev_if;
>         union {
>                 struct hlist_node       skc_bind_node;
> @@ -214,6 +218,8 @@ struct sock_common {
>                 struct hlist_nulls_node skc_nulls_node;
>         };
>         int                     skc_tx_queue_mapping;
> +       int                     skc_rx_queue_mapping;
> +       int                     skc_rx_ifindex;

Two ints in sock_common for this purpose is quite expensive and the
use case for this is limited-- even if a RX->TX queue mapping were
introduced to eliminate the queue pair assumption this still won't
help if the receive and transmit interfaces are different for the
connection. I think we really need to see some very compelling results
to be able to justify this.

Thanks,
Tom
