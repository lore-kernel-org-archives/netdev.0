From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 00/12] bpf: add offload as a first class citizen
Date: Tue, 31 Oct 2017 18:52:05 -0700
Message-ID: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:50749 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKABw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:52:59 -0400
Received: by mail-pg0-f67.google.com with SMTP id y5so793320pgq.7
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:52:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series is my stab at what was discussed at a recent IOvisor
bi-weekly call.  The idea is to make the device translator run at
the program load time.  This makes the offload more explicit to
the user space.  It also makes it easy for the device translator
to insert information into the original verifier log.

The first patch renames the ndo_xdp into ndo_bpf, because I use
it to mux the BPF program load calls.  I'm not sure if that's
necessary.

Note, this RFC will not apply, the NFP patches have conflicts 
both with Alexei's stack work and TC block work.


Jakub Kicinski (12):
  net: bpf: rename ndo_xdp to ndo_bpf
  bpf: offload: add infrastructure for loading programs for a specific
    netdev
  bpf: report offload info to user space
  bpftool: print program device bound info
  xdp: allow attaching programs loaded for specific device
  cls_bpf: allow attaching programs loaded for specific device
  nfp: bpf: drop support for cls_bpf with legacy actions
  nfp: bpf: refactor offload logic
  nfp: bpf: require seamless reload for program replace
  nfp: bpf: remove the register renumbering leftovers
  nfp: bpf: move to new BPF program offload infrastructure
  bpf: remove old offload/analyzer

 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h      |   2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   4 +-
 drivers/net/ethernet/netronome/nfp/bpf/jit.c       | 194 ++-----------
 drivers/net/ethernet/netronome/nfp/bpf/main.c      |  84 +++---
 drivers/net/ethernet/netronome/nfp/bpf/main.h      |  60 ++--
 drivers/net/ethernet/netronome/nfp/bpf/offload.c   | 317 +++++++++------------
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c  |  54 +---
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  37 +++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   2 -
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  12 +-
 drivers/net/ethernet/qlogic/qede/qede.h            |   2 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c     |   2 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c       |   4 +-
 drivers/net/tun.c                                  |   4 +-
 drivers/net/virtio_net.c                           |   4 +-
 include/linux/bpf.h                                |  47 +++
 include/linux/bpf_verifier.h                       |  12 +-
 include/linux/netdevice.h                          |  37 ++-
 include/uapi/linux/bpf.h                           |   8 +
 kernel/bpf/Makefile                                |   1 +
 kernel/bpf/core.c                                  |  10 +-
 kernel/bpf/offload.c                               | 194 +++++++++++++
 kernel/bpf/syscall.c                               |  52 +++-
 kernel/bpf/verifier.c                              |  78 +----
 net/core/dev.c                                     |  40 +--
 net/core/filter.c                                  |  42 ---
 net/core/rtnetlink.c                               |   4 +-
 net/sched/cls_bpf.c                                |  10 +-
 tools/bpf/bpftool/prog.c                           |  31 ++
 tools/include/uapi/linux/bpf.h                     |   8 +
 36 files changed, 700 insertions(+), 680 deletions(-)
 create mode 100644 kernel/bpf/offload.c

-- 
2.14.1
