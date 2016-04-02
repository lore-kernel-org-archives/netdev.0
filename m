From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 02/11] udp: no longer use SLAB_DESTROY_BY_RCU
Date: Sat, 2 Apr 2016 12:34:24 -0400
Message-ID: <CALx6S37nDNGuSa+y5g+u9R7VYAakAmSnCkY0F4zTXjQfrhDjxQ@mail.gmail.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
	<1459525942-30399-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34726 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820AbcDBQe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 12:34:26 -0400
Received: by mail-ig0-f179.google.com with SMTP id sy18so31569076igc.1
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 09:34:25 -0700 (PDT)
In-Reply-To: <1459525942-30399-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 1, 2016 at 11:52 AM, Eric Dumazet <edumazet@google.com> wrote:
> Tom Herbert would like not touching UDP socket refcnt for encapsulated
> traffic. For this to happen, we need to use normal RCU rules, with a grace
> period before freeing a socket. UDP sockets are not short lived in the
> high usage case, so the added cost of call_rcu() should not be a concern.
>
> This actually removes a lot of complexity in UDP stack.
>
> Multicast receives no longer need to hold a bucket spinlock.
>
> Note that ip early demux still needs to take a reference on the socket.
>
> Same remark for functions used by xt_socket and xt_PROXY netfilter modules,
> but this might be changed later.
>
> Performance for a single UDP socket receiving flood traffic from
> many RX queues/cpus.
>
> Simple udp_rx using simple recvfrom() loop :
> 438 kpps instead of 374 kpps : 17 % increase of the peak rate.
>
> v2: Addressed Willem de Bruijn feedback in multicast handling
>  - keep early demux break in __udp4_lib_demux_lookup()
>
Works fine with UDP encapsulation also.

