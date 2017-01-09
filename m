From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/7] net: ivp4: return matching route for GETROUTE request
Date: Mon,  9 Jan 2017 13:32:44 -0800
Message-ID: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35387 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932800AbdAIVc5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:32:57 -0500
Received: by mail-pf0-f180.google.com with SMTP id f144so24367749pfa.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 13:32:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For complicated and highly populated route tables, RTM_GETROUTE requests
are an eye chart trying to match the response with the route entry that
was hit. This series solves that problem by returning the RIB entry that
was matched for a GETROUTE request as an a new nested attribute,
RTA_ROUTE_GET, that contains the typical RTA's for a route spec.

Example:
    $ ip ro get 10.10.10.10
    10.10.10.10 via 172.16.20.21 dev virt01 src 172.16.20.20 uid 0
        cache

    Matching route:
    10.10.10.10  encap mpls  100 via 172.16.20.21 dev virt01

Patches 1-3 refactor the existing input and output route lookups, moving
the rcu read lock protected sections into standalone functions that take
the fib_result as input an argument. inet_rtm_getroute is then converted
to use the new functions while holding the rcu read lock. Doing so gives
inet_rtm_getroute access to the matching fib_info.

Patch 4 refactors fib_dump_info, moving the code that adds route
attributes to a response into a separate function.

Patch 5 adds the prefix for the matching trie entry to fib_result.

Patch 6 then adds the prefix and matching fib_info to the GETROUTE
response using the fib_dump_add_attrs_rcu from Patch 4.

Patch 7 removes the event arg from rt_fill_info simplifying its
argument list.

IPv6 will be converted to return the same in a follow on patch set.

David Ahern (7):
  net: ipv4: refactor __ip_route_output_key_hash
  net: ipv4: refactor ip_route_input_noref
  net: ipv4: Convert inet_rtm_getroute to rcu versions of route lookup
  net: ipv4: refactor fib_dump_info
  net: ipv4: Save trie prefix to fib lookup result
  net: ipv4: return route match in GETROUTE request
  net: ipv4: Remove event arg to rt_fill_info

 include/net/ip_fib.h           |   1 +
 include/net/route.h            |  12 ++-
 include/uapi/linux/rtnetlink.h |   2 +
 net/ipv4/fib_lookup.h          |   2 +
 net/ipv4/fib_semantics.c       |  17 +++-
 net/ipv4/fib_trie.c            |   1 +
 net/ipv4/icmp.c                |   4 +-
 net/ipv4/route.c               | 177 +++++++++++++++++++++++++++--------------
 8 files changed, 149 insertions(+), 67 deletions(-)

-- 
2.1.4
