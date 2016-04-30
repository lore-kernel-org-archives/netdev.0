From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v3 0/4] bridge: per-vlan stats
Date: Sat, 30 Apr 2016 10:25:25 +0200
Message-ID: <1462004729-12185-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35449 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbcD3IZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 04:25:42 -0400
Received: by mail-wm0-f43.google.com with SMTP id e201so52135626wme.0
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 01:25:41 -0700 (PDT)
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

Patches 03 and 04 add the stats support and netlink dump support
respectively. The stats accounting is controlled via a bridge option which
is default off, thus the performance impact is kept minimal.
I've tested this set with both old and modified iproute2, kmemleak on and
some traffic stress tests while adding/removing vlans and ports.

v3:
 - drop the RCU pvid patch and remove one pointer fetch as requested
 - make stats accounting optional with default to off, the option is in the
   same cache line as vlan_proto and vlan_enabled, so it is already fetched
   before the fast path check thus the performance impact is minimal, this
   also allows us to avoid one vlan lookup and return early when using pvid
 - rebased and retested

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


Nikolay Aleksandrov (4):
  net: rtnetlink: allow rtnl_fill_statsinfo to save private state
    counter
  net: rtnetlink: add linkxstats callbacks and attribute
  bridge: vlan: learn to count
  bridge: netlink: export per-vlan stats

 include/net/rtnetlink.h        |   7 +++
 include/uapi/linux/if_bridge.h |  18 +++++++
 include/uapi/linux/if_link.h   |  14 ++++++
 net/bridge/br_netlink.c        |  78 ++++++++++++++++++++++++++++-
 net/bridge/br_private.h        |  18 +++++++
 net/bridge/br_sysfs_br.c       |  17 +++++++
 net/bridge/br_vlan.c           | 109 +++++++++++++++++++++++++++++++++++------
 net/core/rtnetlink.c           |  74 +++++++++++++++++++++++-----
 8 files changed, 307 insertions(+), 28 deletions(-)

-- 
2.4.11
