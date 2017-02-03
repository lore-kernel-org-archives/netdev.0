From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/6] net: dsa: add fabric notifier
Date: Fri,  3 Feb 2017 13:20:15 -0500
Message-ID: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40010 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751834AbdBCSVQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:21:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a switch fabric is composed of multiple switch chips, these chips
must be programmed accordingly when an event occurred on one of them.

Examples of such event include hardware bridging: when a Linux bridge
spans interconnected chips, they must be programmed to allow external
ports to ingress frames on their internal ports.

Another example is cross-chip hardware VLANs. Switch chips in-between
interconnected bridge ports must also configure a given VLAN to allow
packets to pass through them.

In order to support that, this patchset introduces a non-intrusive
notifier mechanism. It adds a notifier head in every DSA switch tree
(the said fabric), and a notifier block in every DSA switch chip.

When an even occurs, it is chained to all notifiers of the fabric.
Switch chips can react accordingly if they are cross-chip capable.

On a dynamic debug enabled system, bridging a port in a multi-chip
fabric will print something like this (ZII Rev B board):

    # brctl addif br0 lan3
    mv88e6085 0.1:00: crosschip DSA port 1.0 bridged to br0
    mv88e6085 0.4:00: crosschip DSA port 1.0 bridged to br0
    # brctl delif br0 lan3
    mv88e6085 0.1:00: crosschip DSA port 1.0 unbridged from br0
    mv88e6085 0.4:00: crosschip DSA port 1.0 unbridged from br0

Currently only bridging events are added. A patchset introducing support
for cross-chip hardware bridging configuration in mv88e6xxx will follow
right after. Then events for switchdev operations are next on the line.

We should note that non-switchdev events do not support rolling-back
switch-wide operations. We'll have to work on closer integration with
switchdev for that, like introducing new attributes or objects, to
benefit from the prepare and commit phases.

Vivien Didelot (6):
  net: dsa: move netdevice notifier registration
  net: dsa: simplify netdevice events handling
  net: dsa: rollback bridging on error
  net: dsa: change state setter scope
  net: dsa: add switch notifier
  net: dsa: introduce bridge notifier

 include/net/dsa.h  |  17 ++++++++
 net/dsa/Makefile   |   1 +
 net/dsa/dsa.c      |  16 ++++---
 net/dsa/dsa2.c     |   6 +++
 net/dsa/dsa_priv.h |   8 +++-
 net/dsa/slave.c    | 121 +++++++++++++++++++++++++++++++++++------------------
 net/dsa/switch.c   |  85 +++++++++++++++++++++++++++++++++++++
 7 files changed, 205 insertions(+), 49 deletions(-)
 create mode 100644 net/dsa/switch.c

-- 
2.11.0
