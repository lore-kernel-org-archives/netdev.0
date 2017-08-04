From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 4/6] net: sockmap with sk redirect support
Date: Thu, 3 Aug 2017 21:22:09 -0700
Message-ID: <CALx6S36fmiyFNTif2B6X91wPXWEb1W3pk5=N0JTMD0T9ZoL5fw@mail.gmail.com>
References: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810> <20170803233756.12107.54982.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34947 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdHDEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 00:22:11 -0400
Received: by mail-wm0-f53.google.com with SMTP id m85so10137432wma.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 21:22:11 -0700 (PDT)
In-Reply-To: <20170803233756.12107.54982.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 3, 2017 at 4:37 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> Recently we added a new map type called dev map used to forward XDP
> packets between ports (6093ec2dc313). This patches introduces a
> similar notion for sockets.
>
> A sockmap allows users to add participating sockets to a map. When
> sockets are added to the map enough context is stored with the
> map entry to use the entry with a new helper
>
>   bpf_sk_redirect_map(map, key, flags)
>
> This helper (analogous to bpf_redirect_map in XDP) is given the map
> and an entry in the map. When called from a sockmap program, discussed
> below, the skb will be sent on the socket using skb_send_sock().
>
> With the above we need a bpf program to call the helper from that will
> then implement the send logic. The initial site implemented in this
> series is the recv_sock hook. For this to work we implemented a map
> attach command to add attributes to a map. In sockmap we add two
> programs a parse program and a verdict program. The parse program
> uses strparser to build messages and pass them to the verdict program.
> The parse program usese normal strparser semantics. The verdict
> program is of type SOCKET_FILTER.
>
> The verdict program returns a verdict BPF_OK, BPF_DROP, BPF_REDIRECT.
> When BPF_REDIRECT is returned, expected when bpf program uses
> bpf_sk_redirect_map(), the sockmap logic will consult per cpu variables
> set by the helper routine and pull the sock entry out of the sock map.
> This pattern follows the existing redirect logic in cls and xdp
> programs.
>
Hi John,

I'm a bit confused. If the verdict program bpf_mux then? I don't see
any use of BPF_OK,DROP, or REDIRECT. I assume I'm missing something.

Tom

