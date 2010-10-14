From: David Miller <davem@davemloft.net>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Thu, 14 Oct 2010 08:09:07 -0700 (PDT)
Message-ID: <20101014.080907.189690627.davem@davemloft.net>
References: <m1fww94ca6.fsf@fess.ebiederm.org>
	<20101013.215013.104074480.davem@davemloft.net>
	<m162x5492h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, daniel.lezcano@free.fr,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46989
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754181Ab0JNPIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 11:08:45 -0400
In-Reply-To: <m162x5492h.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 13 Oct 2010 22:20:28 -0700

> With the network namespace support we limit the scope of the test of
> the invalidate to just a single network namespace, and as such
> rt_is_expired stops being true for every cache entry.  So we cannot
> unconditionally throw away entire chains.
> 
> All of which can be either done by network namespace equality or by
> rt_is_expired().  Although Denis picked rt_is_expired() when he made
> his change.

Right, and I choose to use namespace equality which will completely
compile into no code at all when namespace support is not in the
kernel.

Therefore, making the non-namespace case equivalent and as efficient
as it always was.

> The only place it makes a noticable difference in practice is what
> happens when we do batched deleletes of lots of network devices in
> different network namespaces.
> 
> During batched network device deletes in fib_netdev_event we do
> rt_cache_flush(dev_net(dev), -1) for each network device.  and then a
> final rt_cache_flush_batch() to remove the invalidated entries.  These
> devices can be from multiple network namespaces, so I suspect that is
> a savings worth having.

How can it make a real difference even in this case?  We'll obliterate
all the entries, and then on subsequent passes we'll find nothing
matching that namespace any more.

Show me performance tests that show it makes any difference, please.

> So if we are going to change the tests we need to do something with
> rt_cache_flush_batch().  Further I do not see what is confusing about
> a test that asks if the routing cache entry is unusable.  Is
> rt_cache_expired() a bad name?

It's not a bad name, it's just an unnecessary test that we don't need
to even make in this specific place.

Redundancy tends to accumulate.
