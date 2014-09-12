From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v4 2/9] net: filter: keep original BPF program around
Date: Thu, 11 Sep 2014 20:51:18 -0700
Message-ID: <CAMEtUuxPSGpOnWUNueMVMzwyQWbP4Kb==9HJwwkKoReL+3h09Q@mail.gmail.com>
References: <1396029506-16776-1-git-send-email-dborkman@redhat.com>
	<1396029506-16776-3-git-send-email-dborkman@redhat.com>
	<1410492457.7106.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:58798 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbaILDvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 23:51:19 -0400
Received: by mail-we0-f178.google.com with SMTP id q58so123406wes.9
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 20:51:18 -0700 (PDT)
In-Reply-To: <1410492457.7106.72.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2014 at 8:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> On Fri, 2014-03-28 at 18:58 +0100, Daniel Borkmann wrote:
>> In order to open up the possibility to internally transform a BPF program
>> into an alternative and possibly non-trivial reversible representation, we
>> need to keep the original BPF program around, so that it can be passed back
>> to user space w/o the need of a complex decoder.
>>
>> The reason for that use case resides in commit a8fc92778080 ("sk-filter:
>> Add ability to get socket filter program (v2)"), that is, the ability
>> to retrieve the currently attached BPF filter from a given socket used
>> mainly by the checkpoint-restore project, for example.
>>
>> Therefore, we add two helpers sk_{store,release}_orig_filter for taking
>> care of that. In the sk_unattached_filter_create() case, there's no such
>> possibility/requirement to retrieve a loaded BPF program. Therefore, we
>> can spare us the work in that case.
>>
>> This approach will simplify and slightly speed up both, sk_get_filter()
>> and sock_diag_put_filterinfo() handlers as we won't need to successively
>> decode filters anymore through sk_decode_filter(). As we still need
>> sk_decode_filter() later on, we're keeping it around.
>>
>> Joint work with Alexei Starovoitov.
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Pavel Emelyanov <xemul@parallels.com>
>> ---
>
> Note that this patch added a possible use after free.
>
> Following patch should be sent to stable trees only, as 3.17+
> incidentally fixed this with
> commit 278571baca2aecf5fb5cb5c8b002dbfa0a6c524c
>     net: filter: simplify socket charging
>
> [PATCH] net: filter: fix possible use after free
>
> If kmemdup() fails, we free fp->orig_prog and return -ENOMEM
>
> sk_attach_filter()
>  -> sk_filter_uncharge(sk, fp)
>   -> sk_filter_release(fp)
>    -> call_rcu(&fp->rcu, sk_filter_release_rcu)
>     -> sk_filter_release_rcu()
>      -> sk_release_orig_filter()
>         fprog = fp->orig_prog; // not NULL, but points to freed memory
>           kfree(fprog->filter); // use after free, potential corruption
>           kfree(fprog); // double free or corruption
>
> Note: This was fixed in 3.17+ with commit 278571baca2a
> ("net: filter: simplify socket charging")
>
> Found by AddressSanitizer
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: a3ea269b8bcdb ("net: filter: keep original BPF program around")

Wow. that's a tricky one. Thanks!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Indeed 3.17 is ok, but the fix is small enough, so wouldn't
hurt to apply it everywhere. Just for consistency?

> ---
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 1dbf6462f766..3139f966a178 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1318,6 +1318,7 @@ static int sk_store_orig_filter(struct sk_filter *fp,
>         fkprog->filter = kmemdup(fp->insns, fsize, GFP_KERNEL);
>         if (!fkprog->filter) {
>                 kfree(fp->orig_prog);
> +               fp->orig_prog = NULL;
>                 return -ENOMEM;
>  }
>
>
>
