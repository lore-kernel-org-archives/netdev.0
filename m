From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] icmp: add a global rate limitation
Date: Mon, 22 Sep 2014 13:25:12 -0700
Message-ID: <1411417512.26859.152.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411137520.26859.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140922.160904.1566383839759663411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51969 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887AbaIVUZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:25:13 -0400
Received: by mail-pa0-f53.google.com with SMTP id hz1so5193265pad.12
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 13:25:13 -0700 (PDT)
In-Reply-To: <20140922.160904.1566383839759663411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-22 at 16:09 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 19 Sep 2014 07:38:40 -0700
> 
> > Current ICMP rate limiting uses inetpeer cache, which is an RBL tree
> > protected by a lock, meaning that hosts can be stuck hard if all cpus
> > want to check ICMP limits.
> 
> However, the replacement uses a single global spinlock for
> synchronization.
> 
>  ...
> > Note that if we really want to send millions of ICMP messages per
> > second, we might extend idea and infra added in commit 04ca6973f7c1a
> > ("ip: make IP identifiers less predictable") :
> > add a token bucket in the ip_idents hash and no longer rely on inetpeer.
> 
> That would be preferred.


> 
> I don't really see how this patch makes things better.  The code goes
> through a global spinlock unconditionally, and if it passes then it
> looks up the inetpeer anyways.
> 

The inetpeer is only hit at most 1000 times per second, which is a
rather low rate.


> I need more information to be convinced that this is an improvement
> and that it actually solves the stated problem.  I'm sure you also
> have some performance metrics to share, right? :-)

It does not use the global spinlock in the stress situation.

I tested this patch I can tell you it works ;)

+       /* Check if token bucket is empty and cannot be refilled
+        * without taking the spinlock.
+        */
+       if (!icmp_global.credit) {
+               delta = min_t(u32, now - icmp_global.stamp, HZ);
+               if (delta < HZ / 50)
+                       return false;
+       }
+

So if we are under pressure (credit is exhausted), we exit early unless
20ms were elapsed, and in this case we'll refill the token bucket.

Thanks
