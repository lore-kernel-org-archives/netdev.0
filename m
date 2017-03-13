From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipv6: make ECMP route replacement less greedy
Date: Mon, 13 Mar 2017 13:28:09 +0100
Message-ID: <df56147ddfe635a61f29f651785c02c8c7c56e3d.1489403578.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Michal Kubecek <mkubecek@suse.cz>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Xin Long <lucien.xin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51252 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751204AbdCMM2v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 08:28:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 27596472473a ("ipv6: fix ECMP route replacement") introduced a
loop that removes all siblings of an ECMP route that is being
replaced. However, this loop doesn't stop when it has replaced
siblings, and keeps removing other routes with a higher metric.
We also end up triggering the WARN_ON after the loop, because after
this nsiblings < 0.

Instead, stop the loop when we have taken care of all routes with the
same metric as the route being replaced.

  Reproducer:
  ===========
    #!/bin/sh
    
    ip netns add ns1
    ip netns add ns2
    ip -net ns1 link set lo up
    
    for x in 0 1 2 ; do
        ip link add veth$x netns ns2 type veth peer name eth$x netns ns1
        ip -net ns1 link set eth$x up
        ip -net ns2 link set veth$x up
    done
    
    ip -net ns1 -6 r a 2000::/64 nexthop via fe80::0 dev eth0 \
            nexthop via fe80::1 dev eth1 nexthop via fe80::2 dev eth2
    ip -net ns1 -6 r a 2000::/64 via fe80::42 dev eth0 metric 256
    ip -net ns1 -6 r a 2000::/64 via fe80::43 dev eth0 metric 2048
    
    echo "before replace, 3 routes"
    ip -net ns1 -6 r | grep -v '^fe80\|^ff00'
    echo
    
    ip -net ns1 -6 r c 2000::/64 nexthop via fe80::4 dev eth0 \
            nexthop via fe80::5 dev eth1 nexthop via fe80::6 dev eth2
    
    echo "after replace, only 2 routes, metric 2048 is gone"
    ip -net ns1 -6 r | grep -v '^fe80\|^ff00'

Fixes: 27596472473a ("ipv6: fix ECMP route replacement")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/ipv6/ip6_fib.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index e4266746e4a2..d4bf2c68a545 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -923,6 +923,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			ins = &rt->dst.rt6_next;
 			iter = *ins;
 			while (iter) {
+				if (iter->rt6i_metric > rt->rt6i_metric)
+					break;
 				if (rt6_qualify_for_ecmp(iter)) {
 					*ins = iter->dst.rt6_next;
 					fib6_purge_rt(iter, fn, info->nl_net);
-- 
2.12.0
