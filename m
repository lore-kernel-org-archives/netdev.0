From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 0/5] net: ipv6: Improve user experience with multipath routes
Date: Thu,  2 Feb 2017 12:37:07 -0800
Message-ID: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:32805 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751653AbdBBUhU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 15:37:20 -0500
Received: by mail-pg0-f44.google.com with SMTP id 204so8466924pge.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 12:37:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series closes a couple of gaps between IPv4 and IPv6 with respect
to multipath routes:

1. IPv4 allows all nexthops of multipath routes to be deleted using just
   the prefix and length; IPv6 only deletes the first nexthop for the
   route if only the prefix and length are given.

2. IPv4 returns multipath routes encoded in the RTA_MULTIPATH attribute.
   IPv6 returns a series of routes with the same prefix and length - one
   for each nexthop. This happens for both dumps and notifications.

IPv6 does accept RTA_MULTIPATH encoded routes, but installs them as a
series of routes.

Patch 1 addresses the first item by allowing IPv6 multipath routes to be
deleted using just the prefix and length. Patch 2 addresses the second
allowing IPv6 multipath routes to be returned encoded in the RTA_MULTIPATH.

Patches 3 and 4 upate the RTM_{NEW,DEL}ROUTE notifications to generate
1 notification with RTA_MULTIPATH where applicable.

Patch 5 prints IPv6 addresses in compressed format when showing route
replace errors. This was noticed testing REPLACE failures.

The end result for multipath routes:
1. Dump
   - RTA_MULTIPATH used for multipath routes

    $ ip -6 ro ls vrf red
    2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
    2001:db8:2::/120 dev eth2 proto kernel metric 256  pref medium
    2001:db8:200::/120 metric 1024
	    nexthop via 2001:db8:1::2  dev eth1 weight 1
	    nexthop via 2001:db8:2::2  dev eth2 weight 1
    ...


2. Route Add
   - one notification with RTA_MULTIPATH attribute

    $ ip -6 ro add vrf red 2001:db8:200::/120 nexthop via 2001:db8:1::2 nexthop via 2001:db8:2::2 

    $ ip mon route
    2001:db8:200::/120 table red metric 1024
	nexthop via 2001:db8:1::2  dev eth1 weight 1
	nexthop via 2001:db8:2::2  dev eth2 weight 1

2. Route Replace
   - one notification with RTA_MULTIPATH attribute

    $ ip -6 ro replace vrf red 2001:db8:200::/120 nexthop via 2001:db8:1::16 nexthop via 2001:db8:2::16

    $ ip mon route
    Replaced 2001:db8:200::/120 table red metric 1024
	    nexthop via 2001:db8:1::16  dev eth1 weight 1
	    nexthop via 2001:db8:2::16  dev eth2 weight 1

   - on a failure after the insertion of the first nexthop (which means
     the original route has been replaced in the FIB), a notification is
     sent with the successful nexthops and then the nexthops are deleted
     with one notification per hop. This is consistent with how it works
     today except the successful additions are coalesced into 1
     notification.


3. Route Delete
   - delete of entire multipath route using prefix/length only 1
     notification is generated:
    $ ip -6 ro del vrf red 2001:db8:200::/120

    $ ip mon route
    Deleted 2001:db8:200::/120 table red metric 1024
	    nexthop via 2001:db8:1::16  dev eth1 weight 1
	    nexthop via 2001:db8:2::16  dev eth2 weight 1

   - if a delete request contains nexthops one notification is
     generated per nexthop deleted. This is unavoidable since IPv6
     alllows a single nexthop to be deleted within a multipath route


4. Route Appends
   - IPv6 allows nexthops to be appended to an existing route. In this
     case one notification is sent for the new route with the append
     flag set.

    $ ip -6 ro append vrf red 2001:db8:200::/120 nexthop via 2001:db8:2::20 nexthop via 2001:db8:1::20

    $ ip mon route
    Append 2001:db8:200::/120 table red metric 1024
	    nexthop via 2001:db8:1::2  dev eth1 weight 1
	    nexthop via 2001:db8:2::2  dev eth2 weight 1
	    nexthop via 2001:db8:2::20  dev eth2 weight 1
	    nexthop via 2001:db8:1::20  dev eth1 weight 1

  - on failure of an append, a notification is sent with the route
    containing all of the nexthops successfully added, and it is
    followed by delete notifications as the hops are removed
    returning the route to its prior state. This is consistent with
    how it works today except the successful additions are coalesced
    into 1 notification.

Addresses some of the inconsistencies also noted by Roopa at netdev0.1:
https://www.netdev01.org/docs/prabhu-linux_ipv4_ipv6_inconsistencies_talk_slides.pdf

v4
- changed series to do encoding in 1 patch and updating notificatons
  in separate patches to make it easier to review and understand

- 1 notification for delete when using prefix/length; 1 notification for
  append

- handle delete of a single nexthop without RTA_MULTIPATH in delete request

- upated commit messages and cover letter


v3
- removed the need for a user API to opt-in to change. Requiring an
  API just shifts the difference from same API with different
  behavior to different API to achieve equivalent behavior
- route notifications changed to use RTA_MULTIPATH for add and replace
- upated commit messages and cover letter

v2
- fixed locking in patch 1 as noted by DaveM
- changed user API for patch 2 to require an rtmsg with RTM_F_ALL_NEXTHOPS
  set in rtm_flags
- revamped explanation of patch 2 and cover letter

David Ahern (5):
  net: ipv6: Allow shorthand delete of all nexthops in multipath route
  net: ipv6: Add support to dump multipath routes via RTA_MULTIPATH
    attribute
  net: ipv6: Change notifications for multipath add to RTA_MULTIPATH
  net: ipv6: Change notifications for multipath delete to RTA_MULTIPATH
  net: ipv6: Use compressed IPv6 addresses showing route replace error

 include/net/ip6_fib.h |   4 +-
 include/net/netlink.h |   1 +
 net/ipv6/ip6_fib.c    |  19 ++++-
 net/ipv6/route.c      | 228 +++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 227 insertions(+), 25 deletions(-)

-- 
2.1.4
