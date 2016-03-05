From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 05 Mar 2016 11:33:12 -0500 (EST)
Message-ID: <20160305.113312.1758700509401944239.davem@davemloft.net>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
	<20160304.231109.1838919633640757059.davem@davemloft.net>
	<20160305155714.GM4184@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbcCEQdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 11:33:15 -0500
In-Reply-To: <20160305155714.GM4184@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Sat, 5 Mar 2016 18:57:14 +0300

> On Fri, Mar 04, 2016 at 11:11:09PM -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 04 Mar 2016 16:08:30 -0800
>> 
>> > __inet_del_ifa() should probably take into account in_dev->dead (no
>> > promotion, no list scan...)
>> 
>> Indeed, that is the real problem:
> 
> Well, tried it out. Indeed it partially released the contention
> but with patch applied I stuck with
 ...
> and until everything get cleaned up I couldn't connect
> to the node via ssh. I continue playing with patch maybe
> I find some other optimization paths. Thanks!

What is the order of magnitude of the delay, as a function of
number of IP aliases installed, compred to before the patch?

The remaining cost you are seeing comes of course from the router
deletion, whose path is:

	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
		fib_inetaddr_event()
			fib_del_ifaddr(ifa, NULL);

Which does another full list scan trying to handle primaries and
secondaries.

Probably the same optimization can be applied there, see patch below.
And if that doesn't do it, there is a really easy way to batch the
delete by scanning the FIB tree in one go and deleting every entry
that points to "in_dev".  But I suspect we really won't need that.

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4734475..21add55 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -922,6 +922,9 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 		subnet = 1;
 	}
 
+	if (in_dev->dead)
+		goto no_promotions;
+
 	/* Deletion is more complicated than add.
 	 * We should take care of not to delete too much :-)
 	 *
@@ -997,6 +1000,7 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 		}
 	}
 
+no_promotions:
 	if (!(ok & BRD_OK))
 		fib_magic(RTM_DELROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
 	if (subnet && ifa->ifa_prefixlen < 31) {
