From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 00/10] ipv4: fib: Replay events when registering FIB notifier
Date: Sat,  3 Dec 2016 16:44:57 +0100
Message-ID: <1480779907-32535-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36196 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbcLCPpL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 10:45:11 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so7026425wma.3
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 07:45:10 -0800 (PST)
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
packet loss. This patchset fixes that by dumping the FIB tables and
replaying notifications previously sent in the chain for the registered
notification block.

The entire dump process is done under RCU and thus the FIB notification
chain is converted to be atomic. The listeners are modified accordingly.
This is done in the first eight patches.

The ninth patch adds a change sequence counter to ensure the integrity
of the FIB dump. The last patch adds the dump itself to the FIB chain
registration function and modifies existing listeners to pass a callback
to be executed in case dump was inconsistent.

---
v3->v4:
- Register the notification block after the dump and protect it using
  the change sequence counter (Hannes Frederic Sowa).
- Since we now integrate the dump into the registration function, drop
  the sysctl to set maximum number of retries and instead set it to a
  fixed number. Lets see if it's really a problem before adding something
  we can never remove.
- For the same reason, dump FIB tables for all net namespaces.
- Add a comment regarding guarantees provided by mutex semantics.

v2->v3:
- Add sysctl to set the number of FIB dump retries (Hannes Frederic Sowa).
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

Ido Schimmel (10):
  ipv4: fib: Export free_fib_info()
  ipv4: fib: Add fib_info_hold() helper
  mlxsw: core: Create an ordered workqueue for FIB offload
  mlxsw: spectrum_router: Implement FIB offload in deferred work
  rocker: Create an ordered workqueue for FIB offload
  rocker: Implement FIB offload in deferred work
  rocker: Register FIB notifier before creating ports
  ipv4: fib: Convert FIB notification chain to be atomic
  ipv4: fib: Allow for consistent FIB dumping
  ipv4: fib: Replay events when registering FIB notifier

 drivers/net/ethernet/mellanox/mlxsw/core.c         |  22 +++
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   2 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  92 ++++++++++--
 drivers/net/ethernet/rocker/rocker.h               |   1 +
 drivers/net/ethernet/rocker/rocker_main.c          |  84 +++++++++--
 drivers/net/ethernet/rocker/rocker_ofdpa.c         |   1 +
 include/net/ip_fib.h                               |   8 +-
 include/net/netns/ipv4.h                           |   3 +
 net/ipv4/fib_frontend.c                            |   2 +
 net/ipv4/fib_semantics.c                           |   1 +
 net/ipv4/fib_trie.c                                | 155 ++++++++++++++++++++-
 11 files changed, 342 insertions(+), 29 deletions(-)

-- 
2.7.4
