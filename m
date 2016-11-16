From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] ipv4: fib: Allow modules to dump FIB tables
Date: Wed, 16 Nov 2016 15:08:55 +0100
Message-ID: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36243 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753571AbcKPOJG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:09:06 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so11466365wma.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:09:05 -0800 (PST)
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
This is done in the first five patches.

The sixth patch adds the dump callback itself and the next patches call
it from current listeners of the FIB notification chain.

Ido Schimmel (8):
  ipv4: fib: Export free_fib_info()
  mlxsw: spectrum_router: Implement FIB offload in delayed work
  rocker: Implement FIB offload in delayed work
  ipv4: fib: Convert FIB notification chain to be atomic
  net: ipv4: Send notifications only after removing FIB alias
  ipv4: fib: Add an API to request a FIB dump
  mlxsw: spectrum_router: Request a dump of FIB tables during init
  rocker: Request a dump of FIB tables during init

 drivers/net/ethernet/mellanox/mlxsw/core.c         |   6 +
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  73 ++++++++++--
 drivers/net/ethernet/rocker/rocker_main.c          |  59 ++++++++--
 drivers/net/ethernet/rocker/rocker_ofdpa.c         |   1 +
 include/net/ip_fib.h                               |   1 +
 net/ipv4/fib_semantics.c                           |   1 +
 net/ipv4/fib_trie.c                                | 128 +++++++++++++++++++--
 8 files changed, 242 insertions(+), 28 deletions(-)

-- 
2.7.4
