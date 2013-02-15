From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/1] eventfd: implementation of EFD_MASK flag
Date: Fri, 15 Feb 2013 03:45:20 +0100
Message-ID: <CAHXqBFKpByeeLPD5ibDxTW94wsLA3hSnqhakZ_8YQO_BDT7ruQ@mail.gmail.com>
References: <1360279763-4768-1-git-send-email-sustrik@250bpm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1360279763-4768-1-git-send-email-sustrik@250bpm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/2/8 Martin Sustrik <sustrik@250bpm.com>:
> When implementing network protocols in user space, one has to impleme=
nt
> fake user-space file descriptors to represent the sockets for the pro=
tocol.
[...]
> This patch implements new EFD_MASK flag which attempts to solve this =
problem.
[...]
> @@ -55,6 +64,9 @@ __u64 eventfd_signal(struct eventfd_ctx *ctx, __u64=
 n)
>  {
>         unsigned long flags;
>
> +       /* This function should never be used with eventfd in the mas=
k mode. */
> +       BUG_ON(ctx->flags & EFD_MASK);
> +
>         spin_lock_irqsave(&ctx->wqh.lock, flags);
>         if (ULLONG_MAX - ctx->count < n)
>                 n =3D ULLONG_MAX - ctx->count;
> @@ -123,12 +135,16 @@ static unsigned int eventfd_poll(struct file *f=
ile, poll_table *wait)
>         poll_wait(file, &ctx->wqh, wait);
>
>         spin_lock_irqsave(&ctx->wqh.lock, flags);
> -       if (ctx->count > 0)
> -               events |=3D POLLIN;
> -       if (ctx->count =3D=3D ULLONG_MAX)
> -               events |=3D POLLERR;
> -       if (ULLONG_MAX - 1 > ctx->count)
> -               events |=3D POLLOUT;
> +       if (ctx->flags & EFD_MASK) {
> +               events =3D ctx->mask.events;
> +       } else {
> +               if (ctx->count > 0)
> +                       events |=3D POLLIN;
> +               if (ctx->count =3D=3D ULLONG_MAX)
> +                       events |=3D POLLERR;
> +               if (ULLONG_MAX - 1 > ctx->count)
> +                       events |=3D POLLOUT;
> +       }
>         spin_unlock_irqrestore(&ctx->wqh.lock, flags);
>
>         return events;
[...]
> @@ -412,7 +464,12 @@ struct file *eventfd_file_create(unsigned int co=
unt, int flags)
>
>         kref_init(&ctx->kref);
>         init_waitqueue_head(&ctx->wqh);
> -       ctx->count =3D count;
> +       if (flags & EFD_MASK) {
> +               ctx->mask.events =3D 0;
> +               ctx->mask.ptr =3D NULL;
> +       } else {
> +               ctx->count =3D count;
> +       }
>         ctx->flags =3D flags;
>
>         file =3D anon_inode_getfile("[eventfd]", &eventfd_fops, ctx,

Since EFD_MASK is a persistent flag for a fd's lifetime, maybe you
could instead of all those if/elses and BUG_ON()s use another
file_operations struct for this feature?

Best Regards,
Micha=C5=82 Miros=C5=82aw
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
