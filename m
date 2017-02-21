From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v3 0/8] xdp: Infrastructure to generalize XDP
Date: Tue, 21 Feb 2017 11:34:09 -0800
Message-ID: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33044 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751938AbdBUTe0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 14:34:26 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LJSewB030246
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:25 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28rt2j0fv5-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:25 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 bffd2d4af86c11e69c810002c99331b0-d59f9a00 for <netdev@vger.kernel.org>;        Tue,
 21 Feb 2017 11:34:24 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set generalizes XDP by making the hooks in drivers to be
generic. This has a number of advantages:

  - Allows a means to pipeline XDP programs together
  - Reduces the amount of code and complexity needed in drivers to
    manage XDP
  - Provides a more structured environment that is extensible to new
    features while being mostly transparent to the drivers
  - Allow XDP programs to be set per device or per queue
  - Moves management of BPF programs out of driver into a common
    infrastructure

The generic XDP infrastructure is based on an xdp_hook structure that
contains callback functions and private data structure that can be
populated by the user of XDP. The XDP hooks are registered either on a
netdev or a napi (both maintain a list of XDP hooks). Allowing per
netdev hooks makes management of XDP a lot simpler when the intent is
for the hook to apply to the whole device (as is the case with XDP_BPF
so far).  Multiple xdp hooks may be registered on a device or napi
instance, the order of execution is indicated in the priority field of
the xdp_hook structure. Execution of the list contains to the end or
until a program returns something other than XDP_PASS. If both
napi XDP hooks and device hooks are enabled, the NAPI hooks are run
first.

The xdp_hook structure contains a "hookfn" field that is the function
executes a hook. The "priv" structure is private data that is provided
as an argument to hookfn-- in the case of a BPF hook this is simply
the bpf_prog.

Hooks may be registered by xdp_register_dev_hook or
xdp_register_napi_hook, and subsequently they can be unregistered
but xdp_unregister_dev_hook and xdp_unregister_napi_hook. The
identifier for a hook is the pointer to the template hook that was
used to register the hook. xdp_find_dev_hook and
xdp_find_napi_hook will return whether a hook has been registered
and optionally return the contents of the hook. xdp_bpf_check_prog
is to check if the driver is okay with running the program (uses the
XDP_CHECK_BPF_PROG ndo command described below).

Driver interface:

Drivers no longer deal with BPF programs for the most part, instead
they call into the XDP interface.

There are two functions of interest for use in the receive data path:
  - xdp_hook_run_needed_check: returns true if there is an XDP
    program registered on the napi instance or its device
  - xdp_hook_run, xdp_hook_run_ret_last: runs the XDP programs for
    the hooks registered for the given napi instance or its device.
    The latter variant returns a pointer to the last XDP hook that
    was run (useful for reporting).

The ndo_xdp defines a new set of commands for this interface. A driver
should implement these commands:
  - XDP_MODE_ON: Initialize device to use XDP. Called when first XDP
		 program is registered on a device (including on a NAPI
		 instance).
  - XDP_MODE_OFF: XDP is finished on the device. Called after the last
		  XDP hook has been unregistered for a device.
  - XDP_CHECK_BPF_PROG: Check if a BPF program is acceptable to a device
		  to run.
  - XDP_OFFLOAD_BPF: Offload the associated BPF program (e.g. Netronome).

A new net feature is added NETIF_F_XDP so that a driver indicates
that is supports XDP.

This patch set:
  - Adds the infrastructure described above include xdp.c and xdp.h files.
  - Modifies mlx4, mlx5, qede, nfp, and virt_net drivers to use the new
    interface. That is mostly removed the management of BPF programs and
    changing to call the new interface.

v2:
  - Eliminate use of nfhooks like lists. Just use use simple array for
    the hooks
  - Modify more drivers that now support XDP

v3:
  - Don't allow non-BPF hooks to be set

Tested:

Tested XDP_DROP and XDP_TX on mlx5. No regression or other issues noted.

Testing other drviers is TBD.

Tom Herbert (8):
  xdp: Infrastructure to generalize XDP
  mlx4: Changes to use generic XDP infrastructure
  nfp: Changes to use generic XDP infrastructure
  qede: Changes to use generic XDP infrastructure
  virt_net: Changes to use generic XDP infrastructure
  mlx5: Changes to use generic XDP infrastructure
  bnxt: Changes to use generic XDP infrastructure
  xdp: Cleanup after API changes

 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  14 -
 drivers/net/ethernet/broadcom/bnxt/bnxt.h          |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      |  46 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  92 ++-----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  27 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |   1 -
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 108 ++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  12 +-
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   5 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 170 ++++++------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  12 +-
 drivers/net/ethernet/qlogic/qede/qede.h            |   3 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c    |   2 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c     |  39 ++-
 drivers/net/ethernet/qlogic/qede/qede_fp.c         |  36 ++-
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  23 +-
 drivers/net/virtio_net.c                           |  99 +++----
 include/linux/filter.h                             |  11 +-
 include/linux/netdev_features.h                    |   3 +-
 include/linux/netdevice.h                          |  27 +-
 include/net/xdp.h                                  | 296 ++++++++++++++++++++
 include/trace/events/xdp.h                         |  16 +-
 net/core/Makefile                                  |   2 +-
 net/core/dev.c                                     |  52 ++--
 net/core/filter.c                                  |   7 +-
 net/core/rtnetlink.c                               |  14 +-
 net/core/xdp.c                                     | 306 +++++++++++++++++++++
 30 files changed, 934 insertions(+), 496 deletions(-)
 create mode 100644 include/net/xdp.h
 create mode 100644 net/core/xdp.c

-- 
2.9.3