> This gives the flow,
>
>  recv_sock -> str_parser (parse_prog) -> verdict_prog -> skb_send_sock
>
> As an example use case a message based load balancer may use specific
> logic in the verdict program to select the sock to send on.
>
> Example and sample programs are provided in future patches that
> hopefully illustrate the user interfaces.
>
> TBD: bpf program refcnt'ing needs to be cleaned up, some additional
> cleanup in a few error paths, publish performance numbers and some
> self tests.
>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> ---
>  include/linux/bpf.h       |   11 +
>  include/linux/bpf_types.h |    1
>  include/uapi/linux/bpf.h  |   13 +
>  kernel/bpf/Makefile       |    2
>  kernel/bpf/helpers.c      |   20 +
>  kernel/bpf/sockmap.c      |  623 +++++++++++++++++++++++++++++++++++++++++++++
>  kernel/bpf/syscall.c      |   41 +++
>  net/core/filter.c         |   51 ++++
>  8 files changed, 759 insertions(+), 3 deletions(-)
>  create mode 100644 kernel/bpf/sockmap.c
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 6353c74..9ce6aa0 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -15,6 +15,8 @@
>  #include <linux/err.h>
>  #include <linux/rbtree_latch.h>
>
> +#include <net/sock.h>
> +
>  struct perf_event;
>  struct bpf_map;
>
> @@ -29,6 +31,9 @@ struct bpf_map_ops {
>         /* funcs callable from userspace and from eBPF programs */
>         void *(*map_lookup_elem)(struct bpf_map *map, void *key);
>         int (*map_update_elem)(struct bpf_map *map, void *key, void *value, u64 flags);
> +       int (*map_ctx_update_elem)(struct bpf_sock_ops_kern *skops,
> +                                  struct bpf_map *map,
> +                                  void *key, u64 flags, u64 map_flags);
>         int (*map_delete_elem)(struct bpf_map *map, void *key);
>
>         /* funcs called by prog_array and perf_event_array map */
> @@ -37,6 +42,7 @@ struct bpf_map_ops {
>         void (*map_fd_put_ptr)(void *ptr);
>         u32 (*map_gen_lookup)(struct bpf_map *map, struct bpf_insn *insn_buf);
>         u32 (*map_fd_sys_lookup_elem)(void *ptr);
> +       int (*map_attach)(struct bpf_map *map, struct bpf_prog *p1, struct bpf_prog *p2);
>  };
>
>  struct bpf_map {
> @@ -321,6 +327,7 @@ static inline void bpf_long_memcpy(void *dst, const void *src, u32 size)
>
>  /* Map specifics */
>  struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key);
> +struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key);
>  void __dev_map_insert_ctx(struct bpf_map *map, u32 index);
>  void __dev_map_flush(struct bpf_map *map);
>
> @@ -378,9 +385,13 @@ static inline void __dev_map_flush(struct bpf_map *map)
>  }
>  #endif /* CONFIG_BPF_SYSCALL */
>
> +inline struct sock *do_sk_redirect_map(void);
> +inline u64 get_sk_redirect_flags(void);
> +
>  /* verifier prototypes for helper functions called from eBPF programs */
>  extern const struct bpf_func_proto bpf_map_lookup_elem_proto;
>  extern const struct bpf_func_proto bpf_map_update_elem_proto;
> +extern const struct bpf_func_proto bpf_map_ctx_update_elem_proto;
>  extern const struct bpf_func_proto bpf_map_delete_elem_proto;
>
>  extern const struct bpf_func_proto bpf_get_prandom_u32_proto;
> diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
> index b1e1035..930be52 100644
> --- a/include/linux/bpf_types.h
> +++ b/include/linux/bpf_types.h
> @@ -37,4 +37,5 @@
>  BPF_MAP_TYPE(BPF_MAP_TYPE_HASH_OF_MAPS, htab_of_maps_map_ops)
>  #ifdef CONFIG_NET
>  BPF_MAP_TYPE(BPF_MAP_TYPE_DEVMAP, dev_map_ops)
> +BPF_MAP_TYPE(BPF_MAP_TYPE_SOCKMAP, sock_map_ops)
>  #endif
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 1106a8c..a89e831 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -105,6 +105,7 @@ enum bpf_map_type {
>         BPF_MAP_TYPE_ARRAY_OF_MAPS,
>         BPF_MAP_TYPE_HASH_OF_MAPS,
>         BPF_MAP_TYPE_DEVMAP,
> +       BPF_MAP_TYPE_SOCKMAP,
>  };
>
>  enum bpf_prog_type {
> @@ -129,6 +130,7 @@ enum bpf_attach_type {
>         BPF_CGROUP_INET_EGRESS,
>         BPF_CGROUP_INET_SOCK_CREATE,
>         BPF_CGROUP_SOCK_OPS,
> +       BPF_SOCKMAP_INGRESS,
>         __MAX_BPF_ATTACH_TYPE
>  };
>
> @@ -205,6 +207,7 @@ enum bpf_attach_type {
>                 __u32           attach_bpf_fd;  /* eBPF program to attach */
>                 __u32           attach_type;
>                 __u32           attach_flags;
> +               __u32           attach_bpf_fd2;
>         };
>
>         struct { /* anonymous struct used by BPF_PROG_TEST_RUN command */
> @@ -598,7 +601,9 @@ enum bpf_attach_type {
>         FN(set_hash),                   \
>         FN(setsockopt),                 \
>         FN(skb_adjust_room),            \
> -       FN(redirect_map),
> +       FN(redirect_map),               \
> +       FN(sk_redirect_map),            \
> +       FN(map_ctx_update_elem),        \
>
>  /* integer value in 'imm' field of BPF_CALL instruction selects which helper
>   * function eBPF program intends to call
> @@ -735,6 +740,12 @@ struct xdp_md {
>         __u32 data_end;
>  };
>
> +enum sk_action {
> +       SK_ABORTED = 0,
> +       SK_DROP,
> +       SK_REDIRECT,
> +};
> +
>  #define BPF_TAG_SIZE   8
>
>  struct bpf_prog_info {
> diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
> index 48e9270..3089102 100644
> --- a/kernel/bpf/Makefile
> +++ b/kernel/bpf/Makefile
> @@ -3,7 +3,7 @@ obj-y := core.o
>  obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
>  obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o map_in_map.o
>  ifeq ($(CONFIG_NET),y)
> -obj-$(CONFIG_BPF_SYSCALL) += devmap.o
> +obj-$(CONFIG_BPF_SYSCALL) += devmap.o sockmap.o
>  endif
>  ifeq ($(CONFIG_PERF_EVENTS),y)
>  obj-$(CONFIG_BPF_SYSCALL) += stackmap.o
> diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
> index 3d24e23..feb38e0 100644
> --- a/kernel/bpf/helpers.c
> +++ b/kernel/bpf/helpers.c
> @@ -43,6 +43,26 @@
>         .arg2_type      = ARG_PTR_TO_MAP_KEY,
>  };
>
> +BPF_CALL_5(bpf_ctx_map_update_elem, struct bpf_sock_ops_kern *, bpf_sock,
> +          struct bpf_map *, map, void *, key, u64, flags, u64, map_flags)
> +{
> +       WARN_ON_ONCE(!rcu_read_lock_held());
> +       return map->ops->map_ctx_update_elem(bpf_sock, map, key,
> +                                            flags, map_flags);
> +}
> +
> +const struct bpf_func_proto bpf_map_ctx_update_elem_proto = {
> +       .func           = bpf_ctx_map_update_elem,
> +       .gpl_only       = false,
> +       .pkt_access     = true,
> +       .ret_type       = RET_INTEGER,
> +       .arg1_type      = ARG_PTR_TO_CTX,
> +       .arg2_type      = ARG_CONST_MAP_PTR,
> +       .arg3_type      = ARG_PTR_TO_MAP_KEY,
> +       .arg4_type      = ARG_ANYTHING,
> +       .arg5_type      = ARG_ANYTHING,
> +};
> +
>  BPF_CALL_4(bpf_map_update_elem, struct bpf_map *, map, void *, key,
>            void *, value, u64, flags)
>  {
> diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
> new file mode 100644
> index 0000000..9e88c32
> --- /dev/null
> +++ b/kernel/bpf/sockmap.c
> @@ -0,0 +1,623 @@
> +/* Copyright (c) 2017 Covalent IO, Inc. http://covalent.io
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + */
> +
> +/* A BPF sock_map is used to store sock objects. This is primarly used
> + * for doing socket redirect with BPF helper routines.
> + *
> + * A sock map may have two BPF programs attached to it, a program used
> + * to parse packets and a program to provide a verdict and redirect
> + * decision on the packet. If no BPF parse program is provided it is
> + * assumed that every skb is a "message" (skb->len). Otherwise the
> + * parse program is attached to strparser and used to build messages
> + * that may span multiple skbs. The verdict program will either select
> + * a socket to send/receive the skb on or provide the drop code indicating
> + * the skb should be dropped. More actions may be added later as needed.
> + * The default program will drop packets.
> + *
> + * For reference this program is similar to devmap used in XDP context
> + * reviewing these together may be useful. For a set of examples and
> + * test codes using this map please review ./samples/bpf/sockmap/ here
> + * you can find common usages such as a socket level load balancer and
> + * cgroup integration.
> + */
> +#include <linux/bpf.h>
> +#include <linux/jhash.h>
> +#include <linux/filter.h>
> +#include <net/sock.h>
> +#include <linux/rculist_nulls.h>
> +#include "percpu_freelist.h"
> +#include "bpf_lru_list.h"
> +#include "map_in_map.h"
> +
> +#include <linux/errno.h>
> +#include <linux/file.h>
> +#include <linux/in.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/net.h>
> +#include <linux/rculist.h>
> +#include <linux/skbuff.h>
> +#include <linux/socket.h>
> +#include <linux/workqueue.h>
> +#include <linux/list.h>
> +#include <linux/bpf.h>
> +#include <net/strparser.h>
> +#include <net/netns/generic.h>
> +#include <net/sock.h>
> +
> +struct bpf_stab {
> +       struct bpf_map map;
> +       struct sock **sock_map;
> +       struct bpf_prog *bpf_parse;
> +       struct bpf_prog *bpf_mux;
> +};
> +
> +struct smap_psock {
> +       struct rcu_head rcu;
> +
> +       /* datapath variables used under sock lock */
> +       struct sk_buff_head rxqueue;
> +
> +       bool strp_enabled;
> +
> +       /* datapath error path cache across tx work invocations */
> +       int save_rem;
> +       int save_off;
> +       struct sk_buff *save_skb;
> +       u32 tx_stopped : 1;
> +
> +       struct strparser strp;
> +       struct bpf_prog *bpf_parse;
> +       struct bpf_prog *bpf_mux;
> +       struct bpf_map *map;
> +
> +       /* Back reference to the file descriptor of the sock */
> +       int key;
> +       struct sock *sock;
> +
> +       struct work_struct tx_work;
> +
> +       void (*save_data_ready)(struct sock *sk);
> +       void (*save_write_space)(struct sock *sk);
> +       void (*save_state_change)(struct sock *sk);
> +};
> +
> +static inline struct smap_psock *smap_psock_sk(const struct sock *sk)
> +{
> +       return (struct smap_psock *)sk->sk_user_data;
> +}
> +
> +static int smap_mux_func(struct smap_psock *psock, struct sk_buff *skb)
> +{
> +       struct bpf_prog *prog = psock->bpf_mux;
> +       int rc;
> +
> +       if (unlikely(!prog))
> +               return 0;
> +
> +       skb->sk = psock->sock;
> +       rc = (*prog->bpf_func)(skb, prog->insnsi);
> +       skb->sk = NULL;
> +
> +       return rc;
> +}
> +
> +static struct smap_psock *smap_peers_get(struct smap_psock *psock,
> +                                            struct sk_buff *skb)
> +{
> +       struct sock *sock;
> +       int rc;
> +
> +       rc = smap_mux_func(psock, skb);
> +       if (unlikely(rc < 0))
> +               return NULL;
> +
> +       sock = do_sk_redirect_map();
> +       if (unlikely(!sock))
> +               return NULL;
> +
> +       return smap_psock_sk(sock);
> +}
> +
> +static void smap_report_sk_error(struct smap_psock *psock, int err)
> +{
> +       struct sock *sk = psock->sock;
> +
> +       sk->sk_err = err;
> +       sk->sk_error_report(sk);
> +}
> +
> +static int sock_map_delete_elem(struct bpf_map *map, void *key);
> +
> +static void smap_state_change(struct sock *sk)
> +{
> +       struct smap_psock *psock = smap_psock_sk(sk);
> +
> +       /* Allowing transitions into established an syn_recv states allows
> +        * for early binding sockets to a smap object before the connection
> +        * is established. All other transitions indicate the connection is
> +        * being torn down so tear down the smap socket.
> +        */
> +       switch (sk->sk_state) {
> +       case TCP_SYN_RECV:
> +       case TCP_ESTABLISHED:
> +               break;
> +       case TCP_CLOSE_WAIT:
> +       case TCP_CLOSING:
> +       case TCP_LAST_ACK:
> +       case TCP_FIN_WAIT1:
> +       case TCP_FIN_WAIT2:
> +       case TCP_LISTEN:
> +               break;
> +       case TCP_CLOSE:
> +               sock_map_delete_elem(psock->map, &psock->key);
> +               break;
> +       default:
> +               smap_report_sk_error(psock, EPIPE);
> +               break;
> +       }
> +}
> +
> +static void smap_tx_work(struct work_struct *w);
> +
> +void schedule_writer(struct smap_psock *psock)
> +{
> +       schedule_work(&psock->tx_work);
> +}
> +
> +static int smap_tx_writer(struct smap_psock *peer)
> +{
> +       schedule_writer(peer);
> +       return 0;
> +}
> +
> +static void smap_read_sock_strparser(struct strparser *strp,
> +                                    struct sk_buff *skb)
> +{
> +       struct smap_psock *psock = container_of(strp,
> +                                                 struct smap_psock, strp);
> +       struct smap_psock *peer;
> +
> +       /* TBD useful dbg, add trace here with output sock index or drop */
> +       rcu_read_lock();
> +       peer = smap_peers_get(psock, skb);
> +       if (unlikely(!peer)) {
> +               kfree_skb(skb);
> +               goto out;
> +       }
> +
> +       skb_queue_tail(&peer->rxqueue, skb);
> +       smap_tx_writer(peer);
> +out:
> +       rcu_read_unlock();
> +}
> +
> +/* Called with lock held on socket */
> +static void smap_data_ready(struct sock *sk)
> +{
> +       struct smap_psock *psock;
> +
> +       read_lock_bh(&sk->sk_callback_lock);
> +
> +       psock = smap_psock_sk(sk);
> +       if (likely(psock))
> +               strp_data_ready(&psock->strp);
> +
> +       read_unlock_bh(&sk->sk_callback_lock);
> +}
> +
> +static void smap_tx_work(struct work_struct *w)
> +{
> +       struct smap_psock *psock;
> +       struct sk_buff *skb;
> +       int rem, off, n;
> +
> +       psock = container_of(w, struct smap_psock, tx_work);
> +       if (unlikely(psock->tx_stopped))
> +               return;
> +
> +       if (psock->save_skb) {
> +               skb = psock->save_skb;
> +               rem = psock->save_rem;
> +               off = psock->save_off;
> +               psock->save_skb = NULL;
> +               goto start;
> +       }
> +
> +       while ((skb = skb_dequeue(&psock->rxqueue))) {
> +               rem = skb->len;
> +               off = 0;
> +start:
> +               do {
> +                       n = skb_send_sock(psock->sock, skb, off, rem);
> +                       if (n <= 0) {
> +                               if (n == -EAGAIN) {
> +                                       /* Save state to try again when
> +                                        * there's write space on the
> +                                        * socket.
> +                                        */
> +                                       psock->save_skb = skb;
> +                                       psock->save_rem = rem;
> +                                       psock->save_off = off;
> +                                       break;
> +                               }
> +
> +                               /* Got a hard error or socket had
> +                                * been closed somehow. Report this
> +                                * on the transport socket.
> +                                */
> +                               smap_report_sk_error(psock, n ? -n : EPIPE);
> +                               psock->tx_stopped = 1;
> +                               break;
> +                       }
> +                       rem -= n;
> +                       off += n;
> +               } while (rem);
> +       }
> +}
> +
> +static void smap_write_space(struct sock *sk)
> +{
> +       struct smap_psock *psock = smap_psock_sk(sk);
> +
> +       schedule_writer(psock);
> +}
> +
> +static void smap_stop_sock(struct smap_psock *psock, bool destroy)
> +{
> +       struct sock *sk = psock->sock;
> +
> +       write_lock_bh(&sk->sk_callback_lock);
> +       if (psock->strp_enabled) {
> +               sk->sk_data_ready = psock->save_data_ready;
> +               sk->sk_write_space = psock->save_write_space;
> +               sk->sk_state_change = psock->save_state_change;
> +               strp_stop(&psock->strp);
> +       }
> +
> +       if (destroy)
> +               sk->sk_user_data = NULL;
> +       write_unlock_bh(&sk->sk_callback_lock);
> +
> +       if (psock->strp_enabled)
> +               strp_done(&psock->strp);
> +       psock->strp_enabled = false;
> +}
> +
> +static void smap_destroy_psock(struct rcu_head *rcu)
> +{
> +       struct smap_psock *psock = container_of(rcu,
> +                                                 struct smap_psock, rcu);
> +
> +       smap_stop_sock(psock, true);
> +       cancel_work_sync(&psock->tx_work);
> +       __skb_queue_purge(&psock->rxqueue);
> +       sock_put(psock->sock);
> +       kfree(psock);
> +}
> +
> +static void smap_release_proxy(struct sock *sock)
> +{
> +       struct smap_psock *psock = smap_psock_sk(sock);
> +
> +       call_rcu(&psock->rcu, smap_destroy_psock);
> +}
> +
> +static int smap_parse_func_strparser(struct strparser *strp,
> +                                      struct sk_buff *skb)
> +{
> +       struct smap_psock *psock = container_of(strp,
> +                                                 struct smap_psock, strp);
> +       struct bpf_prog *prog = psock->bpf_parse;
> +
> +       if (unlikely(!prog))
> +               return skb->len;
> +
> +       return (*prog->bpf_func)(skb, prog->insnsi);
> +}
> +
> +
> +static int smap_read_sock_done(struct strparser *strp, int err)
> +{
> +       return err;
> +}
> +
> +static int smap_init_sock(struct smap_psock *psock,
> +                         struct sock *sock)
> +{
> +       struct strp_callbacks cb;
> +       int err;
> +
> +       cb.rcv_msg = smap_read_sock_strparser;
> +       cb.abort_parser = NULL;
> +       cb.parse_msg = smap_parse_func_strparser;
> +       cb.read_sock_done = smap_read_sock_done;
> +
> +       err = strp_init(&psock->strp, sock, &cb);
> +       if (err)
> +               return -EINVAL;
> +       return 0;
> +}
> +
> +static void smap_init_progs(struct smap_psock *psock, struct bpf_stab *stab)
> +{
> +       /* TBD need prog_put and gets here to avoid programs leaving
> +        * us or something in attach
> +        */
> +       if (psock->bpf_mux != stab->bpf_mux)
> +               psock->bpf_mux = stab->bpf_mux;
> +
> +       if (psock->bpf_parse != stab->bpf_parse)
> +               psock->bpf_parse = stab->bpf_parse;
> +}
> +
> +static int smap_start_sock(struct smap_psock *psock, struct sock *sk)
> +{
> +       int err = 0;
> +
> +       write_lock_bh(&sk->sk_callback_lock);
> +       /* only start socket if it is not already running */
> +       if (psock->save_data_ready) {
> +               err = -EINVAL;
> +               goto out;
> +       }
> +       psock->save_data_ready = sk->sk_data_ready;
> +       psock->save_write_space = sk->sk_write_space;
> +       psock->save_state_change = sk->sk_state_change;
> +       sk->sk_data_ready = smap_data_ready;
> +       sk->sk_write_space = smap_write_space;
> +       sk->sk_state_change = smap_state_change;
> +out:
> +       write_unlock_bh(&sk->sk_callback_lock);
> +       return err;
> +}
> +
> +static struct smap_psock *smap_init_psock(struct sock *sock,
> +                                         struct bpf_stab *stab)
> +{
> +       struct smap_psock *psock;
> +
> +       psock = kmalloc(sizeof(struct smap_psock), GFP_ATOMIC);
> +       if (!psock)
> +               return ERR_PTR(-ENOMEM);
> +
> +       memset(psock, 0, sizeof(struct smap_psock));
> +       smap_init_progs(psock, stab);
> +       psock->sock = sock;
> +
> +       skb_queue_head_init(&psock->rxqueue);
> +       INIT_WORK(&psock->tx_work, smap_tx_work);
> +
> +       write_lock_bh(&sock->sk_callback_lock);
> +       sock->sk_user_data = psock;
> +       write_unlock_bh(&sock->sk_callback_lock);
> +
> +       sock_hold(sock);
> +       return psock;
> +}
> +
> +#define SOCK_MAP_STRPARSER 0x01
> +/* BPF map logic */
> +static struct bpf_map *sock_map_alloc(union bpf_attr *attr)
> +{
> +       struct bpf_stab *stab;
> +       int err = -EINVAL;
> +       u64 cost;
> +
> +       /* check sanity of attributes */
> +       if (attr->max_entries == 0 || attr->key_size != 4 ||
> +           attr->value_size != 4 || attr->map_flags)
> +               return ERR_PTR(-EINVAL);
> +
> +       /* if value_size is bigger, the user space won't be able to
> +        * access the elements.
> +        */
> +       if (attr->value_size > KMALLOC_MAX_SIZE)
> +               return ERR_PTR(-E2BIG);
> +
> +       stab = kzalloc(sizeof(*stab), GFP_USER);
> +       if (!stab)
> +               return ERR_PTR(-ENOMEM);
> +
> +       /* mandatory map attributes */
> +       stab->map.map_type = attr->map_type;
> +       stab->map.key_size = attr->key_size;
> +       stab->map.value_size = attr->value_size;
> +       stab->map.max_entries = attr->max_entries;
> +       stab->map.map_flags = attr->map_flags;
> +
> +
> +       /* make sure page count doesn't overflow */
> +       cost = (u64) stab->map.max_entries * sizeof(struct sock *) +
> +                       sizeof(struct socket *);
> +       stab->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
> +
> +       err = -ENOMEM;
> +
> +       /* if map size is larger than memlock limit, reject it early */
> +       err = bpf_map_precharge_memlock(stab->map.pages);
> +       if (err)
> +               goto free_stab;
> +
> +       stab->sock_map = bpf_map_area_alloc(stab->map.max_entries *
> +                                           sizeof(struct sock *));
> +       if (!stab->sock_map)
> +               goto free_stab;
> +
> +       return &stab->map;
> +       /* TBD release progs on errors */
> +free_stab:
> +       kfree(stab);
> +       return ERR_PTR(err);
> +}
> +
> +static void sock_map_free(struct bpf_map *map)
> +{
> +       struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
> +       int i;
> +
> +       synchronize_rcu();
> +
> +       for (i = 0; i < stab->map.max_entries; i++) {
> +               struct sock *sock;
> +
> +               sock = stab->sock_map[i];
> +               if (!sock)
> +                       continue;
> +
> +               smap_release_proxy(sock);
> +       }
> +
> +       bpf_map_area_free(stab->sock_map);
> +       if (stab->bpf_mux)
> +               bpf_prog_put(stab->bpf_mux);
> +       if (stab->bpf_parse)
> +               bpf_prog_put(stab->bpf_mux);
> +       kfree(stab);
> +}
> +
> +static int sock_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
> +{
> +       struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
> +       u32 i = key ? *(u32 *)key : U32_MAX;
> +       u32 *next = (u32 *)next_key;
> +
> +       if (i >= stab->map.max_entries) {
> +               *next = 0;
> +               return 0;
> +       }
> +
> +       if (i == stab->map.max_entries - 1)
> +               return -ENOENT;
> +
> +       *next = i + 1;
> +       return 0;
> +}
> +
> +struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key)
> +{
> +       struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
> +
> +       if (key >= map->max_entries)
> +               return NULL;
> +
> +       return stab->sock_map[key];
> +}
> +
> +static void *sock_map_lookup_elem(struct bpf_map *map, void *key)
> +{
> +       struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
> +       struct sock *sock;
> +       u32 i = *(u32 *)key;
> +
> +       if (i >= map->max_entries)
> +               return NULL;
> +
> +       sock = stab->sock_map[i];
> +       return NULL;
> +}
> +
> +static int sock_map_delete_elem(struct bpf_map *map, void *key)
> +{
> +       struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
> +       struct sock *sock;
> +       int k = *(u32 *)key;
> +
> +       if (k >= map->max_entries)
> +               return -EINVAL;
> +
> +       sock = stab->sock_map[k];
> +       if (!sock)
> +               return -EINVAL;
> +
> +       smap_release_proxy(sock);
> +       return 0;
> +}
> +
> +static int sock_map_update_elem(struct bpf_sock_ops_kern *skops,
> +                               struct bpf_map *map,
> +                               void *key, u64 flags, u64 map_flags)
> +{
> +       struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
> +       struct sock *old_sock, *sock;
> +       struct smap_psock *psock = NULL;
> +       u32 i = *(u32 *)key;
> +       bool update = false;
> +
> +       if (unlikely(flags > BPF_EXIST))
> +               return -EINVAL;
> +
> +       if (unlikely(i >= stab->map.max_entries))
> +               return -E2BIG;
> +
> +       if (unlikely(map_flags > SOCK_MAP_STRPARSER))
> +               return -EINVAL;
> +
> +       if (flags == BPF_EXIST || flags == BPF_ANY) {
> +               sock = rcu_dereference(stab->sock_map[i]);
> +
> +               if (!sock && flags == BPF_EXIST) {
> +                       return -ENOENT;
> +               } else if (sock && sock != skops->sk) {
> +                       return -EINVAL;
> +               } else if (sock) {
> +                       psock = smap_psock_sk(sock);
> +                       update = true;
> +               }
> +       }
> +
> +       if (!psock) {
> +               sock = skops->sk;
> +               psock = smap_init_psock(sock, stab);
> +               if (IS_ERR(psock))
> +                       return PTR_ERR(psock);
> +               psock->key = i;
> +               psock->map = map;
> +       }
> +
> +       if (map_flags & SOCK_MAP_STRPARSER) {
> +               smap_start_sock(psock, sock);
> +               smap_init_progs(psock, stab);
> +               smap_init_sock(psock, sock);
> +               psock->strp_enabled = true;
> +       } else if (update) {
> +               smap_stop_sock(psock, false);
> +       }
> +
> +       if (!update) {
> +               old_sock = xchg(&stab->sock_map[i], skops->sk);
> +               if (old_sock)
> +                       smap_release_proxy(old_sock);
> +       }
> +
> +       return 0;
> +}
> +
> +static int sock_map_attach_prog(struct bpf_map *map,
> +                               struct bpf_prog *parse, struct bpf_prog *mux)
> +{
> +       struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
> +
> +       stab->bpf_parse = parse;
> +       stab->bpf_mux = mux;
> +       return 0;
> +}
> +
> +const struct bpf_map_ops sock_map_ops = {
> +       .map_alloc = sock_map_alloc,
> +       .map_free = sock_map_free,
> +       .map_get_next_key = sock_map_get_next_key,
> +       .map_lookup_elem = sock_map_lookup_elem,
> +       .map_ctx_update_elem = sock_map_update_elem,
> +       .map_delete_elem = sock_map_delete_elem,
> +       .map_attach = sock_map_attach_prog,
> +};
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 6c772ad..e4f48f5 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -1045,7 +1045,40 @@ static int bpf_obj_get(const union bpf_attr *attr)
>
>  #ifdef CONFIG_CGROUP_BPF
>
> -#define BPF_PROG_ATTACH_LAST_FIELD attach_flags
> +#define BPF_PROG_ATTACH_LAST_FIELD attach_bpf_fd2
> +
> +static int sockmap_get_from_fd(const union bpf_attr *attr, int ptype)
> +{
> +       struct bpf_prog *prog1, *prog2;
> +       struct bpf_map *map;
> +       int err;
> +
> +       map = bpf_map_get_with_uref(attr->target_fd);
> +       if (IS_ERR(map))
> +               return PTR_ERR(map);
> +
> +       if (!map->ops->map_attach)
> +               return -EOPNOTSUPP;
> +
> +       prog1 = bpf_prog_get_type(attr->attach_bpf_fd, ptype);
> +       if (IS_ERR(prog1))
> +               return PTR_ERR(prog1);
> +
> +       prog2 = bpf_prog_get_type(attr->attach_bpf_fd2, ptype);
> +       if (IS_ERR(prog2)) {
> +               bpf_prog_put(prog1);
> +               return PTR_ERR(prog2);
> +       }
> +
> +       err = map->ops->map_attach(map, prog1, prog2);
> +       if (err) {
> +               bpf_prog_put(prog1);
> +               bpf_prog_put(prog2);
> +               return PTR_ERR(map);
> +       }
> +
> +       return err;
> +}
>
>  static int bpf_prog_attach(const union bpf_attr *attr)
>  {
> @@ -1074,10 +1107,16 @@ static int bpf_prog_attach(const union bpf_attr *attr)
>         case BPF_CGROUP_SOCK_OPS:
>                 ptype = BPF_PROG_TYPE_SOCK_OPS;
>                 break;
> +       case BPF_SOCKMAP_INGRESS:
> +               ptype = BPF_PROG_TYPE_SOCKET_FILTER;
> +               break;
>         default:
>                 return -EINVAL;
>         }
>
> +       if (attr->attach_type == BPF_SOCKMAP_INGRESS)
> +               return sockmap_get_from_fd(attr, ptype);
> +
>         prog = bpf_prog_get_type(attr->attach_bpf_fd, ptype);
>         if (IS_ERR(prog))
>                 return PTR_ERR(prog);
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 7e97086..2644f2d 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1845,6 +1845,51 @@ int skb_do_redirect(struct sk_buff *skb)
>         .arg3_type      = ARG_ANYTHING,
>  };
>
> +BPF_CALL_3(bpf_sk_redirect_map, struct bpf_map *, map, u32, key, u64, flags)
> +{
> +       struct redirect_info *ri = this_cpu_ptr(&redirect_info);
> +
> +       ri->ifindex = key;
> +       ri->flags = flags;
> +       ri->map = map;
> +
> +       return SK_REDIRECT;
> +}
> +
> +inline struct sock *do_sk_redirect_map(void)
> +{
> +       struct redirect_info *ri = this_cpu_ptr(&redirect_info);
> +       struct sock *sk = NULL;
> +
> +       if (ri->map) {
> +               sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
> +
> +               ri->ifindex = 0;
> +               ri->map = NULL;
> +               /* we do not clear flags for future lookup */
> +       }
> +
> +       return sk;
> +}
> +EXPORT_SYMBOL(do_sk_redirect_map);
> +
> +inline u64 get_sk_redirect_flags(void)
> +{
> +       struct redirect_info *ri = this_cpu_ptr(&redirect_info);
> +
> +       return ri->flags;
> +}
> +EXPORT_SYMBOL(get_sk_redirect_flags);
> +
> +static const struct bpf_func_proto bpf_sk_redirect_map_proto = {
> +       .func           = bpf_sk_redirect_map,
> +       .gpl_only       = false,
> +       .ret_type       = RET_INTEGER,
> +       .arg1_type      = ARG_CONST_MAP_PTR,
> +       .arg2_type      = ARG_ANYTHING,
> +       .arg3_type      = ARG_ANYTHING,
> +};
> +
>  BPF_CALL_1(bpf_get_cgroup_classid, const struct sk_buff *, skb)
>  {
>         return task_get_classid(skb);
> @@ -3090,6 +3135,10 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
>                 return &bpf_get_socket_cookie_proto;
>         case BPF_FUNC_get_socket_uid:
>                 return &bpf_get_socket_uid_proto;
> +       case BPF_FUNC_sk_redirect_map:
> +               return &bpf_sk_redirect_map_proto;
> +       case BPF_FUNC_map_ctx_update_elem:
> +               return &bpf_map_ctx_update_elem_proto;
>         default:
>                 return bpf_base_func_proto(func_id);
>         }
> @@ -3214,6 +3263,8 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
>         switch (func_id) {
>         case BPF_FUNC_setsockopt:
>                 return &bpf_setsockopt_proto;
> +       case BPF_FUNC_map_ctx_update_elem:
> +               return &bpf_map_ctx_update_elem_proto;
>         default:
>                 return bpf_base_func_proto(func_id);
>         }
>
