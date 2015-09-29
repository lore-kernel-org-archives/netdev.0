From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next 0/6] net: switchdev: use specific switchdev_obj_*
Date: Tue, 29 Sep 2015 12:07:12 -0400
Message-ID: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:33783
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934274AbbI2QHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 12:07:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset changes switchdev add, del, dump operations from this:

    int     (*switchdev_port_obj_add)(struct net_device *dev,
                                      struct switchdev_obj *obj,
                                      struct switchdev_trans *trans);
    int     (*switchdev_port_obj_del)(struct net_device *dev,
                                      struct switchdev_obj *obj);
    int     (*switchdev_port_obj_dump)(struct net_device *dev,
                                      struct switchdev_obj *obj);

to something similar to the notifier_call callback of a notifier_block:

    int     (*switchdev_port_obj_add)(struct net_device *dev,
                                      enum switchdev_obj_id id,
                                      const void *obj,
                                      struct switchdev_trans *trans);                                                             
    int     (*switchdev_port_obj_del)(struct net_device *dev,
                                      enum switchdev_obj_id id,
                                      const void *obj);
    int     (*switchdev_port_obj_dump)(struct net_device *dev,
                                       enum switchdev_obj_id id, void *obj,
                                       int (*cb)(void *obj));

This allows the caller to pass and expect back a specific switchdev_obj_*
structure (e.g. switchdev_obj_fdb) instead of the generic switchdev_obj one.

This will simplify pushing the callback function down to the drivers.

The first 3 patches get rid of the dev parameter of the dump callback, since it
is not always neeeded (e.g. vlan_dump) and some drivers (such as DSA drivers)
may not have easy access to it.

Patches 4 and 5 implement the change in the switchdev operations and its users.

Patch 6 extracts the inner switchdev_obj_* structures from switchdev_obj and
removes this last one.

v2: fix error spotted by kbuild (extra ';' inline switchdev_port_obj_dump).

Vivien Didelot (6):
  net: switchdev: remove dev in port_vlan_dump_put
  net: switchdev: move dev in switchdev_fdb_dump
  net: switchdev: remove dev from switchdev_obj cb
  net: switchdev: pass callback to dump operation
  net: switchdev: abstract object in add/del ops
  net: switchdev: extract struct switchdev_obj_*

 drivers/net/ethernet/rocker/rocker.c |  42 ++++----
 include/net/switchdev.h              |  80 ++++++++-------
 net/bridge/br_fdb.c                  |  11 +--
 net/bridge/br_vlan.c                 |  24 ++---
 net/dsa/slave.c                      |  46 +++++----
 net/switchdev/switchdev.c            | 184 ++++++++++++++++-------------------
 6 files changed, 186 insertions(+), 201 deletions(-)

-- 
2.6.0
