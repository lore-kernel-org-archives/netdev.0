From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: add proper locking in __inet{6}_lookup()
Date: Sun, 27 Mar 2016 22:32:22 -0400 (EDT)
Message-ID: <20160327.223222.486104825905902179.davem@davemloft.net>
References: <1458944115.6473.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbcC1Cc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 22:32:27 -0400
In-Reply-To: <1458944115.6473.62.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Mar 2016 15:15:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Blocking BH in __inet{6}_lookup() is not correct, as the lookups
> are done using RCU protection.
> 
> It matters only starting from Lorenzo Colitti patches to destroy
> a TCP socket, since rcu_read_lock() is already held by other users
> of these functions.
> 
> This can be backported to all known stable versions, since TCP got RCU
> lookups back in 2.6.29 : Even if iproute2 contained no code to trigger
> the bug, some user programs could have used the API.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Lorenzo Colitti <lorenzo@google.com>

This is quite the maze of RCU locking here.  With this change,
inet_lookup is now:

	rcu_read_lock();
	sk = x(); {
		rcu_read_lock();
		...
		rcu_read_unlock();
	}
	if (!sk) {
		sk = y(); {
			rcu_read_lock();
			...
			rcu_read_unlock();
		}
	}
	rcu_read_unlock();

It would seem to me that we should bubble up the rcu locking calls.

If, as you say, the other users do RCU locking already, then it should
be safe to do what your patch is doing and also remove the RCU locking
done by __inet_lookup_established() and __inet_lookup_listener().
