From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 0/4]: Allow head adjustment in XDP prog
Date: Tue, 6 Dec 2016 21:31:50 -0800
Message-ID: <1481088714-54512-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:42198 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932090AbcLGFb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 00:31:58 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB75TWWw032760
        for <netdev@vger.kernel.org>; Tue, 6 Dec 2016 21:31:58 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2766ea4s0p-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 21:31:58 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 7783fccabc3e11e6afea0002c992ebde-62dfba50 for <netdev@vger.kernel.org>;        Tue,
 06 Dec 2016 21:31:56 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a helper to allow head adjusting in XDP prog.  mlx4
driver has been modified to support this feature.  An example is written
to encapsulate a packet with an IPv4/v6 header and then XDP_TX it
out.

v3:
1. Check if the driver supports head adjustment before
   setting the xdp_prog fd to the device in patch 1of4.
2. Remove the page alignment assumption on the data_hard_start.
   Instead, add data_hard_start to the struct xdp_buff and the
   driver has to fill it if it supports head adjustment.
3. Keep the wire MTU as before in mlx4
4. Set map0_byte_count to PAGE_SIZE in patch 3of4

v2:
1. Make a variable name change in bpf_xdp_adjust_head() in patch 1
2. Ensure no less than ETH_HLEN data in bpf_xdp_adjust_head() in patch 1
3. Some clarifications in commit log messages of patch 2 and 3

Thanks,
Martin

Martin KaFai Lau (4):
  bpf: xdp: Allow head adjustment in XDP prog
  mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs
  mlx4: xdp: Reserve headroom for receiving packet when XDP prog is
    active
  bpf: xdp: Add XDP example for head adjustment

 arch/powerpc/net/bpf_jit_comp64.c                  |   4 +-
 arch/s390/net/bpf_jit_comp.c                       |   2 +-
 arch/x86/net/bpf_jit_comp.c                        |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  32 ++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  70 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   9 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   3 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   3 +
 drivers/net/ethernet/qlogic/qede/qede_main.c       |   3 +
 include/linux/filter.h                             |   6 +-
 include/linux/netdevice.h                          |  12 +
 include/uapi/linux/bpf.h                           |  11 +-
 kernel/bpf/core.c                                  |   2 +-
 kernel/bpf/syscall.c                               |   2 +
 kernel/bpf/verifier.c                              |   2 +-
 net/core/dev.c                                     |   9 +
 net/core/filter.c                                  |  28 ++-
 samples/bpf/Makefile                               |   4 +
 samples/bpf/bpf_helpers.h                          |   2 +
 samples/bpf/bpf_load.c                             |  94 ++++++++
 samples/bpf/bpf_load.h                             |   1 +
 samples/bpf/xdp1_user.c                            |  93 --------
 samples/bpf/xdp_tx_iptnl_common.h                  |  37 +++
 samples/bpf/xdp_tx_iptnl_kern.c                    | 232 +++++++++++++++++++
 samples/bpf/xdp_tx_iptnl_user.c                    | 253 +++++++++++++++++++++
 26 files changed, 774 insertions(+), 145 deletions(-)
 create mode 100644 samples/bpf/xdp_tx_iptnl_common.h
 create mode 100644 samples/bpf/xdp_tx_iptnl_kern.c
 create mode 100644 samples/bpf/xdp_tx_iptnl_user.c

-- 
2.5.1
