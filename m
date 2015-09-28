From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] l2tp: protect tunnel->del_work by ref_count
Date: Mon, 28 Sep 2015 14:39:44 +0100
Message-ID: <CAEwTi7TDsSYmhWYR-n_uUuRu-GmWAu=6DYS349hdPHDdxWrqxQ@mail.gmail.com>
References: <1443432762-5561-1-git-send-email-lynxis@fe80.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Alexander Couzens <lynxis@fe80.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:60848 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933732AbbI1Njt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 09:39:49 -0400
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id 861904D78A
	for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 14:39:45 +0100 (BST)
Received: by wicfx3 with SMTP id fx3so105238127wic.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 06:39:44 -0700 (PDT)
In-Reply-To: <1443432762-5561-1-git-send-email-lynxis@fe80.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: James Chapman <jchapman@katalix.com>


On 28 September 2015 at 10:32, Alexander Couzens <lynxis@fe80.eu> wrote:
> There is a small chance that tunnel_free() is called before tunnel->del_work scheduled
> resulting in a zero pointer dereference.
>
> Signed-off-by: Alexander Couzens <lynxis@fe80.eu>
> ---
>  net/l2tp/l2tp_core.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index f6b090d..afca2eb 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1319,7 +1319,7 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
>         tunnel = container_of(work, struct l2tp_tunnel, del_work);
>         sk = l2tp_tunnel_sock_lookup(tunnel);
>         if (!sk)
> -               return;
> +               goto out;
>
>         sock = sk->sk_socket;
>
> @@ -1341,6 +1341,8 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
>         }
>
>         l2tp_tunnel_sock_put(sk);
> +out:
> +       l2tp_tunnel_dec_refcount(tunnel);
>  }
>
>  /* Create a socket for the tunnel, if one isn't set up by
> @@ -1636,8 +1638,13 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
>   */
>  int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
>  {
> +       l2tp_tunnel_inc_refcount(tunnel);
>         l2tp_tunnel_closeall(tunnel);
> -       return (false == queue_work(l2tp_wq, &tunnel->del_work));
> +       if (false == queue_work(l2tp_wq, &tunnel->del_work)) {
> +               l2tp_tunnel_dec_refcount(tunnel);
> +               return 1;
> +       }
> +       return 0;
>  }
>  EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
>
> --
> 2.5.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
