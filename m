From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 0/9] bpf: xdp: Report bpf_prog ID in IFLA_XDP
Date: Tue, 13 Jun 2017 14:08:32 -0700
Message-ID: <20170613210841.509578-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40846 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753942AbdFMVIt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:08:49 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DL6vAe025977
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:08:43 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2b29g4ccn3-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:08:43 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 7a9ae54a507c11e78cc70002c95209d8-e47456b0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 14:08:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first usage of the new bpf_prog ID.  It is for
reporting the ID of a xdp_prog through netlink.

It rides on the existing IFLA_XDP.  This patch adds IFLA_XDP_PROG_ID
for the bpf_prog ID reporting.

It starts with changing the generic_xdp first.  After that,
the hardware driver is changed one by one.  Jakub Kicinski mentioned
that he will soon introduce XDP_ATTACHED_HW (on top of the existing
XDP_ATTACHED_DRV and XDP_ATTACHED_SKB)
and he is going to reuse the prog_attached for this purpose.
Hence, this patch set keeps the prog_attached even though
!!prog_id also implies there is xdp_prog attached.

I have tested with generic_xdp, mlx4 and mlx5.

v2:
1. Remove READ_ONCE since it is alredy under rtnl lock
2. Keep prog_attached in 'struct netdev_xdp' as
   requested by Jakub Kicinski.  The existing prog_attached
   and the new prog_id are put under a struct for XDP_QUERY_PROG.

Martin KaFai Lau (9):
  net: Add IFLA_XDP_PROG_ID
  bpf: mlx4: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: mlx5e: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: virtio_net: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: bnxt: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: thunderx: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: ixgbe: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: nfp: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: qede: Report bpf_prog ID during XDP_QUERY_PROG

 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      | 14 +++++++++--
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 14 +++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 14 +++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     | 21 ++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 15 +++++++++---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 14 +++++++++--
 drivers/net/ethernet/qlogic/qede/qede_filter.c     | 14 +++++++++--
 drivers/net/virtio_net.c                           | 13 +++++++----
 include/linux/netdevice.h                          |  7 ++++--
 include/uapi/linux/if_link.h                       |  1 +
 net/core/dev.c                                     | 24 ++++++++++++-------
 net/core/rtnetlink.c                               | 27 +++++++++++++++++-----
 12 files changed, 141 insertions(+), 37 deletions(-)

-- 
2.9.3
