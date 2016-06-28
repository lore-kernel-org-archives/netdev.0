From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/2] net: bridge: add support for IGMP/MLD stats
Date: Tue, 28 Jun 2016 16:57:04 +0200
Message-ID: <1467125826-11980-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: linus.luessing@c0d3.blue, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36104 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcF1O5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 10:57:44 -0400
Received: by mail-wm0-f43.google.com with SMTP id f126so143912921wma.1
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 07:57:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This patchset adds support for the new IFLA_STATS_LINK_XSTATS_SLAVE
attribute which can be used with RTM_GETSTATS in order to export per-slave
statistics. It works by passing the attribute to the linkxstats callback
and if the callback user supports it - it should dump that slave's stats.
This is much more scalable and permits us to request only a single port's
statistics instead of dumping everything every time.
The second patch adds support for per-port IGMP/MLD statistics and uses
the new API to export them for the bridge and its ports. The stats are
made in a very lightweight manner, the normal fast-path is not affected
at all and the flood paths (br_flood/br_multicast_flood) are only affected
if the packet is IGMP and the IGMP stats have been enabled using cache-hot
data for the check.

v2: Patch 01 is new, patch 02 has been reworked to use the new API, also
in addition counters for IGMP/MLD parse errors have been added and members
are added for per-port multicast traffic stats. The multicast counting has
been slightly optimized (moved the br_multicast_count inside the IPv4/6
IGMP functions after the checks for IGMP traffic) to avoid one conditional
that was on all of the multicast traffic path (both IGMP and other).

Thank you,
 Nik

Nikolay Aleksandrov (2):
  net: rtnetlink: add support for the IFLA_STATS_LINK_XSTATS_SLAVE
    attribute
  net: bridge: add support for IGMP/MLD stats and export them via
    netlink

 include/net/rtnetlink.h        |   5 +-
 include/uapi/linux/if_bridge.h |  26 +++++
 include/uapi/linux/if_link.h   |   2 +
 net/bridge/br_device.c         |  10 +-
 net/bridge/br_forward.c        |  13 ++-
 net/bridge/br_if.c             |   9 +-
 net/bridge/br_input.c          |   3 +
 net/bridge/br_multicast.c      | 217 ++++++++++++++++++++++++++++++++++++++---
 net/bridge/br_netlink.c        | 148 ++++++++++++++++++++++------
 net/bridge/br_private.h        |  41 +++++++-
 net/bridge/br_sysfs_br.c       |  25 +++++
 net/core/rtnetlink.c           |  50 +++++++++-
 12 files changed, 497 insertions(+), 52 deletions(-)

-- 
2.1.4
