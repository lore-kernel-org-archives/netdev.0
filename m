From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange packet drops with heavy firewalling
Date: Fri, 09 Apr 2010 13:47:42 +0200
Message-ID: <1270813662.2623.85.camel@edumazet-laptop>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:61058 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab0DILrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 07:47:47 -0400
Received: by bwz1 with SMTP id 1so2473937bwz.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 04:47:45 -0700 (PDT)
In-Reply-To: <m339z50x1l.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 avril 2010 =C3=A0 11:56 +0200, Benny Amorsen a =C3=A9cri=
t :
> I have a netfilter-box which is dropping packets. ethtool -S counts
> 10-20 rx_discards per second on the interface.
>=20
> The switch does not have flow control enabled; with flow control enab=
led
> the rx_discards turn into tx_on_sent which ultimately cause the same
> problem (the load is pretty constant so the switch has to drop the
> packets instead).
>=20
> perf top shows something like:
>              5201.00 -  6.7% : _spin_unlock_irqrestore
>              4232.00 -  5.5% : finish_task_switch
>              3597.00 -  4.6% : tg3_poll	[tg3]
>              3257.00 -  4.2% : handle_IRQ_event
>              2515.00 -  3.2% : tick_nohz_restart_sched_tick
>              1947.00 -  2.5% : nf_ct_tuple_equal
>              1927.00 -  2.5% : tg3_start_xmit	[tg3]
>              1879.00 -  2.4% : kmem_cache_alloc_node
>              1625.00 -  2.1% : tick_nohz_stop_sched_tick
>              1619.00 -  2.1% : ipt_do_table
>              1595.00 -  2.1% : ip_route_input
>              1547.00 -  2.0% : kmem_cache_free
>              1474.00 -  1.9% : __alloc_skb
>              1424.00 -  1.8% : fget_light
>              1391.00 -  1.8% : nf_iterate
>=20
> The rule set is quite large (more than 4000 rules), but organized so
> that each packet only has to traverse a few rules before getting
> accepted or rejected.
>=20
> When the problem started we were using a different server, an old
> two-socket 32-bit Xeon with hyperthreading. CPU usage often hit 100% =
on
> one CPU with that server. After replacing the server with a ProLiant
> DL160 G5 with a quad-core Xeon (without hyperthreading) the CPU usage
> rarely exceeds 10% on any CPU, but the packet loss persists.
>=20

might be micro bursts, check 'ethtool -g eth0' RX parameters (increase
RX ring from 200 to 511 if you want more buffers ?)

> We're using the built-in dual Broadcom Corporation NetXtreme BCM5722 =
Gigabit
> Ethernet PCI Express nics, and the kernel is
> kernel-2.6.32.9-70.fc12.x86_64 from Fedora. Next step is probably
> installing a better ethernet card, perhaps an Intel 82576-based one, =
so
> that we can get multiqueue support.
>=20

Sure, but before this, could you check

cat /proc/net/softnet_stat
cat /proc/interrupts
(check eth0 IRQS are delivered to one cpu)

grep . /proc/sys/net/ipv4/netfilter/ip_conntrack_*
(might need to increase ip_conntrack_buckets)

ethtool -c eth0
(might change coalesce params to reduce number of irqs)

ethtool -g eth0


