From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/6] ipv6: ipv6_dev_get_saddr() rcu works
Date: Sat,  7 Oct 2017 19:30:22 -0700
Message-ID: <20171008023028.32071-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:56337 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdJHCah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 22:30:37 -0400
Received: by mail-pg0-f44.google.com with SMTP id m18so5530830pgd.13
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 19:30:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending IPv6 udp packets on non connected sockets is quite slow,
because ipv6_dev_get_saddr() is still using an rwlock and silly
references games on ifa.

Tested:

$ ./super_netperf 16 -H 4444::555:0786 -l 2000 -t UDP_STREAM -- -m 100 &
[1] 12527

Performance is boosted from 2.02 Mpps to 4.28 Mpps

Kernel profile before patches :
  22.62%  [kernel]  [k] _raw_read_lock_bh
   7.04%  [kernel]  [k] refcount_sub_and_test
   6.56%  [kernel]  [k] ipv6_get_saddr_eval
   5.67%  [kernel]  [k] _raw_read_unlock_bh
   5.34%  [kernel]  [k] __ipv6_dev_get_saddr
   4.95%  [kernel]  [k] refcount_inc_not_zero
   4.03%  [kernel]  [k] __ip6addrlbl_match
   3.70%  [kernel]  [k] _raw_spin_lock
   3.44%  [kernel]  [k] ipv6_dev_get_saddr
   3.24%  [kernel]  [k] ip6_pol_route
   3.06%  [kernel]  [k] refcount_add_not_zero
   2.30%  [kernel]  [k] __local_bh_enable_ip
   1.81%  [kernel]  [k] mlx4_en_xmit
   1.20%  [kernel]  [k] __ip6_append_data
   1.12%  [kernel]  [k] __ip6_make_skb
   1.11%  [kernel]  [k] __dev_queue_xmit
   1.06%  [kernel]  [k] l3mdev_master_ifindex_rcu

Kernel profile after patches :
  11.36%  [kernel]  [k] ip6_pol_route
   7.65%  [kernel]  [k] _raw_spin_lock
   7.16%  [kernel]  [k] __ipv6_dev_get_saddr
   6.49%  [kernel]  [k] ipv6_get_saddr_eval
   6.04%  [kernel]  [k] refcount_add_not_zero
   3.34%  [kernel]  [k] __ip6addrlbl_match
   2.62%  [kernel]  [k] __dev_queue_xmit
   2.37%  [kernel]  [k] mlx4_en_xmit
   2.26%  [kernel]  [k] dst_release
   1.89%  [kernel]  [k] __ip6_make_skb
   1.87%  [kernel]  [k] __ip6_append_data
   1.86%  [kernel]  [k] udpv6_sendmsg
   1.86%  [kernel]  [k] ip6t_do_table
   1.64%  [kernel]  [k] ipv6_dev_get_saddr
   1.64%  [kernel]  [k] find_match
   1.51%  [kernel]  [k] l3mdev_master_ifindex_rcu
   1.24%  [kernel]  [k] ipv6_addr_label

Eric Dumazet (6):
  ipv6: prepare RCU lookups for idev->addr_list
  ipv6: rcu conversion of ipv6_count_addresses()
  ipv6: ipv6_chk_custom_prefix() rcu conversion
  ipv6: ipv6_chk_prefix() rcu conversion
  ipv6: __ipv6_dev_get_saddr() rcu conversion
  ipv6: avoid cache line dirtying in ipv6_dev_get_saddr()

 net/ipv6/addrconf.c | 70 +++++++++++++++++++----------------------------------
 1 file changed, 25 insertions(+), 45 deletions(-)
