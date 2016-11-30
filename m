From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 00/12]  ipv4: fib: Allow modules to dump FIB tables
Date: Wed, 30 Nov 2016 11:08:54 +0100
Message-ID: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33924 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754190AbcK3KJJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 05:09:09 -0500
Received: by mail-wm0-f65.google.com with SMTP id g23so28647382wme.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 02:09:08 -0800 (PST)
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

The eighth and ninth patches add a change sequence counter to ensure the
integrity of the FIB dump and a sysctl to set the number of retries,
respectively. The tenth patch finally introduces the FIB dump itself.

The last two patches modify current listeners of the FIB notification
chain to invoke the dump during their init.

v2->v3:
- Add sysctl to set the number of FIB dump retries
  (Hannes Frederic Sowa).
- Read the sequence counter under RTNL to ensure synchronization
  between the dump process and other processes changing the routing
  tables (Hannes Frederic Sowa).
- Pass a callback to the dump function to be executed prior to a retry.
- Limit the dump to a single net namespace.

v1->v2:
- Add a sequence counter to ensure the integrity of the FIB dump
  (David S. Miller, Hannes Frederic Sowa).
- Protect notifications from re-ordering in listeners by using an
  ordered workqueue (Hannes Frederic Sowa).
- Introduce fib_info_hold() (Jiri Pirko).
- Relieve rocker from the need to invoke the FIB dump by registering
  to the FIB notification chain prior to ports creation.

Ido Schimmel (12):
  ipv4: fib: Export free_fib_info()
  ipv4: fib: Add fib_info_hold() helper
  mlxsw: core: Create an ordered workqueue for FIB offload
  mlxsw: spectrum_router: Implement FIB offload in deferred work
  rocker: Create an ordered workqueue for FIB offload
  rocker: Implement FIB offload in deferred work
  ipv4: fib: Convert FIB notification chain to be atomic
  ipv4: fib: Allow for consistent FIB dumping
  ipv4: fib: Add sysctl to limit number of FIB dump retries
  ipv4: fib: Add an API to request a FIB dump
  mlxsw: spectrum_router: Request a dump of FIB tables during init
  rocker: Register FIB notifier before creating ports

 Documentation/networking/ip-sysctl.txt             |   8 ++
 drivers/net/ethernet/mellanox/mlxsw/core.c         |  22 +++
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   2 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  95 +++++++++++--
 drivers/net/ethernet/rocker/rocker.h               |   1 +
 drivers/net/ethernet/rocker/rocker_main.c          |  78 +++++++++--
 drivers/net/ethernet/rocker/rocker_ofdpa.c         |   1 +
 include/net/ip_fib.h                               |   9 ++
 include/net/netns/ipv4.h                           |   4 +
 net/ipv4/fib_frontend.c                            |   3 +
 net/ipv4/fib_semantics.c                           |   1 +
 net/ipv4/fib_trie.c                                | 147 ++++++++++++++++++++-
 net/ipv4/sysctl_net_ipv4.c                         |   7 +
 13 files changed, 352 insertions(+), 26 deletions(-)

-- 
2.7.4
