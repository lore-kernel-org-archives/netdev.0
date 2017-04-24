From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH v2 net] net: ipv6: regenerate host route if moved to gc list
Date: Mon, 24 Apr 2017 16:03:02 +0200
Message-ID: <CAAeHK+yg=1Bwa3o6-nG72T6MWDk0+n9-juqx-Saq9Yomv_EBhg@mail.gmail.com>
References: <1492879237-31566-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>, mmanning@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f169.google.com ([209.85.213.169]:35227 "EHLO
        mail-yb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1170335AbdDXODF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:03:05 -0400
Received: by mail-yb0-f169.google.com with SMTP id 6so58656504ybq.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 07:03:04 -0700 (PDT)
In-Reply-To: <1492879237-31566-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 22, 2017 at 6:40 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Taking down the loopback device wreaks havoc on IPv6 routes. By
> extension, taking a VRF device wreaks havoc on its table.
>
> Dmitry and Andrey both reported heap out-of-bounds reports in the IPv6
> FIB code while running syzkaller fuzzer. The root cause is a dead dst
> that is on the garbage list gets reinserted into the IPv6 FIB. While on
> the gc (or perhaps when it gets added to the gc list) the dst->next is
> set to an IPv4 dst. A subsequent walk of the ipv6 tables causes the
> out-of-bounds access.
>
> Andrey's reproducer was the key to getting to the bottom of this.
>
> With IPv6, host routes for an address have the dst->dev set to the
> loopback device. When the 'lo' device is taken down, rt6_ifdown initiates
> a walk of the fib evicting routes with the 'lo' device which means all
> host routes are removed. That process moves the dst which is attached to
> an inet6_ifaddr to the gc list and marks it as dead.
>
> The recent change to keep global IPv6 addresses added a new function
> fixup_permanent_addr that is called on admin up. That function restarts
> dad for an inet6_ifaddr and when it completes the host route attached
> to it is inserted into the fib. Since the route was marked dead and
> moved to the gc list, we get the reported out-of-bounds accesses. If
> the device with the address is taken down or the address is removed, the
> WARN_ON in fib6_del is triggered.
>
> All of those faults are fixed by regenerating the host route of the
> existing one has been moved to the gc list, something that can be
> determined by checking if the rt6i_ref counter is 0.
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - change ifp->rt under spinlock vs cmpxchg
> - add comment about rt6i_ref == 0
>
> Dmitry / Andrey: can you guys add this patch to your tree and run
> syzkaller tests? I'd like to confirm that all of the fib traces
> are fixed. Thanks.

Tried fuzzing with your patch, I don't see any fib6 related reports
any more, so it should be good. I'll let you know if I see some
possibly related crashes.

Thanks!

>
>  net/ipv6/addrconf.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 08f9e8ea7a81..97e86158bbcb 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3303,14 +3303,24 @@ static void addrconf_gre_config(struct net_device *dev)
>  static int fixup_permanent_addr(struct inet6_dev *idev,
>                                 struct inet6_ifaddr *ifp)
>  {
> -       if (!ifp->rt) {
> -               struct rt6_info *rt;
> +       /* rt6i_ref == 0 means the host route was removed from the
> +        * FIB, for example, if 'lo' device is taken down. In that
> +        * case regenerate the host route.
> +        */
> +       if (!ifp->rt || !atomic_read(&ifp->rt->rt6i_ref)) {
> +               struct rt6_info *rt, *prev;
>
>                 rt = addrconf_dst_alloc(idev, &ifp->addr, false);
>                 if (unlikely(IS_ERR(rt)))
>                         return PTR_ERR(rt);
>
> +               spin_lock(&ifp->lock);
> +               prev = ifp->rt;
>                 ifp->rt = rt;
> +               spin_unlock(&ifp->lock);
> +
> +               if (prev)
> +                       ip6_rt_put(prev);
>         }
>
>         if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {
> --
> 2.1.4
>
