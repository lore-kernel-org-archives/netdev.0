From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/7] net: speedup netns create/delete time
Date: Mon, 18 Sep 2017 12:07:26 -0700
Message-ID: <20170918190733.26272-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:47101 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbdIRTHi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:07:38 -0400
Received: by mail-pf0-f174.google.com with SMTP id e199so712934pfh.3
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:07:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rate of netns creation/deletion is high enough,
we observe softlockups in cleanup_net() caused by huge list
of netns and way too many rcu_barrier() calls.

This patch series does some optimizations in kobject,
and add batching to tunnels so that netns dismantles are
less costly.

IPv6 addrlabels also get a per netns list, and tcp_metrics
also benefit from batch flushing.

This gives me one order of magnitude gain.
(~50 ms -> ~5 ms for one netns create/delete pair)

Tested:

for i in `seq 1 40`
do
 (for j in `seq 1 100` ; do  unshare -n /bin/true >/dev/null ; done) &
done
wait ; grep net_namespace /proc/slabinfo

Before patch series :

$ time ./add_del_unshare.sh
net_namespace        116    258   5504    1    2 : tunables    8    4    0 : slabdata    116    258      0

real	3m24.910s
user	0m0.747s
sys	0m43.162s

After :
$ time ./add_del_unshare.sh
net_namespace        135    291   5504    1    2 : tunables    8    4    0 : slabdata    135    291      0

real	0m22.117s
user	0m0.728s
sys	0m35.328s

Eric Dumazet (7):
  kobject: add kobject_uevent_net_broadcast()
  kobject: copy env blob in one go
  kobject: factorize skb setup in kobject_uevent_net_broadcast()
  ipv6: addrlabel: per netns list
  tcp: batch tcp_net_metrics_exit
  ipv6: speedup ipv6 tunnels dismantle
  ipv4: speedup ipv6 tunnels dismantle

 include/net/ip_tunnels.h |  3 +-
 include/net/netns/ipv6.h |  5 +++
 lib/kobject_uevent.c     | 95 ++++++++++++++++++++++++++----------------------
 net/ipv4/ip_gre.c        | 22 +++++------
 net/ipv4/ip_tunnel.c     | 13 +++++--
 net/ipv4/ip_vti.c        |  7 ++--
 net/ipv4/ipip.c          |  7 ++--
 net/ipv4/tcp_metrics.c   | 14 ++++---
 net/ipv6/addrlabel.c     | 81 +++++++++++++++--------------------------
 net/ipv6/ip6_gre.c       |  8 ++--
 net/ipv6/ip6_tunnel.c    | 20 +++++-----
 net/ipv6/ip6_vti.c       | 23 +++++++-----
 net/ipv6/sit.c           |  9 +++--
 13 files changed, 159 insertions(+), 148 deletions(-)

-- 
2.14.1.690.gbb1197296e-goog
