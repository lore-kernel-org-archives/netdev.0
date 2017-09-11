From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Mon, 11 Sep 2017 15:07:25 -0700
Message-ID: <CALx6S37XvbjcRon6g+gS19wj14SebL4qKFrVeGyagG0K2EStzA@mail.gmail.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
 <CALx6S371o0Oz9M7jmQWLuG2n3J0NGYGxZ_+okOkFL3x_+GB+2w@mail.gmail.com> <f98198c4-16f2-5271-3e12-7984a03bd6db@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:37297 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdIKWH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 18:07:26 -0400
Received: by mail-qt0-f193.google.com with SMTP id u48so3492631qtc.4
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 15:07:26 -0700 (PDT)
In-Reply-To: <f98198c4-16f2-5271-3e12-7984a03bd6db@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 11, 2017 at 9:49 AM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 9/10/2017 8:19 AM, Tom Herbert wrote:
>>
>> On Thu, Aug 31, 2017 at 4:27 PM, Sridhar Samudrala
>> <sridhar.samudrala@intel.com> wrote:
>>>
>>> This patch introduces a new socket option SO_SYMMETRIC_QUEUES that can be
>>> used
>>> to enable symmetric tx and rx queues on a socket.
>>>
>>> This option is specifically useful for epoll based multi threaded
>>> workloads
>>> where each thread handles packets received on a single RX queue . In this
>>> model,
>>> we have noticed that it helps to send the packets on the same TX queue
>>> corresponding to the queue-pair associated with the RX queue specifically
>>> when
>>> busy poll is enabled with epoll().
>>>
>>> Two new fields are added to struct sock_common to cache the last rx
>>> ifindex and
>>> the rx queue in the receive path of an SKB. __netdev_pick_tx() returns
>>> the cached
>>> rx queue when this option is enabled and the TX is happening on the same
>>> device.
>>>
>>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>>> ---
>>>   include/net/request_sock.h        |  1 +
>>>   include/net/sock.h                | 17 +++++++++++++++++
>>>   include/uapi/asm-generic/socket.h |  2 ++
>>>   net/core/dev.c                    |  8 +++++++-
>>>   net/core/sock.c                   | 10 ++++++++++
>>>   net/ipv4/tcp_input.c              |  1 +
>>>   net/ipv4/tcp_ipv4.c               |  1 +
>>>   net/ipv4/tcp_minisocks.c          |  1 +
>>>   8 files changed, 40 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
>>> index 23e2205..c3bc12e 100644
>>> --- a/include/net/request_sock.h
>>> +++ b/include/net/request_sock.h
>>> @@ -100,6 +100,7 @@ static inline struct sock *req_to_sk(struct
>>> request_sock *req)
>>>          req_to_sk(req)->sk_prot = sk_listener->sk_prot;
>>>          sk_node_init(&req_to_sk(req)->sk_node);
>>>          sk_tx_queue_clear(req_to_sk(req));
>>> +       req_to_sk(req)->sk_symmetric_queues =
>>> sk_listener->sk_symmetric_queues;
>>>          req->saved_syn = NULL;
>>>          refcount_set(&req->rsk_refcnt, 0);
>>>
>>> diff --git a/include/net/sock.h b/include/net/sock.h
>>> index 03a3625..3421809 100644
>>> --- a/include/net/sock.h
>>> +++ b/include/net/sock.h
>>> @@ -138,11 +138,14 @@ void SOCK_DEBUG(const struct sock *sk, const char
>>> *msg, ...)
>>>    *     @skc_node: main hash linkage for various protocol lookup tables
>>>    *     @skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
>>>    *     @skc_tx_queue_mapping: tx queue number for this connection
>>> + *     @skc_rx_queue_mapping: rx queue number for this connection
>>> + *     @skc_rx_ifindex: rx ifindex for this connection
>>>    *     @skc_flags: place holder for sk_flags
>>>    *             %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
>>>    *             %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
>>>    *     @skc_incoming_cpu: record/match cpu processing incoming packets
>>>    *     @skc_refcnt: reference count
>>> + *     @skc_symmetric_queues: symmetric tx/rx queues
>>>    *
>>>    *     This is the minimal network layer representation of sockets, the
>>> header
>>>    *     for struct sock and struct inet_timewait_sock.
>>> @@ -177,6 +180,7 @@ struct sock_common {
>>>          unsigned char           skc_reuseport:1;
>>>          unsigned char           skc_ipv6only:1;
>>>          unsigned char           skc_net_refcnt:1;
>>> +       unsigned char           skc_symmetric_queues:1;
>>>          int                     skc_bound_dev_if;
>>>          union {
>>>                  struct hlist_node       skc_bind_node;
>>> @@ -214,6 +218,8 @@ struct sock_common {
>>>                  struct hlist_nulls_node skc_nulls_node;
>>>          };
>>>          int                     skc_tx_queue_mapping;
>>> +       int                     skc_rx_queue_mapping;
>>> +       int                     skc_rx_ifindex;
>>>          union {
>>>                  int             skc_incoming_cpu;
>>>                  u32             skc_rcv_wnd;
>>> @@ -324,6 +330,8 @@ struct sock {
>>>   #define sk_nulls_node          __sk_common.skc_nulls_node
>>>   #define sk_refcnt              __sk_common.skc_refcnt
>>>   #define sk_tx_queue_mapping    __sk_common.skc_tx_queue_mapping
>>> +#define sk_rx_queue_mapping    __sk_common.skc_rx_queue_mapping
>>> +#define sk_rx_ifindex          __sk_common.skc_rx_ifindex
>>>
>>>   #define sk_dontcopy_begin      __sk_common.skc_dontcopy_begin
>>>   #define sk_dontcopy_end                __sk_common.skc_dontcopy_end
>>> @@ -340,6 +348,7 @@ struct sock {
>>>   #define sk_reuseport           __sk_common.skc_reuseport
>>>   #define sk_ipv6only            __sk_common.skc_ipv6only
>>>   #define sk_net_refcnt          __sk_common.skc_net_refcnt
>>> +#define sk_symmetric_queues    __sk_common.skc_symmetric_queues
>>>   #define sk_bound_dev_if                __sk_common.skc_bound_dev_if
>>>   #define sk_bind_node           __sk_common.skc_bind_node
>>>   #define sk_prot                        __sk_common.skc_prot
>>> @@ -1676,6 +1685,14 @@ static inline int sk_tx_queue_get(const struct
>>> sock *sk)
>>>          return sk ? sk->sk_tx_queue_mapping : -1;
>>>   }
>>>
>>> +static inline void sk_mark_rx_queue(struct sock *sk, struct sk_buff
>>> *skb)
>>> +{
>>> +       if (sk->sk_symmetric_queues) {
>>> +               sk->sk_rx_ifindex = skb->skb_iif;
>>> +               sk->sk_rx_queue_mapping = skb_get_rx_queue(skb);
>>> +       }
>>> +}
>>> +
>>>   static inline void sk_set_socket(struct sock *sk, struct socket *sock)
>>>   {
>>>          sk_tx_queue_clear(sk);
>>> diff --git a/include/uapi/asm-generic/socket.h
>>> b/include/uapi/asm-generic/socket.h
>>> index e47c9e4..f6b416e 100644
>>> --- a/include/uapi/asm-generic/socket.h
>>> +++ b/include/uapi/asm-generic/socket.h
>>> @@ -106,4 +106,6 @@
>>>
>>>   #define SO_ZEROCOPY            60
>>>
>>> +#define SO_SYMMETRIC_QUEUES    61
>>> +
>>>   #endif /* __ASM_GENERIC_SOCKET_H */
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 270b547..d96cda8 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -3322,7 +3322,13 @@ static u16 __netdev_pick_tx(struct net_device
>>> *dev, struct sk_buff *skb)
>>>
>>>          if (queue_index < 0 || skb->ooo_okay ||
>>>              queue_index >= dev->real_num_tx_queues) {
>>> -               int new_index = get_xps_queue(dev, skb);
>>> +               int new_index = -1;
>>> +
>>> +               if (sk && sk->sk_symmetric_queues && dev->ifindex ==
>>> sk->sk_rx_ifindex)
>>> +                       new_index = sk->sk_rx_queue_mapping;
>>> +
>>> +               if (new_index < 0 || new_index >=
>>> dev->real_num_tx_queues)
>>> +                       new_index = get_xps_queue(dev, skb);
>>
>> This enforces that notion of queue pairs which is not universal
>> concept to NICs. There are many devices and instances where we
>> purposely avoid having a 1-1 relationship between rx and tx queues.
>
>
> Yes. This patch assumes that TX and RX queues come in pairs.
>
>> An alternative might be to create a rx queue to tx queue map, add the
>> rx queue argument to get_xps_queue, and then that function can
>> consider the mapping. The administrator can configure the mapping as
>> appropriate and can select which rx queues are subject to the mapping.
>
> This alternative looks much cleaner and doesn't require the apps to
> configure the
> queues. Do we need to support 1 to many rx to tx queue mappings?
> For our symmetric queues usecase, where a single application thread is
> associated with
> 1 queue-pair,  1-1 mapping is sufficient.
> Do you see any usecase where it is useful to support 1-many mappings?
> I guess i can add a sysfs entry per rx-queue to setup a tx-queue OR
> tx-queue-map.

There is no reason do disallow 1 to many, XPS already does that. In
fact, the mapping algorithm in XSP is pretty much what is needed where
instead of mapping a CPU to a queue set, this just maps a rx queue to
queue set. ooo handling can still be done, although it might be less
critical in this case.

Tom
