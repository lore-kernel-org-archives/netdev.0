From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/16] Mellanox 100G SRIOV E-Switch offload and VF representors
Date: Mon, 27 Jun 2016 19:07:13 +0300
Message-ID: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36404 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751745AbcF0QJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 12:09:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

We are happy to announce SRIOV E-Switch offload and VF netdev representors.

Or Gerlitz says:

Currently, the way SR-IOV embedded switches are dealt with in Linux is limited 
in its expressiveness and flexibility, but this is not necessarily due to 
hardware limitations. The kernel software model for controlling the SR-IOV
switch simply does not allow the configuration of anything more complex than
MAC/VLAN based forwarding. 

Hence the benefits brought by SRIOV come at a price of management flexibility, 
when compared to software virtual switches which are used in Para-Virtual (PV) 
schemes and allow implementing complex policies and virtual topologies. Such 
SW switching typically involved a complex per-packet processing within the host 
kernel using subsystems such as TC, Bridge, Netfilter and Open-vswitch.

We'd like to change that and get the best of both worlds: the performance of SR-IOV 
with the management flexibility of software switches. This will eventually include 
a richer model for controlling the SR-IOV switch for flow-based switching and 
tunneling. Under this model, the e-switch is configured dynamically and a fallback 
to software exists in case the hardware is unable to offload all required flows.

This series from Hadar Hen-Zion and myself, is the 1st step in that direction, 
specfically, it provides full control on the SRIOV embedded switching by host 
software and paves the way to offload switching rules and polices with downstream 
patches.

To allow for host based SW control on the SRIOV HW switch, we introduce per VF 
representor host netdevice. The VF representor plays the same role as TAP devices
in PV setup. A packet send through the VF representor on the host arrives to 
the VF, and a packet sent through the VF is received by its representor. The
administrator can hook the representor netdev into a kernel switching component. 
Once they do that, packets from the VF are subject to steering (matching and 
actions) of that software component."

Doing so indeed hurts the performance benefits of SRIOV as it forces all the 
traffic to go through the hypervisor. However, this SW representation is what  
would eventually allow us to introduce hybrid model, where we offload steering 
for some of the VF/VM traffic to the HW while keeping other VM traffic to go 
through the hypervisor. Examples for the latter are first packet of flows which 
are needed for SW switches learning and/or matching against policy database or
types of traffic for which offloading is not desired or not supported by the
current HW eswitch generation.

The embedded switch is managed through a PCI device driver. As such, we introduce
a devlink/pci based scheme for setting the mode of the e-switch. The current mode
(where steering is done based on mac/vlan, etc) is referred to as "legacy" and the 
new mode as "offloads".

For the mlx5 driver / ConnectX4 HW case, the VF representors implement a functional 
subset of mlx5e Ethernet netdevices using their own profile. This design buys us robust 
implementation with code reuse and sharing.

The representors are created by the host PCI driver when (1) in SRIOV and (2) the 
e-switch is set to offloads mode. Currently, in mlx5 the e-switch management is done 
through the PF vport (0) and hence the VF representors along with the existing PF 
netdev which represents the uplink share the PCI PF device instance.

The series is built from two major components, the first relates to the e-switch 
management and the second to VF representors.

We start with a refactoring that treats the existing SRIOV e-switch code as of operating 
in legacy mode. Next, we add the code for the offloads mode which programs the e-switch
to operate in a way which serves for software based switching:

1. miss rule which matches all packets that do not match any HW other switching rule 
and forwards them to the e-switch management port (0) for further processing.

2. infrastructure for send-to-vport rules which conceptually bypass other "normal" 
steering rules which present at the e-switch datapath. Such rules apply only for packets 
that originate in the e-switch manager vport (0).

Since all the VF reps run over the same e-switch port, we use more logic in the host PCI 
driver to do HW steering of missed packets into the HW queue opened by a the respective VF 
representor. Finally here, we add the devlink APIs to configure the e-switch mode.

The second part from Hadar starts with some refactoring work which allow for multiple 
mlx5e NIC instances to be created over the same PCI function, use common resources
and avoid wrong loopbacks.

Next comes the heart of the change which is a profile definition which allow to practically 
have both "conventional" mlx5e NIC use cases such as native mode (non SRIOV), VF, PF and VF 
representor to share the Ethernet driver code. This is done by a small surgery that ended up 
with few internal callbacks that should be implemented by a profile instance. The profile 
for the conventional NIC is implemented, to preserve the existing functionality.

The last two patches add e-switch registration API for the VF representors and the 
implementation of the VF representors netdevice profile. Being an mlx5e instance, the 
VF representor uses HW send/recv queues, completions queues and such. It currently doesn't 
support NIC offloads but some of them could be added later on. The VF representor has 
switchdev ops, where currently the only supported API is the one to the HW ID,
which is needed to identify multiple representors belonging to the same e-switch.

The architecture + solution (software and firmware) work were done by a team consisting 
of Ilya Lesokhin, Haggai Eran, Rony Efraim, Tal Anker, Natan Oppenheimer, Saeed Mahameed, 
Hadar and Or, thanks you all!

Thanks,
Or & Saeed.

Hadar Hen Zion (6):
  net/mlx5e: Create NIC global resources only once
  net/mlx5e: TIRs management refactoring
  net/mlx5e: Mark enabled RQTs instances explicitly
  net/mlx5e: Add support for multiple profiles
  net/mlx5: Add Representors registration API
  net/mlx5e: Introduce SRIOV VF representors

Or Gerlitz (10):
  net/mlx5: E-Switch, Add operational mode to the SRIOV e-Switch
  net/mlx5: E-Switch, Add support for the sriov offloads mode
  net/mlx5: E-Switch, Add miss rule for offloads mode
  net/mlx5: E-Switch, Add API to create send-to-vport rules
  net/mlx5: Introduce offloads steering namespace
  net/mlx5: E-Switch, Add offloads table
  net/mlx5: E-Switch, Add API to create vport rx rules
  net/devlink: Add E-Switch mode control
  net/mlx5: Add devlink interface
  net/mlx5e: Add devlink based SRIOV mode changes (legacy --> offloads)

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  73 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  14 +-
 .../net/ethernet/mellanox/mlx5/core/en_common.c    | 160 ++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 627 ++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 387 +++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  90 +--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  78 ++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 549 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  11 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  26 +-
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |   5 +-
 include/linux/mlx5/driver.h                        |  13 +
 include/linux/mlx5/fs.h                            |   1 +
 include/net/devlink.h                              |   3 +
 include/uapi/linux/devlink.h                       |   9 +
 net/core/devlink.c                                 |  87 +++
 20 files changed, 1817 insertions(+), 331 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_common.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c

-- 
2.8.0
