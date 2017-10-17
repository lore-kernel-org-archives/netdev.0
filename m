From: Christoph Paasch <cpaasch@apple.com>
Subject: Re: [PATCH net-next] tcp: Enable TFO without a cookie on a per-socket
 basis
Date: Tue, 17 Oct 2017 10:42:58 -0700
Message-ID: <20171017174258.GK73751@Chimay.local>
References: <20171017063714.17346-1-cpaasch@apple.com>
 <CAK6E8=dV_tGikBEVX1QFTo37sMEjd1W1HJsJv=mUaDe-8RAvKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out22.apple.com ([17.171.2.32]:46798 "EHLO
        mail-in22.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753775AbdJQR6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:58:01 -0400
Content-disposition: inline
In-reply-to: <CAK6E8=dV_tGikBEVX1QFTo37sMEjd1W1HJsJv=mUaDe-8RAvKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/10/17 - 10:26:58, Yuchung Cheng wrote:
> On Mon, Oct 16, 2017 at 11:37 PM, Christoph Paasch <cpaasch@apple.com> wrote:
> > We already allow to enable TFO without a cookie by using the
> > fastopen-sysctl and setting it to TFO_SERVER_COOKIE_NOT_REQD (0x200).
> > This is safe to do in certain environments where we know that there
> > isn't a malicous host (aka., data-centers).
> >
> > A server however might be talking to both sides (public Internet and
> > data-center). So, this server would want to enable cookie-less TFO for
> > the connections that go to the data-center while enforcing cookies for
> > the traffic from the Internet.
> >
> > This patch exposes a socket-option to enable this (protected by
> > CAP_NET_ADMIN).
> >
> > Signed-off-by: Christoph Paasch <cpaasch@apple.com>
> > ---
> >  include/linux/tcp.h      |  1 +
> >  include/uapi/linux/tcp.h |  1 +
> >  net/ipv4/tcp.c           | 14 ++++++++++++++
> >  net/ipv4/tcp_fastopen.c  |  6 ++++--
> >  4 files changed, 20 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> > index 1d2c44e09e31..cda5d4dc8d70 100644
> > --- a/include/linux/tcp.h
> > +++ b/include/linux/tcp.h
> > @@ -228,6 +228,7 @@ struct tcp_sock {
> >                 syn_fastopen_ch:1, /* Active TFO re-enabling probe */
> >                 syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
> >                 save_syn:1,     /* Save headers of SYN packet */
> > +               no_tfo_cookie:1, /* Allow send/recv SYN+data without a cookie */
> can we rename to fastopen_no_cookie and move one line above so TFO
> stuff is together with similar naming.

Sure, will rename & move.

> 
> >                 is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
> >         u32     tlp_high_seq;   /* snd_nxt at the time of TLP retransmit. */
> >
> > diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> > index 15c25eccab2b..d44f4bef056c 100644
> > --- a/include/uapi/linux/tcp.h
> > +++ b/include/uapi/linux/tcp.h
> > @@ -119,6 +119,7 @@ enum {
> >  #define TCP_FASTOPEN_CONNECT   30      /* Attempt FastOpen with connect */
> >  #define TCP_ULP                        31      /* Attach a ULP to a TCP connection */
> >  #define TCP_MD5SIG_EXT         32      /* TCP MD5 Signature with extensions */
> > +#define TCP_NO_TFO_COOKIE      33      /* Enable TFO without a TFO cookie */
> >
> >  struct tcp_repair_opt {
> >         __u32   opt_code;
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 3b34850d361f..88c90be12d9f 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -2821,6 +2821,16 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
> >                         err = -EOPNOTSUPP;
> >                 }
> >                 break;
> > +       case TCP_NO_TFO_COOKIE:
> rename to TCP_FASTOPEN_NO_COOKIE for better consistency on TFO
> options?

Yes, I will rename.

> I am also cooking a TCP_FASTOPEN_KEY option patch to allow
> listener to update the key.

I see - nice!


Thanks,
Christoph

> 
> > +               if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
> > +                       err = -EPERM;
> > +               else if (val > 1 || val < 0)
> > +                       err = -EINVAL;
> > +               else if (!((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN)))
> > +                       err = -EINVAL;
> > +               else
> > +                       tp->no_tfo_cookie = 1;
> > +               break;
> >         case TCP_TIMESTAMP:
> >                 if (!tp->repair)
> >                         err = -EPERM;
> > @@ -3219,6 +3229,10 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
> >                 val = tp->fastopen_connect;
> >                 break;
> >
> > +       case TCP_NO_TFO_COOKIE:
> > +               val = tp->no_tfo_cookie;
> > +               break;
> > +
> >         case TCP_TIMESTAMP:
> >                 val = tcp_time_stamp_raw() + tp->tsoffset;
> >                 break;
> > diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> > index 7ee4aadcdd71..c1b00b666b43 100644
> > --- a/net/ipv4/tcp_fastopen.c
> > +++ b/net/ipv4/tcp_fastopen.c
> > @@ -309,7 +309,8 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
> >                 return NULL;
> >         }
> >
> > -       if (syn_data && (tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD))
> > +       if (syn_data && ((tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD) ||
> > +                        tcp_sk(sk)->no_tfo_cookie))
> >                 goto fastopen;
> >
> >         if (foc->len >= 0 &&  /* Client presents or requests a cookie */
> > @@ -363,7 +364,8 @@ bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
> >                 return false;
> >         }
> >
> > -       if (sock_net(sk)->ipv4.sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE) {
> > +       if ((sock_net(sk)->ipv4.sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE) ||
> > +           tcp_sk(sk)->no_tfo_cookie) {
> >                 cookie->len = -1;
> >                 return true;
> >         }
> > --
> > 2.14.1
> >
