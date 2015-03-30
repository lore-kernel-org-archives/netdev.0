From: sfeldma@gmail.com
Subject: [PATCH net-next 00/18] switchdev: spring cleanup
Date: Mon, 30 Mar 2015 01:40:18 -0700
Message-ID: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32830 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbbC3Ijp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 04:39:45 -0400
Received: by pacgg7 with SMTP id gg7so31580971pac.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 01:39:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The main theme of this patch set is to cleanup swdev in preparation for
new features or fixes to be added soon.  We have a pretty good idea now how
to handle stacked drivers in swdev, but there where some loose ends.  For
example, if a set failed in the middle of walking the lower devs, we would
leave the system in an undefined state...there was no way to recover back to
the previous state.  Speaking of sets, also recognize a pattern that most
swdev API accesses are gets or sets of port attributes, so go ahead and make
port attr get/set the central swdev API, and convert everything that is
set-ish/get-ish to this new API.

Features/fixes that should follow from this cleanup:

 - solve the duplicate pkt forwarding issue
 - get/set bridge attrs, like ageing_time, from/to device
 - get/set more bridge port attrs from/to device

There are some rename cleanups tagging along at the end, to give swdev
consistent naming.

And finally, some much needed updates to the switchdev.txt documentation to
hopefully capture the state-of-the-art of swdev.  Hopefully, we can do a better
job keeping this document up-to-date.

Tested with rocker, of course, to make sure nothing functional broke.  There
are a couple minor tweaks to DSA code for getting switch ID and setting STP
updates to use new API, but not expecting amy breakage there.


Scott Feldman (18):
  switchdev: introduce get/set attrs ops
  switchdev: flesh out get/set attr ops
  switchdev: convert parent_id_get to swdev attr get
  switchdev: convert STP update to swdev attr set
  switchdev: add bridge port flags attr
  rocker: use swdev get/set attr for bridge port flags
  switchdev: add new swdev bridge setlink
  rocker: cut over to new swdev_port_bridge_setlink
  bonding: cut over to new swdev_port_bridge_setlink
  team: cut over to new swdev_port_bridge_setlink
  switchdev: remove old netdev_switch_port_bridge_setlink
  switchdev: remove unused netdev_switch_port_bridge_dellink
  switchdev: remove unused NETIF_F_HW_SWITCH_OFFLOAD
  switchdev: add new swdev_port_bridge_getlink
  rocker: cut over to new swdev_port_bridge_getlink
  switchdev: rename netdev_switch_fib_* to swdev_fib_*
  switchdev: rename netdev_switch_notifier_* to swdev_notifier_*
  switchdev: bring documentation up-to-date

 Documentation/networking/switchdev.txt |  426 +++++++++++++++++++++++++++-----
 drivers/net/bonding/bond_main.c        |    8 +-
 drivers/net/ethernet/rocker/rocker.c   |  108 +++-----
 drivers/net/team/team.c                |    5 +-
 include/linux/netdev_features.h        |    5 +-
 include/net/switchdev.h                |  144 ++++++-----
 net/bridge/br.c                        |   22 +-
 net/bridge/br_netlink.c                |   24 +-
 net/bridge/br_stp.c                    |    6 +-
 net/core/ethtool.c                     |    1 -
 net/core/net-sysfs.c                   |   10 +-
 net/core/rtnetlink.c                   |    9 +-
 net/dsa/slave.c                        |   35 ++-
 net/ipv4/fib_trie.c                    |   38 ++-
 net/switchdev/switchdev.c              |  334 ++++++++++++++-----------
 15 files changed, 750 insertions(+), 425 deletions(-)

-- 
1.7.10.4
