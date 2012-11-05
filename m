From: Maxime Bizon <mbizon@freebox.fr>
Subject: 3.6 routing cache regression, multicast loopback broken
Date: Mon, 05 Nov 2012 17:37:51 +0100
Message-ID: <1352133471.12029.43.camel@sakura.staff.proxad.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:49460 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750895Ab2KEQhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2012 11:37:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi David & all,


kernel 3.6 to 3.6.5 (3.5 is working fine)

I have a "sender" sample app that does:

  - socket(dgram)
  - setsockopt mcast ttl 8
  - setsockopt mcast loopback
  - sendto() to 239.0.0.x

and a "receiver" sample app:

  - socket(dgram)
  - bind(239.0.0.x)
  - add membership (239.0.0.x)
  - loop on recv()


My setup: no default route, "ip route add 239.0.0.0/8 dev eth0", sender
& receiver running on same host.

If I first start one sender app (on 239.0.0.1), and after a receiver app
on 239.0.0.1 => no problem

If I first start two or more sender apps (239.0.0.1/239.0.0.2/...), then
assuming I don't start as many matching receivers, receivers sometimes
get all data or nothing at all.


After digging in __mkroute_output(), I found that unless I'm using a
default route (fi != NULL), rtable is cached and shared by all senders
(even those with different mcast addresses)

Since ip_check_mc_rcu() returns different results depending on whether
fl->daddr is present in device mc_list or not, I don't think we can
cache this.

The random working/not working effect I get is because add_membership
flushes the rt_cache, so depending on which sender does sendto() first
after flush, the cached entry will either use ip_mc_output() or
ip_output().

-- 
Maxime
