From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] ipv6: all routes share same inetpeer
Date: Tue, 19 Jul 2011 19:23:49 +0200
Message-ID: <1311096229.2375.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34507 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337Ab1GSRX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 13:23:58 -0400
Received: by wwe5 with SMTP id 5so4410551wwe.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 10:23:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

While polishing a patch and testing it, I found that all ipv6 routes
shared the same inetpeer ! Oh well...


Apparently we call rt6_bind_peer() at wrong time, providing NULL
addresses.

Maybe you can find the bug before me ?

With following quick/dirty/debugging patch :

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 39d1230..f24391c 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -88,6 +88,7 @@ static inline struct inet_peer *inet_getpeer_v6(const struct in6_addr *v6daddr,
 
        ipv6_addr_copy((struct in6_addr *)daddr.addr.a6, v6daddr);
        daddr.family = AF_INET6;
+       WARN_ON(daddr.addr.a6[0] == 0 && daddr.addr.a6[1] == 0 && daddr.addr.a6[2] == 0 && daddr.addr.a6[3] == 0);
        return inet_getpeer(&daddr, create);
 }
 

I get for example :

[  299.024117] ------------[ cut here ]------------
[  299.024176] WARNING: at include/net/inetpeer.h:91 rt6_bind_peer+0x84/0xb0()
[  299.024234] Hardware name: ProLiant BL460c G1
[  299.024287] Modules linked in: xt_hashlimit ipmi_devintf ipmi_si ipmi_msghandler tg3 bonding
[  299.024583] Pid: 7119, comm: ping6 Tainted: G        W   3.0.0-rc7-03555-ge798b6e-dirty #1048
[  299.024657] Call Trace:
[  299.024709]  [<c1042b4d>] warn_slowpath_common+0x6d/0xa0
[  299.024765]  [<c1373104>] ? rt6_bind_peer+0x84/0xb0
[  299.024820]  [<c1373104>] ? rt6_bind_peer+0x84/0xb0
[  299.024875]  [<c1042b9d>] warn_slowpath_null+0x1d/0x20
[  299.024931]  [<c1373104>] rt6_bind_peer+0x84/0xb0
[  299.024985]  [<c13731ec>] ipv6_cow_metrics+0xbc/0xe0
[  299.025046]  [<c13722a8>] ip6_rt_copy+0x1e8/0x210
[  299.025101]  [<c1372a70>] rt6_alloc_cow.isra.32+0x10/0x1d0
[  299.025158]  [<c1048fb9>] ? local_bh_enable_ip+0x59/0xc0
[  299.025213]  [<c137356b>] ip6_pol_route.isra.37+0x29b/0x2a0
[  299.025270]  [<c13735a1>] ip6_pol_route_output+0x31/0x40
[  299.025325]  [<c1376277>] fib6_rule_lookup+0x17/0x20
[  299.025380]  [<c137238c>] ip6_route_output+0x5c/0xa0
[  299.025436]  [<c1373570>] ? ip6_pol_route.isra.37+0x2a0/0x2a0
[  299.025492]  [<c1365004>] ip6_dst_lookup_tail+0xd4/0xe0
[  299.025548]  [<c136519f>] ip6_dst_lookup_flow+0x2f/0x90
[  299.025604]  [<c1048fb9>] ? local_bh_enable_ip+0x59/0xc0
[  299.025660]  [<c1390ef4>] ip6_datagram_connect+0x174/0x490
[  299.025717]  [<c12bdd42>] ? release_sock+0xf2/0x150
[  299.025772]  [<c137d9a7>] ? udp_v6_get_port+0x47/0x60
[  299.025829]  [<c132f838>] inet_dgram_connect+0x28/0x70
[  299.025884]  [<c12bc5c0>] sys_connect+0x60/0xa0
[  299.025939]  [<c10d239e>] ? might_fault+0x2e/0x80
[  299.026001]  [<c13c438d>] ? _raw_spin_unlock+0x1d/0x20
[  299.026057]  [<c10d239e>] ? might_fault+0x2e/0x80
[  299.026117]  [<c10d23e4>] ? might_fault+0x74/0x80
[  299.026172]  [<c12bcfeb>] sys_socketcall+0xbb/0x2e0
[  299.026227]  [<c13c4fc3>] ? sysenter_exit+0xf/0x18
[  299.026282]  [<c11a3ec0>] ? trace_hardirqs_on_thunk+0xc/0x10
[  299.026338]  [<c13c4f90>] sysenter_do_call+0x12/0x36
[  299.026393] ---[ end trace 53d11c892332cf99 ]---


or :

[  299.032017] ------------[ cut here ]------------
[  299.032072] WARNING: at include/net/inetpeer.h:91 rt6_bind_peer+0x84/0xb0()
[  299.032130] Hardware name: ProLiant BL460c G1
[  299.032183] Modules linked in: xt_hashlimit ipmi_devintf ipmi_si ipmi_msghandler tg3 bonding
[  299.032482] Pid: 0, comm: kworker/0:1 Tainted: G        W   3.0.0-rc7-03555-ge798b6e-dirty #1048
[  299.032557] Call Trace:
[  299.032614]  [<c1042b4d>] warn_slowpath_common+0x6d/0xa0
[  299.032671]  [<c1373104>] ? rt6_bind_peer+0x84/0xb0
[  299.032725]  [<c1373104>] ? rt6_bind_peer+0x84/0xb0
[  299.032780]  [<c1042b9d>] warn_slowpath_null+0x1d/0x20
[  299.032835]  [<c1373104>] rt6_bind_peer+0x84/0xb0
[  299.032890]  [<c13731ec>] ipv6_cow_metrics+0xbc/0xe0
[  299.032945]  [<c1373a90>] icmp6_dst_alloc+0x1a0/0x2a0
[  299.033001]  [<c13738f0>] ? ip6_blackhole_route+0x240/0x240
[  299.033058]  [<c137a0bf>] ndisc_send_skb+0x4f/0x310
[  299.033113]  [<c137957b>] ? ndisc_fill_addr_option+0x5b/0x90
[  299.033169]  [<c137a3d2>] __ndisc_send+0x52/0x60
[  299.033224]  [<c137ad5d>] ndisc_send_ns+0x5d/0x90
[  299.033279]  [<c136b559>] ? ipv6_chk_addr+0x119/0x130
[  299.033335]  [<c137ae2f>] ndisc_solicit+0x9f/0x130
[  299.033391]  [<c12d8b8e>] neigh_timer_handler+0x10e/0x2a0
[  299.033447]  [<c105168a>] run_timer_softirq+0x13a/0x370
[  299.033503]  [<c1051608>] ? run_timer_softirq+0xb8/0x370
[  299.033558]  [<c12d8a80>] ? neigh_update+0x4c0/0x4c0
[  299.033614]  [<c1049577>] __do_softirq+0x97/0x1f0
[  299.033674]  [<c10494e0>] ? remote_softirq_receive+0x60/0x60



