From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 14 Dec 2016 23:59:32 -0800
Message-ID: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks Jason for the valuable feedback.
Here is the revised HFI VNIC patch series.

ChangeLog:
=========
v1 => v2:
a) Removed hfi_vnic bus, instead make hfi_vnic driver an 'ib client',
   as per feedback from Jason Gunthorpe.
b) Interface changes, data structure changes and variable name changes
   associated with (a).
c) Add hfi_ibdev abstraction to provide VNIC control operations to
   hfi_vnic client.
d) Minor fixes
e) Moved hfi_vnic driver from .../sw/intel/vnic/hfi_vnic to
   .../sw/intel/hfi_vnic.

v1: Initial post @ https://www.spinics.net/lists/linux-rdma/msg43158.html

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

The HW dependent VNIC functionality is part of the HFI1 driver. It
implements the callback functions to do various tasks which includes
adding and removing of VNIC ports, HW resource allocation for VNIC
functionality and actual transmission and reception of encapsulated
Ethernet packets over the fabric. Each VNIC port is addressed by the
HFI port number, and the VNIC port number on that HFI port.

The HFI VNIC module implements the HW independent VNIC functionality.
It consists of two parts. The VNIC Ethernet Management Agent (VEMA)
registers itself with IB core as an IB client and interfaces with the
IB MAD stack. It exchanges the management information with the Ethernet
Manager (EM) and the VNIC netdev. The VNIC netdev part interfaces with
the Linux network stack, thus providing standard Ethernet network
interfaces. It invokes HFI device's VNIC callback functions for HW access.
The VNIC netdev encapsulates the Ethernet packets with an Omni-Path
header before passing them to the HFI1 driver for transmission.
Similarly, it de-encapsulates the received Omni-Path packets before
passing them to the network stack. For each VNIC interface, the
information required for encapsulation is configured by EM via VEMA MAD
interface.


        +-------------------+ +----------------------+
        |                   | |       Linux          |
        |     IB MAD        | |      Network         |
        |                   | |       Stack          |
        +-------------------+ +----------------------+
                 |                       |
                 |                       |
        +--------------------------------------------+
        |                                            |
        |             HFI VNIC Module                |
        |    (HFI VNIC Netdev and EMA drivers)       |
        |                                            |
        +--------------------------------------------+
                             |
                             |
                    +------------------+
                    |      IB core     |
                    +------------------+
                             |
                             |
        +--------------------------------------------+
        |                                            |
        |      HFI1 Driver with VNIC support         |
        |                                            |
        +--------------------------------------------+

Vishwanathapura, Niranjana (10):
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) documentation
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) interface
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) netdev
  IB/hfi-vnic: VNIC Ethernet Management (EM) structure definitions
  IB/hfi-vnic: VNIC statistics support
  IB/hfi-vnic: VNIC MAC table support
  IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) interface
  IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) function
  IB/hfi1: Virtual Network Interface Controller (VNIC) support
  IB/hfi1: VNIC SDMA support

 Documentation/infiniband/hfi_vnic.txt              |   95 ++
 MAINTAINERS                                        |    7 +
 drivers/infiniband/Kconfig                         |    1 +
 drivers/infiniband/hw/hfi1/Makefile                |    2 +-
 drivers/infiniband/hw/hfi1/aspm.h                  |   13 +-
 drivers/infiniband/hw/hfi1/chip.c                  |  272 +++++-
 drivers/infiniband/hw/hfi1/chip.h                  |    2 +
 drivers/infiniband/hw/hfi1/debugfs.c               |    6 +-
 drivers/infiniband/hw/hfi1/driver.c                |   84 +-
 drivers/infiniband/hw/hfi1/file_ops.c              |   25 +-
 drivers/infiniband/hw/hfi1/hfi.h                   |   52 +-
 drivers/infiniband/hw/hfi1/init.c                  |   41 +-
 drivers/infiniband/hw/hfi1/intr.c                  |    2 +-
 drivers/infiniband/hw/hfi1/mad.c                   |   10 +-
 drivers/infiniband/hw/hfi1/pio.c                   |   17 +
 drivers/infiniband/hw/hfi1/pio.h                   |    6 +
 drivers/infiniband/hw/hfi1/qp.c                    |   24 +-
 drivers/infiniband/hw/hfi1/ruc.c                   |    2 +-
 drivers/infiniband/hw/hfi1/sysfs.c                 |   24 +-
 drivers/infiniband/hw/hfi1/user_exp_rcv.c          |    6 +-
 drivers/infiniband/hw/hfi1/user_pages.c            |    3 +-
 drivers/infiniband/hw/hfi1/verbs.c                 |  120 +--
 drivers/infiniband/hw/hfi1/verbs.h                 |    9 +-
 drivers/infiniband/hw/hfi1/vnic.h                  |  173 ++++
 drivers/infiniband/hw/hfi1/vnic_main.c             |  631 ++++++++++++
 drivers/infiniband/hw/hfi1/vnic_sdma.c             |  320 ++++++
 drivers/infiniband/sw/Makefile                     |    1 +
 drivers/infiniband/sw/intel/hfi_vnic/Kconfig       |    8 +
 drivers/infiniband/sw/intel/hfi_vnic/Makefile      |    7 +
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c  |  489 ++++++++++
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.h  |  510 ++++++++++
 .../sw/intel/hfi_vnic/hfi_vnic_ethtool.c           |  208 ++++
 .../sw/intel/hfi_vnic/hfi_vnic_internal.h          |  443 +++++++++
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c |  810 ++++++++++++++++
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_vema.c   | 1024 ++++++++++++++++++++
 .../sw/intel/hfi_vnic/hfi_vnic_vema_iface.c        |  432 +++++++++
 include/rdma/opa_hfi.h                             |  199 ++++
 include/rdma/opa_port_info.h                       |    2 +-
 38 files changed, 5891 insertions(+), 189 deletions(-)
 create mode 100644 Documentation/infiniband/hfi_vnic.txt
 create mode 100644 drivers/infiniband/hw/hfi1/vnic.h
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_main.c
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_sdma.c
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/Kconfig
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/Makefile
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.h
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_vema.c
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_vema_iface.c
 create mode 100644 include/rdma/opa_hfi.h

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
