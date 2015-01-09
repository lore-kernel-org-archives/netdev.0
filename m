From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net v3] gen_stats.c: Duplicate xstats buffer for later use
Date: Fri, 9 Jan 2015 14:35:41 -0800
Message-ID: <CAHA+R7OpbP_+iwh6X=sh4SsXJ4VreBjze7dPrV6Xh8RHEe+cGw@mail.gmail.com>
References: <20150108123343.GA8541@zenon.in.qult.net>
	<20150108133037.GA10389@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Ignacy_Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:59019 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbAIWfm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 17:35:42 -0500
Received: by mail-qg0-f44.google.com with SMTP id q107so11163214qgd.3
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 14:35:42 -0800 (PST)
In-Reply-To: <20150108133037.GA10389@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 5:30 AM, Ignacy Gaw=C4=99dzki
<ignacy.gawedzki@green-communications.fr> wrote:
> The gnet_stats_copy_app() function gets called, more often than not, =
with its
> second argument a pointer to an automatic variable in the caller's st=
ack.
> Therefore, to avoid copying garbage afterwards when calling
> gnet_stats_finish_copy(), this data is better copied to a dynamically=
 allocated
> memory that gets freed after use.

Good catch!

>
> Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communicat=
ions.fr>
> ---
>  net/core/gen_stats.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
> index 0c08062..c9f1fa8 100644
> --- a/net/core/gen_stats.c
> +++ b/net/core/gen_stats.c
> @@ -32,6 +32,9 @@ gnet_stats_copy(struct gnet_dump *d, int type, void=
 *buf, int size)
>         return 0;
>
>  nla_put_failure:
> +       kfree(d->xstats);
> +       d->xstats =3D NULL;
> +       d->xstats_len =3D 0;
>         spin_unlock_bh(d->lock);
>         return -1;
>  }

Although it is not your fault, the API sucks, gnet_stats_copy()
should not need to care about the error path of its caller.
I will cook a patch for it.

> @@ -305,7 +308,10 @@ int
>  gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
>  {
>         if (d->compat_xstats) {
> -               d->xstats =3D st;
> +               kfree(d->xstats);
> +               d->xstats =3D kmemdup(st, len, GFP_ATOMIC);
> +               if (!d->xstats)
> +                       goto kmalloc_failure;

Do we really need to call kfree() before kmemdup()?
I don't think gnet_stats_copy_app() is supposed to be called
twice before gnet_stats_copy_finish()?

Thanks.
