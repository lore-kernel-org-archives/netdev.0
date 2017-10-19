From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net-next v3 1/2] ipv6: start fib6 gc on RTF_CACHE dst creation
Date: Thu, 19 Oct 2017 13:13:14 -0700
Message-ID: <CAEA6p_Dc4G34V=Nx6-_7LQ54RO47DbfhfS_7pYH-K+jEN_xs-w@mail.gmail.com>
References: <cover.1508421311.git.pabeni@redhat.com> <f699f29b3fb7675fdfe5d85ab39e153c147c12f8.1508421311.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Martin KaFai Lau <kafai@fb.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:45616 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753736AbdJSUNP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 16:13:15 -0400
Received: by mail-vk0-f67.google.com with SMTP id q13so6132593vkb.2
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 13:13:15 -0700 (PDT)
In-Reply-To: <f699f29b3fb7675fdfe5d85ab39e153c147c12f8.1508421311.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 7:07 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> After the commit 2b760fcf5cfb ("ipv6: hook up exception table
> to store dst cache"), the fib6 gc is not started after the
> creation of a RTF_CACHE via a redirect or pmtu update, since
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
> v2 -> v3:
>  - clarified the commit message
>
> Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

Acked-by: Wei Wang <weiwan@google.com>

>  net/ipv6/route.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 01a103c23a6c..5c27313803d2 100644
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
