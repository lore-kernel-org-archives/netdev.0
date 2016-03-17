From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 00/13] devlink: add support for configuration of shared buffers
Date: Thu, 17 Mar 2016 18:13:40 +0100
Message-ID: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37291 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934357AbcCQRN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:13:57 -0400
Received: by mail-wm0-f49.google.com with SMTP id p65so3271840wmp.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:13:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This RFC implements support for configuring ASIC shared buffers.

ASICs implement shared buffer for packet forwarding purposes and enable
flexible partitioning of the shared buffer for different flows and ports,
enabling non-blocking progress of different flows as well as separation
of lossy traffic from loss-less traffic when using Per-Priority Flow
Control (PFC). The shared buffer optimizes the buffer utilization for better
absorption of packet bursts.

This patchset implements API which is based on the model SAI uses. That is
aligned with multiple ASIC vendors so this API should be vendor neutral.

Userspace counterpart patch for devlink iproute2 tool can be found here:
https://github.com/jpirko/iproute2_mlxsw/tree/devlink_sb_rfc

Couple of examples of usage:
$ devlink sb help
Usage: devlink sb show [ DEV [ sb SB_INDEX ] ]
       devlink sb pool show [ DEV [ sb SB_INDEX ] pool POOL_INDEX ]
       devlink sb pool set DEV [ sb SB_INDEX ] pool POOL_INDEX
                           size POOL_SIZE thtype { static | dynamic }
       devlink sb port pool show [ DEV/PORT_INDEX [ sb SB_INDEX ]
                                   pool POOL_INDEX ]
       devlink sb port pool set DEV/PORT_INDEX [ sb SB_INDEX ]
                                pool POOL_INDEX th THRESHOLD
       devlink sb tc bind show [ DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX ]
       devlink sb tc bind set DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX
                              type { ingress | egress } pool POOL_INDEX
                              th THRESHOLD

$ devlink sb show
pci/0000:03:00.0: sb 0 size 16777216 ingress_pools 4 egress_pools 4 tcs 8

$ devlink sb pool show
pci/0000:03:00.0: sb 0 pool 0 type ingress size 12399936 thtype dynamic
pci/0000:03:00.0: sb 0 pool 1 type ingress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 2 type ingress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 3 type ingress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 4 type egress size 13219968 thtype dynamic
pci/0000:03:00.0: sb 0 pool 5 type egress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 6 type egress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 7 type egress size 13219968 thtype dynamic

$ devlink sb port pool show
pci/0000:03:00.0/1: sb 0 pool 0 threshold 255
pci/0000:03:00.0/1: sb 0 pool 1 threshold 0
pci/0000:03:00.0/1: sb 0 pool 2 threshold 0
pci/0000:03:00.0/1: sb 0 pool 3 threshold 0
pci/0000:03:00.0/1: sb 0 pool 4 threshold 7
pci/0000:03:00.0/1: sb 0 pool 5 threshold 0
pci/0000:03:00.0/1: sb 0 pool 6 threshold 0
pci/0000:03:00.0/1: sb 0 pool 7 threshold 0
...
pci/0000:03:00.0/63: sb 0 pool 0 threshold 255
pci/0000:03:00.0/63: sb 0 pool 1 threshold 0
pci/0000:03:00.0/63: sb 0 pool 2 threshold 0
pci/0000:03:00.0/63: sb 0 pool 3 threshold 0
pci/0000:03:00.0/63: sb 0 pool 4 threshold 7
pci/0000:03:00.0/63: sb 0 pool 5 threshold 0
pci/0000:03:00.0/63: sb 0 pool 6 threshold 0
pci/0000:03:00.0/63: sb 0 pool 7 threshold 0

