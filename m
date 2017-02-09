From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/12] Netronome NFP4000 and NFP6000 PF driver
Date: Thu,  9 Feb 2017 09:17:26 -0800
Message-ID: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33878 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753468AbdBIRb1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:31:27 -0500
Received: by mail-pg0-f53.google.com with SMTP id 14so2343426pgg.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:30:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This is a base PF driver for Netronome NFP4000 and NFP6000 chips.  This
series doesn't add any exciting new features, it provides a foundation
for supporting more advanced firmware applications.

Patch 1 moves a bitfield-related helper from our BPF code to the global
header.

Patch 2 renames the kernel module and adds a new main file.  We were
considering 3-module approach (pf, vf, common netdev library) but 
ultimately settled on a single module to keep things simple.

Patch 3 adds support for accessing chip internals.  It provides a way of
configuring access windows to different parts of chip memory and issuing 
pretty much any commands on chip's NoC.

Patches 4, 5, 6, 7, 8 provide support for accessing and interpreting 
various hardware and firmware information structures.

Patch 9 introduces service processor (NSP) ABI.  This ABI gives us 
access to PHY/SFP module configuration and information as well as
methods for unloading and loading application firmware.

Patches 10 and 11 modify the existing netdev code to make it possible 
to support multi-port devices (sharing a PCI device).

Patch 12 adds a new driver probe path which will be used for the PF 
PCI device IDs.  It utilizes the newly added infrastructure and is able
to load application FW and spawn netdevs for all card's ports.

Jakub Kicinski (12):
  bitfield.h: add FIELD_FIT() helper
  nfp: rename the driver and add new main file
  nfp: add CPP access core
  nfp: add support for resources
  nfp: add hwinfo support
  nfp: add support for reading nffw info
  nfp: add MIP reading support
  nfp: add rtsym support
  nfp: add support for service processor access
  nfp: add port layer to debugfs directories
  nfp: allocate irqs in lower driver
  nfp: add the PF driver

 drivers/net/ethernet/netronome/Kconfig             |   18 +-
 drivers/net/ethernet/netronome/Makefile            |    2 +-
 drivers/net/ethernet/netronome/nfp/Makefile        |   21 +-
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       |    2 -
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  415 +++++
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |   97 ++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   67 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  144 +-
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   39 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |    8 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  585 +++++++
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  115 +-
 drivers/net/ethernet/netronome/nfp/nfpcore/crc32.h |   65 +
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |  106 ++
 .../netronome/nfp/nfpcore/nfp6000/nfp6000.h        |   88 +
 .../netronome/nfp/nfpcore/nfp6000/nfp_xpb.h        |   57 +
 .../ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c  | 1364 +++++++++++++++
 .../ethernet/netronome/nfp/nfpcore/nfp6000_pcie.h  |   46 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_arm.h   |  246 +++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h   |  438 +++++
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   | 1746 ++++++++++++++++++++
 .../ethernet/netronome/nfp/nfpcore/nfp_cpplib.c    |  281 ++++
 .../ethernet/netronome/nfp/nfpcore/nfp_hwinfo.c    |  318 ++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_mip.c   |  174 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nffw.c  |  323 ++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h  |   95 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |  417 +++++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   |  270 +++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h   |   81 +
 .../ethernet/netronome/nfp/nfpcore/nfp_resource.c  |  279 ++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c |  304 ++++
 .../ethernet/netronome/nfp/nfpcore/nfp_target.c    |  764 +++++++++
 include/linux/bitfield.h                           |   13 +
 33 files changed, 8794 insertions(+), 194 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_main.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_main.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_main.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/crc32.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000/nfp6000.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000/nfp_xpb.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_arm.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpplib.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_hwinfo.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_target.c

-- 
2.11.0
