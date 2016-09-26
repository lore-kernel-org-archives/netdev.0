From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 0/6] fib offload: switch to notifier
Date: Mon, 26 Sep 2016 12:52:28 +0200
Message-ID: <1474887154-6286-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, kaber@trash.net, john@phrozen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34692 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935530AbcIZKwh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 06:52:37 -0400
Received: by mail-wm0-f67.google.com with SMTP id l132so13446126wmf.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 03:52:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The goal of this patchset is to allow driver to propagate all prefixes
configured in kernel down HW. This is necessary for routing to work
as expected. If we don't do that HW might forward prefixes known to kernel
incorrectly. Take an example when default route is set in switch HW and there
is an IP address set on a management (non-switch) port.

Currently, only FIB entries related to the switch port netdev are
offloaded using switchdev ops. This model is not extendable so the
first patch introduces a replacement: notifier to propagate FIB entry
additions and removals to whoever is interested.

The second patch introduces couple of helpers to deal with RTNH_F_OFFLOAD
flags. Currently it is set in switchdev core. There the assumption is
that only one offload device exists. But for FIB notifier, we assume
multiple offload devices. So the patch introduces a per FIB entry
reference counter and helpers use it in order to achieve this:
   0 means RTNH_F_OFFLOAD is not set, no device offloads this entry
   n means RTNH_F_OFFLOAD is set and the entry is offloaded by n devices

Patches 3 and 4 convert mlxsw and rocker to adopt this new way, registering
one notifier block for each asic instance. Both of these patches also
implement internal "abort" mechanism.

Using switchdev ops, "abort" is called by switchdev core whenever there is
an error during FIB entry add offload. This leads to removal of all
offloaded entries on system by fib_trie code.

Now the new notifier assumes the driver takes care of the abort action.
Here's why:
1) The fact that one HW cannot offload an entry does not mean that the
   others can't do it. So let only one entity to abort and leave the rest
   to work happily.
2) The driver knows what to in order to properly abort. For example,
   currently abort is broken for mlxsw, as for Spectrum there is a need
   to set 0.0.0.0/0 trap in RALUE register.

The fifth patch removes the old, no longer used FIB offload infrastructure.

The last patch reflects the changes into switchdev documentation file.

---
v2->v3:
 -patch 3/6
   -fixed offload inc/dec to be done in fib4_entry_init/fini and only
    in case !trap as suggested by Ido
v1->v2:
 -patch 3/6:
   -fixed lpm tree setup and binding for abort and pointed out by Ido
   -do nexthop checks as suggested by Ido
   -fix use after free during abort
 -patch 6/6:
   -fixed texts as suggested by Ido

Jiri Pirko (6):
  fib: introduce FIB notification infrastructure
  fib: introduce FIB info offload flag helpers
  mlxsw: spectrum_router: Use FIB notifications instead of switchdev
    calls
  rocker: use FIB notifications instead of switchdev calls
  switchdev: remove FIB offload infrastructure
  doc: update switchdev L3 section

 Documentation/networking/switchdev.txt             |  27 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   9 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 437 ++++++++++++---------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   9 -
 drivers/net/ethernet/rocker/rocker.h               |  15 +-
 drivers/net/ethernet/rocker/rocker_main.c          | 120 ++++--
 drivers/net/ethernet/rocker/rocker_ofdpa.c         | 115 ++++--
 include/net/ip_fib.h                               |  49 ++-
 include/net/switchdev.h                            |  40 --
 net/ipv4/fib_frontend.c                            |  29 +-
 net/ipv4/fib_rules.c                               |  12 +-
 net/ipv4/fib_trie.c                                | 166 +++-----
 net/switchdev/switchdev.c                          | 181 ---------
 13 files changed, 581 insertions(+), 628 deletions(-)

-- 
2.5.5
