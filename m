From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] rhashtable: fix a memory leak in alloc_bucket_locks()
Date: Fri, 26 Aug 2016 10:19:02 -0700
Message-ID: <CAM_iQpVLCqapbA-Z04gk+t+n7+GyHL7gKuOjusNQYJs4kYyfpQ@mail.gmail.com>
References: <544270328.2536943.1472154674747.JavaMail.zimbra@redhat.com>
 <1474737839.2538727.1472155133819.JavaMail.zimbra@redhat.com>
 <CANn89iL3J6nTbNRm215xv2LL_6SjoPV-XtUJq7Ka_7pFsuAg0g@mail.gmail.com>
 <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
 <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com> <1472226699.14381.186.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, CAI Qian <caiqian@redhat.com>,
        Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <edumazet@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35308 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbcHZRTY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 13:19:24 -0400
Received: by mail-wm0-f66.google.com with SMTP id i5so116638wmg.2
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 10:19:23 -0700 (PDT)
In-Reply-To: <1472226699.14381.186.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 8:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> If vmalloc() was successful, do not attempt a kmalloc_array()
>
> Fixes: 4cf0b354d92e ("rhashtable: avoid large lock-array allocations")
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Florian Westphal <fw@strlen.de>
> ---
>  lib/rhashtable.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 5ba520b544d7..56054e541a0f 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -77,17 +77,18 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
>         size = min_t(unsigned int, size, tbl->size >> 1);
>
>         if (sizeof(spinlock_t) != 0) {
> +               tbl->locks = NULL;
>  #ifdef CONFIG_NUMA
>                 if (size * sizeof(spinlock_t) > PAGE_SIZE &&
>                     gfp == GFP_KERNEL)
>                         tbl->locks = vmalloc(size * sizeof(spinlock_t));
> -               else
>  #endif

Not directly for your patch, but why did we have this CONFIG_NUMA
for vmalloc()? I think this macro is the real cause of the bug. :-P
