From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Mon, 23 Jan 2017 12:55:16 -0800
Message-ID: <CAK6E8=fb_8Nq-LHU7dPLESBdZHM4Vhc7Vw4UHQEJPcMMVkoiWw@mail.gmail.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com> <20170123185922.48046-4-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:36206 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWU4n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 15:56:43 -0500
Received: by mail-it0-f44.google.com with SMTP id c7so72398738itd.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 12:55:58 -0800 (PST)
In-Reply-To: <20170123185922.48046-4-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 10:59 AM, Wei Wang <tracywwnj@gmail.com> wrote:
> From: Wei Wang <weiwan@google.com>
>
> This patch adds a new socket option, TCP_FASTOPEN_CONNECT, as an
> alternative way to perform Fast Open on the active side (client). Prior
> to this patch, a client needs to replace the connect() call with
> sendto(MSG_FASTOPEN). This can be cumbersome for applications who want
> to use Fast Open: these socket operations are often done in lower layer
> libraries used by many other applications. Changing these libraries
> and/or the socket call sequences are not trivial. A more convenient
> approach is to perform Fast Open by simply enabling a socket option when
> the socket is created w/o changing other socket calls sequence:
>   s =3D socket()
>     create a new socket
>   setsockopt(s, IPPROTO_TCP, TCP_FASTOPEN_CONNECT =E2=80=A6);
>     newly introduced sockopt
>     If set, new functionality described below will be used.
>     Return ENOTSUPP if TFO is not supported or not enabled in the
>     kernel.
>
>   connect()
>     With cookie present, return 0 immediately.
>     With no cookie, initiate 3WHS with TFO cookie-request option and
>     return -1 with errno =3D EINPROGRESS.
>
>   write()/sendmsg()
>     With cookie present, send out SYN with data and return the number of
>     bytes buffered.
>     With no cookie, and 3WHS not yet completed, return -1 with errno =3D
>     EINPROGRESS.
>     No MSG_FASTOPEN flag is needed.
>
>   read()
>     Return -1 with errno =3D EWOULDBLOCK/EAGAIN if connect() is called bu=
t
>     write() is not called yet.
>     Return -1 with errno =3D EWOULDBLOCK/EAGAIN if connection is
>     established but no msg is received yet.
>     Return number of bytes read if socket is established and there is
>     msg received.
>
> The new API simplifies life for applications that always perform a write(=
)
> immediately after a successful connect(). Such applications can now take
> advantage of Fast Open by merely making one new setsockopt() call at the =
time
> of creating the socket. Nothing else about the application's socket call
> sequence needs to change.
>
> Signed-off-by: Wei Wang <weiwan@google.com>
> ---
Acked-by: Yuchung Cheng <ycheng@google.com>

Thanks for making this happen.

