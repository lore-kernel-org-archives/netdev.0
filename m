From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/7] bridge: per-vlan stats
Date: Wed, 27 Apr 2016 18:18:15 +0200
Message-ID: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37511 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbcD0QS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:18:29 -0400
Received: by mail-wm0-f42.google.com with SMTP id a17so22919626wme.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 09:18:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This set adds support for bridge per-vlan statistics.
In order to be able to dump statistics we need a way to continue
dumping after reaching maximum size, thus patches 01-03 extend the new
stats API with a per-device extended link stats attribute and callback
which can save its local state and continue where it left off afterwards.
I considered using the already existing "fill_xstats" callback but it gets
confusing since we need to separate the linkinfo dump from the new stats
api dump and adding a flag/argument to do that just looks messy. I don't
think the rtnl_link_ops size is an issue, so adding these seemed like the
cleaner approach.

Patch 05 converts the pvid to a pointer so we can consolidate the vlan
stats accounting paths later, also allows to simplify the pvid code.
Patches 06 and 07 add the stats support and netlink dump support
respectively.
I've tested this set with both old and modified iproute2, kmemleak on and
some traffic stress tests while adding/removing vlans and ports.

Thank you,
 Nik

Note: Jamal I haven't forgotten about the per-port per-vlan stats, I've got
a follow-up patch that adds it. You can easily see that the infrastructure
for private port/vlan stats is in place after this set. Though the stats
api will need some more changes to support that.


Nikolay Aleksandrov (7):
  net: rtnetlink: allow rtnl_fill_statsinfo to save private state
    counter
  net: rtnetlink: allow only one idx saving stats attribute
  net: rtnetlink: add linkxstats callbacks and attribute
  net: constify is_skb_forwardable's arguments
  bridge: vlan: RCUify pvid
  bridge: vlan: learn to count
  bridge: netlink: export per-vlan stats

 include/linux/netdevice.h      |   3 +-
 include/net/rtnetlink.h        |  10 +++
 include/uapi/linux/if_bridge.h |   8 +++
 include/uapi/linux/if_link.h   |   9 +++
 net/bridge/br_netlink.c        |  80 ++++++++++++++++++++----
 net/bridge/br_private.h        |  32 +++++-----
 net/bridge/br_vlan.c           | 134 +++++++++++++++++++++++++++++------------
 net/core/dev.c                 |   2 +-
 net/core/rtnetlink.c           |  64 +++++++++++++++++---
 9 files changed, 266 insertions(+), 76 deletions(-)

-- 
2.4.11
