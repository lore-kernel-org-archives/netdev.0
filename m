From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Tue, 9 May 2017 13:56:12 -0700
Message-ID: <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170508.143557.105629611489969352.davem@davemloft.net> <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170508.212211.1291611254198273979.davem@davemloft.net> <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com> <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:32980 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdEIU4e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 16:56:34 -0400
Received: by mail-wr0-f194.google.com with SMTP id w50so3239653wrc.0
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 13:56:33 -0700 (PDT)
In-Reply-To: <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 9, 2017 at 9:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-05-09 at 09:44 -0700, Cong Wang wrote:
>
>>
>> Eric, how did you produce it?
>> I guess it's because of nh_dev which is the only netdevice pointer inside
>> fib_info. Let me take a deeper look.
>>
>
> Nothing particular, I am using kexec to boot new kernels, and all my
> attempts with your patch included demonstrated the issue.


Interesting. So this happens on your eth0 teardown path, but
I don't see any problem in the related NETDEV_UNREGISTER
notifiers yet, we don't call dst_destroy() on this path and will defer it
to GC, but that should not be delayed for so long?

Wait... if we transfer dst->dev to loopback_dev because we don't
want to block unregister path, then we might have a similar problem
for rt->fi too, fib_info is still referenced by dst, so these nh_dev's still
hold the dev references...

Something like this (just for proof of concept):

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index da449dd..85cd614 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -205,7 +205,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
        struct fib_info *fi = container_of(head, struct fib_info, rcu);

        change_nexthops(fi) {
-               if (nexthop_nh->nh_dev)
+               if (nexthop_nh->nh_dev && !(nexthop_nh->nh_flags & RTNH_F_DEAD))
                        dev_put(nexthop_nh->nh_dev);
                lwtstate_put(nexthop_nh->nh_lwtstate);
                free_nh_exceptions(nexthop_nh);
@@ -1414,8 +1414,10 @@ int fib_sync_down_dev(struct net_device *dev,
unsigned long event, bool force)
                        else if (nexthop_nh->nh_dev == dev &&
                                 nexthop_nh->nh_scope != scope) {
                                switch (event) {
-                               case NETDEV_DOWN:
                                case NETDEV_UNREGISTER:
+                                       dev_put(dev);
+                                       /* fall through */
+                               case NETDEV_DOWN:
                                        nexthop_nh->nh_flags |= RTNH_F_DEAD;
                                        /* fall through */
                                case NETDEV_CHANGE:
