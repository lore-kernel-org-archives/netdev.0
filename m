From: Andrew Yourtchenko <ayourtch@gmail.com>
Subject: Re: [PATCH v2 1/2] ipv6: save route expiry in RTA_EXPIRES if
 RTF_EXPIRES set
Date: Mon, 22 Aug 2016 13:41:41 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1608221334210.31827@ayourtch-u1604b2>
References: <1471355943-21288-1-git-send-email-ayourtch@gmail.com> <cover.1471622715.git.ayourtch@gmail.com> <d9679ca53d5162eaa88ac5050410e1b4fb3c2874.1471622715.git.ayourtch@gmail.com> <1471638376.29842.113.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33254 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbcHVLlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:41:50 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so13068811wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:41:49 -0700 (PDT)
In-Reply-To: <1471638376.29842.113.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Aug 2016, Eric Dumazet wrote:

> On Fri, 2016-08-19 at 18:41 +0200, Andrew Yourtchenko wrote:
> > This allows "ip -6 route save" to save the expiry for the routes
> > that have it, such that it can be correctly restored later by
> > "ip -6 route restore".
> > 
> > If a route has RTF_EXPIRES set, generate RTA_EXPIRES value which
> > will be used to restore the flag and expiry value by already
> > existing code in rtm_to_fib6_config.
> > 
> > The expiry was already being saved as part of RTA_CACHEINFO
> > in rtnl_put_cacheinfo(), but adding code to generate RTF_EXPIRES upon save
> > looked more appropriate than redundant cherrypicking from
> > RTA_CACHEINFO upon restore.
> > 
> > Signed-off-by: Andrew Yourtchenko <ayourtch@gmail.com>
> > ---
> > Changes since v1 [1]: 
> >  * fixed the indentation in a multiline function call
> >    as per David Miller's review
> > 
> > [1] v1: http://marc.info/?l=linux-netdev&m=147135597422280&w=2
> > 
> >  net/ipv6/route.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index 4981755..f5b987d 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -3244,6 +3244,14 @@ static int rt6_fill_node(struct net *net,
> >  	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
> >  		goto nla_put_failure;
> >  
> > +	/* Can't rely on expires == 0. It is zero if no expires flag,
> > +	 * or if the timing is precisely at expiry. So, recheck the flag.
> > +	 */
> > +	if (rt->rt6i_flags & RTF_EXPIRES)
> > +		if (nla_put_u32(skb, RTA_EXPIRES,
> > +				expires > 0 ? expires / HZ : 0))
> > +			goto nla_put_failure;
> > +
> 
> Why sending (kernel -> user) the value in second units, while the other
> direction (user -> kernel) expects hz ?

No, the userland does expect seconds, see below:

> 
> iproute2$ git grep -n RTA_EXPIRES
> include/linux/rtnetlink.h:389:  RTA_EXPIRES,
> ip/iproute.c:930:                       addattr32(&req.n, sizeof(req), RTA_EXPIRES, expires*hz);
> 

Fixed by commit eecc006952d6f3992b632974d0f04f995d2a176e
Author: Andrew Vagin <avagin@virtuozzo.com>
Date:   Wed Jun 29 02:27:14 2016 +0300

    ip route: timeout for routes has to be set in seconds

    Currently a timeout is multiplied by HZ in user-space and
    then it multiplied by HZ in kernel-space.


> kernel patch : (32bc201e1974976b7d3fea9a9b17bb7392ca6394)
> 
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> 
> @@ -2809,6 +2810,15 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
>         if (tb[RTA_ENCAP_TYPE])
>                 cfg->fc_encap_type = nla_get_u16(tb[RTA_ENCAP_TYPE]);
>  
> +       if (tb[RTA_EXPIRES]) {
> +               unsigned long timeout = addrconf_timeout_fixup(nla_get_u32(tb[RTA_EXPIRES]), HZ);
> +
> +               if (addrconf_finite_timeout(timeout)) {
> +                       cfg->fc_expires = jiffies_to_clock_t(timeout * HZ);
> +                       cfg->fc_flags |= RTF_EXPIRES;
> +               }
> +       }
> +
> 

Which is exactly the bug this snippet would trigger together with the 
older git grep that you have enclosed - the resulting value from user 
space assigned to fc_expires would have been:

jiffies_to_clock_t(timeout * HZ * hz).

So, the userland needs value in seconds. I suppose a good idea might be to 
change my comment within the commit into something like:

/* Can't rely on expires == 0. It is zero if no expires flag,
 * or if the timing is precisely at expiry. So, recheck the flag.
 * The division by HZ is to obtain the value in seconds, which
 * is needed by the userland, see commit
 * eecc006952d6f3992b632974d0f04f995d2a176e
 * "ip route: timeout for routes has to be set in seconds"
 */

What do you think ?

--a
