From: David Ahern <dsahern@gmail.com>
Subject: Re: net/ipv6: GPF in rt6_device_match
Date: Wed, 3 May 2017 12:22:35 -0600
Message-ID: <4ef76406-8e05-ccdf-fefb-dc47d56c71c9@gmail.com>
References: <CAAeHK+yfX9ZtpFMTFXKAtjYE17MDBXMQJS_mH0b3=xTuv3jk9g@mail.gmail.com>
 <CAM_iQpUtVZiKTxnUBYEPLQzJSK+G_=Be-uzwuqph6g2VPsZijw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34310 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdECSWj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 14:22:39 -0400
In-Reply-To: <CAM_iQpUtVZiKTxnUBYEPLQzJSK+G_=Be-uzwuqph6g2VPsZijw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/17 11:02 AM, Cong Wang wrote:
> A quick glance shows we need to simply check local->rt6i_idev
> since we do the same check for sprt right above.

As I recall, rt6i_idev is set for all routes except null_entry and it is
not set on null_entry only because of initialization order.

> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index a1bf426..61ec3c8 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -511,7 +511,7 @@ static inline struct rt6_info
> *rt6_device_match(struct net *net,
>                                     sprt->rt6i_idev->dev->ifindex != oif) {
>                                         if (flags & RT6_LOOKUP_F_IFACE)
>                                                 continue;
> -                                       if (local &&
> +                                       if (local && local->rt6i_idev &&
> 
> local->rt6i_idev->dev->ifindex == oif)
>                                                 continue;
>                                 }
> 

Or don't consider null_entry at all:


@@ -515,7 +528,8 @@ static inline struct rt6_info
*rt6_device_match(struct net *net,

local->rt6i_idev->dev->ifindex == oif)
                                                continue;
                                }
-                               local = sprt;
+                               if (sprt != net->ipv6.ip6_null_entry)
+                                       local = sprt;
                        }
