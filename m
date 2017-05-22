From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 00/13] nfp: introduce nfp_port and nfp_app
Date: Mon, 22 May 2017 10:59:21 -0700
Message-ID: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33374 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759987AbdEVSBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:01:02 -0400
Received: by mail-pf0-f174.google.com with SMTP id e193so89412135pfh.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:01:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series builds foundation for upcoming development.  So far the nfp
driver was focused on delivering basic NIC-like functionality.  We want
to switch gears a bit going forward and support more advanced applications.

First few patches are naming clean ups and reshuffling.  The two main 
structures this series adds are nfp_port and nfp_app.  

nfp_port represents a device port, where port can mean external port,
VF or PF.  For now only external port/MAC/PHY port is added.  nfp_port
is supposed to make it easy to share ethtool and devlink code regardless
of netdev type (full vNIC vs representors).

nfp_app is an abstraction which should allow easier development of new
applications.  So far we have relied fully on port capabilities to detect
which offloads and features are available.  The usual development model
for NFP is that people start with one of our "core NIC" FW apps (C one, 
or a macro assembler one) and build advanced functionality on top of that.
Therefore basic netdev code is shared, but the higher-level logic is 
usually more project specific.  The higher-level logic is also per-adapter
rather than per-port, so creating per-adapter control entity makes sense.
Hopefully the separation of lower-level netdev code and application logic
will help us limit interdependencies and accelerate parallel projects
(e.g. TC flower offloads vs eBPF offload).

v2:
 - don't hide definition of nfp_app to avoid silly function calls (Dave);
 - reorder kdoc of nfp_main (Simon);
 - make nfp_netdev_is_nfp_net() static inline as well.

Jakub Kicinski (12):
  nfp: make nfp_net alloc/init/cleanup/free not depend on netdevs
  nfp: rename netdev/port to vNIC
  nfp: add nfp_net_pf_free_vnic() function
  nfp: introduce very minimal nfp_app
  nfp: disallow mixing vNICs with and without NSP port entry
  nfp: introduce nfp_port
  nfp: update port state in place
  nfp: move refresh tracking into the port structure
  nfp: provide linking on port structures
  nfp: mark port state as stale after reconfig
  nfp: mark port state as stale if update failed
  nfp: refresh port state before reporting autonegotiation

Simon Horman (1):
  nfp: add nfp_cppcore_pcie_unit() helper

 drivers/net/ethernet/netronome/nfp/Makefile        |   4 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.c       |  57 ++++
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  56 ++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  25 +-
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  44 +--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  76 ++---
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   4 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  62 ++--
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 346 ++++++++++++---------
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  14 +-
 drivers/net/ethernet/netronome/nfp/nfp_port.c      | 121 +++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      | 102 ++++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h   |  11 +
 14 files changed, 658 insertions(+), 265 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_app.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_app.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_port.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_port.h

-- 
2.11.0
