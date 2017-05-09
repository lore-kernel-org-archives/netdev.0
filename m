From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Mon, 08 May 2017 19:18:22 -0700
Message-ID: <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
         <20170508.143557.105629611489969352.davem@davemloft.net>
         <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170508.212211.1291611254198273979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        andreyknvl@google.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34869 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754479AbdEICS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 22:18:29 -0400
Received: by mail-pg0-f67.google.com with SMTP id i63so13015162pgd.2
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 19:18:29 -0700 (PDT)
In-Reply-To: <20170508.212211.1291611254198273979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-08 at 21:22 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 08 May 2017 17:01:20 -0700
> 
> > On Mon, 2017-05-08 at 14:35 -0400, David Miller wrote:
> >> From: Cong Wang <xiyou.wangcong@gmail.com>
> >> Date: Thu,  4 May 2017 14:54:17 -0700
> >> 
> >> > IPv4 dst could use fi->fib_metrics to store metrics but fib_info
> >> > itself is refcnt'ed, so without taking a refcnt fi and
> >> > fi->fib_metrics could be freed while dst metrics still points to
> >> > it. This triggers use-after-free as reported by Andrey twice.
> >> > 
> >> > This patch reverts commit 2860583fe840 ("ipv4: Kill rt->fi") to
> >> > restore this reference counting. It is a quick fix for -net and
> >> > -stable, for -net-next, as Eric suggested, we can consider doing
> >> > reference counting for metrics itself instead of relying on fib_info.
> >> > 
> >> > IPv6 is very different, it copies or steals the metrics from mx6_config
> >> > in fib6_commit_metrics() so probably doesn't need a refcnt.
> >> > 
> >> > Decnet has already done the refcnt'ing, see dn_fib_semantic_match().
> >> > 
> >> > Fixes: 2860583fe840 ("ipv4: Kill rt->fi")
> >> > Reported-by: Andrey Konovalov <andreyknvl@google.com>
> >> > Tested-by: Andrey Konovalov <andreyknvl@google.com>
> >> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> >> 
> >> Applied and queued up for -stable, thanks.
> > 
> > Although I now have on latest net tree these messages when I reboot my
> > test machine.
> > 
> > [  224.085873] unregister_netdevice: waiting for eth0 to become free. Usage count = 43
> 
> Strange, the refcounting looks quite OK in the patch you're quoting.
> I looked over it a few times and cannot figure out a possible cause
> there.
> 
> I am assuming you are quite confident it is this change?

At least, reverting the patch resolves the issue for me.

Keeping fib (and their reference to netdev) is apparently too much,
we probably need to implement a refcount on the metrics themselves,
being stand alone objects.
