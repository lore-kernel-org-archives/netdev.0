From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v4 net-next 0/4]: Allow head adjustment in XDP prog
Date: Wed, 7 Dec 2016 15:53:10 -0800
Message-ID: <1481154794-2311034-1-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39438 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932434AbcLGXzc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 18:55:32 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uB7NkYwZ019310
        for <netdev@vger.kernel.org>; Wed, 7 Dec 2016 15:55:31 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 276r39u6cq-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 15:55:31 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 5159dd4abcd811e6954c0002c99331b0-873f3a50 for <netdev@vger.kernel.org>;        Wed,
 07 Dec 2016 15:53:14 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a helper to allow head adjusting in XDP prog.  mlx4
driver has been modified to support this feature.  An example is written
to encapsulate a packet with an IPv4/v6 header and then XDP_TX it
out.

v4:
1. Remove XDP_QUERY_FEATURES command.  Instead, check
   the prog->xdp_adjust_head bit inside the driver itself
   during XDP_SETUP_PROG in patch 1of4.
   Thanks for everybody's ideas.
2. Nit changes on sample code per Jesper

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
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  29 ++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  70 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   9 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   5 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   4 +
 drivers/net/ethernet/qlogic/qede/qede_main.c       |   5 +
 include/linux/filter.h                             |   6 +-
 include/uapi/linux/bpf.h                           |  11 +-
 kernel/bpf/core.c                                  |   2 +-
 kernel/bpf/syscall.c                               |   2 +
 kernel/bpf/verifier.c                              |   2 +-
 net/core/filter.c                                  |  28 ++-
 samples/bpf/Makefile                               |   4 +
 samples/bpf/bpf_helpers.h                          |   2 +
 samples/bpf/bpf_load.c                             |  94 ++++++++
 samples/bpf/bpf_load.h                             |   1 +
 samples/bpf/xdp1_user.c                            |  93 --------
 samples/bpf/xdp_tx_iptunnel_common.h               |  37 +++
 samples/bpf/xdp_tx_iptunnel_kern.c                 | 236 +++++++++++++++++++
 samples/bpf/xdp_tx_iptunnel_user.c                 | 256 +++++++++++++++++++++
 24 files changed, 762 insertions(+), 145 deletions(-)
 create mode 100644 samples/bpf/xdp_tx_iptunnel_common.h
 create mode 100644 samples/bpf/xdp_tx_iptunnel_kern.c
 create mode 100644 samples/bpf/xdp_tx_iptunnel_user.c

-- 
2.5.1
