From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time device specific parameters
Date: Wed, 11 Mar 2015 11:08:50 +0200
Message-ID: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, shannon.nelson@intel.com,
	dledford@redhat.com, greearb@candelatech.com,
	Rose Gregory V <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg K-H <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48091 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751746AbbCKJJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 05:09:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset adds support to enabling configuring _ConnectX-3 specific_
hardware tunables. Hadar took the RFC [1] (the V0) and adapted it according to
Greg K-H comments. And also according to previous similar discussions with
Intel [1] and [2]. I understand and agree with your approach that user
shouldn't care which hardware is at the bottom of the network stack. but, we're
talking here on an HCA that could be both Ethernet and RDMA device - so, the
usual networking API's might not suitable for all its tunables. Also, customers
are paying for a very sophisticated piece of hardware, and we would like to
enable power user to tweak it in some situtations. Of course the default mode
should be used in 99% of the use cases.

Below is Hadar text that gets into the details.

Thanks,
Amir.


When configuring a device at an early boot stage, most kernel drivers
use module parameters (the parameters' settings can be determined in
modprobe.d config files).
These parameters are difficult to manage, and one of the reasons is that
module parameters are set per driver and not per device (NICs using the
same driver cannot be set with different configurations).
Furthermore, using other existing configuration tools like ethtool,
ifconfig, ip link commands or sysfs entries is not applicable, since
they all rely on having a netdevice already set up.

In the past, 'request_firmware' solution for configuration parameters
was suggested by Shannon Nelson from Intel[1]. The idea was rejected by
Greg KH, who claimed it was abusive of the request_firmware mechanism.
Greg suggested using configfs for device configuration instead (as done
by the USB gadget driver).

We introduce a new mlx4_core infrastructure using configfs to allow the
configuration of mlx4 device. The goal is to set low-level device
functionality which is specific to Mellanox ConnectX device
hardware/firmware, needs to be sorted when the device is initialized and
before the upper layer protocol (Ethernet or Infiniband) is set.

Lately Intel suggested to configure NPAR BW configuration through
configfs[2]. The idea was rejected since those are networking
parameters that could be used in the future by other devices or vendors.

This patchset is a continuation to the RFC already sent by us[3].
We follow Greg K-H suggestion and implemented configfs for mlx4_core use
only.

In this patchset we export to configfs 2 parameters dmfs mode and port
type. Both parameters must be set at initialization stage since port
type determine which upper layer protocol to use and dmfs mode must be
set before Ethernet or IPoIB interfaces are up. Until now, the user was
able to change dmfs mode and port type (in SR-IOV) only through module
parameter, before mlx4_core was loaded. Using configfs allows setting
those parameters after mlx4_core is loaded and also set different
configuration per pci device. In the future, new low-level and specific
device configurations for mlx4_core will be configured through configfs.

Hadar.

Changes from V0:
- Remove devconf generic module
- Move configfs configuration tree from drivers/devconf to mlx4
private location.

[1] - https://lkml.org/lkml/2013/1/10/606
[2] - https://lkml.org/lkml/2015/3/3/724
[3] - http://marc.info/?l=linux-netdev&m=142074512422335&w=2

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>

Hadar Hen Zion (3):
  net/mlx4_core: Add configfs entries for setting device specific
    parameters
  net/mlx4_core: Set port_type value according to configfs configuration
  net/mlx4_core: Set DMFS mode according to configfs configuration

 drivers/net/ethernet/mellanox/mlx4/Kconfig  |   8 +
 drivers/net/ethernet/mellanox/mlx4/Makefile |   2 +-
 drivers/net/ethernet/mellanox/mlx4/catas.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx4/conf.c   | 532 ++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c   |  76 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h   |  47 ++-
 include/linux/mlx4/device.h                 |  12 +
 7 files changed, 659 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/conf.c

-- 
1.9.3
