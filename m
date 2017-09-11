From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Mon, 11 Sep 2017 09:48:35 -0700
Message-ID: <91a48bc5-57d9-db09-78c0-98a49b414a28@intel.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
 <CAKgT0UfZed3_3KBmKbMbcmdsA+ctFRUCu8jp_rCnatC9AMv__g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45964 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752025AbdIKQs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 12:48:59 -0400
In-Reply-To: <CAKgT0UfZed3_3KBmKbMbcmdsA+ctFRUCu8jp_rCnatC9AMv__g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/9/2017 6:28 PM, Alexander Duyck wrote:
> On Thu, Aug 31, 2017 at 4:27 PM, Sridhar Samudrala
> <sridhar.samudrala@intel.com> wrote:
>> This patch introduces a new socket option SO_SYMMETRIC_QUEUES that can be used
>> to enable symmetric tx and rx queues on a socket.
>>
>> This option is specifically useful for epoll based multi threaded workloads
>> where each thread handles packets received on a single RX queue . In this model,
>> we have noticed that it helps to send the packets on the same TX queue
>> corresponding to the queue-pair associated with the RX queue specifically when
>> busy poll is enabled with epoll().
>>
>> Two new fields are added to struct sock_common to cache the last rx ifindex and
>> the rx queue in the receive path of an SKB. __netdev_pick_tx() returns the cached
>> rx queue when this option is enabled and the TX is happening on the same device.
>>
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> ---
>>   include/net/request_sock.h        |  1 +
>>   include/net/sock.h                | 17 +++++++++++++++++
>>   include/uapi/asm-generic/socket.h |  2 ++
>>   net/core/dev.c                    |  8 +++++++-
>>   net/core/sock.c                   | 10 ++++++++++
>>   net/ipv4/tcp_input.c              |  1 +
>>   net/ipv4/tcp_ipv4.c               |  1 +
>>   net/ipv4/tcp_minisocks.c          |  1 +
>>   8 files changed, 40 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
>> index 23e2205..c3bc12e 100644
>> --- a/include/net/request_sock.h
>> +++ b/include/net/request_sock.h
>> @@ -100,6 +100,7 @@ static inline struct sock *req_to_sk(struct request_sock *req)
>>          req_to_sk(req)->sk_prot = sk_listener->sk_prot;
>>          sk_node_init(&req_to_sk(req)->sk_node);
>>          sk_tx_queue_clear(req_to_sk(req));
>> +       req_to_sk(req)->sk_symmetric_queues = sk_listener->sk_symmetric_queues;
>>          req->saved_syn = NULL;
>>          refcount_set(&req->rsk_refcnt, 0);
>>
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 03a3625..3421809 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -138,11 +138,14 @@ void SOCK_DEBUG(const struct sock *sk, const char *msg, ...)
>>    *     @skc_node: main hash linkage for various protocol lookup tables
>>    *     @skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
>>    *     @skc_tx_queue_mapping: tx queue number for this connection
>> + *     @skc_rx_queue_mapping: rx queue number for this connection
>> + *     @skc_rx_ifindex: rx ifindex for this connection
>>    *     @skc_flags: place holder for sk_flags
>>    *             %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
>>    *             %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
>>    *     @skc_incoming_cpu: record/match cpu processing incoming packets
>>    *     @skc_refcnt: reference count
>> + *     @skc_symmetric_queues: symmetric tx/rx queues
>>    *
>>    *     This is the minimal network layer representation of sockets, the header
>>    *     for struct sock and struct inet_timewait_sock.
>> @@ -177,6 +180,7 @@ struct sock_common {
>>          unsigned char           skc_reuseport:1;
>>          unsigned char           skc_ipv6only:1;
>>          unsigned char           skc_net_refcnt:1;
>> +       unsigned char           skc_symmetric_queues:1;
>>          int                     skc_bound_dev_if;
>>          union {
>>                  struct hlist_node       skc_bind_node;
>> @@ -214,6 +218,8 @@ struct sock_common {
>>                  struct hlist_nulls_node skc_nulls_node;
>>          };
>>          int                     skc_tx_queue_mapping;
>> +       int                     skc_rx_queue_mapping;
>> +       int                     skc_rx_ifindex;
>>          union {
>>                  int             skc_incoming_cpu;
>>                  u32             skc_rcv_wnd;
>> @@ -324,6 +330,8 @@ struct sock {
>>   #define sk_nulls_node          __sk_common.skc_nulls_node
>>   #define sk_refcnt              __sk_common.skc_refcnt
>>   #define sk_tx_queue_mapping    __sk_common.skc_tx_queue_mapping
>> +#define sk_rx_queue_mapping    __sk_common.skc_rx_queue_mapping
>> +#define sk_rx_ifindex          __sk_common.skc_rx_ifindex
>>
>>   #define sk_dontcopy_begin      __sk_common.skc_dontcopy_begin
>>   #define sk_dontcopy_end                __sk_common.skc_dontcopy_end
>> @@ -340,6 +348,7 @@ struct sock {
>>   #define sk_reuseport           __sk_common.skc_reuseport
>>   #define sk_ipv6only            __sk_common.skc_ipv6only
>>   #define sk_net_refcnt          __sk_common.skc_net_refcnt
>> +#define sk_symmetric_queues    __sk_common.skc_symmetric_queues
>>   #define sk_bound_dev_if                __sk_common.skc_bound_dev_if
>>   #define sk_bind_node           __sk_common.skc_bind_node
>>   #define sk_prot                        __sk_common.skc_prot
>> @@ -1676,6 +1685,14 @@ static inline int sk_tx_queue_get(const struct sock *sk)
>>          return sk ? sk->sk_tx_queue_mapping : -1;
>>   }
>>
>> +static inline void sk_mark_rx_queue(struct sock *sk, struct sk_buff *skb)
>> +{
>> +       if (sk->sk_symmetric_queues) {
>> +               sk->sk_rx_ifindex = skb->skb_iif;
>> +               sk->sk_rx_queue_mapping = skb_get_rx_queue(skb);
>> +       }
>> +}
>> +
>>   static inline void sk_set_socket(struct sock *sk, struct socket *sock)
>>   {
>>          sk_tx_queue_clear(sk);
>> diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
>> index e47c9e4..f6b416e 100644
>> --- a/include/uapi/asm-generic/socket.h
>> +++ b/include/uapi/asm-generic/socket.h
>> @@ -106,4 +106,6 @@
>>
>>   #define SO_ZEROCOPY            60
>>
>> +#define SO_SYMMETRIC_QUEUES    61
>> +
>>   #endif /* __ASM_GENERIC_SOCKET_H */
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 270b547..d96cda8 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3322,7 +3322,13 @@ static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
>>
>>          if (queue_index < 0 || skb->ooo_okay ||
>>              queue_index >= dev->real_num_tx_queues) {
>> -               int new_index = get_xps_queue(dev, skb);
>> +               int new_index = -1;
>> +
>> +               if (sk && sk->sk_symmetric_queues && dev->ifindex == sk->sk_rx_ifindex)
>> +                       new_index = sk->sk_rx_queue_mapping;
>> +
>> +               if (new_index < 0 || new_index >= dev->real_num_tx_queues)
>> +                       new_index = get_xps_queue(dev, skb);
>>
>>                  if (new_index < 0)
>>                          new_index = skb_tx_hash(dev, skb);
> So one thing I am not sure about is if we should be overriding XPS. It
> might make sense to instead place this after XPS so that if the root
> user configures it then it applies, otherwise if the socket is
> requesting symmetric queues you could fall back to that, and then
> finally just use hashing as the final solution for distributing the
> workload.
Isn't XPS on by default and all the devices that support XPS setup XPS 
maps as part of
the initialization?
Are you suggesting that the root user needs to disable XPS on the 
specific queues before an
application can use this option to enable symmetric queues?


>
> That way if somebody decides to reserve queues for some sort of
> specific traffic like AF_PACKET then they can configure the Tx via
> XPS, configure the Rx via RSS redirection table reprogramming, and
> then setup a filters on the hardware to direct the traffic they want
> to the queues that are running AF_PACKET.
>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 9b7b6bb..3876cce 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1059,6 +1059,10 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
>>                          sock_valbool_flag(sk, SOCK_ZEROCOPY, valbool);
>>                  break;
>>
>> +       case SO_SYMMETRIC_QUEUES:
>> +               sk->sk_symmetric_queues = valbool;
>> +               break;
>> +
>>          default:
>>                  ret = -ENOPROTOOPT;
>>                  break;
>> @@ -1391,6 +1395,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
>>                  v.val = sock_flag(sk, SOCK_ZEROCOPY);
>>                  break;
>>
>> +       case SO_SYMMETRIC_QUEUES:
>> +               v.val = sk->sk_symmetric_queues;
>> +               break;
>> +
>>          default:
>>                  /* We implement the SO_SNDLOWAT etc to not be settable
>>                   * (1003.1g 7).
>> @@ -2738,6 +2746,8 @@ void sock_init_data(struct socket *sock, struct sock *sk)
>>          sk->sk_max_pacing_rate = ~0U;
>>          sk->sk_pacing_rate = ~0U;
>>          sk->sk_incoming_cpu = -1;
>> +       sk->sk_rx_ifindex = -1;
>> +       sk->sk_rx_queue_mapping = -1;
>>          /*
>>           * Before updating sk_refcnt, we must commit prior changes to memory
>>           * (Documentation/RCU/rculist_nulls.txt for details)
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index c5d7656..12381e0 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -6356,6 +6356,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
>>          tcp_rsk(req)->snt_isn = isn;
>>          tcp_rsk(req)->txhash = net_tx_rndhash();
>>          tcp_openreq_init_rwin(req, sk, dst);
>> +       sk_mark_rx_queue(req_to_sk(req), skb);
>>          if (!want_cookie) {
>>                  tcp_reqsk_record_syn(sk, req, skb);
>>                  fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc);
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index a63486a..82f9af4 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -1450,6 +1450,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
>>
>>                  sock_rps_save_rxhash(sk, skb);
>>                  sk_mark_napi_id(sk, skb);
>> +               sk_mark_rx_queue(sk, skb);
>>                  if (dst) {
>>                          if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
>>                              !dst->ops->check(dst, 0)) {
>> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
>> index 188a6f3..2b5efd5 100644
>> --- a/net/ipv4/tcp_minisocks.c
>> +++ b/net/ipv4/tcp_minisocks.c
>> @@ -809,6 +809,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
>>
>>          /* record NAPI ID of child */
>>          sk_mark_napi_id(child, skb);
>> +       sk_mark_rx_queue(child, skb);
>>
>>          tcp_segs_in(tcp_sk(child), skb);
>>          if (!sock_owned_by_user(child)) {
>> --
>> 1.8.3.1
>>
