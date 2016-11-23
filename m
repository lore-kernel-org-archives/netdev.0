From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 00/11] ipv4: fib: Allow modules to dump FIB tables
Date: Wed, 23 Nov 2016 15:34:21 +0100
Message-ID: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33890 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964959AbcKWOed (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:34:33 -0500
Received: by mail-wm0-f66.google.com with SMTP id g23so2186548wme.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:34:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

In kernel 4.9 the switchdev-specific FIB offload mechanism was replaced
by a new FIB notification chain to which modules could register in order
to be notified about the addition and deletion of FIB entries. The
motivation for this change was that switchdev drivers need to be able to
reflect the entire FIB table and not only FIBs configured on top of the
port netdevs themselves. This is useful in case of in-band management.

The fundamental problem with this approach is that upon registration
listeners lose all the information previously sent in the chain and
thus have an incomplete view of the FIB tables, which can result in
packet loss. This patchset fixes that by introducing a new API to dump
the FIB tables.

The entire dump process is done under RCU and thus the FIB notification
chain is converted to be atomic. The listeners are modified accordingly.
This is done in the first seven patches.

The eighth patch adds a change sequence counter to ensure the integrity
of the FIB dump, which is finally introduced in the following patch. The
last two patches modify current listeners of the FIB notification chain
to invoke the dump during their init.

---
v1->v2:
- Add a sequence counter to ensure the integrity of the FIB dump
  (David S. Miller, Hannes Frederic Sowa).
- Protect notifications from re-ordering in listeners by using an
  ordered workqueue (Hannes Frederic Sowa).
- Introduce fib_info_hold() (Jiri Pirko).
- Relieve rocker from the need to invoke the FIB dump by registering
  to the FIB notification chain prior to ports creation.
 
Ido Schimmel (11):
  ipv4: fib: Export free_fib_info()
  ipv4: fib: Add fib_info_hold() helper
  mlxsw: core: Create an ordered workqueue for FIB offload
  mlxsw: spectrum_router: Implement FIB offload in deferred work
  rocker: Create an ordered workqueue for FIB offload
  rocker: Implement FIB offload in deferred work
  ipv4: fib: Convert FIB notification chain to be atomic
  ipv4: fib: Allow for consistent FIB dumping
  ipv4: fib: Add an API to request a FIB dump
  mlxsw: spectrum_router: Request a dump of FIB tables during init
  rocker: Register FIB notifier before creating ports

 drivers/net/ethernet/mellanox/mlxsw/core.c         |  22 ++++
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   2 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  88 ++++++++++++--
 drivers/net/ethernet/rocker/rocker.h               |   1 +
 drivers/net/ethernet/rocker/rocker_main.c          |  78 +++++++++++--
 drivers/net/ethernet/rocker/rocker_ofdpa.c         |   1 +
 include/net/ip_fib.h                               |   6 +
 include/net/netns/ipv4.h                           |   2 +
 net/ipv4/fib_frontend.c                            |   2 +
 net/ipv4/fib_semantics.c                           |   1 +
 net/ipv4/fib_trie.c                                | 126 ++++++++++++++++++++-
 11 files changed, 303 insertions(+), 26 deletions(-)

-- 
2.7.4
