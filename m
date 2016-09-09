From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 08 Sep 2016 19:35:02 -0700
Message-ID: <1473388502.18970.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473373012.18970.13.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAJD3hpUMdSt6UXEFjU9OnU4K7qiET50xo8AQ194+4vpX2CfOUA@mail.gmail.com>
         <CAJD3hpUDTZiJQ4YMiCizcYBKw=GD6jZoww3GxYjmajSdn6CE=g@mail.gmail.com>
         <20160908.170443.533565891486140434.davem@davemloft.net>
         <CAJD3hpVDo+WVVM0cvcD2z8LzXrsyBPvPC1E72ETN_yG2rNaeLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jojy Varghese <jojy.varghese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34435 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751372AbcIICfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 22:35:34 -0400
Received: by mail-pf0-f194.google.com with SMTP id g202so3287583pfb.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 19:35:04 -0700 (PDT)
In-Reply-To: <CAJD3hpVDo+WVVM0cvcD2z8LzXrsyBPvPC1E72ETN_yG2rNaeLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 17:35 -0700, Jojy Varghese wrote:
> Thanks for the feedback guys. I appreciate it.
> 
> I am working with 4.4.3 kernel.  I will try to reproduce the issue
> with the kernel tree at
> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git.
> 

Good.

Please do not top post on netdev.

> In the meantime, the only data I have now is :
> -  "dst-ifdown"  does not look correct since it will never release
> reference to loopback device.

Normally at netns dismantle, all sockets and devices holding references
to dst in this netns are closed and dst freed. Details are in various
notifiers.

At that time the dst->dev references will be released, including the
ones having dst->dev == loopback (on the soon to be freed netns)

We do not want to force in dst_ifdown() a dst->dev pointing nowhere, as
it might crash say when dst->dev is used later during a sendmsg() or
something like that.


> -  One way to fix might be to assign the 'dst''s net device to the
> init net device. I thought adding reference to init net device's
> loopback might be safe.
> 


You only make _rebooting_ the host not possible, since the problem of
having some reference on loopback device will still be there.

We really have to find the root cause, not simply working around it.