>  include/linux/tcp.h      |  3 ++-
>  include/net/inet_sock.h  |  6 +++++-
>  include/net/tcp.h        |  1 +
>  include/uapi/linux/tcp.h |  1 +
>  net/ipv4/af_inet.c       | 31 ++++++++++++++++++++++++-------
>  net/ipv4/tcp.c           | 35 ++++++++++++++++++++++++++++++++++-
>  net/ipv4/tcp_fastopen.c  | 33 +++++++++++++++++++++++++++++++++
>  net/ipv4/tcp_ipv4.c      |  7 ++++++-
>  net/ipv6/tcp_ipv6.c      |  5 +++++
>  9 files changed, 111 insertions(+), 11 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 5371b3d70cfe..f88f4649ba6f 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -222,7 +222,8 @@ struct tcp_sock {
>         u32     chrono_stat[3]; /* Time in jiffies for chrono_stat stats =
*/
>         u8      chrono_type:2,  /* current chronograph type */
>                 rate_app_limited:1,  /* rate_{delivered,interval_us} limi=
ted? */
> -               unused:5;
> +               fastopen_connect:1, /* FASTOPEN_CONNECT sockopt */
> +               unused:4;
>         u8      nonagle     : 4,/* Disable Nagle algorithm?             *=
/
>                 thin_lto    : 1,/* Use linear timeouts for thin streams *=
/
>                 unused1     : 1,
> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index c9cff977a7fb..aa95053dfc78 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -206,7 +206,11 @@ struct inet_sock {
>                                 transparent:1,
>                                 mc_all:1,
>                                 nodefrag:1;
> -       __u8                    bind_address_no_port:1;
> +       __u8                    bind_address_no_port:1,
> +                               defer_connect:1; /* Indicates that fastop=
en_connect is set
> +                                                 * and cookie exists so =
we defer connect
> +                                                 * until first data fram=
e is written
> +                                                 */
>         __u8                    rcv_tos;
>         __u8                    convert_csum;
>         int                     uc_index;
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index de67541d7adf..6ec4ea652f3f 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1495,6 +1495,7 @@ struct sock *tcp_try_fastopen(struct sock *sk, stru=
ct sk_buff *skb,
>  void tcp_fastopen_init_key_once(bool publish);
>  bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
>                              struct tcp_fastopen_cookie *cookie);
> +bool tcp_fastopen_defer_connect(struct sock *sk, int *err);
>  #define TCP_FASTOPEN_KEY_LENGTH 16
>
>  /* Fastopen key context */
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index c53de2691cec..6ff35eb48d10 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -116,6 +116,7 @@ enum {
>  #define TCP_SAVE_SYN           27      /* Record SYN headers for new con=
nections */
>  #define TCP_SAVED_SYN          28      /* Get SYN headers recorded for c=
onnection */
>  #define TCP_REPAIR_WINDOW      29      /* Get/set window parameters */
> +#define TCP_FASTOPEN_CONNECT   30      /* Attempt FastOpen with connect =
*/
>
>  struct tcp_repair_opt {
>         __u32   opt_code;
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index aae410bb655a..d8a0dc076f97 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -576,13 +576,24 @@ int __inet_stream_connect(struct socket *sock, stru=
ct sockaddr *uaddr,
>         int err;
>         long timeo;
>
> -       if (addr_len < sizeof(uaddr->sa_family))
> -               return -EINVAL;
> +       /*
> +        * uaddr can be NULL and addr_len can be 0 if:
> +        * sk is a TCP fastopen active socket and
> +        * TCP_FASTOPEN_CONNECT sockopt is set and
> +        * we already have a valid cookie for this socket.
> +        * In this case, user can call write() after connect().
> +        * write() will invoke tcp_sendmsg_fastopen() which calls
> +        * __inet_stream_connect().
> +        */
> +       if (uaddr) {
> +               if (addr_len < sizeof(uaddr->sa_family))
> +                       return -EINVAL;
>
> -       if (uaddr->sa_family =3D=3D AF_UNSPEC) {
> -               err =3D sk->sk_prot->disconnect(sk, flags);
> -               sock->state =3D err ? SS_DISCONNECTING : SS_UNCONNECTED;
> -               goto out;
> +               if (uaddr->sa_family =3D=3D AF_UNSPEC) {
> +                       err =3D sk->sk_prot->disconnect(sk, flags);
> +                       sock->state =3D err ? SS_DISCONNECTING : SS_UNCON=
NECTED;
> +                       goto out;
> +               }
>         }
>
>         switch (sock->state) {
> @@ -593,7 +604,10 @@ int __inet_stream_connect(struct socket *sock, struc=
t sockaddr *uaddr,
>                 err =3D -EISCONN;
>                 goto out;
>         case SS_CONNECTING:
> -               err =3D -EALREADY;
> +               if (inet_sk(sk)->defer_connect)
> +                       err =3D -EINPROGRESS;
> +               else
> +                       err =3D -EALREADY;
>                 /* Fall out of switch with err, set for this state */
>                 break;
>         case SS_UNCONNECTED:
> @@ -607,6 +621,9 @@ int __inet_stream_connect(struct socket *sock, struct=
 sockaddr *uaddr,
>
>                 sock->state =3D SS_CONNECTING;
>
> +               if (!err && inet_sk(sk)->defer_connect)
> +                       goto out;
> +
>                 /* Just entered SS_CONNECTING state; the only
>                  * difference is that return value in non-blocking
>                  * case is EINPROGRESS, rather than EALREADY.
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index c43eb1a831d7..d9735b76d073 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -533,6 +533,12 @@ unsigned int tcp_poll(struct file *file, struct sock=
et *sock, poll_table *wait)
>
>                 if (tp->urg_data & TCP_URG_VALID)
>                         mask |=3D POLLPRI;
> +       } else if (sk->sk_state =3D=3D TCP_SYN_SENT && inet_sk(sk)->defer=
_connect) {
> +               /* Active TCP fastopen socket with defer_connect
> +                * Return POLLOUT so application can call write()
> +                * in order for kernel to generate SYN+data
> +                */
> +               mask |=3D POLLOUT | POLLWRNORM;
>         }
>         /* This barrier is coupled with smp_wmb() in tcp_reset() */
>         smp_rmb();
> @@ -1071,6 +1077,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, st=
ruct msghdr *msg,
>                                 int *copied, size_t size)
>  {
>         struct tcp_sock *tp =3D tcp_sk(sk);
> +       struct inet_sock *inet =3D inet_sk(sk);
>         int err, flags;
>
>         if (!(sysctl_tcp_fastopen & TFO_CLIENT_ENABLE))
> @@ -1085,9 +1092,19 @@ static int tcp_sendmsg_fastopen(struct sock *sk, s=
truct msghdr *msg,
>         tp->fastopen_req->data =3D msg;
>         tp->fastopen_req->size =3D size;
>
> +       if (inet->defer_connect) {
> +               err =3D tcp_connect(sk);
> +               /* Same failure procedure as in tcp_v4/6_connect */
> +               if (err) {
> +                       tcp_set_state(sk, TCP_CLOSE);
> +                       inet->inet_dport =3D 0;
> +                       sk->sk_route_caps =3D 0;
> +               }
> +       }
>         flags =3D (msg->msg_flags & MSG_DONTWAIT) ? O_NONBLOCK : 0;
>         err =3D __inet_stream_connect(sk->sk_socket, msg->msg_name,
>                                     msg->msg_namelen, flags);
> +       inet->defer_connect =3D 0;
>         *copied =3D tp->fastopen_req->copied;
>         tcp_free_fastopen_req(tp);
>         return err;
> @@ -1107,7 +1124,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg=
, size_t size)
>         lock_sock(sk);
>
>         flags =3D msg->msg_flags;
> -       if (flags & MSG_FASTOPEN) {
> +       if (unlikely(flags & MSG_FASTOPEN || inet_sk(sk)->defer_connect))=
 {
>                 err =3D tcp_sendmsg_fastopen(sk, msg, &copied_syn, size);
>                 if (err =3D=3D -EINPROGRESS && copied_syn > 0)
>                         goto out;
> @@ -2656,6 +2673,18 @@ static int do_tcp_setsockopt(struct sock *sk, int =
level,
>                         err =3D -EINVAL;
>                 }
>                 break;
> +       case TCP_FASTOPEN_CONNECT:
> +               if (val > 1 || val < 0) {
> +                       err =3D -EINVAL;
> +               } else if (sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) {
> +                       if (sk->sk_state =3D=3D TCP_CLOSE)
> +                               tp->fastopen_connect =3D val;
> +                       else
> +                               err =3D -EINVAL;
> +               } else {
> +                       err =3D -EOPNOTSUPP;
> +               }
> +               break;
>         case TCP_TIMESTAMP:
>                 if (!tp->repair)
>                         err =3D -EPERM;
> @@ -3016,6 +3045,10 @@ static int do_tcp_getsockopt(struct sock *sk, int =
level,
>                 val =3D icsk->icsk_accept_queue.fastopenq.max_qlen;
>                 break;
>
> +       case TCP_FASTOPEN_CONNECT:
> +               val =3D tp->fastopen_connect;
> +               break;
> +
>         case TCP_TIMESTAMP:
>                 val =3D tcp_time_stamp + tp->tsoffset;
>                 break;
> diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> index f90e09e1ff4c..9674bec4a0f8 100644
> --- a/net/ipv4/tcp_fastopen.c
> +++ b/net/ipv4/tcp_fastopen.c
> @@ -346,3 +346,36 @@ bool tcp_fastopen_cookie_check(struct sock *sk, u16 =
*mss,
>         }
>         return cookie->len > 0;
>  }
> +
> +/* This function checks if we want to defer sending SYN until the first
> + * write().  We defer under the following conditions:
> + * 1. fastopen_connect sockopt is set
> + * 2. we have a valid cookie
> + * Return value: return true if we want to defer until application write=
s data
> + *               return false if we want to send out SYN immediately
> + */
> +bool tcp_fastopen_defer_connect(struct sock *sk, int *err)
> +{
> +       struct tcp_fastopen_cookie cookie =3D { .len =3D 0 };
> +       struct tcp_sock *tp =3D tcp_sk(sk);
> +       u16 mss;
> +
> +       if (tp->fastopen_connect && !tp->fastopen_req) {
> +               if (tcp_fastopen_cookie_check(sk, &mss, &cookie)) {
> +                       inet_sk(sk)->defer_connect =3D 1;
> +                       return true;
> +               }
> +
> +               /* Alloc fastopen_req in order for FO option to be includ=
ed
> +                * in SYN
> +                */
> +               tp->fastopen_req =3D kzalloc(sizeof(*tp->fastopen_req),
> +                                          sk->sk_allocation);
> +               if (tp->fastopen_req)
> +                       tp->fastopen_req->cookie =3D cookie;
> +               else
> +                       *err =3D -ENOBUFS;
> +       }
> +       return false;
> +}
> +EXPORT_SYMBOL(tcp_fastopen_defer_connect);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index f7325b25b06e..27b726c96459 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -232,6 +232,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *=
uaddr, int addr_len)
>         /* OK, now commit destination to socket.  */
>         sk->sk_gso_type =3D SKB_GSO_TCPV4;
>         sk_setup_caps(sk, &rt->dst);
> +       rt =3D NULL;
>
>         if (!tp->write_seq && likely(!tp->repair))
>                 tp->write_seq =3D secure_tcp_sequence_number(inet->inet_s=
addr,
> @@ -242,9 +243,13 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr =
*uaddr, int addr_len)
>
>         inet->inet_id =3D tp->write_seq ^ jiffies;
>
> +       if (tcp_fastopen_defer_connect(sk, &err))
> +               return err;
> +       if (err)
> +               goto failure;
> +
>         err =3D tcp_connect(sk);
>
> -       rt =3D NULL;
>         if (err)
>                 goto failure;
>
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 0b7cd3d009b6..95c05e5293b1 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -287,6 +287,11 @@ static int tcp_v6_connect(struct sock *sk, struct so=
ckaddr *uaddr,
>                                                              inet->inet_d=
port,
>                                                              &tp->tsoffse=
t);
>
> +       if (tcp_fastopen_defer_connect(sk, &err))
> +               return err;
> +       if (err)
> +               goto late_failure;
> +
>         err =3D tcp_connect(sk);
>         if (err)
>                 goto late_failure;
> --
> 2.11.0.483.g087da7b7c-goog
>