Tested-by: Tom Herbert <tom@herbertland.com>

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Willem de Bruijn <willemb@google.com>
> ---
>  include/linux/udp.h |   8 +-
>  include/net/sock.h  |  12 +--
>  include/net/udp.h   |   2 +-
>  net/ipv4/udp.c      | 293 ++++++++++++++++------------------------------------
>  net/ipv4/udp_diag.c |  18 ++--
>  net/ipv6/udp.c      | 196 ++++++++++++-----------------------
>  6 files changed, 171 insertions(+), 358 deletions(-)
>
> diff --git a/include/linux/udp.h b/include/linux/udp.h
> index 87c094961bd5..32342754643a 100644
> --- a/include/linux/udp.h
> +++ b/include/linux/udp.h
> @@ -98,11 +98,11 @@ static inline bool udp_get_no_check6_rx(struct sock *sk)
>         return udp_sk(sk)->no_check6_rx;
>  }
>
> -#define udp_portaddr_for_each_entry(__sk, node, list) \
> -       hlist_nulls_for_each_entry(__sk, node, list, __sk_common.skc_portaddr_node)
> +#define udp_portaddr_for_each_entry(__sk, list) \
> +       hlist_for_each_entry(__sk, list, __sk_common.skc_portaddr_node)
>
> -#define udp_portaddr_for_each_entry_rcu(__sk, node, list) \
> -       hlist_nulls_for_each_entry_rcu(__sk, node, list, __sk_common.skc_portaddr_node)
> +#define udp_portaddr_for_each_entry_rcu(__sk, list) \
> +       hlist_for_each_entry_rcu(__sk, list, __sk_common.skc_portaddr_node)
>
>  #define IS_UDPLITE(__sk) (udp_sk(__sk)->pcflag)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index c88785a3e76c..c3a707d1cee8 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -178,7 +178,7 @@ struct sock_common {
>         int                     skc_bound_dev_if;
>         union {
>                 struct hlist_node       skc_bind_node;
> -               struct hlist_nulls_node skc_portaddr_node;
> +               struct hlist_node       skc_portaddr_node;
>         };
>         struct proto            *skc_prot;
>         possible_net_t          skc_net;
> @@ -670,18 +670,18 @@ static inline void sk_add_bind_node(struct sock *sk,
>         hlist_for_each_entry(__sk, list, sk_bind_node)
>
>  /**
> - * sk_nulls_for_each_entry_offset - iterate over a list at a given struct offset
> + * sk_for_each_entry_offset_rcu - iterate over a list at a given struct offset
>   * @tpos:      the type * to use as a loop cursor.
>   * @pos:       the &struct hlist_node to use as a loop cursor.
>   * @head:      the head for your list.
>   * @offset:    offset of hlist_node within the struct.
>   *
>   */
> -#define sk_nulls_for_each_entry_offset(tpos, pos, head, offset)                       \
> -       for (pos = (head)->first;                                              \
> -            (!is_a_nulls(pos)) &&                                             \
> +#define sk_for_each_entry_offset_rcu(tpos, pos, head, offset)                 \
> +       for (pos = rcu_dereference((head)->first);                             \
> +            pos != NULL &&                                                    \
>                 ({ tpos = (typeof(*tpos) *)((void *)pos - offset); 1;});       \
> -            pos = pos->next)
> +            pos = rcu_dereference(pos->next))
>
>  static inline struct user_namespace *sk_user_ns(struct sock *sk)
>  {
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 92927f729ac8..d870ec1611c4 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -59,7 +59,7 @@ struct udp_skb_cb {
>   *     @lock:  spinlock protecting changes to head/count
>   */
>  struct udp_hslot {
> -       struct hlist_nulls_head head;
> +       struct hlist_head       head;
>         int                     count;
>         spinlock_t              lock;
>  } __attribute__((aligned(2 * sizeof(long))));
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 08eed5e16df0..0475aaf95040 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -143,10 +143,9 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
>                                unsigned int log)
>  {
>         struct sock *sk2;
> -       struct hlist_nulls_node *node;
>         kuid_t uid = sock_i_uid(sk);
>
> -       sk_nulls_for_each(sk2, node, &hslot->head) {
> +       sk_for_each(sk2, &hslot->head) {
>                 if (net_eq(sock_net(sk2), net) &&
>                     sk2 != sk &&
>                     (bitmap || udp_sk(sk2)->udp_port_hash == num) &&
> @@ -177,12 +176,11 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
>                                                   bool match_wildcard))
>  {
>         struct sock *sk2;
> -       struct hlist_nulls_node *node;
>         kuid_t uid = sock_i_uid(sk);
>         int res = 0;
>
>         spin_lock(&hslot2->lock);
> -       udp_portaddr_for_each_entry(sk2, node, &hslot2->head) {
> +       udp_portaddr_for_each_entry(sk2, &hslot2->head) {
>                 if (net_eq(sock_net(sk2), net) &&
>                     sk2 != sk &&
>                     (udp_sk(sk2)->udp_port_hash == num) &&
> @@ -207,11 +205,10 @@ static int udp_reuseport_add_sock(struct sock *sk, struct udp_hslot *hslot,
>                                                     bool match_wildcard))
>  {
>         struct net *net = sock_net(sk);
> -       struct hlist_nulls_node *node;
>         kuid_t uid = sock_i_uid(sk);
>         struct sock *sk2;
>
> -       sk_nulls_for_each(sk2, node, &hslot->head) {
> +       sk_for_each(sk2, &hslot->head) {
>                 if (net_eq(sock_net(sk2), net) &&
>                     sk2 != sk &&
>                     sk2->sk_family == sk->sk_family &&
> @@ -333,17 +330,18 @@ found:
>                         goto fail_unlock;
>                 }
>
> -               sk_nulls_add_node_rcu(sk, &hslot->head);
> +               sk_add_node_rcu(sk, &hslot->head);
>                 hslot->count++;
>                 sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
>
>                 hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
>                 spin_lock(&hslot2->lock);
> -               hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
> +               hlist_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
>                                          &hslot2->head);
>                 hslot2->count++;
>                 spin_unlock(&hslot2->lock);
>         }
> +       sock_set_flag(sk, SOCK_RCU_FREE);
>         error = 0;
>  fail_unlock:
>         spin_unlock_bh(&hslot->lock);
> @@ -497,37 +495,27 @@ static struct sock *udp4_lib_lookup2(struct net *net,
>                 struct sk_buff *skb)
>  {
>         struct sock *sk, *result;
> -       struct hlist_nulls_node *node;
>         int score, badness, matches = 0, reuseport = 0;
> -       bool select_ok = true;
>         u32 hash = 0;
>
> -begin:
>         result = NULL;
>         badness = 0;
> -       udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
> +       udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
>                 score = compute_score2(sk, net, saddr, sport,
>                                       daddr, hnum, dif);
>                 if (score > badness) {
> -                       result = sk;
> -                       badness = score;
>                         reuseport = sk->sk_reuseport;
>                         if (reuseport) {
>                                 hash = udp_ehashfn(net, daddr, hnum,
>                                                    saddr, sport);
> -                               if (select_ok) {
> -                                       struct sock *sk2;
> -
> -                                       sk2 = reuseport_select_sock(sk, hash, skb,
> +                               result = reuseport_select_sock(sk, hash, skb,
>                                                         sizeof(struct udphdr));
> -                                       if (sk2) {
> -                                               result = sk2;
> -                                               select_ok = false;
> -                                               goto found;
> -                                       }
> -                               }
> +                               if (result)
> +                                       return result;
>                                 matches = 1;
>                         }
> +                       badness = score;
> +                       result = sk;
>                 } else if (score == badness && reuseport) {
>                         matches++;
>                         if (reciprocal_scale(hash, matches) == 0)
> @@ -535,23 +523,6 @@ begin:
>                         hash = next_pseudo_random32(hash);
>                 }
>         }
> -       /*
> -        * if the nulls value we got at the end of this lookup is
> -        * not the expected one, we must restart lookup.
> -        * We probably met an item that was moved to another chain.
> -        */
> -       if (get_nulls_value(node) != slot2)
> -               goto begin;
> -       if (result) {
> -found:
> -               if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
> -                       result = NULL;
> -               else if (unlikely(compute_score2(result, net, saddr, sport,
> -                                 daddr, hnum, dif) < badness)) {
> -                       sock_put(result);
> -                       goto begin;
> -               }
> -       }
>         return result;
>  }
>
> @@ -563,15 +534,12 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
>                 int dif, struct udp_table *udptable, struct sk_buff *skb)
>  {
>         struct sock *sk, *result;
> -       struct hlist_nulls_node *node;
>         unsigned short hnum = ntohs(dport);
>         unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
>         struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
>         int score, badness, matches = 0, reuseport = 0;
> -       bool select_ok = true;
>         u32 hash = 0;
>
> -       rcu_read_lock();
>         if (hslot->count > 10) {
>                 hash2 = udp4_portaddr_hash(net, daddr, hnum);
>                 slot2 = hash2 & udptable->mask;
> @@ -593,35 +561,27 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
>                                                   htonl(INADDR_ANY), hnum, dif,
>                                                   hslot2, slot2, skb);
>                 }
> -               rcu_read_unlock();
>                 return result;
>         }
>  begin:
>         result = NULL;
>         badness = 0;
> -       sk_nulls_for_each_rcu(sk, node, &hslot->head) {
> +       sk_for_each_rcu(sk, &hslot->head) {
>                 score = compute_score(sk, net, saddr, hnum, sport,
>                                       daddr, dport, dif);
>                 if (score > badness) {
> -                       result = sk;
> -                       badness = score;
>                         reuseport = sk->sk_reuseport;
>                         if (reuseport) {
>                                 hash = udp_ehashfn(net, daddr, hnum,
>                                                    saddr, sport);
> -                               if (select_ok) {
> -                                       struct sock *sk2;
> -
> -                                       sk2 = reuseport_select_sock(sk, hash, skb,
> +                               result = reuseport_select_sock(sk, hash, skb,
>                                                         sizeof(struct udphdr));
> -                                       if (sk2) {
> -                                               result = sk2;
> -                                               select_ok = false;
> -                                               goto found;
> -                                       }
> -                               }
> +                               if (result)
> +                                       return result;
>                                 matches = 1;
>                         }
> +                       result = sk;
> +                       badness = score;
>                 } else if (score == badness && reuseport) {
>                         matches++;
>                         if (reciprocal_scale(hash, matches) == 0)
> @@ -629,25 +589,6 @@ begin:
>                         hash = next_pseudo_random32(hash);
>                 }
>         }
> -       /*
> -        * if the nulls value we got at the end of this lookup is
> -        * not the expected one, we must restart lookup.
> -        * We probably met an item that was moved to another chain.
> -        */
> -       if (get_nulls_value(node) != slot)
> -               goto begin;
> -
> -       if (result) {
> -found:
> -               if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
> -                       result = NULL;
> -               else if (unlikely(compute_score(result, net, saddr, hnum, sport,
> -                                 daddr, dport, dif) < badness)) {
> -                       sock_put(result);
> -                       goto begin;
> -               }
> -       }
> -       rcu_read_unlock();
>         return result;
>  }
>  EXPORT_SYMBOL_GPL(__udp4_lib_lookup);
> @@ -663,13 +604,24 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
>                                  udptable, skb);
>  }
>
> +/* Must be called under rcu_read_lock().
> + * Does increment socket refcount.
> + */
> +#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
> +    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)
>  struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
>                              __be32 daddr, __be16 dport, int dif)
>  {
> -       return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif,
> -                                &udp_table, NULL);
> +       struct sock *sk;
> +
> +       sk = __udp4_lib_lookup(net, saddr, sport, daddr, dport,
> +                              dif, &udp_table, NULL);
> +       if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> +               sk = NULL;
> +       return sk;
>  }
>  EXPORT_SYMBOL_GPL(udp4_lib_lookup);
> +#endif
>
>  static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
>                                        __be16 loc_port, __be32 loc_addr,
> @@ -771,7 +723,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
>         sk->sk_err = err;
>         sk->sk_error_report(sk);
>  out:
> -       sock_put(sk);
> +       return;
>  }
>
>  void udp_err(struct sk_buff *skb, u32 info)
> @@ -1474,13 +1426,13 @@ void udp_lib_unhash(struct sock *sk)
>                 spin_lock_bh(&hslot->lock);
>                 if (rcu_access_pointer(sk->sk_reuseport_cb))
>                         reuseport_detach_sock(sk);
> -               if (sk_nulls_del_node_init_rcu(sk)) {
> +               if (sk_del_node_init_rcu(sk)) {
>                         hslot->count--;
>                         inet_sk(sk)->inet_num = 0;
>                         sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>
>                         spin_lock(&hslot2->lock);
> -                       hlist_nulls_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
> +                       hlist_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
>                         hslot2->count--;
>                         spin_unlock(&hslot2->lock);
>                 }
> @@ -1513,12 +1465,12 @@ void udp_lib_rehash(struct sock *sk, u16 newhash)
>
>                         if (hslot2 != nhslot2) {
>                                 spin_lock(&hslot2->lock);
> -                               hlist_nulls_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
> +                               hlist_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
>                                 hslot2->count--;
>                                 spin_unlock(&hslot2->lock);
>
>                                 spin_lock(&nhslot2->lock);
> -                               hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
> +                               hlist_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
>                                                          &nhslot2->head);
>                                 nhslot2->count++;
>                                 spin_unlock(&nhslot2->lock);
> @@ -1697,35 +1649,6 @@ drop:
>         return -1;
>  }
>
> -static void flush_stack(struct sock **stack, unsigned int count,
> -                       struct sk_buff *skb, unsigned int final)
> -{
> -       unsigned int i;
> -       struct sk_buff *skb1 = NULL;
> -       struct sock *sk;
> -
> -       for (i = 0; i < count; i++) {
> -               sk = stack[i];
> -               if (likely(!skb1))
> -                       skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
> -
> -               if (!skb1) {
> -                       atomic_inc(&sk->sk_drops);
> -                       UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
> -                                        IS_UDPLITE(sk));
> -                       UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
> -                                        IS_UDPLITE(sk));
> -               }
> -
> -               if (skb1 && udp_queue_rcv_skb(sk, skb1) <= 0)
> -                       skb1 = NULL;
> -
> -               sock_put(sk);
> -       }
> -       if (unlikely(skb1))
> -               kfree_skb(skb1);
> -}
> -
>  /* For TCP sockets, sk_rx_dst is protected by socket lock
>   * For UDP, we use xchg() to guard against concurrent changes.
>   */
> @@ -1749,14 +1672,14 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>                                     struct udp_table *udptable,
>                                     int proto)
>  {
> -       struct sock *sk, *stack[256 / sizeof(struct sock *)];
> -       struct hlist_nulls_node *node;
> +       struct sock *sk, *first = NULL;
>         unsigned short hnum = ntohs(uh->dest);
>         struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
> -       int dif = skb->dev->ifindex;
> -       unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
>         unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
> -       bool inner_flushed = false;
> +       unsigned int offset = offsetof(typeof(*sk), sk_node);
> +       int dif = skb->dev->ifindex;
> +       struct hlist_node *node;
> +       struct sk_buff *nskb;
>
>         if (use_hash2) {
>                 hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
> @@ -1767,23 +1690,28 @@ start_lookup:
>                 offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
>         }
>
> -       spin_lock(&hslot->lock);
> -       sk_nulls_for_each_entry_offset(sk, node, &hslot->head, offset) {
> -               if (__udp_is_mcast_sock(net, sk,
> -                                       uh->dest, daddr,
> -                                       uh->source, saddr,
> -                                       dif, hnum)) {
> -                       if (unlikely(count == ARRAY_SIZE(stack))) {
> -                               flush_stack(stack, count, skb, ~0);
> -                               inner_flushed = true;
> -                               count = 0;
> -                       }
> -                       stack[count++] = sk;
> -                       sock_hold(sk);
> +       sk_for_each_entry_offset_rcu(sk, node, &hslot->head, offset) {
> +               if (!__udp_is_mcast_sock(net, sk, uh->dest, daddr,
> +                                        uh->source, saddr, dif, hnum))
> +                       continue;
> +
> +               if (!first) {
> +                       first = sk;
> +                       continue;
>                 }
> -       }
> +               nskb = skb_clone(skb, GFP_ATOMIC);
>
> -       spin_unlock(&hslot->lock);
> +               if (unlikely(!nskb)) {
> +                       atomic_inc(&sk->sk_drops);
> +                       UDP_INC_STATS_BH(net, UDP_MIB_RCVBUFERRORS,
> +                                        IS_UDPLITE(sk));
> +                       UDP_INC_STATS_BH(net, UDP_MIB_INERRORS,
> +                                        IS_UDPLITE(sk));
> +                       continue;
> +               }
> +               if (udp_queue_rcv_skb(sk, nskb) > 0)
> +                       consume_skb(nskb);
> +       }
>
>         /* Also lookup *:port if we are using hash2 and haven't done so yet. */
>         if (use_hash2 && hash2 != hash2_any) {
> @@ -1791,16 +1719,13 @@ start_lookup:
>                 goto start_lookup;
>         }
>
> -       /*
> -        * do the slow work with no lock held
> -        */
> -       if (count) {
> -               flush_stack(stack, count, skb, count - 1);
> +       if (first) {
> +               if (udp_queue_rcv_skb(first, skb) > 0)
> +                       consume_skb(skb);
>         } else {
> -               if (!inner_flushed)
> -                       UDP_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
> -                                        proto == IPPROTO_UDPLITE);
> -               consume_skb(skb);
> +               kfree_skb(skb);
> +               UDP_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
> +                                proto == IPPROTO_UDPLITE);
>         }
>         return 0;
>  }
> @@ -1897,7 +1822,6 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>                                                  inet_compute_pseudo);
>
>                 ret = udp_queue_rcv_skb(sk, skb);
> -               sock_put(sk);
>
>                 /* a return value > 0 means to resubmit the input, but
>                  * it wants the return to be -protocol, or 0
> @@ -1958,49 +1882,24 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
>                                                   int dif)
>  {
>         struct sock *sk, *result;
> -       struct hlist_nulls_node *node;
>         unsigned short hnum = ntohs(loc_port);
> -       unsigned int count, slot = udp_hashfn(net, hnum, udp_table.mask);
> +       unsigned int slot = udp_hashfn(net, hnum, udp_table.mask);
>         struct udp_hslot *hslot = &udp_table.hash[slot];
>
>         /* Do not bother scanning a too big list */
>         if (hslot->count > 10)
>                 return NULL;
>
> -       rcu_read_lock();
> -begin:
> -       count = 0;
>         result = NULL;
> -       sk_nulls_for_each_rcu(sk, node, &hslot->head) {
> -               if (__udp_is_mcast_sock(net, sk,
> -                                       loc_port, loc_addr,
> -                                       rmt_port, rmt_addr,
> -                                       dif, hnum)) {
> +       sk_for_each_rcu(sk, &hslot->head) {
> +               if (__udp_is_mcast_sock(net, sk, loc_port, loc_addr,
> +                                       rmt_port, rmt_addr, dif, hnum)) {
> +                       if (result)
> +                               return NULL;
>                         result = sk;
> -                       ++count;
> -               }
> -       }
> -       /*
> -        * if the nulls value we got at the end of this lookup is
> -        * not the expected one, we must restart lookup.
> -        * We probably met an item that was moved to another chain.
> -        */
> -       if (get_nulls_value(node) != slot)
> -               goto begin;
> -
> -       if (result) {
> -               if (count != 1 ||
> -                   unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
> -                       result = NULL;
> -               else if (unlikely(!__udp_is_mcast_sock(net, result,
> -                                                      loc_port, loc_addr,
> -                                                      rmt_port, rmt_addr,
> -                                                      dif, hnum))) {
> -                       sock_put(result);
> -                       result = NULL;
>                 }
>         }
> -       rcu_read_unlock();
> +
>         return result;
>  }
>
> @@ -2013,37 +1912,22 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
>                                             __be16 rmt_port, __be32 rmt_addr,
>                                             int dif)
>  {
> -       struct sock *sk, *result;
> -       struct hlist_nulls_node *node;
>         unsigned short hnum = ntohs(loc_port);
>         unsigned int hash2 = udp4_portaddr_hash(net, loc_addr, hnum);
>         unsigned int slot2 = hash2 & udp_table.mask;
>         struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
>         INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr);
>         const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
> +       struct sock *sk;
>
> -       rcu_read_lock();
> -       result = NULL;
> -       udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
> -               if (INET_MATCH(sk, net, acookie,
> -                              rmt_addr, loc_addr, ports, dif))
> -                       result = sk;
> +       udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
> +               if (INET_MATCH(sk, net, acookie, rmt_addr,
> +                              loc_addr, ports, dif))
> +                       return sk;
>                 /* Only check first socket in chain */
>                 break;
>         }
> -
> -       if (result) {
> -               if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
> -                       result = NULL;
> -               else if (unlikely(!INET_MATCH(sk, net, acookie,
> -                                             rmt_addr, loc_addr,
> -                                             ports, dif))) {
> -                       sock_put(result);
> -                       result = NULL;
> -               }
> -       }
> -       rcu_read_unlock();
> -       return result;
> +       return NULL;
>  }
>
>  void udp_v4_early_demux(struct sk_buff *skb)
> @@ -2051,7 +1935,7 @@ void udp_v4_early_demux(struct sk_buff *skb)
>         struct net *net = dev_net(skb->dev);
>         const struct iphdr *iph;
>         const struct udphdr *uh;
> -       struct sock *sk;
> +       struct sock *sk = NULL;
>         struct dst_entry *dst;
>         int dif = skb->dev->ifindex;
>         int ours;
> @@ -2083,11 +1967,9 @@ void udp_v4_early_demux(struct sk_buff *skb)
>         } else if (skb->pkt_type == PACKET_HOST) {
>                 sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
>                                              uh->source, iph->saddr, dif);
> -       } else {
> -               return;
>         }
>
> -       if (!sk)
> +       if (!sk || !atomic_inc_not_zero_hint(&sk->sk_refcnt, 2))
>                 return;
>
>         skb->sk = sk;
> @@ -2387,14 +2269,13 @@ static struct sock *udp_get_first(struct seq_file *seq, int start)
>
>         for (state->bucket = start; state->bucket <= state->udp_table->mask;
>              ++state->bucket) {
> -               struct hlist_nulls_node *node;
>                 struct udp_hslot *hslot = &state->udp_table->hash[state->bucket];
>
> -               if (hlist_nulls_empty(&hslot->head))
> +               if (hlist_empty(&hslot->head))
>                         continue;
>
>                 spin_lock_bh(&hslot->lock);
> -               sk_nulls_for_each(sk, node, &hslot->head) {
> +               sk_for_each(sk, &hslot->head) {
>                         if (!net_eq(sock_net(sk), net))
>                                 continue;
>                         if (sk->sk_family == state->family)
> @@ -2413,7 +2294,7 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
>         struct net *net = seq_file_net(seq);
>
>         do {
> -               sk = sk_nulls_next(sk);
> +               sk = sk_next(sk);
>         } while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
>
>         if (!sk) {
> @@ -2622,12 +2503,12 @@ void __init udp_table_init(struct udp_table *table, const char *name)
>
>         table->hash2 = table->hash + (table->mask + 1);
>         for (i = 0; i <= table->mask; i++) {
> -               INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
> +               INIT_HLIST_HEAD(&table->hash[i].head);
>                 table->hash[i].count = 0;
>                 spin_lock_init(&table->hash[i].lock);
>         }
>         for (i = 0; i <= table->mask; i++) {
> -               INIT_HLIST_NULLS_HEAD(&table->hash2[i].head, i);
> +               INIT_HLIST_HEAD(&table->hash2[i].head);
>                 table->hash2[i].count = 0;
>                 spin_lock_init(&table->hash2[i].lock);
>         }
> diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
> index df1966f3b6ec..3d5ccf4b1412 100644
> --- a/net/ipv4/udp_diag.c
> +++ b/net/ipv4/udp_diag.c
> @@ -36,10 +36,11 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
>                         const struct inet_diag_req_v2 *req)
>  {
>         int err = -EINVAL;
> -       struct sock *sk;
> +       struct sock *sk = NULL;
>         struct sk_buff *rep;
>         struct net *net = sock_net(in_skb->sk);
>
> +       rcu_read_lock();
>         if (req->sdiag_family == AF_INET)
>                 sk = __udp4_lib_lookup(net,
>                                 req->id.idiag_src[0], req->id.idiag_sport,
> @@ -54,9 +55,9 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
>                                 req->id.idiag_dport,
>                                 req->id.idiag_if, tbl, NULL);
>  #endif
> -       else
> -               goto out_nosk;
> -
> +       if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> +               sk = NULL;
> +       rcu_read_unlock();
>         err = -ENOENT;
>         if (!sk)
>                 goto out_nosk;
> @@ -96,24 +97,23 @@ static void udp_dump(struct udp_table *table, struct sk_buff *skb,
>                      struct netlink_callback *cb,
>                      const struct inet_diag_req_v2 *r, struct nlattr *bc)
>  {
> -       int num, s_num, slot, s_slot;
>         struct net *net = sock_net(skb->sk);
> +       int num, s_num, slot, s_slot;
>
>         s_slot = cb->args[0];
>         num = s_num = cb->args[1];
>
>         for (slot = s_slot; slot <= table->mask; s_num = 0, slot++) {
> -               struct sock *sk;
> -               struct hlist_nulls_node *node;
>                 struct udp_hslot *hslot = &table->hash[slot];
> +               struct sock *sk;
>
>                 num = 0;
>
> -               if (hlist_nulls_empty(&hslot->head))
> +               if (hlist_empty(&hslot->head))
>                         continue;
>
>                 spin_lock_bh(&hslot->lock);
> -               sk_nulls_for_each(sk, node, &hslot->head) {
> +               sk_for_each(sk, &hslot->head) {
>                         struct inet_sock *inet = inet_sk(sk);
>
>                         if (!net_eq(sock_net(sk), net))
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 8125931106be..b28c0dc63c63 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -213,37 +213,28 @@ static struct sock *udp6_lib_lookup2(struct net *net,
>                 struct sk_buff *skb)
>  {
>         struct sock *sk, *result;
> -       struct hlist_nulls_node *node;
>         int score, badness, matches = 0, reuseport = 0;
> -       bool select_ok = true;
>         u32 hash = 0;
>
> -begin:
>         result = NULL;
>         badness = -1;
> -       udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
> +       udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
>                 score = compute_score2(sk, net, saddr, sport,
>                                       daddr, hnum, dif);
>                 if (score > badness) {
> -                       result = sk;
> -                       badness = score;
>                         reuseport = sk->sk_reuseport;
>                         if (reuseport) {
>                                 hash = udp6_ehashfn(net, daddr, hnum,
>                                                     saddr, sport);
> -                               if (select_ok) {
> -                                       struct sock *sk2;
>
> -                                       sk2 = reuseport_select_sock(sk, hash, skb,
> +                               result = reuseport_select_sock(sk, hash, skb,
>                                                         sizeof(struct udphdr));
> -                                       if (sk2) {
> -                                               result = sk2;
> -                                               select_ok = false;
> -                                               goto found;
> -                                       }
> -                               }
> +                               if (result)
> +                                       return result;
>                                 matches = 1;
>                         }
> +                       result = sk;
> +                       badness = score;
>                 } else if (score == badness && reuseport) {
>                         matches++;
>                         if (reciprocal_scale(hash, matches) == 0)
> @@ -251,27 +242,10 @@ begin:
>                         hash = next_pseudo_random32(hash);
>                 }
>         }
> -       /*
> -        * if the nulls value we got at the end of this lookup is
> -        * not the expected one, we must restart lookup.
> -        * We probably met an item that was moved to another chain.
> -        */
> -       if (get_nulls_value(node) != slot2)
> -               goto begin;
> -
> -       if (result) {
> -found:
> -               if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
> -                       result = NULL;
> -               else if (unlikely(compute_score2(result, net, saddr, sport,
> -                                 daddr, hnum, dif) < badness)) {
> -                       sock_put(result);
> -                       goto begin;
> -               }
> -       }
>         return result;
>  }
>
> +/* rcu_read_lock() must be held */
>  struct sock *__udp6_lib_lookup(struct net *net,
>                                       const struct in6_addr *saddr, __be16 sport,
>                                       const struct in6_addr *daddr, __be16 dport,
> @@ -279,15 +253,12 @@ struct sock *__udp6_lib_lookup(struct net *net,
>                                       struct sk_buff *skb)
>  {
>         struct sock *sk, *result;
> -       struct hlist_nulls_node *node;
>         unsigned short hnum = ntohs(dport);
>         unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
>         struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
>         int score, badness, matches = 0, reuseport = 0;
> -       bool select_ok = true;
>         u32 hash = 0;
>
> -       rcu_read_lock();
>         if (hslot->count > 10) {
>                 hash2 = udp6_portaddr_hash(net, daddr, hnum);
>                 slot2 = hash2 & udptable->mask;
> @@ -309,34 +280,26 @@ struct sock *__udp6_lib_lookup(struct net *net,
>                                                   &in6addr_any, hnum, dif,
>                                                   hslot2, slot2, skb);
>                 }
> -               rcu_read_unlock();
>                 return result;
>         }
>  begin:
>         result = NULL;
>         badness = -1;
> -       sk_nulls_for_each_rcu(sk, node, &hslot->head) {
> +       sk_for_each_rcu(sk, &hslot->head) {
>                 score = compute_score(sk, net, hnum, saddr, sport, daddr, dport, dif);
>                 if (score > badness) {
> -                       result = sk;
> -                       badness = score;
>                         reuseport = sk->sk_reuseport;
>                         if (reuseport) {
>                                 hash = udp6_ehashfn(net, daddr, hnum,
>                                                     saddr, sport);
> -                               if (select_ok) {
> -                                       struct sock *sk2;
> -
> -                                       sk2 = reuseport_select_sock(sk, hash, skb,
> +                               result = reuseport_select_sock(sk, hash, skb,
>                                                         sizeof(struct udphdr));
> -                                       if (sk2) {
> -                                               result = sk2;
> -                                               select_ok = false;
> -                                               goto found;
> -                                       }
> -                               }
> +                               if (result)
> +                                       return result;
>                                 matches = 1;
>                         }
> +                       result = sk;
> +                       badness = score;
>                 } else if (score == badness && reuseport) {
>                         matches++;
>                         if (reciprocal_scale(hash, matches) == 0)
> @@ -344,25 +307,6 @@ begin:
>                         hash = next_pseudo_random32(hash);
>                 }
>         }
> -       /*
> -        * if the nulls value we got at the end of this lookup is
> -        * not the expected one, we must restart lookup.
> -        * We probably met an item that was moved to another chain.
> -        */
> -       if (get_nulls_value(node) != slot)
> -               goto begin;
> -
> -       if (result) {
> -found:
> -               if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
> -                       result = NULL;
> -               else if (unlikely(compute_score(result, net, hnum, saddr, sport,
> -                                       daddr, dport, dif) < badness)) {
> -                       sock_put(result);
> -                       goto begin;
> -               }
> -       }
> -       rcu_read_unlock();
>         return result;
>  }
>  EXPORT_SYMBOL_GPL(__udp6_lib_lookup);
> @@ -382,12 +326,24 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
>                                  udptable, skb);
>  }
>
> +/* Must be called under rcu_read_lock().
> + * Does increment socket refcount.
> + */
> +#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
> +    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)
>  struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
>                              const struct in6_addr *daddr, __be16 dport, int dif)
>  {
> -       return __udp6_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table, NULL);
> +       struct sock *sk;
> +
> +       sk =  __udp6_lib_lookup(net, saddr, sport, daddr, dport,
> +                               dif, &udp_table, NULL);
> +       if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> +               sk = NULL;
> +       return sk;
>  }
>  EXPORT_SYMBOL_GPL(udp6_lib_lookup);
> +#endif
>
>  /*
>   *     This should be easy, if there is something there we
> @@ -585,7 +541,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>         sk->sk_err = err;
>         sk->sk_error_report(sk);
>  out:
> -       sock_put(sk);
> +       return;
>  }
>
>  static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> @@ -747,33 +703,6 @@ static bool __udp_v6_is_mcast_sock(struct net *net, struct sock *sk,
>         return true;
>  }
>
> -static void flush_stack(struct sock **stack, unsigned int count,
> -                       struct sk_buff *skb, unsigned int final)
> -{
> -       struct sk_buff *skb1 = NULL;
> -       struct sock *sk;
> -       unsigned int i;
> -
> -       for (i = 0; i < count; i++) {
> -               sk = stack[i];
> -               if (likely(!skb1))
> -                       skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
> -               if (!skb1) {
> -                       atomic_inc(&sk->sk_drops);
> -                       UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
> -                                         IS_UDPLITE(sk));
> -                       UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
> -                                         IS_UDPLITE(sk));
> -               }
> -
> -               if (skb1 && udpv6_queue_rcv_skb(sk, skb1) <= 0)
> -                       skb1 = NULL;
> -               sock_put(sk);
> -       }
> -       if (unlikely(skb1))
> -               kfree_skb(skb1);
> -}
> -
>  static void udp6_csum_zero_error(struct sk_buff *skb)
>  {
>         /* RFC 2460 section 8.1 says that we SHOULD log
> @@ -792,15 +721,15 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>                 const struct in6_addr *saddr, const struct in6_addr *daddr,
>                 struct udp_table *udptable, int proto)
>  {
> -       struct sock *sk, *stack[256 / sizeof(struct sock *)];
> +       struct sock *sk, *first = NULL;
>         const struct udphdr *uh = udp_hdr(skb);
> -       struct hlist_nulls_node *node;
>         unsigned short hnum = ntohs(uh->dest);
>         struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
> -       int dif = inet6_iif(skb);
> -       unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
> +       unsigned int offset = offsetof(typeof(*sk), sk_node);
>         unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
> -       bool inner_flushed = false;
> +       int dif = inet6_iif(skb);
> +       struct hlist_node *node;
> +       struct sk_buff *nskb;
>
>         if (use_hash2) {
>                 hash2_any = udp6_portaddr_hash(net, &in6addr_any, hnum) &
> @@ -811,27 +740,32 @@ start_lookup:
>                 offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
>         }
>
> -       spin_lock(&hslot->lock);
> -       sk_nulls_for_each_entry_offset(sk, node, &hslot->head, offset) {
> -               if (__udp_v6_is_mcast_sock(net, sk,
> -                                          uh->dest, daddr,
> -                                          uh->source, saddr,
> -                                          dif, hnum) &&
> -                   /* If zero checksum and no_check is not on for
> -                    * the socket then skip it.
> -                    */
> -                   (uh->check || udp_sk(sk)->no_check6_rx)) {
> -                       if (unlikely(count == ARRAY_SIZE(stack))) {
> -                               flush_stack(stack, count, skb, ~0);
> -                               inner_flushed = true;
> -                               count = 0;
> -                       }
> -                       stack[count++] = sk;
> -                       sock_hold(sk);
> +       sk_for_each_entry_offset_rcu(sk, node, &hslot->head, offset) {
> +               if (!__udp_v6_is_mcast_sock(net, sk, uh->dest, daddr,
> +                                           uh->source, saddr, dif, hnum))
> +                       continue;
> +               /* If zero checksum and no_check is not on for
> +                * the socket then skip it.
> +                */
> +               if (!uh->check && !udp_sk(sk)->no_check6_rx)
> +                       continue;
> +               if (!first) {
> +                       first = sk;
> +                       continue;
> +               }
> +               nskb = skb_clone(skb, GFP_ATOMIC);
> +               if (unlikely(!nskb)) {
> +                       atomic_inc(&sk->sk_drops);
> +                       UDP6_INC_STATS_BH(net, UDP_MIB_RCVBUFERRORS,
> +                                         IS_UDPLITE(sk));
> +                       UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS,
> +                                         IS_UDPLITE(sk));
> +                       continue;
>                 }
> -       }
>
> -       spin_unlock(&hslot->lock);
> +               if (udpv6_queue_rcv_skb(sk, nskb) > 0)
> +                       consume_skb(nskb);
> +       }
>
>         /* Also lookup *:port if we are using hash2 and haven't done so yet. */
>         if (use_hash2 && hash2 != hash2_any) {
> @@ -839,13 +773,13 @@ start_lookup:
>                 goto start_lookup;
>         }
>
> -       if (count) {
> -               flush_stack(stack, count, skb, count - 1);
> +       if (first) {
> +               if (udpv6_queue_rcv_skb(first, skb) > 0)
> +                       consume_skb(skb);
>         } else {
> -               if (!inner_flushed)
> -                       UDP6_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
> -                                         proto == IPPROTO_UDPLITE);
> -               consume_skb(skb);
> +               kfree_skb(skb);
> +               UDP6_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
> +                                 proto == IPPROTO_UDPLITE);
>         }
>         return 0;
>  }
> @@ -853,10 +787,10 @@ start_lookup:
>  int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>                    int proto)
>  {
> +       const struct in6_addr *saddr, *daddr;
>         struct net *net = dev_net(skb->dev);
> -       struct sock *sk;
>         struct udphdr *uh;
> -       const struct in6_addr *saddr, *daddr;
> +       struct sock *sk;
>         u32 ulen = 0;
>
>         if (!pskb_may_pull(skb, sizeof(struct udphdr)))
> @@ -910,7 +844,6 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>                 int ret;
>
>                 if (!uh->check && !udp_sk(sk)->no_check6_rx) {
> -                       sock_put(sk);
>                         udp6_csum_zero_error(skb);
>                         goto csum_error;
>                 }
> @@ -920,7 +853,6 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>                                                  ip6_compute_pseudo);
>
>                 ret = udpv6_queue_rcv_skb(sk, skb);
> -               sock_put(sk);
>
>                 /* a return value > 0 means to resubmit the input */
>                 if (ret > 0)
> --
> 2.8.0.rc3.226.g39d4020
>
