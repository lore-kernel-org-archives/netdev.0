From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] ipv4: Don't override return code from ip_route_input_noref()
Date: Thu, 31 Aug 2017 09:39:31 -0700
Message-ID: <CAEA6p_Dwtt3+VGzsEJMof33EVDHXhZPnjqaY-7WG1X=vgRk=gg@mail.gmail.com>
References: <c4d8970306e614ac139cf2f33ab5e6bb73b30154.1504194307.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Sabrina Dubroca <sdubroca@redhat.com>
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:34336 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751717AbdHaQjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 12:39:33 -0400
Received: by mail-ua0-f173.google.com with SMTP id l11so532318uaf.1
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 09:39:32 -0700 (PDT)
In-Reply-To: <c4d8970306e614ac139cf2f33ab5e6bb73b30154.1504194307.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> After ip_route_input() calls ip_route_input_noref(), another
> check on skb_dst() is done, but if this fails, we shouldn't
> override the return code from ip_route_input_noref(), as it
> could have been more specific (i.e. -EHOSTUNREACH).
>
> This also saves one call to skb_dst_force_safe() and one to
> skb_dst() in case the ip_route_input_noref() check fails.
>
> Reported-by: Sabrina Dubroca <sdubroca@redhat.com>
> Fixes: ad65a2f05695 ("ipv4: call dst_hold_safe() properly")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>

Acked-by: Wei Wang <weiwan@google.com>


On Thu, Aug 31, 2017 at 9:11 AM, Stefano Brivio <sbrivio@redhat.com> wrote:
> After ip_route_input() calls ip_route_input_noref(), another
> check on skb_dst() is done, but if this fails, we shouldn't
> override the return code from ip_route_input_noref(), as it
> could have been more specific (i.e. -EHOSTUNREACH).
>
> This also saves one call to skb_dst_force_safe() and one to
> skb_dst() in case the ip_route_input_noref() check fails.
>
> Reported-by: Sabrina Dubroca <sdubroca@redhat.com>
> Fixes: ad65a2f05695 ("ipv4: call dst_hold_safe() properly")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
> ---
>  include/net/route.h | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/include/net/route.h b/include/net/route.h
> index cb0a76d9dde1..1b09a9368c68 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -189,10 +189,11 @@ static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
>
>         rcu_read_lock();
>         err = ip_route_input_noref(skb, dst, src, tos, devin);
> -       if (!err)
> +       if (!err) {
>                 skb_dst_force_safe(skb);
> -       if (!skb_dst(skb))
> -               err = -EINVAL;
> +               if (!skb_dst(skb))
> +                       err = -EINVAL;
> +       }
>         rcu_read_unlock();
>
>         return err;
> --
> 2.9.4
>
