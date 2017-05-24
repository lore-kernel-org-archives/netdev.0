From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 0/8] net: extend RTM_GETROUTE to return fib result
Date: Wed, 24 May 2017 11:19:03 -0700
Message-ID: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34541 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933768AbdEXSTR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 14:19:17 -0400
Received: by mail-pf0-f173.google.com with SMTP id 9so143115665pfj.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:19:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series adds a new RTM_F_FIB_MATCH flag to return matched fib result
with RTM_GETROUTE. This is useful for applications and protocols in
userspace wanting to query the selected route.

examples (with patched iproute2):
ipv4:
----
$ip route show
default via 192.168.0.2 dev eth0
10.0.14.0/24
        nexthop via 172.16.0.3  dev dummy0 weight 1
        nexthop via 172.16.1.3  dev dummy1 weight 1

$ip route get 10.0.14.2
10.0.14.2 via 172.16.1.3 dev dummy1  src 172.16.1.1 
    cache 

$ip route get fibmatch 10.0.14.2
10.0.14.0/24
        nexthop via 172.16.0.3  dev dummy0 weight 1
        nexthop via 172.16.1.3  dev dummy1 weight 1

ipv6:
----
$ip -6 route show
2001:db9:100::/120  metric 1024 
        nexthop via 2001:db8:2::2  dev dummy0 weight 1
        nexthop via 2001:db8:12::2  dev dummy1 weight 1

$ip -6 route get 2001:db9:100::1
2001:db9:100::1 from :: via 2001:db8:12::2 dev dummy1  src 2001:db8:12::1  metric 1024  pref medium

$ip -6 route get fibmatch 2001:db9:100::1
2001:db9:100::/120  metric 1024 
        nexthop via 2001:db8:12::2  dev dummy1 weight 1
        nexthop via 2001:db8:2::2  dev dummy0 weight 1


David Ahern (5):
  net: ipv4: refactor __ip_route_output_key_hash
  net: ipv4: refactor ip_route_input_noref
  net: ipv4: Remove event arg to rt_fill_info
  net: ipv4: Convert inet_rtm_getroute to rcu versions of route lookup
  net: ipv4: Save trie prefix to fib lookup result

Roopa Prabhu (3):
  net: ipv4: add new RTM_F_FIB_MATCH flag for use with RTM_GETROUTE
  net: ipv4: RTM_GETROUTE: return matched fib result when requested
  net: ipv6: RTM_GETROUTE: return matched fib result when requested

 include/net/ip_fib.h           |   1 +
 include/net/route.h            |  10 ++-
 include/uapi/linux/rtnetlink.h |   1 +
 net/ipv4/fib_trie.c            |   1 +
 net/ipv4/icmp.c                |   2 +-
 net/ipv4/route.c               | 160 ++++++++++++++++++++++++-----------------
 net/ipv6/route.c               |  11 ++-
 7 files changed, 116 insertions(+), 70 deletions(-)

-- 
1.9.1