$ devlink sb tc bind show
pci/0000:03:00.0/1: sb 0 tc 0 type ingress pool 0 threshold 8
pci/0000:03:00.0/1: sb 0 tc 0 type egress pool 4 threshold 9
pci/0000:03:00.0/1: sb 0 tc 1 type ingress pool 0 threshold 0
pci/0000:03:00.0/1: sb 0 tc 1 type egress pool 4 threshold 9
pci/0000:03:00.0/1: sb 0 tc 2 type ingress pool 0 threshold 0
pci/0000:03:00.0/1: sb 0 tc 2 type egress pool 4 threshold 9
pci/0000:03:00.0/1: sb 0 tc 3 type ingress pool 0 threshold 0
pci/0000:03:00.0/1: sb 0 tc 3 type egress pool 4 threshold 9
pci/0000:03:00.0/1: sb 0 tc 4 type ingress pool 0 threshold 0
pci/0000:03:00.0/1: sb 0 tc 4 type egress pool 4 threshold 9
pci/0000:03:00.0/1: sb 0 tc 5 type ingress pool 0 threshold 0
pci/0000:03:00.0/1: sb 0 tc 5 type egress pool 4 threshold 9
pci/0000:03:00.0/1: sb 0 tc 6 type ingress pool 0 threshold 0
pci/0000:03:00.0/1: sb 0 tc 6 type egress pool 4 threshold 9
pci/0000:03:00.0/1: sb 0 tc 7 type ingress pool 0 threshold 0
pci/0000:03:00.0/1: sb 0 tc 7 type egress pool 4 threshold 9
...
pci/0000:03:00.0/63: sb 0 tc 0 type ingress pool 0 threshold 8
pci/0000:03:00.0/63: sb 0 tc 0 type egress pool 4 threshold 9
pci/0000:03:00.0/63: sb 0 tc 1 type ingress pool 0 threshold 0
pci/0000:03:00.0/63: sb 0 tc 1 type egress pool 4 threshold 9
pci/0000:03:00.0/63: sb 0 tc 2 type ingress pool 0 threshold 0
pci/0000:03:00.0/63: sb 0 tc 2 type egress pool 4 threshold 9
pci/0000:03:00.0/63: sb 0 tc 3 type ingress pool 0 threshold 0
pci/0000:03:00.0/63: sb 0 tc 3 type egress pool 4 threshold 9
pci/0000:03:00.0/63: sb 0 tc 4 type ingress pool 0 threshold 0
pci/0000:03:00.0/63: sb 0 tc 4 type egress pool 4 threshold 9
pci/0000:03:00.0/63: sb 0 tc 5 type ingress pool 0 threshold 0
pci/0000:03:00.0/63: sb 0 tc 5 type egress pool 4 threshold 9
pci/0000:03:00.0/63: sb 0 tc 6 type ingress pool 0 threshold 0
pci/0000:03:00.0/63: sb 0 tc 6 type egress pool 4 threshold 9
pci/0000:03:00.0/63: sb 0 tc 7 type ingress pool 0 threshold 0
pci/0000:03:00.0/63: sb 0 tc 7 type egress pool 4 threshold 9

$ sudo devlink sb pool set pci/0000:03:00.0 pool 1 size 40000 thtype static

$ devlink sb pool show pci/0000:03:00.0 pool 1
pci/0000:03:00.0: sb 0 pool 1 type ingress size 40032 thtype static

$ sudo devlink sb port pool set pci/0000:03:00.0/1 pool 1 th 20000

$ devlink sb port pool show pci/0000:03:00.0/1 pool 1
pci/0000:03:00.0/1: sb 0 pool 1 threshold 20064

$ sudo devlink sb tc bind set pci/0000:03:00.0/1 tc 1 type ingress pool 1 th 10000

$ devlink sb tc bind show pci/0000:03:00.0/1 tc 1 type ingress
pci/0000:03:00.0/1: sb 0 tc 1 type ingress pool 1 threshold 10080

Jiri Pirko (13):
  devlink: share user_ptr pointer for for both devlink and devlink_port
  devlink: add shared buffer configuration
  mlxsw: Move devlink port registration into common core code
  mlxsw: Pass mlxsw_core as a param of mlxsw_core_skb_transmit*
  mlxsw: Do not pass around driver_priv directly
  mlxsw: reg: Share direction enum between SBPR, SBCM, SBPM
  mlxsw: reg: Fix SBPM register name
  mlxsw: core: Add devlink shared buffer callbacks
  mlxsw: spectrum_buffers: Push out shared buffer register writes
  mlxsw: spectrum_buffers: Push out indexes and direction out of SB
    structs
  mlxsw: spectrum_buffers: Rename "pool" to "pr" in initialization
  mlxsw: spectrum_buffers: Cache shared buffer configuration
  mlxsw: spectrum: Implement shared buffer configuration

 drivers/net/ethernet/mellanox/mlxsw/core.c         | 161 +++-
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  55 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  27 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  60 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  52 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 698 ++++++++++-----
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |  42 +-
 include/net/devlink.h                              |  46 +
 include/uapi/linux/devlink.h                       |  41 +
 net/core/devlink.c                                 | 932 ++++++++++++++++++++-
 10 files changed, 1773 insertions(+), 341 deletions(-)

-- 
2.5.0
