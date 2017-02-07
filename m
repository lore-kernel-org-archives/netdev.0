From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Tue,  7 Feb 2017 12:22:59 -0800
Message-ID: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ChangeLog:
=========
v2 => v3:
a) Introduce and adopt generic RDMA netdev interface including,
     - having bottom hfi1 driver directly interfacing with netstack.
     - optimizing interface between hfi_vnic and hfi1 driver.
b) Remove bitfield usage.
c) Move hfi_vnic driver to drivers/infiniband/ulp folder.
d) Minor fixes

v2: Initial post @ https://www.spinics.net/lists/linux-rdma/msg44110.html

Description:
============
Intel Omni-Path Host Fabric Interface (HFI) Virtual Network Interface
Controller (VNIC) feature supports Ethernet functionality over Omni-Path
fabric by encapsulating the Ethernet packets between HFI nodes.

The patterns of exchanges of Omni-Path encapsulated Ethernet packets
involves one or more virtual Ethernet switches overlaid on the Omni-Path
fabric topology. A subset of HFI nodes on the Omni-Path fabric are
permitted to exchange encapsulated Ethernet packets across a particular
virtual Ethernet switch. The virtual Ethernet switches are logical
abstractions achieved by configuring the HFI nodes on the fabric for
header generation and processing. In the simplest configuration all HFI
nodes across the fabric exchange encapsulated Ethernet packets over a
single virtual Ethernet switch. A virtual Ethernet switch, is effectively
an independent Ethernet network. The configuration is performed by an
Ethernet Manager (EM) which is part of the trusted Fabric Manager (FM)
application. HFI nodes can have multiple VNICs each connected to a
different virtual Ethernet switch. The below diagram presents a case
of two virtual Ethernet switches with two HFI nodes.

                             +-------------------+
                             |      Subnet/      |
                             |     Ethernet      |
                             |      Manager      |
                             +-------------------+
                                /          /
                              /           /
                            /            /
                          /             /
+-----------------------------+  +------------------------------+
|  Virtual Ethernet Switch    |  |  Virtual Ethernet Switch     |
|  +---------+    +---------+ |  | +---------+    +---------+   |
|  | VPORT   |    |  VPORT  | |  | |  VPORT  |    |  VPORT  |   |
+--+---------+----+---------+-+  +-+---------+----+---------+---+
         |                 \        /                 |
         |                   \    /                   |
         |                     \/                     |
         |                    /  \                    |
         |                  /      \                  |
     +-----------+------------+  +-----------+------------+
     |   VNIC    |    VNIC    |  |    VNIC   |    VNIC    |
     +-----------+------------+  +-----------+------------+
     |          HFI           |  |          HFI           |
     +------------------------+  +------------------------+


Intel HFI VNIC software design is presented in the below diagram.
HFI VNIC functionality has a HW dependent component and a HW
independent component.

The support has been added for IB device to allocate and free the RDMA
netdev devices. The RDMA netdev supports interfacing with the network
stack thus creating standard network interfaces. HFI_VNIC is an RDMA
netdev device type.

The HW dependent VNIC functionality is part of the HFI1 driver. It
implements the verbs to allocate and free the HFI_VNIC RDMA netdev.
It involves HW resource allocation/management for VNIC functionality.
It interfaces with the network stack and implements the required
net_device_ops functions. It expects Omni-Path encapsulated Ethernet
packets in the transmit path and provides HW access to them. It strips
the Omni-Path header from the received packets before passing them up
the network stack. It also implements the RDMA netdev control operations.

The HFI VNIC module implements the HW independent VNIC functionality.
It consists of two parts. The VNIC Ethernet Management Agent (VEMA)
registers itself with IB core as an IB client and interfaces with the
IB MAD stack. It exchanges the management information with the Ethernet
Manager (EM) and the VNIC netdev. The VNIC netdev part allocates and frees
the HFI_VNIC RDMA netdev devices. It overrides the net_device_ops functions
set by HW dependent VNIC driver where required to accommodate any control
operation. It also handles the encapsulation of Ethernet packets with an
Omni-Path header in the transmit path. For each VNIC interface, the
information required for encapsulation is configured by the EM via VEMA MAD
interface. It also passes any control information to the HW dependent driver
by invoking the RDMA netdev control operations.

        +-------------------+ +----------------------+
        |                   | |       Linux          |
        |     IB MAD        | |      Network         |
        |                   | |       Stack          |
        +-------------------+ +----------------------+
                 |               |          |
                 |               |          |
        +----------------------------+      |
        |                            |      |
        |      HFI VNIC Module       |      |
        |  (HFI VNIC RDMA Netdev     |      |
        |     & EMA functions)       |      |
        |                            |      |
        +----------------------------+      |
                    |                       |
                    |                       |
           +------------------+             |
           |     IB core      |             |
           +------------------+             |
                    |                       |
                    |                       |
        +--------------------------------------------+
        |                                            |
        |      HFI1 Driver with VNIC support         |
        |                                            |
        +--------------------------------------------+

