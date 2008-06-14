From: Petr Baudis <pasky@suse.cz>
Subject: NULL pointer dereference in fib6_del()
Date: Sat, 14 Jun 2008 16:24:48 +0200
Message-ID: <20080614142448.GK18781@machine.or.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from w241.dkm.cz ([62.24.88.241]:45081 "EHLO machine.or.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754816AbYFNOcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 10:32:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Hello,

  I have just hit an IPv6 bug in 2.6.25.4 on the server running
git.or.cz and repo.or.cz (it also serves as an XS26 router, so it has
huge number of tunnel interfaces and full IPv6 BGP feed in its routing
table); I probably triggered it by sending packets to a tentative
address:

3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen
100
    link/ether 00:30:48:30:bc:d0 brd ff:ff:ff:ff:ff:ff
    inet 62.24.64.27/24 brd 62.24.64.255 scope global eth0
    inet6 2a01:b0:0:2::/64 scope global tentative  <--
       valid_lft forever preferred_lft forever
    inet6 fe80::230:48ff:fe30:bcd0/64 scope link
       valid_lft forever preferred_lft forever

  The old repo.or.cz server re-appeared on the ethernet segment some
time ago and reclaimed 2a01:b0:0:2:: for itself (configuration error).
Pinging new server on the address triggered few shrieks of

	Jun 14 15:39:42 rover eth0: duplicate address detected!

but then a kaboom of

	Jun 14 15:41:23 rover NULL pointer dereference
	Jun 14 15:41:23 rover at 0000000000000028
	Jun 14 15:41:23 rover IP:
	Jun 14 15:41:23 rover [<ffffffff80400d95>] fib6_del+0x108/0x23d
	Jun 14 15:41:23 rover PGD 439b5067
	Jun 14 15:41:23 rover PUD 189a9067
	Jun 14 15:41:23 rover PMD 0
	Jun 14 15:41:23 rover Oops: 0000 [1]
	Jun 14 15:41:23 rover SMP
	Jun 14 15:41:23 rover CPU 0

followed by a quick collapse. Unfortunately, there seem to be three
oopses interleaved in parallel in my syslog, so the backtrace is hard to
make out with certainty, but it is probably:

	Jun 14 15:41:23 rover [<ffffffff80400f0c>] ? fib6_clean_node+0x42/0x9b
	Jun 14 15:41:23 rover [<ffffffff803baf94>] ? ip_queue_xmit+0x2c2/0x315
	Jun 14 15:41:23 rover [<ffffffff8040042c>] ? fib6_walk_continue+0x98/0x140
	Jun 14 15:41:23 rover [<ffffffff80400525>] ? fib6_walk+0x51/0x8d
	Jun 14 15:41:23 rover [<ffffffff80400589>] ? fib6_clean_tree+0x28/0x2d
	Jun 14 15:41:23 rover [<ffffffff803c0004>] ? tcp_cleanup_rbuf+0x77/0xe8
	Jun 14 15:41:23 rover [<ffffffff80400eca>] ? fib6_clean_node+0x0/0x9b
	Jun 14 15:41:23 rover [<ffffffff803c66b7>] ? tcp_ack+0x17b1/0x1970

  Has anyone seen anything like this before? Any tips on where the
problem could lie?

  Thanks,

-- 
				Petr "Pasky" Baudis
The last good thing written in C++ was the Pachelbel Canon. -- J. Olson
