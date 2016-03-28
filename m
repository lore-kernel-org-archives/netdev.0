From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: add proper locking in __inet{6}_lookup()
Date: Mon, 28 Mar 2016 06:29:32 -0700
Message-ID: <1459171772.6473.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458944115.6473.62.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160327.223222.486104825905902179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35917 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbcC1N3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 09:29:45 -0400
Received: by mail-pa0-f46.google.com with SMTP id tt10so98140882pab.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 06:29:44 -0700 (PDT)
In-Reply-To: <20160327.223222.486104825905902179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-03-27 at 22:32 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 25 Mar 2016 15:15:15 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Blocking BH in __inet{6}_lookup() is not correct, as the lookups
> > are done using RCU protection.
> > 
> > It matters only starting from Lorenzo Colitti patches to destroy
> > a TCP socket, since rcu_read_lock() is already held by other users
> > of these functions.
> > 
> > This can be backported to all known stable versions, since TCP got RCU
> > lookups back in 2.6.29 : Even if iproute2 contained no code to trigger
> > the bug, some user programs could have used the API.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Lorenzo Colitti <lorenzo@google.com>
> 
> This is quite the maze of RCU locking here.  With this change,
> inet_lookup is now:
> 
> 	rcu_read_lock();
> 	sk = x(); {
> 		rcu_read_lock();
> 		...
> 		rcu_read_unlock();
> 	}
> 	if (!sk) {
> 		sk = y(); {
> 			rcu_read_lock();
> 			...
> 			rcu_read_unlock();
> 		}
> 	}
> 	rcu_read_unlock();
> 
> It would seem to me that we should bubble up the rcu locking calls.
> 
> If, as you say, the other users do RCU locking already, then it should
> be safe to do what your patch is doing and also remove the RCU locking
> done by __inet_lookup_established() and __inet_lookup_listener().
> 

Sure, but the caller changed quite a lot in all stable versions.

I took the easiest path for stable maintainers, and was planing to
implement a better way in net-next.

I certainly can take the final form and let you do the backports ?

Thanks.
