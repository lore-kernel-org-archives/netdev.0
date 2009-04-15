From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: remove superfluous call to synchronize_net()
Date: Wed, 15 Apr 2009 14:54:54 -0700
Message-ID: <20090415215454.GU6766@linux.vnet.ibm.com>
References: <49E5FF5E.50409@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:37798 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbZDOVy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 17:54:57 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3FLimrx022710
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 17:44:48 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3FLssWh183304
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 17:54:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3FLsrnq029253
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 17:54:53 -0400
Content-Disposition: inline
In-Reply-To: <49E5FF5E.50409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 05:38:06PM +0200, Eric Dumazet wrote:
> inet_register_protosw() is adding inet_protosw to inetsw[] with appropriate
> locking section and rcu variant. No need to call synchronize_net() to wait
> for a RCU grace period. Changes are immediatly visible to other cpus anyway.

I agree with the conclusion (that this change is safe), but not with
the reasoning process.  ;-)

The reason that this change is safe is that any inter-process
communication mechanism used to tell other CPUs that this protocol has
been registered must contain relevant memory barriers, otherwise, that
mechanism won't be reliable.

If an unreliable mechanism was to be used, the other CPU might not yet see
the protocol.  For example, if the caller did a simple non-atomic store
to a variable that the other CPU accessed with a simple non-atomic load,
then that other CPU could potentially see the inetsw[] without the new
protocol, given that inet_create() is lockless.  Unlikely, but possible.

But if a proper inter-process communication mechanism is used to inform
the other CPU, then the first CPU's memory operations will be seen.

So I suggest a comment to this effect.

> This saves about 13 ms on boot time on a HZ=1000 8 cpus machine ;)
> (4 calls to inet_register_protosw(), and about 3200 us per call)
> 
> But more seriously, we should audit all synchronize_{rcu|net}() calls
> to make sure we dont waste time and hide some bugs because of artificial
> delays.

Good point!

							Thanx, Paul

> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 7f03373..1706896 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1003,8 +1003,6 @@ void inet_register_protosw(struct inet_protosw *p)
>  out:
>  	spin_unlock_bh(&inetsw_lock);
> 
> -	synchronize_net();
> -
>  	return;
> 
>  out_permanent:
