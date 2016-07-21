From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/9] mlxsw: implement port mirroring offload
Date: Thu, 21 Jul 2016 12:03:08 +0200
Message-ID: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33622 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbcGUKDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 06:03:20 -0400
Received: by mail-wm0-f65.google.com with SMTP id o80so1964337wme.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 03:03:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset introduces tc matchall classifier and its offload
to Spectrum hardware. In combination with mirred action, defined port mirroring
setup is offloaded by mlxsw/spectrum driver.

The commands used for creating mirror ports:

# ingress mirroring using matchall
tc qdisc  add dev eth25 handle ffff: ingress
tc filter add dev eth25 parent ffff:            \
        matchall skip_sw                        \
        action mirred egress mirror             \
        dev eth27

# egress mirroring using matchall
tc qdisc add dev eth25 handle 1: root prio
tc filter add dev eth25 parent 1:               \
        matchall skip_sw                        \
        action mirred egress mirror             \
        dev eth27

These patches contain:
 - Resource query implementation
 - Hardware port mirorring support for spectrum.
 - Definition of the matchall traffic classifier.
 - General support for hw-offloading for that classifier.
 - Specific spectrum implementaion for matchall offloading.

---
v1->v2:
 - couple of minor style fixes

Jiri Pirko (1):
  net/sched: introduce Match-all classifier

Nogah Frankel (2):
  mlxsw: pci: Add resources query implementation.
  mlxsw: pci: Add max span resources to resources query

Yotam Gigi (6):
  net/sched: Add match-all classifier hw offloading.
  mlxsw: reg: Add Shared Buffer Internal Buffer register
  mlxsw: reg: Add Monitoring Port Analyzer Table register
  mlxsw: reg: Add the Monitoring Port Analyzer register
  net/sched: act_mirred: Add helper inlines to access tcf_mirred info.
  mlxsw: spectrum: Add support in matchall mirror TC offloading

 drivers/net/ethernet/mellanox/mlxsw/cmd.h      |  32 ++
 drivers/net/ethernet/mellanox/mlxsw/core.c     |  10 +-
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  11 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c      |  64 +++-
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 162 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 465 ++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  44 +++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |   1 +
 include/linux/netdevice.h                      |   2 +
 include/net/pkt_cls.h                          |  11 +
 include/net/tc_act/tc_mirred.h                 |   9 +
 include/uapi/linux/pkt_cls.h                   |  12 +
 net/sched/Kconfig                              |  10 +
 net/sched/Makefile                             |   1 +
 net/sched/cls_matchall.c                       | 318 +++++++++++++++++
 15 files changed, 1148 insertions(+), 4 deletions(-)
 create mode 100644 net/sched/cls_matchall.c

-- 
2.5.5
