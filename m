From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] tcp: fix use after free in tcp_xmit_retransmit_queue()
Date: Wed, 17 Aug 2016 09:12:34 -0700
Message-ID: <CAM_iQpXf3DQ428gKCnTvbYFa8y_RLA7GMJ6aUdw85LWO4xyeXw@mail.gmail.com>
References: <20160816104551.GA28052@kroah.com> <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com> <1471438586.4943.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Marco Grassi <marco.gra@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32940 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbcHQQNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 12:13:41 -0400
Received: by mail-it0-f66.google.com with SMTP id d65so9842471ith.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 09:12:55 -0700 (PDT)
In-Reply-To: <1471438586.4943.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 5:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> From: Eric Dumazet <edumazet@google.com>
>
> When tcp_sendmsg() allocates a fresh and empty skb, it puts it at the
> tail of the write queue using tcp_add_write_queue_tail()
>
> Then it attempts to copy user data into this fresh skb.
>
> If the copy fails, we undo the work and remove the fresh skb.
>
> Unfortunately, this undo lacks the change done to tp->highest_sack and
> we can leave a dangling pointer (to a freed skb)
>
> Later, tcp_xmit_retransmit_queue() can dereference this pointer and
> access freed memory. For regular kernels where memory is not unmapped,
> this might cause SACK bugs because tcp_highest_sack_seq() is buggy,
> returning garbage instead of tp->snd_nxt, but with various debug
> features like CONFIG_DEBUG_PAGEALLOC, this can crash the kernel.
>
> This bug was found by Marco Grassi thanks to syzkaller.
>
> Fixes: 6859d49475d4 ("[TCP]: Abstract tp->highest_sack accessing & point =
to next skb")
> Reported-by: Marco Grassi <marco.gra@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
>  include/net/tcp.h |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index c00e7d51bb18..7717302cab91 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1523,6 +1523,8 @@ static inline void tcp_check_send_head(struct sock =
*sk, struct sk_buff *skb_unli
>  {
>         if (sk->sk_send_head =3D=3D skb_unlinked)
>                 sk->sk_send_head =3D NULL;
> +       if (tcp_sk(sk)->highest_sack =3D=3D skb_unlinked)
> +               tcp_sk(sk)->highest_sack =3D NULL;
>  }
>

Nit: the function name probably needs to change too, since it now
checks more than just send_head. ;) But we can always do this
for net-next, don't let this be a blocker for this security fix.

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
