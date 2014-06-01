From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] net: filter: fix possible memory leak in __sk_prepare_filter()
Date: Sat, 31 May 2014 23:25:24 -0700
Message-ID: <CAMEtUuyw3uWp9VVDO+9-+z_GY3iTOi7+d-Y5pwfvr+G00ctQkg@mail.gmail.com>
References: <1401601045-7829-1-git-send-email-chianglungyu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Leon Yu <chianglungyu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:54051 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaFAGZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 02:25:26 -0400
Received: by mail-wi0-f169.google.com with SMTP id hi2so2868418wib.0
        for <netdev@vger.kernel.org>; Sat, 31 May 2014 23:25:25 -0700 (PDT)
In-Reply-To: <1401601045-7829-1-git-send-email-chianglungyu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 31, 2014 at 10:37 PM, Leon Yu <chianglungyu@gmail.com> wrote:
> __sk_prepare_filter() was reworked in commit bd4cf0ed3 (net: filter:
> rework/optimize internal BPF interpreter's instruction set) so that it should
> have uncharged memory once things went wrong. However that work isn't complete.
> Error is handled only in __sk_migrate_filter() while memory can still leak in
> the error path right after sk_chk_filter().
>
> Signed-off-by: Leon Yu <chianglungyu@gmail.com>

Nice catch. Thanks!
kmemleak confirmed the leak.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
Tested-by: Alexei Starovoitov <ast@plumgrid.com>
Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF
interpreter's instruction set")

Thankfully the fix doesn't have any conflicts with pending net-next patches.

> ---
>  net/core/filter.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 9d79ca0..4aec7b9 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1559,8 +1559,13 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
>         fp->jited = 0;
>
>         err = sk_chk_filter(fp->insns, fp->len);
> -       if (err)
> +       if (err) {
> +               if (sk != NULL)
> +                       sk_filter_uncharge(sk, fp);
> +               else
> +                       kfree(fp);
>                 return ERR_PTR(err);
> +       }
>
>         /* Probe if we can JIT compile the filter and if so, do
>          * the compilation of the filter.
> --
> 1.9.3
>
