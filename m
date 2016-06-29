From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH] ip route: timeout for routes has to be set in seconds
Date: Wed, 29 Jun 2016 18:26:47 +0800
Message-ID: <CADvbK_dZCz=5Ue1qkv_dh3R7UoHABjURK0OhLOr9eN-6pZ-1OA@mail.gmail.com>
References: <1467156434-2157-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Andrew Vagin <avagin@virtuozzo.com>,
	Hangbin Liu <liuhangbin@gmail.com>,
	Stephen Hemminger <shemming@brocade.com>
To: Andrey Vagin <avagin@openvz.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33052 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbcF2K0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 06:26:48 -0400
Received: by mail-qk0-f195.google.com with SMTP id n132so8809234qka.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 03:26:48 -0700 (PDT)
In-Reply-To: <1467156434-2157-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Jun 29, 2016 at 7:27 AM, Andrey Vagin <avagin@openvz.org> wrote:
> From: Andrew Vagin <avagin@virtuozzo.com>
>
> Currently a timeout is multiplied by HZ in user-space and
> then it multiplied by HZ in kernel-space.
>
> $ ./ip/ip r add 2002::0/64 dev veth1 expires 10
> $ ./ip/ip -6 r
> 2002::/64 dev veth1  metric 1024 linkdown  expires 996sec pref medium
>
> Cc: Xin Long <lucien.xin@gmail.com>
> Cc: Hangbin Liu <liuhangbin@gmail.com>
> Cc: Stephen Hemminger <shemming@brocade.com>
> Fixes: 68eede250500 ("route: allow routes to be configured with expire values")
> Signed-off-by: Andrew Vagin <avagin@virtuozzo.com>
> ---
>  ip/iproute.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 8224d7f..7c0f5a4 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -839,7 +839,6 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
>         int table_ok = 0;
>         int raw = 0;
>         int type_ok = 0;
> -       static int hz;
>
>         memset(&req, 0, sizeof(req));
>
> @@ -923,9 +922,7 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
>                         NEXT_ARG();
>                         if (get_u32(&expires, *argv, 0))
>                                 invarg("\"expires\" value is invalid\n", *argv);
> -                       if (!hz)
> -                               hz = get_user_hz();
> -                       addattr32(&req.n, sizeof(req), RTA_EXPIRES, expires*hz);
> +                       addattr32(&req.n, sizeof(req), RTA_EXPIRES, expires);
>                 } else if (matches(*argv, "metric") == 0 ||
>                            matches(*argv, "priority") == 0 ||
>                            strcmp(*argv, "preference") == 0) {
> --
> 2.7.4
>
This patch looks good to me.

There's another issue.
now  the expires transition with HZ happens in kernel when we add
route with expire, but when we dump,  the expires transition is in the
user-space:
                        if (ci->rta_expires != 0)
                                fprintf(fp, " expires %dsec",
ci->rta_expires/hz);

I'm not sure if  the *hz* value between kernel and user-space are
always same. I'd like to do this transition both in kernel. just like
ipaddr's
valid_lft, preferred_lft.
