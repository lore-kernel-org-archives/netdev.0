From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v2 net-next 0/7] net: speedup netns create/delete time
Date: Tue, 26 Sep 2017 14:21:08 +0300
Message-ID: <8edb310a-562d-bff1-0482-64314833e722@mellanox.com>
References: <20170919232709.14690-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Yonatan Cohen <yonatanc@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0067.outbound.protection.outlook.com ([104.47.2.67]:22422
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1030323AbdIZLVP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 07:21:15 -0400
In-Reply-To: <20170919232709.14690-1-edumazet@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 20/09/2017 2:27 AM, Eric Dumazet wrote:
> When rate of netns creation/deletion is high enough,
> we observe softlockups in cleanup_net() caused by huge list
> of netns and way too many rcu_barrier() calls.
> 
> This patch series does some optimizations in kobject,
> and add batching to tunnels so that netns dismantles are
> less costly.
> 
> IPv6 addrlabels also get a per netns list, and tcp_metrics
> also benefit from batch flushing.
> 
> This gives me one order of magnitude gain.
> (~50 ms -> ~5 ms for one netns create/delete pair)
> 
...
> 
> Eric Dumazet (7):
>    kobject: add kobject_uevent_net_broadcast()
>    kobject: copy env blob in one go
>    kobject: factorize skb setup in kobject_uevent_net_broadcast()
>    ipv6: addrlabel: per netns list
>    tcp: batch tcp_net_metrics_exit
>    ipv6: speedup ipv6 tunnels dismantle
>    ipv4: speedup ipv6 tunnels dismantle
> 
>   include/net/ip_tunnels.h |  3 +-
>   include/net/netns/ipv6.h |  5 +++
>   lib/kobject_uevent.c     | 94 ++++++++++++++++++++++++++----------------------
>   net/ipv4/ip_gre.c        | 22 +++++-------
>   net/ipv4/ip_tunnel.c     | 12 +++++--
>   net/ipv4/ip_vti.c        |  7 ++--
>   net/ipv4/ipip.c          |  7 ++--
>   net/ipv4/tcp_metrics.c   | 14 +++++---
>   net/ipv6/addrlabel.c     | 81 ++++++++++++++++-------------------------
>   net/ipv6/ip6_gre.c       |  8 +++--
>   net/ipv6/ip6_tunnel.c    | 20 ++++++-----
>   net/ipv6/ip6_vti.c       | 23 +++++++-----
>   net/ipv6/sit.c           |  9 +++--
>   13 files changed, 157 insertions(+), 148 deletions(-)
> 

Hi Eric,

We see a regression introduced in this series, specifically in the 
patches touching lib/kobject_uevent.c.
We tried to figure out what is wrong there, but couldn't point it out.

Bug is that mlx4 driver restart fails, because mlx4_core is still in use.
According to module dependencies, both mlx4_en and mlx4_ib should have 
been unloaded at this point
Please see log below.

This looks to be some kind of a race, as the repro is not deterministic.
Probably the en/ib modules are now mistakenly reloaded.

Any idea what could this be?

Regards,
Tariq


[root@reg-l-vrt-41016-009 ~]# /etc/init.d/openibd stop
Unloading HCA driver:                                      [  OK  ]
[root@reg-l-vrt-41016-009 ~]# /etc/init.d/openibd start
Loading HCA driver and Access Layer:                       [  OK  ]
[root@reg-l-vrt-41016-009 ~]# /etc/init.d/openibd stop
Unloading mlx4_core                                        [FAILED]
rmmod: ERROR: Module mlx4_core is in use
