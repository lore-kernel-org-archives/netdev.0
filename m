From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/5] bridge: per-vlan stats
Date: Thu, 28 Apr 2016 17:52:46 +0200
Message-ID: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36869 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbcD1PxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 11:53:00 -0400
Received: by mail-wm0-f51.google.com with SMTP id a17so72835028wme.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 08:52:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This set adds support for bridge per-vlan statistics.
In order to be able to dump statistics for many vlans we need a way to
continue dumping after reaching maximum size, thus patches 01 and 02 extend
the new stats API with a per-device extended link stats attribute and
callback which can save its local state and continue where it left off
afterwards. I considered using the already existing "fill_xstats" callback
but it gets confusing since we need to separate the linkinfo dump from the
new stats api dump and adding a flag/argument to do that just looks messy.
I don't think the rtnl_link_ops size is an issue, so adding these seemed
like the cleaner approach.

Patch 03 converts the pvid to a pointer so we can consolidate the vlan
stats accounting paths later, also allows to simplify the pvid code.
Patches 04 and 05 add the stats support and netlink dump support
respectively.
I've tested this set with both old and modified iproute2, kmemleak on and
some traffic stress tests while adding/removing vlans and ports.

v2:
 - Improve the error checking, rename lidx to prividx and save the current
   idx user instead of restricting it to one in patch 01
 - squash patch 02 into 01 and remove the restriction
 - add callback descriptions, improve the size calculation and change the
   xstats message structure to have an embedding level per rtnl link type
   so we can avoid one call to get the link type (and thus filter on it)
   and also each link type can now have any number of private attributes
   inside
 - fix a problem where the vlan stats are not dumped if the bridge has 0
   vlans on it but has vlans on the ports, add bridge link type private
   attributes and also add paddings for future extensions to avoid at least
   a few netlink attributes and improve struct alignment
 - drop the is_skb_forwardable argument constifying patch as it's not
   needed anymore, but it's a nice cleanup which I'll send separately

Thank you,
 Nik

Note: Jamal I haven't forgotten about the per-port per-vlan stats, I've got
a follow-up patch that adds it. You can easily see that the infrastructure
for private port/vlan stats is in place after this set. Though the stats
api will need some more changes to support that.


Nikolay Aleksandrov (5):
  net: rtnetlink: allow rtnl_fill_statsinfo to save private state
    counter
  net: rtnetlink: add linkxstats callbacks and attribute
  bridge: vlan: RCUify pvid
  bridge: vlan: learn to count
  bridge: netlink: export per-vlan stats

 include/net/rtnetlink.h        |   7 +++
 include/uapi/linux/if_bridge.h |  18 ++++++
 include/uapi/linux/if_link.h   |  13 ++++
 net/bridge/br_netlink.c        |  88 +++++++++++++++++++++++----
 net/bridge/br_private.h        |  32 +++++-----
 net/bridge/br_vlan.c           | 134 +++++++++++++++++++++++++++++------------
 net/core/rtnetlink.c           |  74 +++++++++++++++++++----
 7 files changed, 287 insertions(+), 79 deletions(-)

-- 
2.4.11
