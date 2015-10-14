From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 0/8] switchdev: change locking
Date: Wed, 14 Oct 2015 19:40:47 +0200
Message-ID: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35155 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680AbbJNRk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:40:58 -0400
Received: by wicll6 with SMTP id ll6so7865493wic.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:40:57 -0700 (PDT)
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
switchdev core to process the op later, in deferred queue.

Function to force to process switchdev deferred ops can be called by op
caller in appropriate location, for example after it releases
spin lock, to force switchdev core to process pending ops.

v1->v2:
- rebased on current net-next head (including Scott's ageing patchset)
v2->v3:
- fixed comment s/of/or/ typo suggested by Nik
v3->v4:
- the actual patchset is sent instead of different branch I send in v3 :/
v4->v5:
- added patch to "const" attr param
- reworked deferred ops infrastructure (mainly patch number 1 and
  internal users (patch 3 and 5)) - resolves the issue pointed out
  by John

Jiri Pirko (8):
  switchdev: introduce switchdev deferred ops infrastructure
  switchdev: make struct switchdev_attr parameter const for attr_set
    calls
  switchdev: allow caller to explicitly request attr_set as deferred
  switchdev: remove pointers from switchdev objects
  switchdev: introduce possibility to defer obj_add/del
  bridge: defer switchdev fdb del call in fdb_del_external_learn
  rocker: remove nowait from switchdev callbacks.
  switchdev: assert rtnl mutex when going over lower netdevs

 drivers/net/ethernet/rocker/rocker.c |  15 +-
 include/net/switchdev.h              |  20 ++-
 net/bridge/br_fdb.c                  |   7 +-
 net/bridge/br_if.c                   |   3 +
 net/bridge/br_stp.c                  |   3 +-
 net/dsa/slave.c                      |   4 +-
 net/switchdev/switchdev.c            | 315 ++++++++++++++++++++++++-----------
 7 files changed, 254 insertions(+), 113 deletions(-)

-- 
1.9.3