Vishwanathapura, Niranjana (11):
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) documentation
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) interface
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) netdev
  IB/hfi-vnic: VNIC Ethernet Management (EM) structure definitions
  IB/hfi-vnic: VNIC statistics support
  IB/hfi-vnic: VNIC MAC table support
  IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) interface
  IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) function
  IB/hfi1: HFI_VNIC RDMA netdev support
  IB/hfi1: Virtual Network Interface Controller (VNIC) HW support
  IB/hfi1: VNIC SDMA support

 Documentation/infiniband/hfi_vnic.txt              |  102 ++
 MAINTAINERS                                        |    7 +
 drivers/infiniband/Kconfig                         |    1 +
 drivers/infiniband/hw/hfi1/Makefile                |    2 +-
 drivers/infiniband/hw/hfi1/aspm.h                  |   15 +-
 drivers/infiniband/hw/hfi1/chip.c                  |  293 +++++-
 drivers/infiniband/hw/hfi1/chip.h                  |    4 +-
 drivers/infiniband/hw/hfi1/debugfs.c               |    8 +-
 drivers/infiniband/hw/hfi1/driver.c                |   77 +-
 drivers/infiniband/hw/hfi1/file_ops.c              |   27 +-
 drivers/infiniband/hw/hfi1/hfi.h                   |   57 +-
 drivers/infiniband/hw/hfi1/init.c                  |   39 +-
 drivers/infiniband/hw/hfi1/mad.c                   |   10 +-
 drivers/infiniband/hw/hfi1/pio.c                   |   19 +-
 drivers/infiniband/hw/hfi1/pio.h                   |    8 +-
 drivers/infiniband/hw/hfi1/sysfs.c                 |    4 +-
 drivers/infiniband/hw/hfi1/user_exp_rcv.c          |    8 +-
 drivers/infiniband/hw/hfi1/user_pages.c            |    5 +-
 drivers/infiniband/hw/hfi1/verbs.c                 |    8 +-
 drivers/infiniband/hw/hfi1/vnic.h                  |  184 ++++
 drivers/infiniband/hw/hfi1/vnic_main.c             |  909 +++++++++++++++++
 drivers/infiniband/hw/hfi1/vnic_sdma.c             |  323 ++++++
 drivers/infiniband/ulp/Makefile                    |    1 +
 drivers/infiniband/ulp/hfi_vnic/Kconfig            |    8 +
 drivers/infiniband/ulp/hfi_vnic/Makefile           |    7 +
 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_encap.c   |  475 +++++++++
 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_encap.h   |  485 +++++++++
 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_ethtool.c |  205 ++++
 .../infiniband/ulp/hfi_vnic/hfi_vnic_internal.h    |  329 ++++++
 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_netdev.c  |  388 +++++++
 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_vema.c    | 1071 ++++++++++++++++++++
 .../infiniband/ulp/hfi_vnic/hfi_vnic_vema_iface.c  |  390 +++++++
 include/rdma/ib_verbs.h                            |   27 +
 include/rdma/opa_hfi.h                             |  147 +++
 include/rdma/opa_port_info.h                       |    4 +-
 35 files changed, 5533 insertions(+), 114 deletions(-)
 create mode 100644 Documentation/infiniband/hfi_vnic.txt
 create mode 100644 drivers/infiniband/hw/hfi1/vnic.h
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_main.c
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_sdma.c
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/Kconfig
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/Makefile
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_encap.c
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_encap.h
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_ethtool.c
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_internal.h
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_netdev.c
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_vema.c
 create mode 100644 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_vema_iface.c
 create mode 100644 include/rdma/opa_hfi.h

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
