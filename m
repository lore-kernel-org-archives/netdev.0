From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 00/18] Introducing ConnectX-4 Ethernet SRIOV
Date: Mon, 23 Nov 2015 13:11:33 +0200
Message-ID: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37111 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750941AbbKWLMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 06:12:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset introduces the support of Ethernet SRIOV in ConnectX-4 
family of 100G Ethernet NICs.

Some features are still missing, but all the basic SRIOV functionalities
are there already.

Basic Introduction:
ConnectX-4 HW architecture provides two kinds of underlying HW switches.

MPFS (Multi Physical Function Switch) or L2 Table in Software terms:

The HCA has one MPFS switch per physical port, this switch is responsible
of forwarding Unicast traffic to the various overlying Physical Functions (PFs). 
Multicast traffic is flooded amongst all the PFs, Each PF can request to
forward a unicast MAC to its E-Switch Uplink vport (which we will cover later) 
through SET_L2_TABLE_ENTRY HW command.

MPFS has five ports, four are connected to PFs (one for each) and one is connected 
directly to the Physical Port (Physical Link).

E-Switch (Ethernet Switch): 

The HCA has one per physical function. The main responsibility of this component is 
to forward Unicast/Multicast and vlan tagged/untagged traffic to the various 
Virtual Functions (VFs) allocated by the PF. Unlike MPFS, the PF needs to explicitly 
create the E-Switch FDB table, Which is a HW flow table managed by the PF driver 
whenever vport_group_manager capability bit is set for this PF.

E-Switch has Virtual Ports (vports) entities as its ports, vport0 and uplink vport
are special kind of vports that represents PF vport (vport0) and uplink vport which
is connected to the MPFS switch (if exists) as the PF external link.
vport1..vportN represent VF0..VF(N-1) egress/ingress ports.

E-Switch FDB contains forwarding rules such as:
        UC MAC0 -> vport0(PF).
        UC MAC1 -> vport1.
        UC MAC2 -> vport2.
        MC MACX -> vport0, vport2, Uplink.
        MC MACY -> vport1, Uplink.
    
    For unmatched traffic FDB has the following default rules:
        Unmatched Traffic (src vport != Uplink) -> Uplink.
        Unmatched Traffic (src vport == Uplink) -> vport0(PF).

NIC VPort context: 
Each NIC (VF/PF) has its own vport context which will be used to store the current
NIC vport context (UC/MC and vlan lists) and other NIC properties such as MTU, promisc 
mode, etc.. NIC (VF/PF) driver is responsible of constantly updating this context.

FDB rules population:
Each NIC vport (VF/PF) will notify E-Switch manager of its UC/MC vport
context changes via modify vport context command, which will be
translated to an event that will be handled by E-Switch manager (PF)
which will update FDB table accordingly.

Both PF and VF use the same driver and submit commands directly to the firmware.
The PF sees the vport_group_manager capability bit and as such runs the code
to populate the embedded switches as explained above.

The patch goes as follows:

Patches 1-2 introduces the basic PCI SRIOV functionalities and the support of
Connectx4 to enable specific VFs via enable/disable HCA commands. These two
patches will be also in use later for the IB SRIOV flow.

Patches 3-8 Introduces the basic E-Switch capabilities and commands to be used later by
VF to modify and update its NIC vport context, and by PF (E-Switch Manager) driver to
Query the VF NIC context and acts accordingly.

Patches 9-10 Provide the needed functionality of a NIC driver VF/PF to support SRIOV,
mainly vport context update support.

Patch 11 ("net/mlx5: Introducing E-Switch and l2 table"), Introduces the basic
E-Switch support and infrastructure to read vport context events and to update
MPFS L2 Table of the UC mac addresses request by the PF.

Patches 12-18 Introduces SRIOV enablemenet and E-Switch FDB table management
It adds the Basic E-Swtich public API to set and get sriov properties to be used
in PF netdev sriov ndos.

Patchset was applied ontop of commit 3f8c0f7 "gianfar: use of_property_read_bool()"

Saeed, Eli and Or.

Eli Cohen (2):
  net/mlx5_core: Modify enable/disable hca functions
  net/mlx5_core: Add base sriov support

Saeed Mahameed (16):
  net/mlx5: Add HW capabilities and structs for SR-IOV E-Switch.
  net/mlx5: Update access functions to Query/Modify vport MAC address
  net/mlx5: Introduce access functions to modify/query vport mac lists
  net/mlx5: Introduce access functions to modify/query vport state
  net/mlx5: Introduce access functions to modify/query vport promisc mode
  net/mlx5: Introduce access functions to modify/query vport vlans
  net/mlx5e: Write UC/MC list and promisc mode into vport context
  net/mlx5e: Write vlan list into vport context
  net/mlx5: Introducing E-Switch and l2 table
  net/mlx5: E-Switch, Introduce FDB hardware capabilities
  net/mlx5: E-Switch, Add SR-IOV (FDB) support
  net/mlx5: E-Switch, Introduce Vport administration functions
  net/mlx5: E-Switch, Introduce HCA cap and E-Switch vport context
  net/mlx5: E-Switch, Introduce set vport vlan (VST mode)
  net/mlx5: E-Switch, Introduce get vf statistics
  net/mlx5e: Add support for SR-IOV ndos

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    1 +
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    |  148 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   88 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   13 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 1282 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  161 +++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   24 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   99 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    5 +
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |   38 +
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |  233 ++++
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  435 ++++++-
 include/linux/mlx5/device.h                        |   44 +
 include/linux/mlx5/driver.h                        |   28 +
 include/linux/mlx5/flow_table.h                    |    9 +
 include/linux/mlx5/mlx5_ifc.h                      |  174 ++-
 include/linux/mlx5/vport.h                         |   37 +-
 18 files changed, 2752 insertions(+), 71 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/sriov.c

-- 
2.3.7
