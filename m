From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: ppp: don't call sk_chk_filter twice
Date: Sat, 12 Jul 2014 05:59:46 +0200
Message-ID: <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
References: <53BF8DEC.4000307@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Christoph Schulz <develop@kristov.de>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <53BF8DEC.4000307@kristov.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2014 at 9:10 AM, Christoph Schulz <develop@kristov.de> wrote:
> From: Christoph Schulz <develop@kristov.de>
>
> Commit 568f194e8bd16c353ad50f9ab95d98b20578a39d ("net: ppp: use
> sk_unattached_filter api") causes sk_chk_filter() to be called twice when
> setting a pass or active filter. The first call is from within get_filter().
> The second one is through the call chain
>
>   ppp_ioctl() --> sk_unattached_filter_create()
>               --> __sk_prepare_filter()
>               --> sk_chk_filter()
>
> However, sk_chk_filter() is not idempotent as it sometimes replaces filter
> codes. So running it a second time over the same filter does not work and

It's a good thing not to call sk_chk_filter() twice, but the commit
log is incorrect.
sk_chk_filter() doesn't replace filter codes anymore.

> yields EINVAL. The net effect is that setting pass and/or active PPP filters
> does not work anymore, since sk_unattached_filter_create() always returns
> EINVAL due to the second (and erroneous) call to sk_chk_filter(), regardless
> whether the filter was sane or not. So this patch simply removes the call to
> sk_chk_filter() from within get_filter(). This is safe as the filter will
> be checked by sk_chk_filter() later anyway.
>
> This error is found in exactly the same way in the isdn4linux PPP driver, so
> it is fixed there the same way.
>
> Signed-off-by: Christoph Schulz <develop@kristov.de>
> ---
> diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
> index 61ac632..a333b7f 100644
> --- a/drivers/isdn/i4l/isdn_ppp.c
> +++ b/drivers/isdn/i4l/isdn_ppp.c
> @@ -442,7 +442,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
>  {
>         struct sock_fprog uprog;
>         struct sock_filter *code = NULL;
> -       int len, err;
> +       int len;
>
>         if (copy_from_user(&uprog, arg, sizeof(uprog)))
>                 return -EFAULT;
> @@ -458,12 +458,6 @@ static int get_filter(void __user *arg, struct sock_filter **p)
>         if (IS_ERR(code))
>                 return PTR_ERR(code);
>
> -       err = sk_chk_filter(code, uprog.len);
> -       if (err) {
> -               kfree(code);
> -               return err;
> -       }
> -
>         *p = code;
>         return uprog.len;
>  }
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index 91d6c12..e2f20f8 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -539,7 +539,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
>  {
>         struct sock_fprog uprog;
>         struct sock_filter *code = NULL;
> -       int len, err;
> +       int len;
>
>         if (copy_from_user(&uprog, arg, sizeof(uprog)))
>                 return -EFAULT;
> @@ -554,12 +554,6 @@ static int get_filter(void __user *arg, struct sock_filter **p)
>         if (IS_ERR(code))
>                 return PTR_ERR(code);
>
> -       err = sk_chk_filter(code, uprog.len);
> -       if (err) {
> -               kfree(code);
> -               return err;
> -       }
> -
>         *p = code;
>         return uprog.len;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
