From: Masami Ichikawa <masami256@gmail.com>
Subject: Re: [PATCH] seccomp: fix memory leak on filter attach
Date: Tue, 15 Apr 2014 08:30:06 +0900
Message-ID: <CACOXgS9UNKk67TePoqRmiDQZLiyJeiz=qZqJxMTrtt78totnfA@mail.gmail.com>
References: <20140414171114.GA31384@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Will Drewry <wad@chromium.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Rashika Kheria <rashika.kheria@gmail.com>,
	James Morris <james.l.morris@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Paris <eparis@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140414171114.GA31384@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2014 at 2:11 AM, Kees Cook <keescook@chromium.org> wrote:
> This sets the correct error code when final filter memory is unavailable,
> and frees the raw filter no matter what.
>
> unreferenced object 0xffff8800d6ea4000 (size 512):
>   comm "sshd", pid 278, jiffies 4294898315 (age 46.653s)
>   hex dump (first 32 bytes):
>     21 00 00 00 04 00 00 00 15 00 01 00 3e 00 00 c0  !...........>...
>     06 00 00 00 00 00 00 00 21 00 00 00 00 00 00 00  ........!.......
>   backtrace:
>     [<ffffffff8151414e>] kmemleak_alloc+0x4e/0xb0
>     [<ffffffff811a3a40>] __kmalloc+0x280/0x320
>     [<ffffffff8110842e>] prctl_set_seccomp+0x11e/0x3b0
>     [<ffffffff8107bb6b>] SyS_prctl+0x3bb/0x4a0
>     [<ffffffff8152ef2d>] system_call_fastpath+0x1a/0x1f
>     [<ffffffffffffffff>] 0xffffffffffffffff
>
> Reported-by: Masami Ichikawa <masami256@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Cc: stable@vger.kernel.org

Tested-by: Masami Ichikawa <masami256@gmail.com>

> ---
>  kernel/seccomp.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index fd609bd9d6dd..2d7dcdfb7422 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -256,6 +256,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
>                 goto free_prog;
>
>         /* Allocate a new seccomp_filter */
> +       ret = -ENOMEM;
>         filter = kzalloc(sizeof(struct seccomp_filter) +
>                          sizeof(struct sock_filter_int) * new_len,
>                          GFP_KERNEL|__GFP_NOWARN);
> @@ -265,6 +266,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
>         ret = sk_convert_filter(fp, fprog->len, filter->insnsi, &new_len);
>         if (ret)
>                 goto free_filter;
> +       kfree(fp);
>
>         atomic_set(&filter->usage, 1);
>         filter->len = new_len;
> --
> 1.7.9.5
>
>
> --
> Kees Cook
> Chrome OS Security

-- 
Masami Ichikawa
