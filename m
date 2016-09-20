From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 0/3] xdp: Generalize XDP
Date: Tue, 20 Sep 2016 15:00:21 -0700
Message-ID: <1474408824-418864-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tariqt@mellanox.com>,
        <bblanco@plumgrid.com>, <alexei.starovoitov@gmail.com>,
        <eric.dumazet@gmail.com>, <brouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39905 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754509AbcITWAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 18:00:33 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8KLxmcl020233
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:00:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25kbkegxrv-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:00:32 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 a629ac587f7d11e6aa9b0002c9dfb610-183fda50 for <netdev@vger.kernel.org>;        Tue,
 20 Sep 2016 15:00:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set generalizes XDP by make the hooks in drivers to be
generic in the same manner of nfhooks. This has a number of
advantages:

  - Allows alternative users of the XDP hooks other than the original
    BPF
  - Allows a means to pipeline XDP programs together
  - Reduces the amount of code and complexity needed in drivers to
    manage XDP
  - Provides a more structured environment that is extensible to new
    features while being mostly transparent to the drivers 

The generic XDP infrastructure is based on how nfhooks works. The new
xdp_hook_ops structure contains callback functions and private data
structure that can be populated by the user of XDP. The hook ops are
registered either on a netdev or a napi (both maintain a list of XDP
hook ops). Allow per netdev ops makes management of XDP a lot simpler
when the intent is for the hook to apply to the whole driver (as is the
case with XDP_BPF so far). The downside is that we may need per napi
data (such as counters of returned actions).

The xdp_hook_ops contains three fields of interest. The "hook" field is
the function that is run for the hook. This takes a private data field
and the xdp_buff as arguments. "priv" is private data and "put_priv"
is a function called when XDP is done with the private data. In XDP_BPF
terminology the hook field is bpf_prog_run_xdp, "priv" is the xdp_prog,
and "put_priv" is bpf_prog_put.

The meaning of ndo_xdp is also changed. There are two commands for this
nod: XDP_DEV_INIT and XDP_DEV_FINISH. XDP_DEV_INIT is called the first
time an XDP hook is set on a device, this is primarily intended to
allow the device to initialize XDP (allocated the XDP TX queues for
instance). XDP_DEV_FINISH is called when the last XDP hook is
removed from a driver so that the driver can cleanup when XDP is done.

A new net feature is added NETIF_F_XDP so that a driver indicates
that is supports XDP.

The primary modification to a driver to support XDP is that it call
xdp_hook_run in the receive path (equivalent to bpf_prog_run in
previous XDP-BPF). The driver must deal with the four XDP return
actions XDP_PASS, XDP_DROP, XDP_TX, and XDP_ABORT.

xdp.h contains the interface to register and manage XDP hooks.

Tested:

Created a simple hook that does XDP_PASS and saw it works. A lot more
testing is needed for this.

Tom Herbert (3):
  xdp: Infrastructure to generalize XDP
  mlx4: Change XDP/BPF to use generic XDP infrastructure
  netdevice: Remove obsolete xdp_netdev_command

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  64 ++------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  25 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |   1 -
 include/linux/filter.h                         |  19 +--
 include/linux/netdev_features.h                |   3 +-
 include/linux/netdevice.h                      |  24 ++-
 include/net/xdp.h                              | 218 +++++++++++++++++++++++++
 include/uapi/linux/bpf.h                       |  20 ---
 include/uapi/linux/xdp.h                       |  24 +++
 net/core/Makefile                              |   2 +-
 net/core/dev.c                                 |  44 ++++-
 net/core/filter.c                              |   7 +-
 net/core/rtnetlink.c                           |  16 +-
 net/core/xdp.c                                 | 211 ++++++++++++++++++++++++
 14 files changed, 534 insertions(+), 144 deletions(-)
 create mode 100644 include/net/xdp.h
 create mode 100644 include/uapi/linux/xdp.h
 create mode 100644 net/core/xdp.c

-- 
2.8.0.rc2
