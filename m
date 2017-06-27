From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/14] nfp: get_phys_port_name for representors and SR-IOV reorder
Date: Tue, 27 Jun 2017 00:50:14 -0700
Message-ID: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36602 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751498AbdF0HvH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:07 -0400
Received: by mail-pg0-f51.google.com with SMTP id u62so11960967pgb.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series starts by making the error message if FW cannot be located
easier to understand.  Then I move some functions from PCI probe files
into library code (nfpcore) where they belong, and remove one function
which is never used.

Next few patches equip representors with nfp_port structure and make
their NDOs fully shared (not defined in apps), thanks to which we can 
easily determine which netdevs are NFP's by comparing the NDO pointers.

10th patch makes use of the shared NDOs and nfp_ports to deliver
netdev-type independent .ndo_get_phys_port_name() implementation.

Patches 11 and 12 reorder the nfp_app SR-IOV callbacks with enabling
SR-IOV VFs.  Unfortunately due to how PCI subsystem works we can't
guarantee being able to disable SR-IOV at exit or that it will be
disabled when we first probe...  We must therefore make sure FW is
able to deal with being loaded while SR-IOV is already on.

Patch 13 fixes potential deadlock when enabling SR-IOV happens at
the same time as port state refresh.  Note that this can't happen
at this point, since Flower doesn't refresh ports... but lockdep 
doesn't know about such details and we will have to deal with this
sooner or later anyway.

Last but not least a new Kconfig is added to make sure those who 
don't care about flower offloads have a way of not including the 
code in their kernels.  Thanks to nfp_app separation this costs us
a single ifdef and excluding flower files from the build.

Jakub Kicinski (14):
  nfp: explicitly check if application FW is loaded
  nfp: move area mapping helper into nfpcore
  nfp: add helper for mapping runtime symbols
  nfp: remove unused nfp_cpp_area_check_range()
  nfp: add nfp_app cleanup callback and make flower use it
  nfp: spawn nfp_ports for PF and VF ports
  nfp: make the representor get stats app-independent
  nfp: move representors' struct net_device_ops to shared code
  nfp: allow converting representor's netdev into nfp_port
  nfp: wire get_phys_port_name on representors
  nfp: handle SR-IOV already enabled when driver is probing
  nfp: reorder SR-IOV config and nfp_app SR-IOV callbacks
  nfp: allocate a private workqueue for driver work
  nfp: flower: add Kconfig for flower app

 drivers/net/ethernet/netronome/Kconfig             |  10 ++
 drivers/net/ethernet/netronome/nfp/Makefile        |   8 +-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   |   5 +-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   |   2 +-
 drivers/net/ethernet/netronome/nfp/flower/main.c   |  89 ++++++++-------
 drivers/net/ethernet/netronome/nfp/nfp_app.c       |   2 +
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  30 +++++-
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  56 ++++++----
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |   4 +
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 119 ++++++---------------
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  |  69 +++++++++---
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h  |  15 ++-
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  48 ++++++---
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  20 +++-
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h   |   9 +-
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   |  57 ++++++----
 .../ethernet/netronome/nfp/nfpcore/nfp_cpplib.c    |  40 +++++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h  |   4 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c |  27 +++++
 19 files changed, 388 insertions(+), 226 deletions(-)

-- 
2.11.0
