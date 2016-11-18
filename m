From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Fri, 18 Nov 2016 14:42:08 -0800
Message-ID: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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
independent component. HFI VNIC Bus module decouples these two
functionalities.

The HW dependent VNIC functionality is part of the HFI1 driver. It
implements the bus operations to do various tasks including HW resource
allocation for VNIC functionality and actual transmission and reception
of encapsulated Ethernet packets over the fabric. It creates a control
device (per HFI) on the HFI VNIC bus for the control plane operations
and VNIC devices for the data plane. Each VNIC device on the HFI VNIC
bus is addressed by the HFI instance, HFI port, and a VNIC port number
on the HFI port.

The HFI VNIC module implements the HW independent VNIC functionality.
It consists of two drivers. The VNIC Ethernet Management Agent (VEMA)
driver binds with the control device on the VNIC bus and interfaces with
the Infiniband MAD stack. It exchanges the management information with
the Ethernet Manager (EM). The VNIC netdev driver binds with the VNIC
devices on the HFI VNIC bus and interfaces with the Linux network stack,
thus providing standard Ethernet network interfaces. The VNIC netdev
driver encapsulates the Ethernet packets with an Omni-Path header before
passing them to the HFI1 driver for transmission. Similarly, it
de-encapsulates the received Omni-Path packets before passing them to the
network stack. For each VNIC interface, the information required for
encapsulation is configured by EM via VEMA MAD interface.


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
        +--------------------------------------------+
        |              HFI VNIC Bus                  |
        +--------------------------------------------+
                             |
                             |
        +--------------------------------------------+
        |                                            |
        |      HFI1 Driver with VNIC support         |
        |                                            |
        +--------------------------------------------+

Vishwanathapura, Niranjana (10):
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) documentation
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) Bus driver
  IB/hfi-vnic: Virtual Network Interface Controller (VNIC) netdev driver
  IB/hfi-vnic: VNIC Ethernet Management (EM) structure definitions
  IB/hfi-vnic: VNIC statistics support
  IB/hfi-vnic: VNIC MAC table support
  IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) interface
  IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) driver
  IB/hfi1: Virtual Network Interface Controller (VNIC) support
  IB/hfi1: VNIC SDMA support

 Documentation/infiniband/hfi_vnic.txt              |   97 ++
 MAINTAINERS                                        |    7 +
 drivers/infiniband/Kconfig                         |    2 +
 drivers/infiniband/hw/hfi1/Kconfig                 |    2 +-
 drivers/infiniband/hw/hfi1/Makefile                |    3 +-
 drivers/infiniband/hw/hfi1/aspm.h                  |   13 +-
 drivers/infiniband/hw/hfi1/chip.c                  |  270 +++++-
 drivers/infiniband/hw/hfi1/chip.h                  |    2 +
 drivers/infiniband/hw/hfi1/debugfs.c               |    6 +-
 drivers/infiniband/hw/hfi1/driver.c                |   78 +-
 drivers/infiniband/hw/hfi1/file_ops.c              |   25 +-
 drivers/infiniband/hw/hfi1/hfi.h                   |   51 +-
 drivers/infiniband/hw/hfi1/init.c                  |   44 +-
 drivers/infiniband/hw/hfi1/mad.c                   |    8 +-
 drivers/infiniband/hw/hfi1/pio.c                   |   17 +
 drivers/infiniband/hw/hfi1/pio.h                   |    6 +
 drivers/infiniband/hw/hfi1/sysfs.c                 |    2 +-
 drivers/infiniband/hw/hfi1/user_exp_rcv.c          |    6 +-
 drivers/infiniband/hw/hfi1/user_pages.c            |    3 +-
 drivers/infiniband/hw/hfi1/vnic.h                  |  183 ++++
 drivers/infiniband/hw/hfi1/vnic_device.c           |  168 ++++
 drivers/infiniband/hw/hfi1/vnic_main.c             |  573 +++++++++++
 drivers/infiniband/hw/hfi1/vnic_sdma.c             |  320 ++++++
 drivers/infiniband/sw/Makefile                     |    1 +
 drivers/infiniband/sw/intel/vnic/Makefile          |    2 +
 drivers/infiniband/sw/intel/vnic/hfi_vnic/Kconfig  |    8 +
 drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile |    8 +
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_encap.c        |  490 ++++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h        |  510 ++++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_ethtool.c      |  212 ++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h     |  422 ++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c       |  883 +++++++++++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_vema.c         | 1024 ++++++++++++++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c   |  385 ++++++++
 .../infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig  |    8 +
 .../infiniband/sw/intel/vnic/hfi_vnic_bus/Makefile |    5 +
 .../sw/intel/vnic/hfi_vnic_bus/hfi_vnic_bus.c      |  366 +++++++
 .../infiniband/sw/intel/vnic/include/hfi_vnic.h    |  282 ++++++
 include/rdma/opa_port_info.h                       |    2 +-
 39 files changed, 6395 insertions(+), 99 deletions(-)
 create mode 100644 Documentation/infiniband/hfi_vnic.txt
 create mode 100644 drivers/infiniband/hw/hfi1/vnic.h
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_device.c
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_main.c
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_sdma.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/Makefile
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/Kconfig
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_ethtool.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Makefile
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/hfi_vnic_bus.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/include/hfi_vnic.h

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
