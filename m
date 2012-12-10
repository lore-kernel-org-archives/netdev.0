From: Julius Werner <jwerner@chromium.org>
Subject: Re: [PATCH] tcp: Avoid infinite loop on recvmsg bug
Date: Mon, 10 Dec 2012 11:33:27 -0800
Message-ID: <CAODwPW_P_UNGV8rRC7hFC+PBrWeu64ODu5mTby=9GCqMnyDtdQ@mail.gmail.com>
References: <CAODwPW9kiG-jo=n0zedv5KT-8-gJcEUrdC3F2mAEjt78tne18g@mail.gmail.com>
	<1352316791-16491-1-git-send-email-jwerner@chromium.org>
	<1352317219.5552.6.camel@edumazet-glaptop>
	<CAODwPW8mBJspF3k5SCBR-BShNvBLQpD-vyhLRh5Cq-4h=VZDgg@mail.gmail.com>
	<1352331192.2748.10.camel@edumazet-glaptop>
	<1352331754.2748.14.camel@edumazet-glaptop>
	<CAODwPW90mZuCDgYPZEJtYNOGGt752VpP=S_EYACUCGua_x=WjA@mail.gmail.com>
	<1352431796.19779.536.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>
To: Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352431796.19779.536.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Have you thought about picking up one of the patches to tcp_recvmsg I
proposed in this thread? We consider the underlying bug in Chromium OS
that led mere here to be fixed now, but I bet this will not be the
last time someone hits this code path and has to deal with the bad
error handling.

I understand that not everyone here agrees on what the best solution
is, but I think both of them are far better than the inconsistent and
potentially hard-disk-filling way that the current kernel does it.

On Wed, 2012-11-07 at 11:33 -0800, Julius Werner wrote:
> tcp_recvmsg contains a sanity check that WARNs when there is a gap
> between the socket's copied_seq and the first buffer in the
> sk_receive_queue. In theory, the TCP stack makes sure that This Should
> Never Happen (TM)... however, practice shows that there are still a few
> bug reports from it out there (and one in my inbox).
>
> Unfortunately, when it does happen for whatever reason, the situation
> is not handled very well: the kernel logs a warning and breaks out of
> the loop that walks the receive queue. It proceeds to find nothing else
> to do on the socket and hits sk_wait_data, which cannot block because
> the receive queue is not empty. As no data was read, the outer while
> loop repeats (logging the same warning again) ad infinitum until the
> system's syslog exhausts all available hard drive capacity.
>
> This patch addresses that issue by closing the socket outright and
> throwing EBADFD to userspace (which seems most appropriate to me at this
> point). As the underlying bug condition is "impossible" and therefore by
> definition unrecoverable, this is the only sensible action other than a
> full panic.
>
> Signed-off-by: Julius Werner <jwerner@chromium.org>
> ---
>  net/ipv4/tcp.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 197c000..d612308 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1628,7 +1628,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>                                "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
>                                *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
>                                flags))
> -                             break;
> +                             goto selfdestruct;
>
>                       offset = *seq - TCP_SKB_CB(skb)->seq;
>                       if (tcp_hdr(skb)->syn)
> @@ -1936,6 +1936,11 @@ recv_urg:
>  recv_sndq:
>       err = tcp_peek_sndq(sk, msg, len);
>       goto out;
> +
> +selfdestruct:
> +     err = -EBADFD;
> +     tcp_done(sk);
> +     goto out;
>  }
>  EXPORT_SYMBOL(tcp_recvmsg);
>

On Tue, Nov 06, 2012 at 04:15:35PM -0800, Julius Werner wrote:
> tcp_recvmsg contains a sanity check that WARNs when there is a gap
> between the socket's copied_seq and the first buffer in the
> sk_receive_queue. In theory, the TCP stack makes sure that This Should
> Never Happen (TM)... however, practice shows that there are still a few
> bug reports from it out there (and one in my inbox).
>
> Unfortunately, when it does happen for whatever reason, the situation
> is not handled very well: the kernel logs a warning and breaks out of
> the loop that walks the receive queue. It proceeds to find nothing else
> to do on the socket and hits sk_wait_data, which cannot block because
> the receive queue is not empty. As no data was read, the outer while
> loop repeats (logging the same warning again) ad infinitum until the
> system's syslog exhausts all available hard drive capacity.
>
> This patch improves that behavior by going straight to a proper kernel
> crash. The cause of the error can be identified right away and the
> system's hard drive is not unnecessarily strained.
>
> Signed-off-by: Julius Werner <jwerner@chromium.org>
> ---
>  net/ipv4/tcp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 197c000..fcb0927 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1628,7 +1628,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>                               "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
>                               *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
>                               flags))
> -                            break;
> +                            BUG();
>
>                      offset = *seq - TCP_SKB_CB(skb)->seq;
>                      if (tcp_hdr(skb)->syn)
