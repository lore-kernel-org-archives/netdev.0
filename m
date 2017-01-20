From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/2] net: ipv6: Improve user experience with multipath routes
Date: Thu, 19 Jan 2017 22:10:24 -0800
Message-ID: <1484892626-14257-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36668 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdATGKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 01:10:36 -0500
Received: by mail-pf0-f175.google.com with SMTP id 189so19868047pfu.3
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 22:10:36 -0800 (PST)
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

Patch 1 addresses the first by allowing IPv6 multipath routes to be
deleted using just the prefix and length. Patch 2 addresses the second
allowing IPv6 multipath routes to be returned encoded in the RTA_MULTIPATH.

In both cases, the new behavior requires users to opt in by setting a new
flag, RTM_F_ALL_NEXTHOPS, in the rtm_flags of struct rtmsg which is
expected to be the ancillary header in the netlink request received from
the user. A program must opt in to the new behavior so as to not break
any existing applications.

The opt-in behavior works for both route deletes and dumps (the two
differences noted above), but not for notifications as notifications
do not take user input to specify flags. The only way to have
notifications generate RTA_MULTIPATH encodings is to have a gobal
flag -- e.g., sysctl. I'd prefer not to add a sysctl knob for this
backwards compatibility.

Notifications can always be handled as a follow on patch since any
existing code that actually works with IPv6 multipath routes (e.g.,
quagga does not) has to be able to handle the series of routes
currently returned by the dump request and notifications.

v2
- fixed locking in patch 1 as noted by DaveM
- changed user API for patch 2 to require an rtmsg with RTM_F_ALL_NEXTHOPS
  set in rtm_flags
- revamped explanation of patch 2 and cover letter

David Ahern (2):
  net: ipv6: Allow shorthand delete of all nexthops in multipath route
  net: ipv6: Add option to dump multipath routes via RTA_MULTIPATH
    attribute

 include/net/ip6_fib.h          |   4 +-
 include/net/ip6_route.h        |   1 +
 include/uapi/linux/rtnetlink.h |   4 ++
 net/ipv6/ip6_fib.c             |  28 ++++++++-
 net/ipv6/route.c               | 138 ++++++++++++++++++++++++++++++++++-------
 5 files changed, 152 insertions(+), 23 deletions(-)

-- 
2.1.4
