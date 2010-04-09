From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Strange packet drops with heavy firewalling
Date: Fri, 09 Apr 2010 11:56:06 +0200
Message-ID: <m339z50x1l.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:48175 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757469Ab0DIJ4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Apr 2010 05:56:19 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1O0Awi-0006Ko-F1
	for netdev@vger.kernel.org; Fri, 09 Apr 2010 11:56:16 +0200
Received: from 94.127.50.7 ([94.127.50.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 11:56:16 +0200
Received: from benny+usenet by 94.127.50.7 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 11:56:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have a netfilter-box which is dropping packets. ethtool -S counts
10-20 rx_discards per second on the interface.

The switch does not have flow control enabled; with flow control enabled
the rx_discards turn into tx_on_sent which ultimately cause the same
problem (the load is pretty constant so the switch has to drop the
packets instead).

perf top shows something like:
             5201.00 -  6.7% : _spin_unlock_irqrestore
             4232.00 -  5.5% : finish_task_switch
             3597.00 -  4.6% : tg3_poll	[tg3]
             3257.00 -  4.2% : handle_IRQ_event
             2515.00 -  3.2% : tick_nohz_restart_sched_tick
             1947.00 -  2.5% : nf_ct_tuple_equal
             1927.00 -  2.5% : tg3_start_xmit	[tg3]
             1879.00 -  2.4% : kmem_cache_alloc_node
             1625.00 -  2.1% : tick_nohz_stop_sched_tick
             1619.00 -  2.1% : ipt_do_table
             1595.00 -  2.1% : ip_route_input
             1547.00 -  2.0% : kmem_cache_free
             1474.00 -  1.9% : __alloc_skb
             1424.00 -  1.8% : fget_light
             1391.00 -  1.8% : nf_iterate

The rule set is quite large (more than 4000 rules), but organized so
that each packet only has to traverse a few rules before getting
accepted or rejected.

When the problem started we were using a different server, an old
two-socket 32-bit Xeon with hyperthreading. CPU usage often hit 100% on
one CPU with that server. After replacing the server with a ProLiant
DL160 G5 with a quad-core Xeon (without hyperthreading) the CPU usage
rarely exceeds 10% on any CPU, but the packet loss persists.

We're using the built-in dual Broadcom Corporation NetXtreme BCM5722 Gigabit
Ethernet PCI Express nics, and the kernel is
kernel-2.6.32.9-70.fc12.x86_64 from Fedora. Next step is probably
installing a better ethernet card, perhaps an Intel 82576-based one, so
that we can get multiqueue support.

The traffic is about 300Mbps (twice that if you count both in and out,
like Cisco).


/Benny

