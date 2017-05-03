From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: ipv6: Fix warning of freeing alive inet6 address
Date: Wed, 3 May 2017 10:58:19 -0700
Message-ID: <CAM_iQpVNqU7zJhOe2Qqn5Og+qer4RKhFwh4bdvRcAnt82zyj3A@mail.gmail.com>
References: <1493749857-18032-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33479 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754450AbdECR6l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 13:58:41 -0400
Received: by mail-wm0-f66.google.com with SMTP id y10so14591077wmh.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 10:58:40 -0700 (PDT)
In-Reply-To: <1493749857-18032-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 2, 2017 at 11:30 AM, Mike Manning <mmanning@brocade.com> wrote:
> While this is not reproducible manually, Andrey's syzkaller program hit
> the warning "IPv6: Freeing alive inet6 address" with this part trace:
>
> inet6_ifa_finish_destroy+0x12e/0x190 c:894
> in6_ifa_put ./include/net/addrconf.h:330
> addrconf_dad_work+0x4e9/0x1040 net/ipv6/addrconf.c:3963
>
> The fix is to call in6_ifa_put() for the inet6_ifaddr before rather
> than after calling addrconf_ifdown(), as the latter may remove it from
> the address hash table.
>
> Fixes: 85b51b12115c ("net: ipv6: Remove addresses for failures with strict DAD")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  net/ipv6/addrconf.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 80ce478..361993a 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3902,8 +3902,11 @@ static void addrconf_dad_work(struct work_struct *w)
>         } else if (action == DAD_ABORT) {
>                 in6_ifa_hold(ifp);
>                 addrconf_dad_stop(ifp, 1);
> -               if (disable_ipv6)
> +               if (disable_ipv6) {
> +                       in6_ifa_put(ifp);
>                         addrconf_ifdown(idev->dev, 0);
> +                       goto unlock;
> +               }


But addrconf_dad_stop() calls ipv6_del_addr() which could unhash
the addr too...
