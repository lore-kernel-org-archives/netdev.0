From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with multipath routes
Date: Fri, 27 Jan 2017 15:20:54 -0800
Message-ID: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36756 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750724AbdA0XWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 18:22:03 -0500
Received: by mail-pf0-f179.google.com with SMTP id 189so76466774pfu.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 15:21:04 -0800 (PST)
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

Patch 2 addresses the first item by allowing IPv6 multipath routes to be
deleted using just the prefix and length. Patch 3 addresses the second
allowing IPv6 multipath routes to be returned encoded in the RTA_MULTIPATH.

Patch 1 adds the NLM_F_APPEND flag to notifications when the flag is
present in the request. The lack of this flag was noted testing route
appends and comparing to IPv4.

Patch 4 prints IPv6 addresses in compressed format when showing route
replace errors. This was noticed testing REPLACE failures.

The end result for multipath routes:
1. Route Add
   - one notification with RTA_MULTIPATH attribute

2. Route Replace
   - notification for first route and all siblings that have
     succeeded. This is needed regardless of success of remaining
     nexthops to maintain add/delete consistency should a failure
     happens on the second or following nexthop (ie., need to tell
     userspace that original route has been replaced and then the
     failure logic deletes all routes inserted thus far).
     
3. Route Delete
   - for multipath route only given nexthops are deleted. This path
     is hit when DELETE contains RTA_MULTIPATH. All other route deletes,
     all nexthops are deleted for given prefix and length (and any
     other specs if given)

   - one notification sent per nexthop deleted. This is unavoidable
     since IPv6 alllows a single nexthop to be deleted within a multipath
     route

4. Route Appends
   - IPv6 allows nexthops to be appended to an existing route. In this
     case one notification is sent per nexthop added

Addresses some of the inconsistencies also noted by Roopa at netdev0.1:
https://www.netdev01.org/docs/prabhu-linux_ipv4_ipv6_inconsistencies_talk_slides.pdf

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

David Ahern (4):
  net: ipv6: add NLM_F_APPEND in notifications when applicable
  net: ipv6: Allow shorthand delete of all nexthops in multipath route
  net: ipv6: Add support to dump multipath routes via RTA_MULTIPATH
    attribute
  net: ipv6: Use compressed IPv6 addresses showing route replace error

 include/net/ip6_fib.h |   4 +-
 include/net/netlink.h |   1 +
 net/ipv6/ip6_fib.c    |  19 +++++-
 net/ipv6/route.c      | 163 ++++++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 165 insertions(+), 22 deletions(-)

-- 
2.1.4
