From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Tue, 09 May 2017 15:54:11 -0700
Message-ID: <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
         <20170508.143557.105629611489969352.davem@davemloft.net>
         <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170508.212211.1291611254198273979.davem@davemloft.net>
         <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
         <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
         <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
         <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33759 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEIWyN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 18:54:13 -0400
Received: by mail-pg0-f68.google.com with SMTP id s62so1669914pgc.0
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 15:54:13 -0700 (PDT)
In-Reply-To: <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 15:52 -0700, Eric Dumazet wrote:
> On Tue, 2017-05-09 at 15:07 -0700, Cong Wang wrote:
> > On Tue, May 9, 2017 at 1:56 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > > Wait... if we transfer dst->dev to loopback_dev because we don't
> > > want to block unregister path, then we might have a similar problem
> > > for rt->fi too, fib_info is still referenced by dst, so these nh_dev's still
> > > hold the dev references...
> > >
> > 
> > I finally come up with the attach patch... Do you mind to give it a try?
> 
> I will, but this might be delayed by a few hours.
> 
> In the mean time, it looks like you could try adding the following to
> your .config ;)
> 
> CONFIG_IP_ROUTE_MULTIPATH=y
> 
> 

+                               /* This should be fine, we are on unregister
+                                * path so synchronize_net() already waits for
+                                * existing readers. We have to release the
+                                * dev here because dst could still hold this
+                                * fib_info via rt->fi, we can't wait for GC.
+                                */
+                               RCU_INIT_POINTER(nexthop_nh->nh_dev, NULL);
+                               dev_put(dev);
                                dead = fi->fib_nhs;

dead = fi->fib_mhs looks wrong if you remove the break; statement ?

-                               break;
                        }
