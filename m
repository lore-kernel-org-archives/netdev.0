From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net-next 2/3] ipv6: start fib6 gc on RTF_CACHE dst creation
Date: Tue, 17 Oct 2017 11:35:13 -0700
Message-ID: <CAEA6p_CKWdf0ZYm-n3kECnLMipEU3v+VVD4JFzHyPtxdBkvxSQ@mail.gmail.com>
References: <cover.1508261949.git.pabeni@redhat.com> <013c220c347b63c0458332898709edc0b469361d.1508261949.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>, Martin KaFai Lau <kafai@fb.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:46502 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753743AbdJQSfO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 14:35:14 -0400
Received: by mail-vk0-f52.google.com with SMTP id k123so1756469vkb.3
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 11:35:14 -0700 (PDT)
In-Reply-To: <013c220c347b63c0458332898709edc0b469361d.1508261949.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 10:40 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> After the commit Fixes: 2b760fcf5cfb ("ipv6: hook up exception
> table to store dst cache"), the fib6 gc is not started after
> the creation of a RTF_CACHE via a redirect or pmtu update, since
> fib6_add() isn't invoked anymore for such dsts.
>
> We need the fib6 gc to run periodically to clean the RTF_CACHE,
> or the dst will stay there forever.
>
> Fix it by explicitly calling fib6_force_start_gc() on successful
> exception creation. gc_args->more accounting will ensure that
> the gc timer will run for whatever time needed to properly
> clean the table.
>
> Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
Acked-by: Wei Wang <weiwan@google.com>

Totally true. Thanks for catching this.

>  net/ipv6/route.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 5bb53dbd4fd3..8b25a31b6b03 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1340,8 +1340,10 @@ static int rt6_insert_exception(struct rt6_info *nrt,
>         spin_unlock_bh(&rt6_exception_lock);
>
>         /* Update fn->fn_sernum to invalidate all cached dst */
> -       if (!err)
> +       if (!err) {
>                 fib6_update_sernum(ort);
> +               fib6_force_start_gc(net);
> +       }
>
>         return err;
>  }
> --
> 2.13.6
>
