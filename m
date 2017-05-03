From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: Do not duplicate DAD on link up
Date: Wed, 03 May 2017 09:46:57 -0400 (EDT)
Message-ID: <20170503.094657.2281913213391375194.davem@davemloft.net>
References: <1493761424-17407-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, andreyknvl@google.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdECNq7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 09:46:59 -0400
In-Reply-To: <1493761424-17407-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue,  2 May 2017 14:43:44 -0700

> Andrey reported a warning triggered by the rcu code:
 ...
> Andrey's reproducer program runs in a very tight loop, calling
> 'unshare -n' and then spawning 2 sets of 14 threads running random ioctl
> calls. The relevant networking sequence:
> 
> 1. New network namespace created via unshare -n
> - ip6tnl0 device is created in down state
> 
> 2. address added to ip6tnl0
> - equivalent to ip -6 addr add dev ip6tnl0 fd00::bb/1
> - DAD is started on the address and when it completes the host
>   route is inserted into the FIB
> 
> 3. ip6tnl0 is brought up
> - the new fixup_permanent_addr function restarts DAD on the address
> 
> 4. exit namespace
> - teardown / cleanup sequence starts
> - once in a blue moon, lo teardown appears to happen BEFORE teardown
>   of ip6tunl0
>   + down on 'lo' removes the host route from the FIB since the dst->dev
>     for the route is loobback
>   + host route added to rcu callback list
>     * rcu callback has not run yet, so rt is NOT on the gc list so it has
>       NOT been marked obsolete
> 
> 5. in parallel to 4. worker_thread runs addrconf_dad_completed
> - DAD on the address on ip6tnl0 completes
> - calls ipv6_ifa_notify which inserts the host route
> 
> All of that happens very quickly. The result is that a host route that
> has been deleted from the IPv6 FIB and added to the RCU list is re-inserted
> into the FIB.
> 
> The exit namespace eventually gets to cleaning up ip6tnl0 which removes the
> host route from the FIB again, calls the rcu function for cleanup -- and
> triggers the double rcu trace.
> 
> The root cause is duplicate DAD on the address -- steps 2 and 3. Arguably,
> DAD should not be started in step 2. The interface is in the down state,
> so it can not really send out requests for the address which makes starting
> DAD pointless.
> 
> Since the second DAD was introduced by a recent change, seems appropriate
> to use it for the Fixes tag and have the fixup function only start DAD for
> addresses in the PREDAD state which occurs in addrconf_ifdown if the
> address is retained.
> 
> Big thanks to Andrey for isolating a reliable reproducer for this problem.
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied and queued up for -stable, thanks!
