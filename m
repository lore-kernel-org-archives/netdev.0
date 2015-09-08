From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 0/3] net: switchdev: extract specific object structures
Date: Tue,  8 Sep 2015 16:47:52 -0400
Message-ID: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:41193
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751552AbbIHUtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 16:49:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Current implementations of .switchdev_port_obj_add and .switchdev_port_obj_dump
must pass the generic switchdev_obj structure instead of a specific one (e.g.
switchdev_obj_fdb) to the related driver accessors, because it contains the
object transaction and callback. This is not very convenient for drivers.

Instead of having all specific structures included into a switchdev_obj union,
it would be simpler to embed a switchdev_obj structure as the first member of
the more specific ones. That way, a driver can cast the switchdev_obj pointer
to the specific structure and have access to all the information from it.

As an example, this allows Rocker to change its two FDB accessors:

    rocker_port_fdb_add(rocker_port, obj->trans, &obj->u.fdb);
    rocker_port_fdb_dump(rocker_port, obj);

for these most consistent ones:

    fdb = (struct switchdev_obj_fdb *) obj;
    rocker_port_fdb_add(rocker_port, fdb);
    rocker_port_fdb_dump(rocker_port, fdb);

This is what struct netdev_notifier_info and its specific supersets (e.g.
struct netdev_notifier_changeupper_info) do in include/linux/netdevice.h.

This patchset does that and updates bridge, Rocker and DSA accordingly.

Note that this patchset was sent as an RFC not to bother David with new
net-next stuffs, but if the changes look good, it is ready to merge.

Also, please take note that the change sits on top of:
http://patchwork.ozlabs.org/patch/514894/

Vivien Didelot (3):
  net: switchdev: extract switchdev_obj_vlan
  net: switchdev: extract switchdev_obj_ipv4_fib
  net: switchdev: extract switchdev_obj_fdb

 drivers/net/ethernet/rocker/rocker.c |  50 ++++++++------
 include/net/switchdev.h              |  49 ++++++++------
 net/bridge/br_fdb.c                  |  12 ++--
 net/bridge/br_vlan.c                 |  26 +++----
 net/dsa/slave.c                      |  59 +++++++++-------
 net/switchdev/switchdev.c            | 127 ++++++++++++++++-------------------
 6 files changed, 165 insertions(+), 158 deletions(-)

-- 
2.5.1
