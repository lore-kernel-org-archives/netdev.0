From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Mon, 15 May 2017 11:34:57 -0700
Message-ID: <CAM_iQpXtWUZoGS_KEqfZc+ZbzYxaF1hbAV7H9Qd82=r4auJojw@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
 <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
 <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
 <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
 <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg> <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
 <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
 <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg> <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com>
 <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36034 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964990AbdEOSfT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:35:19 -0400
Received: by mail-qk0-f193.google.com with SMTP id y128so18799488qka.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 11:35:18 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 2:27 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         Now the main question: is FIB_LOOKUP_NOREF used
> everywhere in IPv4? I guess so. If not, it means
> someone can walk its res->fi NHs which is bad. I think,
> this will delay the unregistration for long time and we
> can not solve the problem.
>
>         If yes, free_fib_info() should not use call_rcu.
> Instead, fib_release_info() will start RCU callback to
> drop everything via a common function for fib_release_info
> and free_fib_info. As result, the last fib_info_put will
> just need to free fi->fib_metrics and fi.


Yes it is used. But this is a different problem from the
dev refcnt issue, right? I can send a separate patch to
address it.


>> Are you sure we are safe to call dev_put() in fib_release_info()
>> for _all_ paths, especially non-unregister paths? See:
>
>         Yep, dev_put is safe there...
>
>> commit e49cc0da7283088c5e03d475ffe2fdcb24a6d5b1
>> Author: Yanmin Zhang <yanmin_zhang@linux.intel.com>
>> Date:   Wed May 23 15:39:45 2012 +0000
>>
>>     ipv4: fix the rcu race between free_fib_info and ip_route_output_slow
>
>         ...as long as we do not set nh_dev to NULL
>

OK, fair enough, then I think the best solution here is to move
the dev_put() from free_fib_info_rcu() to fib_release_info(),
fib_nh is already removed from hash there anyway.


diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index da449dd..cb712d1 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -205,8 +205,6 @@ static void free_fib_info_rcu(struct rcu_head *head)
        struct fib_info *fi = container_of(head, struct fib_info, rcu);

        change_nexthops(fi) {
-               if (nexthop_nh->nh_dev)
-                       dev_put(nexthop_nh->nh_dev);
                lwtstate_put(nexthop_nh->nh_lwtstate);
                free_nh_exceptions(nexthop_nh);
                rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
@@ -246,6 +244,14 @@ void fib_release_info(struct fib_info *fi)
                        if (!nexthop_nh->nh_dev)
                                continue;
                        hlist_del(&nexthop_nh->nh_hash);
+                       /* We have to release these nh_dev here because a dst
+                        * could still hold a fib_info via rt->fi, we can't wait
+                        * for GC, a socket could hold the dst for a long time.
+                        *
+                        * This is safe, dev_put() alone does not really free
+                        * the netdevice, we just have to put the refcnt back.
+                        */
+                       dev_put(nexthop_nh->nh_dev);
                } endfor_nexthops(fi)
                fi->fib_dead = 1;
                fib_info_put(fi);


Thanks!
