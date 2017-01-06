From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: Fix inconsistent rtnl_lock usage on
 dev_get_stats().
Date: Fri, 06 Jan 2017 12:13:23 -0800
Message-ID: <1483733603.9712.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483676478-14228-1-git-send-email-michael.chan@broadcom.com>
         <1483723976.9712.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170106.130134.50153126758574257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35183 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755202AbdAFUN3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:13:29 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so1463338pfa.2
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 12:13:25 -0800 (PST)
In-Reply-To: <20170106.130134.50153126758574257.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-06 at 13:01 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 06 Jan 2017 09:32:56 -0800
> 
> > This makes no sense to me.
> > 
> > RTNL is absolutely not needed to get device stats.
> > 
> > We try to not add RTNL, especially when not required.
> > 
> > Sure, RTNETLINK dumps currently hold RTNL, but we had various attempts
> > in the past to get rid of this behavior.
> > 
> > If a device driver expects RTNL being locked, it is clearly a bug that
> > needs a fix anyway.
> 
> This is extremely problematic when the driver has to synchronize some
> piece of state between the get stats method and open/close.  It is
> exactly the case we are trying to solve in tg3, and lots of drivers
> end up hitting the same exact issue.
> 
> If open/close can happen asynchronously to get stats, it is very hard
> to make dynamically allocated data structures or DMA buffers usable
> from the stats call.

Yes, I had some issues lately with mlx4. netdevices are protected by
RCU, adding proper RCU logic for the stats is doable.

> 
> Drivers in this situation will just add a mutex specifically for this
> situation if we don't consistently apply RTNL locking here.

Well, there are cases where RTNL is quite contended, but supervisions
like to get /proc/net/devices or various sysfs attributes
(netstat_show() can be called very very often
for /sys/class/net/*/statistics/*) in a reasonable amount of time.


I fear that such a change will add drifts, when devices are constantly
added/removed.
