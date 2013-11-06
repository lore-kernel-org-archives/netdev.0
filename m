From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] net: don't forget to free sk_filter
Date: Wed, 6 Nov 2013 08:39:00 -0800
Message-ID: <CAMEtUuwkA0+tKhDB0-cK9wZu11dBvJYPdyfGJLt7jeTGETb4tg@mail.gmail.com>
References: <1383753106-26978-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:59370 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754822Ab3KFQjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 11:39:01 -0500
Received: by mail-wg0-f45.google.com with SMTP id z12so5278522wgg.24
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 08:39:00 -0800 (PST)
In-Reply-To: <1383753106-26978-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 6, 2013 at 7:51 AM, Andrey Vagin <avagin@openvz.org> wrote:
> sk_filter isn't freed if bpf_func is equal to sk_run_filter.

good catch! thanks.

> This memory leak was introduced by
> commit d45ed4a4e33ae103053c0a53d280014e7101bb5c
> Author: Alexei Starovoitov <ast@plumgrid.com>
> Date:   Fri Oct 4 00:14:06 2013 -0700
>
>     net: fix unsafe set_memory_rw from softirq
>
> Before this patch sk_filter was freed in sk_filter_release_rcu,
> now it is freed in bpf_jit_free.
>
> Here is output of kmemleak:
> unreferenced object 0xffff8800b774eab0 (size 128):
>   comm "systemd", pid 1, jiffies 4294669014 (age 124.062s)
>   hex dump (first 32 bytes):
>     00 00 00 00 0b 00 00 00 20 63 7f b7 00 88 ff ff  ........ c......
>     60 d4 55 81 ff ff ff ff 30 d9 55 81 ff ff ff ff  `.U.....0.U.....
>   backtrace:
>     [<ffffffff816444be>] kmemleak_alloc+0x4e/0xb0
>     [<ffffffff811845af>] __kmalloc+0xef/0x260
>     [<ffffffff81534028>] sock_kmalloc+0x38/0x60
>     [<ffffffff8155d4dd>] sk_attach_filter+0x5d/0x190
>     [<ffffffff815378a1>] sock_setsockopt+0x991/0x9e0
>     [<ffffffff81531bd6>] SyS_setsockopt+0xb6/0xd0
>     [<ffffffff8165f3e9>] system_call_fastpath+0x16/0x1b
>     [<ffffffffffffffff>] 0xffffffffffffffff
>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: stable@vger.kernel.org # 3.12
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  arch/x86/net/bpf_jit_comp.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
> index 516593e..3c55de5 100644
> --- a/arch/x86/net/bpf_jit_comp.c
> +++ b/arch/x86/net/bpf_jit_comp.c
> @@ -788,5 +788,6 @@ void bpf_jit_free(struct sk_filter *fp)
>         if (fp->bpf_func != sk_run_filter) {
>                 INIT_WORK(&fp->work, bpf_jit_free_deferred);
>                 schedule_work(&fp->work);
> -       }
> +       } else
> +               kfree(fp);

please add extra { } after else

Thanks
Alexei
