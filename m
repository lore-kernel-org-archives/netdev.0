From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Thu, 6 May 2010 07:45:40 -0700
Message-ID: <AANLkTikd6xej_qA7IHVucmDdjR4Wo-7AoGsQiSi-sdWQ@mail.gmail.com>
References: <1271775421.7895.19.camel@edumazet-laptop>
	 <20100420.144106.118596093.davem@davemloft.net>
	 <g2m65634d661004211212t13714cccyd27936c520515684@mail.gmail.com>
	 <20100506.010651.173849727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, franco@lastsummer.de, xiaosuo@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:31226 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333Ab0EFOpp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 10:45:45 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o46EjgH7025885
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 07:45:43 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by kpbe12.cbf.corp.google.com with ESMTP id o46EjfJe006951
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 07:45:41 -0700
Received: by pva18 with SMTP id 18so14808pva.19
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 07:45:41 -0700 (PDT)
In-Reply-To: <20100506.010651.173849727.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 6, 2010 at 1:06 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 21 Apr 2010 12:12:41 -0700
>
>> On Tue, Apr 20, 2010 at 2:41 PM, David Miller <davem@davemloft.net> =
wrote:
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Tue, 20 Apr 2010 16:57:01 +0200
>>>
>>>> I know many applications using TCP on loopback, they are real :)
>>>
>>> This is all true and I support your hashing patch and all of that.
>>>
>>> But if we really want TCP over loopback to go fast, there are much
>>> better ways to do this.
>>>
>>> Eric, do you remember that "TCP friends" rough patch I sent you las=
t
>>> year that essentailly made TCP sockets over loopback behave like
>>> AF_UNIX ones and just queue the SKBs directly to the destination
>>> socket without doing any protocol work?
>>>
>> This is sounds very interesting! =A0Could you post a patch? :-)
>
> I was finally able to unearth a copy, it's completely raw, it's at le=
ast
> a year old, and it's not fully implemented at all.
>
> But you asked for it :-)
>
Thanks!  We'll take a look... I've always thought sockets should have
friends :-)

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 299ec4b..7f855d3 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -206,6 +206,7 @@ typedef unsigned char *sk_buff_data_t;
> =A0* =A0 =A0 @mac_header: Link layer header
> =A0* =A0 =A0 @dst: destination entry
> =A0* =A0 =A0 @sp: the security path, used for xfrm
> + * =A0 =A0 @friend: loopback friend socket
> =A0* =A0 =A0 @cb: Control buffer. Free for use by every layer. Put pr=
ivate vars here
> =A0* =A0 =A0 @len: Length of actual data
> =A0* =A0 =A0 @data_len: Data length
> @@ -262,6 +263,7 @@ struct sk_buff {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct =A0rtable =A0 =A0 =A0 =A0 =A0*r=
table;
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0struct =A0sec_path =A0 =A0 =A0 =A0*sp;
> + =A0 =A0 =A0 struct sock =A0 =A0 =A0 =A0 =A0 =A0 *friend;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * This is the control buffer. It is free to use for e=
very
> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
> index b220b5f..52b2f7a 100644
> --- a/include/net/request_sock.h
> +++ b/include/net/request_sock.h
> @@ -53,6 +53,7 @@ struct request_sock {
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 expi=
res;
> =A0 =A0 =A0 =A0const struct request_sock_ops =A0 *rsk_ops;
> =A0 =A0 =A0 =A0struct sock =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *s=
k;
> + =A0 =A0 =A0 struct sock =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *fr=
iend;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 secid;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 peer_secid;
> =A0};
> diff --git a/include/net/sock.h b/include/net/sock.h
> index dc42b44..3e86190 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -137,6 +137,7 @@ struct sock_common {
> =A0 * =A0 =A0@sk_userlocks: %SO_SNDBUF and %SO_RCVBUF settings
> =A0 * =A0 =A0@sk_lock: =A0 =A0 =A0 synchronizer
> =A0 * =A0 =A0@sk_rcvbuf: size of receive buffer in bytes
> + =A0* =A0 =A0@sk_friend: loopback friend socket
> =A0 * =A0 =A0@sk_sleep: sock wait queue
> =A0 * =A0 =A0@sk_dst_cache: destination cache
> =A0 * =A0 =A0@sk_dst_lock: destination cache lock
> @@ -227,6 +228,7 @@ struct sock {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *head;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *tail;
> =A0 =A0 =A0 =A0} sk_backlog;
> + =A0 =A0 =A0 struct sock =A0 =A0 =A0 =A0 =A0 =A0 *sk_friend;
> =A0 =A0 =A0 =A0wait_queue_head_t =A0 =A0 =A0 *sk_sleep;
> =A0 =A0 =A0 =A0struct dst_entry =A0 =A0 =A0 =A0*sk_dst_cache;
> =A0 =A0 =A0 =A0struct xfrm_policy =A0 =A0 =A0*sk_policy[2];
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 4fe605f..0eef90a 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -435,6 +435,7 @@ static void __copy_skb_header(struct sk_buff *new=
, const struct sk_buff *old)
> =A0#ifdef CONFIG_INET
> =A0 =A0 =A0 =A0new->sp =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D secpath_ge=
t(old->sp);
> =A0#endif
> + =A0 =A0 =A0 new->friend =A0 =A0 =A0 =A0 =A0 =A0 =3D old->friend;
> =A0 =A0 =A0 =A0memcpy(new->cb, old->cb, sizeof(old->cb));
> =A0 =A0 =A0 =A0new->csum_start =A0 =A0 =A0 =A0 =3D old->csum_start;
> =A0 =A0 =A0 =A0new->csum_offset =A0 =A0 =A0 =A0=3D old->csum_offset;
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index 828ea21..375dc2e 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -503,6 +503,8 @@ struct sock *inet_csk_clone(struct sock *sk, cons=
t struct request_sock *req,
> =A0 =A0 =A0 =A0if (newsk !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct inet_connection_sock *newicsk =3D=
 inet_csk(newsk);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 newsk->sk_friend =3D req->friend;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0newsk->sk_state =3D TCP_SYN_RECV;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0newicsk->icsk_bind_hash =3D NULL;
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 58ac838..042ee1d 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -474,7 +474,8 @@ static inline int forced_push(struct tcp_sock *tp=
)
> =A0 =A0 =A0 =A0return after(tp->write_seq, tp->pushed_seq + (tp->max_=
window >> 1));
> =A0}
>
> -static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
> +static inline void skb_entail(struct sock *sk, struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_b=
uff_head *friend_queue)
> =A0{
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> =A0 =A0 =A0 =A0struct tcp_skb_cb *tcb =3D TCP_SKB_CB(skb);
> @@ -484,7 +485,10 @@ static inline void skb_entail(struct sock *sk, s=
truct sk_buff *skb)
> =A0 =A0 =A0 =A0tcb->flags =A0 =3D TCPCB_FLAG_ACK;
> =A0 =A0 =A0 =A0tcb->sacked =A0=3D 0;
> =A0 =A0 =A0 =A0skb_header_release(skb);
> - =A0 =A0 =A0 tcp_add_write_queue_tail(sk, skb);
> + =A0 =A0 =A0 if (sk->sk_friend)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __skb_queue_tail(friend_queue, skb);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_add_write_queue_tail(sk, skb);
> =A0 =A0 =A0 =A0sk->sk_wmem_queued +=3D skb->truesize;
> =A0 =A0 =A0 =A0sk_mem_charge(sk, skb->truesize);
> =A0 =A0 =A0 =A0if (tp->nonagle & TCP_NAGLE_PUSH)
> @@ -501,7 +505,7 @@ static inline void tcp_mark_urg(struct tcp_sock *=
tp, int flags,
> =A0}
>
> =A0static inline void tcp_push(struct sock *sk, int flags, int mss_no=
w,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nonagle)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nonagle, st=
ruct sk_buff_head *friend_queue)
> =A0{
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
>
> @@ -512,6 +516,19 @@ static inline void tcp_push(struct sock *sk, int=
 flags, int mss_now,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_mark_urg(tp, flags, skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__tcp_push_pending_frames(sk, mss_now,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0(flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
> + =A0 =A0 =A0 } else if (sk->sk_friend) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sock *friend =3D sk->sk_friend;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int len;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_bh(&friend->sk_lock.slock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while ((skb =3D __skb_dequeue(friend_qu=
eue)) !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __skb_queue_tail(&sk->s=
k_receive_queue, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_data_ready(friend, len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_bh(&friend->sk_lock.slock);
> =A0 =A0 =A0 =A0}
> =A0}
>
> @@ -658,6 +675,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, =
struct page **pages, int poffse
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t psize, int fla=
gs)
> =A0{
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> + =A0 =A0 =A0 struct sk_buff_head friend_queue;
> =A0 =A0 =A0 =A0int mss_now, size_goal;
> =A0 =A0 =A0 =A0int err;
> =A0 =A0 =A0 =A0ssize_t copied;
> @@ -674,6 +692,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, =
struct page **pages, int poffse
> =A0 =A0 =A0 =A0size_goal =3D tp->xmit_size_goal;
> =A0 =A0 =A0 =A0copied =3D 0;
>
> + =A0 =A0 =A0 skb_queue_head_init(&friend_queue);
> +
> =A0 =A0 =A0 =A0err =3D -EPIPE;
> =A0 =A0 =A0 =A0if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto do_error;
> @@ -694,7 +714,7 @@ new_segment:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto w=
ait_for_memory;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_entail(sk, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_entail(sk, skb, &fr=
iend_queue);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0copy =3D size_goal;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> @@ -749,7 +769,8 @@ wait_for_sndbuf:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(SOCK_NOSPACE, &sk->sk_socket->=
flags);
> =A0wait_for_memory:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (copied)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_push(sk, flags & ~M=
SG_MORE, mss_now, TCP_NAGLE_PUSH);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_push(sk, flags & ~M=
SG_MORE, mss_now, TCP_NAGLE_PUSH,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&fri=
end_queue);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((err =3D sk_stream_wait_memory(sk,=
 &timeo)) !=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto do_error;
> @@ -760,7 +781,7 @@ wait_for_memory:
>
> =A0out:
> =A0 =A0 =A0 =A0if (copied)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_push(sk, flags, mss_now, tp->nonagl=
e);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_push(sk, flags, mss_now, tp->nonagl=
e, &friend_queue);
> =A0 =A0 =A0 =A0return copied;
>
> =A0do_error:
> @@ -817,6 +838,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket=
 *sock, struct msghdr *msg,
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0struct iovec *iov;
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> + =A0 =A0 =A0 struct sk_buff_head friend_queue;
> =A0 =A0 =A0 =A0struct sk_buff *skb;
> =A0 =A0 =A0 =A0int iovlen, flags;
> =A0 =A0 =A0 =A0int mss_now, size_goal;
> @@ -849,6 +871,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket=
 *sock, struct msghdr *msg,
> =A0 =A0 =A0 =A0if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto do_error;
>
> + =A0 =A0 =A0 skb_queue_head_init(&friend_queue);
> =A0 =A0 =A0 =A0while (--iovlen >=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int seglen =3D iov->iov_len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned char __user *from =3D iov->io=
v_base;
> @@ -881,7 +904,7 @@ new_segment:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk=
->sk_route_caps & NETIF_F_ALL_CSUM)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0skb->ip_summed =3D CHECKSUM_PARTIAL;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_ent=
ail(sk, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_ent=
ail(sk, skb, &friend_queue);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0copy =3D=
 size_goal;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> @@ -995,7 +1018,8 @@ wait_for_sndbuf:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(SOCK_NOSPACE, =
&sk->sk_socket->flags);
> =A0wait_for_memory:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (copied)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_pus=
h(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_pus=
h(sk, flags & ~MSG_MORE, mss_now,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0TCP_NAGLE_PUSH, &friend_queue);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((err =3D sk_stream=
_wait_memory(sk, &timeo)) !=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto d=
o_error;
> @@ -1007,7 +1031,7 @@ wait_for_memory:
>
> =A0out:
> =A0 =A0 =A0 =A0if (copied)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_push(sk, flags, mss_now, tp->nonagl=
e);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_push(sk, flags, mss_now, tp->nonagl=
e, &friend_queue);
> =A0 =A0 =A0 =A0TCP_CHECK_TIMER(sk);
> =A0 =A0 =A0 =A0release_sock(sk);
> =A0 =A0 =A0 =A0return copied;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index cdc051b..eb6f914 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4998,6 +4998,7 @@ static int tcp_rcv_synsent_state_process(struct=
 sock *sk, struct sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * =A0 =A0state to ESTABLISHED..."
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_friend =3D skb->friend;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TCP_ECN_rcv_synack(tp, th);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->snd_wl1 =3D TCP_SKB_CB(skb)->seq;
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 7766151..4d91ff4 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1289,6 +1289,7 @@ int tcp_v4_conn_request(struct sock *sk, struct=
 sk_buff *skb)
> =A0 =A0 =A0 =A0if (!req)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>
> + =A0 =A0 =A0 req->friend =3D skb->friend;
> =A0#ifdef CONFIG_TCP_MD5SIG
> =A0 =A0 =A0 =A0tcp_rsk(req)->af_specific =3D &tcp_request_sock_ipv4_o=
ps;
> =A0#endif
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index debf235..a4d4c14 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -577,6 +577,7 @@ static int tcp_transmit_skb(struct sock *sk, stru=
ct sk_buff *skb, int clone_it,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->friend =3D sk;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_syn_build_options((__be32 *)(th + =
1),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0tcp_advertise_mss(sk),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0(sysctl_flags & SYSCTL_FLAG_TSTAMPS),
> @@ -1006,6 +1007,8 @@ unsigned int tcp_current_mss(struct sock *sk, i=
nt large_allowed)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xmit_size_goal =3D tcp_bound_to_half_w=
nd(tp, xmit_size_goal);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xmit_size_goal -=3D (xmit_size_goal % =
mss_now);
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 if (sk->sk_friend)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xmit_size_goal =3D ~(u16)0;
> =A0 =A0 =A0 =A0tp->xmit_size_goal =3D xmit_size_goal;
>
> =A0 =A0 =A0 =A0return mss_now;
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 715965f..c79d3ea 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1280,6 +1280,7 @@ static int tcp_v6_conn_request(struct sock *sk,=
 struct sk_buff *skb)
> =A0 =A0 =A0 =A0if (req =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>
> + =A0 =A0 =A0 req->friend =3D skb->friend;
> =A0#ifdef CONFIG_TCP_MD5SIG
> =A0 =A0 =A0 =A0tcp_rsk(req)->af_specific =3D &tcp_request_sock_ipv6_o=
ps;
> =A0#endif
>
