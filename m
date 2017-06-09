From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] net/flow: fix fc->percpu NULL pointer dereference
Date: Fri, 9 Jun 2017 16:23:01 +0800
Message-ID: <CAPwn2JSeKnspZpnWTXsze7sCSXJ9mbq2K3-mu-muuy8iT4A1qw@mail.gmail.com>
References: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Xin Long <lucien.xin@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34755 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751650AbdFIIXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 04:23:03 -0400
Received: by mail-it0-f68.google.com with SMTP id 201so3772444itu.1
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 01:23:02 -0700 (PDT)
In-Reply-To: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

BTW, If we put the check in xfrm_policy_flush(), we can prevent it earlier.
But If we put the check in flow_cache_percpu_empty(), we can prevent
other functions set fc->percpu to NULL, although not much possible : )

So I'm not quite sure whether we should put the check in
flow_cache_percpu_empty() or in xfrm_policy_flush().

Do you have any suggestion?

Thanks
Hangbin

2017-06-09 16:13 GMT+08:00 Hangbin Liu <liuhangbin@gmail.com>:
> Now we will force to do garbage collection if any policy removed in
> xfrm_policy_flush(). But during xfrm_net_exit(). We call flow_cache_fini()
> first and set set fc->percpu to NULL. Then after we call xfrm_policy_fini()
> -> frxm_policy_flush() -> flow_cache_flush(), we will get NULL pointer
> dereference when check percpu_empty. The code path looks like:
>
> flow_cache_fini()
>   - fc->percpu = NULL
> xfrm_policy_fini()
>   - xfrm_policy_flush()
>     - xfrm_garbage_collect()
>       - flow_cache_flush()
>         - flow_cache_percpu_empty()
>           - fcp = per_cpu_ptr(fc->percpu, cpu)
>
> To reproduce, just add ipsec in netns and then remove the netns.
>
> Fixes: 35db06912189 ("xfrm: do the garbage collection after flushing policy")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  net/core/flow.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/flow.c b/net/core/flow.c
> index f7f5d19..321fc53 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -332,10 +332,13 @@ static int flow_cache_percpu_empty(struct flow_cache *fc, int cpu)
>         struct flow_cache_percpu *fcp;
>         unsigned int i;
>
> -       fcp = per_cpu_ptr(fc->percpu, cpu);
> -       for (i = 0; i < flow_cache_hash_size(fc); i++)
> -               if (!hlist_empty(&fcp->hash_table[i]))
> -                       return 0;
> +       if (fc->percpu) {
> +               fcp = per_cpu_ptr(fc->percpu, cpu);
> +               for (i = 0; i < flow_cache_hash_size(fc); i++)
> +                       if (!hlist_empty(&fcp->hash_table[i]))
> +                               return 0;
> +       }
> +
>         return 1;
>  }
>
> --
> 2.5.5
>
