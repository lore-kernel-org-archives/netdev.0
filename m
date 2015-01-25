From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 0/9] mlx4: Fix and enhance the device reset flow
Date: Sun, 25 Jan 2015 16:59:34 +0200
Message-ID: <1422197983-16048-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33606 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751799AbbAYO7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 09:59:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series from Yishai Hadas fixes the device reset flow and adds SRIOV support.

Reset flows are required whenever a device experiences errors, is unresponsive,
or is not in a deterministic state. In such cases, the driver is expected to
reset the HW and continue operation. When SRIOV is enabled, these requirements
apply both to PF and VF devices.

Currently, the mlx4 reset flow doesn't work properly: when a fatal error is 
detected on the FW internal buffer the chip is not reset and stays in its 
bad state. There are cases that assumed to be fatal such as non-responsive FW, 
errors via closing commands but are not handled today.

The AER mechanism should also be fixed:
- It should use mlx4_load_one instead of __mlx4_init_one which is done
  upon HCA probing.
- It must be aligned with concurrent catas flow, mark device to be in
  an error state, reset chip, etc.
- Port types should be restored to their original values before error occurred.

In addition, there the SRIOV use-case isn't supported.

In above cases when the device state becomes fatal we must act as follows:
1) Reset the chip and mark the HW device state as in fatal error.
2) Wake up any pending commands, preventing new ones to come in.
3) Restart the software stack.

We also address the SRIOV mode as follows: In case the PF detects a fatal error, 
it lets VFs know about that, then both itself and VFs are restarted asynchronously. 
However, in case only the VF encountered a fatal case or forced to be reset, they 
reset the VF stuff and then restart software.

changes from V0:

#patch #7:  
No need to call pci_disable_device upon permanent PCI error. This will
be done as part of mlx4_remove_one which is called later once we
return PCI_ERS_RESULT_DISCONNECT from the pci error handler.

#patch  #8: 
Initial toggle value should use only the T bit and not the whole byte value.
Not doing so sometimes broke SRIOV as of junky value seen by the VF as a 
non-ready comm channel

Yishai, Matan and Or.

Yishai Hadas (9):
  net/mlx4_core: Maintain a persistent memory for mlx4 device
  net/mlx4_core: Set device configuration data to be persistent across reset
  net/mlx4_core: Refactor the catas flow to work per device
  net/mlx4_core: Enhance the catas flow to support device reset
  net/mlx4_core: Activate reset flow upon fatal command cases
  net/mlx4_core: Manage interface state for Reset flow cases
  net/mlx4_core: Handle AER flow properly
  net/mlx4_core: Enable device recovery flow with SRIOV
  net/mlx4_core: Reset flow activation upon SRIOV fatal command cases

 drivers/infiniband/hw/mlx4/alias_GUID.c            |    2 +-
 drivers/infiniband/hw/mlx4/mad.c                   |    3 +-
 drivers/infiniband/hw/mlx4/main.c                  |   17 +-
 drivers/infiniband/hw/mlx4/mr.c                    |    6 +-
 drivers/infiniband/hw/mlx4/sysfs.c                 |    6 +-
 drivers/net/ethernet/mellanox/mlx4/alloc.c         |   15 +-
 drivers/net/ethernet/mellanox/mlx4/catas.c         |  294 +++++++++++----
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  407 +++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_cq.c         |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c       |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |    4 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   52 ++-
 drivers/net/ethernet/mellanox/mlx4/icm.c           |   11 +-
 drivers/net/ethernet/mellanox/mlx4/intf.c          |    8 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |  392 +++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    6 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   27 +-
 drivers/net/ethernet/mellanox/mlx4/mr.c            |    8 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c            |    6 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |   17 +-
 drivers/net/ethernet/mellanox/mlx4/reset.c         |   23 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   36 ++-
 include/linux/mlx4/cmd.h                           |    3 +
 include/linux/mlx4/device.h                        |   34 ++-
 27 files changed, 1046 insertions(+), 347 deletions(-)
