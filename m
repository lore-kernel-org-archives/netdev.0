From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/18] devlink + mlxsw: add support for config and control of shared buffers
Date: Thu, 14 Apr 2016 18:19:12 +0200
Message-ID: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33076 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235AbcDNQTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:34 -0400
Received: by mail-wm0-f47.google.com with SMTP id f198so4665458wme.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

ASICs implement shared buffer for packet forwarding purposes and enable
flexible partitioning of the shared buffer for different flows and ports,
enabling non-blocking progress of different flows as well as separation
of lossy traffic from loss-less traffic when using Per-Priority Flow
Control (PFC). The shared buffer optimizes the buffer utilization for better
absorption of packet bursts.

This patchset implements API which is based on the model SAI uses. That is
aligned with multiple ASIC vendors so this API should be vendor neutral.

Userspace counterpart patchset for devlink iproute2 tool can be found here:
https://github.com/jpirko/iproute2_mlxsw/tree/devlink_sb

Couple of examples of usage:

switch$ devlink sb help
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
       devlink sb occupancy show { DEV | DEV/PORT_INDEX } [ sb SB_INDEX ]
       devlink sb occupancy snapshot DEV [ sb SB_INDEX ]
       devlink sb occupancy clearmax DEV [ sb SB_INDEX ]

# list available share buffers
switch$ devlink sb show
pci/0000:03:00.0: sb 0 size 16777216 ing_pools 4 eg_pools 4 ing_tcs 8 eg_tcs 8

# list available pools and their config
switch$ devlink sb pool show
pci/0000:03:00.0: sb 0 pool 0 type ingress size 12400032 thtype dynamic
pci/0000:03:00.0: sb 0 pool 1 type ingress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 2 type ingress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 3 type ingress size 200064 thtype dynamic
pci/0000:03:00.0: sb 0 pool 4 type egress size 13220064 thtype dynamic
pci/0000:03:00.0: sb 0 pool 5 type egress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 6 type egress size 0 thtype dynamic
pci/0000:03:00.0: sb 0 pool 7 type egress size 0 thtype dynamic

# show port-pool setup for port sw0p7
switch$ devlink sb port pool show sw0p7 pool 0
sw0p7: sb 0 pool 0 threshold 16

# change threshold for port sw0p7
switch$ sudo devlink sb port pool set sw0p7 pool 0 th 15

# show port-pool changed setup for port sw0p7
switch$ devlink sb port pool show sw0p7 pool 0
sw0p7: sb 0 pool 0 threshold 15

# show TC binding setup for port sw0p7 ingress TC 0
switch$ devlink sb tc bind show sw0p7 tc 0 type ingress
sw0p7: sb 0 tc 0 type ingress pool 0 threshold 10

# change threshold TC binding setup for port sw0p7 ingress TC 0
switch$ sudo devlink sb tc bind set sw0p7 tc 0 type ingress pool 0 th 9

# show TC binding changed setup for port sw0p7 ingress TC 0
switch$ devlink sb tc bind show sw0p7 tc 0 type ingress
sw0p7: sb 0 tc 0 type ingress pool 0 threshold 9

# make a snapshot of occupancy of shared buffer for device pci/0000:03:00.0
switch$ sudo devlink sb occupancy snapshot pci/0000:03:00.0

# show occupancy for port sw0p7 from the snapshot (current/watermark)
switch$ devlink sb occupancy show sw0p7
sw0p7:
  pool: 0:      82944/3217344 1:          0/0       2:          0/0       3:          0/0      
        4:          0/384     5:          0/0       6:          0/0       7:          0/0      
  itc:  0(0):   96768/3217344 1(0):       0/0       2(0):       0/0       3(0):       0/0      
        4(0):       0/0       5(0):       0/0       6(0):       0/0       7(0):       0/0      
  etc:  0(4):       0/384     1(4):       0/0       2(4):       0/0       3(4):       0/0      
        4(4):       0/0       5(4):       0/0       6(4):       0/0       7(4):       0/0

# clear watermarks for shared buffer of device pci/0000:03:00.0
switch$ sudo devlink sb occupancy clearmax pci/0000:03:00.0

Jiri Pirko (18):
  devlink: add shared buffer configuration
  devlink: implement shared buffer occupancy monitoring interface
  mlxsw: core: Add devlink shared buffer callbacks
  mlxsw: spectrum_buffers: Push out shared buffer register writes
  mlxsw: spectrum_buffers: Push out indexes and direction out of SB
    structs
  mlxsw: spectrum_buffers: Rename "pool" to "pr" in initialization
  mlxsw: spectrum_buffers: Cache shared buffer configuration
  mlxsw: spectrum_buffers: Remove eg pool 3 default init and CPU port TC
    binding to it
  mlxsw: spectrum_buffers: Change initialization of PG 9
  mlxsw: spectrum_buffers: Get max_buff defaults into limits exposed to
    user
  mlxsw: core: Add mlxsw_core_port_driver_priv helper
  mlxsw: spectrum_buffers: Implement shared buffer configuration
  mlxsw: core: Add devlink shared buffer occupancy callbacks
  mlxsw: reg: Add Shared Buffer Status register definition
  mlxsw: reg: Extend SBPM register for occupancy control
  mlxsw: core: Add mlxsw specific workqueue and use it for FDB notif.
    processing
  mlxsw: core: Introduce support for asynchronous EMAD register access
  mlxsw: spectrum_buffers: Implement occupancy monitoring

 drivers/net/ethernet/mellanox/mlxsw/core.c         |  682 ++++++++---
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   56 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  135 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   32 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   68 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c |  974 +++++++++++----
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |    4 +-
 include/net/devlink.h                              |   59 +
 include/uapi/linux/devlink.h                       |   63 +
 net/core/devlink.c                                 | 1236 ++++++++++++++++++--
 10 files changed, 2787 insertions(+), 522 deletions(-)

-- 
2.5.5
