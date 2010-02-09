From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Tue, 09 Feb 2010 07:06:38 +0100
Message-ID: <1265695598.4236.95.camel@edumazet-laptop>
References: <1265639549.3048.33.camel@edumazet-laptop>
	 <1265657560.4236.80.camel@edumazet-laptop>
	 <20100208152606.91c55722.akpm@linux-foundation.org>
	 <20100208.153406.123254133.davem@davemloft.net>
	 <20100208153744.236158aa.akpm@linux-foundation.org>
	 <20100208155053.4ad68484@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36152 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010Ab0BIGGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 01:06:46 -0500
Received: by bwz19 with SMTP id 19so490080bwz.28
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 22:06:44 -0800 (PST)
In-Reply-To: <20100208155053.4ad68484@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 15:50 -0800, Stephen Hemminger a =C3=
=A9crit :

> No, cache doesn't help.
>=20
> Robert who is the expert in this area, runs with FIB TRIE and
> no routing cache.

Who knows, it probably depends on many factors. I always run with cache
enabled, because it saves cycles on moderate load.

=46IB_TRIE is unrelated here, if routing table is very small, it fits H=
ASH
or TRIE.

Pawel hit the bug with tunables that basically enabled the cache but in
a non helpful way (filling the list of busy dst). User error combined
with a lazy kernel function :)

Please note that conversion from softirq to workqueue, without
scheduling point, might/probably use same cpu for handling network irqs
and running dst_gc_task() :

On big routers, admins usually use irq affinities, so we can have very
litle cpu time available to run other tasks on those cpus.

After this patch, I believe that scheduler is allowed to migrate
dst_gc_task() to an idle cpu.

Another point (for 2.6.34) to address is the dst_gc_mutex that can dela=
y
NETDEV_UNREGISTER/NETDEV_DOWN events for a long period.



