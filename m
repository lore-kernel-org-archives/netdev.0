From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: use gfp insteaad of GFP_NOWAIT in
 idr_alloc_cyclic when sctp_assoc_set_id
Date: Tue, 8 Mar 2016 10:54:52 +0800
Message-ID: <CADvbK_dMjcw6LKsSQogb65i_9VHNKdrc_YTcJ3osYQ=aEytQWw@mail.gmail.com>
References: <ef48b2b8895b4d0fab07b4e72b464d5a11d3bd79.1457193572.git.lucien.xin@gmail.com>
	<1457196133.2663.3.camel@edumazet-ThinkPad-T530>
	<CADvbK_faS8mNtUNiVT6d-kLRnngQ=4+z6meuO0XM+RJG50iaNw@mail.gmail.com>
	<1457306476.2663.28.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f196.google.com ([209.85.214.196]:33273 "EHLO
	mail-ob0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468AbcCHCyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 21:54:53 -0500
In-Reply-To: <1457306476.2663.28.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 7:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> What is the problem of being not able to allocate memory at this point ?
>
Now I think about it again,  this patch cannot work, because of:
__sctp_connect()
    sctp_assoc_set_id(asoc, GFP_KERNEL)

thanks, Eric

> If really it bothers you (although we have thousands of other places it
> can happen), maybe add __GFP_NOWARN
>
> But whatever flag we use here, idr_alloc() _can_ fail.
>
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 2bf8ec92dde4..2ae3874e3696 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1606,7 +1606,8 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
>                 idr_preload(gfp);
>         spin_lock_bh(&sctp_assocs_id_lock);
>         /* 0 is not a valid assoc_id, must be >= 1 */
> -       ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0, GFP_NOWAIT);
> +       ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0,
> +                              (gfp & ~__GFP_DIRECT_RECLAIM) | __GFP_NOWARN);
>         spin_unlock_bh(&sctp_assocs_id_lock);
>         if (preload)
>                 idr_preload_end();
>
>
