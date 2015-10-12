From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 0/7] switchdev: change locking
Date: Mon, 12 Oct 2015 17:45:43 +0200
Message-ID: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38588 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbJLPpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 11:45:53 -0400
Received: by wieq12 with SMTP id q12so26504985wie.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 08:45:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is something which I'm currently struggling with.
Callers of attr_set and obj_add/del often hold not only RTNL, but also
spinlock (bridge). So in that case, the driver implementing the op cannot sleep.

The way rocker is dealing with this now is just to invoke driver operation
and go out, without any checking or reporting of the operation status.

Since it would be nice to at least put a warning in case the operation fails,
it makes sense to do this in delayed work directly in switchdev core
instead of implementing this in separate drivers. And that is what this patchset
is introducing.

So from now on, the locking of switchdev mod ops is consistent. Caller either
holds rtnl mutex or in case it does not, caller sets defer flag, telling
switchdev core to process the op later in delayed work.

Flush function for switchdev deferred ops can be called by op
caller in appropriate location, for example after it releases
spin lock, to force switchdev core to process pending ops.

v1->v2:
- rebased on current net-next head (including Scott's ageing patchset)
v2->v3:
- fixed comment s/of/or/ typo suggested by Nik

Jiri Pirko (7):
  switchdev: assert rtnl in switchdev_port_obj_del
  switchdev: introduce switchdev workqueue
  switchdev: allow caller to explicitly request attr_set as deferred
  switchdev: remove pointers from switchdev objects
  switchdev: introduce possibility to defer obj_add/del
  bridge: defer switchdev fdb del call in fdb_del_external_learn
  rocker: remove nowait from switchdev callbacks.

 drivers/net/ethernet/rocker/rocker.c |  13 +-
 include/net/switchdev.h              |  14 +-
 net/bridge/br_fdb.c                  |   7 +-
 net/bridge/br_if.c                   |   3 +
 net/bridge/br_stp.c                  |   3 +-
 net/dsa/slave.c                      |   2 +-
 net/switchdev/switchdev.c            | 276 +++++++++++++++++++++++++----------
 7 files changed, 222 insertions(+), 96 deletions(-)

-- 
1.9.3
