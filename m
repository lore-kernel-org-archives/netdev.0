From: Harold Cook <HCook-wMcxCoczb+1t1OO0OYaSVA@public.gmane.org>
Subject: RE: [PATCH 00/11] Omni-Path Virtual Network Interface Controller
 (VNIC)
Date: Thu, 23 Feb 2017 16:44:22 +0000
Message-ID: <434ed56fc3ce452399f03b8922a9f66e@MBX082-W3-CO-4.EXCH082.SERVERPOD.NET>
References: <1487833606-57917-1-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1487833606-57917-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thank you! I guess we are on the right track...



--- Harold


-----Original Message-----
From: netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Vishwanathapura, Niranjana
Sent: Wednesday, February 22, 2017 11:07 PM
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org; ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH 00/11] Omni-Path Virtual Network Interface Controller (VNIC)

Intel Omni-Path (OPA) Virtual Network Interface Controller (VNIC) feature supports Ethernet functionality over Omni-Path fabric by encapsulating the Ethernet packets between HFI nodes.

Architecture
=============
The patterns of exchanges of Omni-Path encapsulated Ethernet packets involves one or more virtual Ethernet switches overlaid on the Omni-Path fabric topology. A subset of HFI nodes on the Omni-Path fabric are permitted to exchange encapsulated Ethernet packets across a particular virtual Ethernet switch. The virtual Ethernet switches are logical abstractions achieved by configuring the HFI nodes on the fabric for header generation and processing. In the simplest configuration all HFI nodes across the fabric exchange encapsulated Ethernet packets over a single virtual Ethernet switch. A virtual Ethernet switch, is effectively an independent Ethernet network. The configuration is performed by an Ethernet Manager (EM) which is part of the trusted Fabric Manager (FM) application. HFI nodes can
  have multiple VNICs each connected to a different virtual Ethernet switch. The below diagram presents a case of two virtual Ethernet switches with two HFI nodes.

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


The Omni-Path encapsulated Ethernet packet format is as described below.

Bits          Field
------------------------------------
Quad Word 0:
0-19      SLID (lower 20 bits)
20-30     Length (in Quad Words)
31        BECN bit
32-51     DLID (lower 20 bits)
52-56     SC (Service Class)
57-59     RC (Routing Control)
60        FECN bit
61-62     L2 (=10, 16B format)
63        LT (=1, Link Transfer Head Flit)

Quad Word 1:
0-7       L4 type (=0x78 ETHERNET)
8-11      SLID[23:20]
12-15     DLID[23:20]
16-31     PKEY
32-47     Entropy
48-63     Reserved

Quad Word 2:
0-15      Reserved
16-31     L4 header
32-63     Ethernet Packet

Quad Words 3 to N-1:
0-63      Ethernet packet (pad extended)

Quad Word N (last):
0-23      Ethernet packet (pad extended)
24-55     ICRC
56-61     Tail
62-63     LT (=01, Link Transfer Tail Flit)

Ethernet packet is padded on the transmit side to ensure that the VNIC OPA packet is quad word aligned. The 'Tail' field contains the number of bytes padded. On the receive side the 'Tail' field is read and the padding is removed (along with ICRC, Tail and OPA header) before passing packet up the network stack.

The L4 header field contains the virtual Ethernet switch id the VNIC port belongs to. On the receive side, this field is used to de-multiplex the received VNIC packets to different VNIC ports.

Driver Design
==============
Intel OPA VNIC software design is presented in the below diagram.
OPA VNIC functionality has a HW dependent component and a HW independent component.

The support has been added for IB device to allocate and free the RDMA netdev devices. The RDMA netdev supports interfacing with the network stack thus creating standard network interfaces. OPA_VNIC is an RDMA netdev device type.

The HW dependent VNIC functionality is part of the HFI1 driver. It implements the verbs to allocate and free the OPA_VNIC RDMA netdev.
It involves HW resource allocation/management for VNIC functionality.
It interfaces with the network stack and implements the required net_device_ops functions. It expects Omni-Path encapsulated Ethernet packets in the transmit path and provides HW access to them. It strips the Omni-Path header from the received packets before passing them up the network stack. It also implements the RDMA netdev control operations.

The OPA VNIC module implements the HW independent VNIC functionality.
It consists of two parts. The VNIC Ethernet Management Agent (VEMA) registers itself with IB core as an IB client and interfaces with the IB MAD stack. It exchanges the management information with the Ethernet Manager (EM) and the VNIC netdev. The VNIC netdev part allocates and frees the OPA_VNIC RDMA netdev devices. It overrides the net_device_ops functions set by HW dependent VNIC driver where required to accommodate any control operation. It also handles the encapsulation of Ethernet packets with an Omni-Path header in the transmit path. For each VNIC interface, the information required for encapsulation is configured by the EM via VEMA MAD interface. It also passes any control information to the HW dependent driver by invoking the RDMA netdev control operations.

        +-------------------+ +----------------------+
        |                   | |       Linux          |
        |     IB MAD        | |      Network         |
        |                   | |       Stack          |
        +-------------------+ +----------------------+
                 |               |          |
                 |               |          |
        +----------------------------+      |
        |                            |      |
        |      OPA VNIC Module       |      |
        |  (OPA VNIC RDMA Netdev     |      |
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
  IB/opa-vnic: Virtual Network Interface Controller (VNIC) documentation
  IB/opa-vnic: Virtual Network Interface Controller (VNIC) interface
  IB/opa-vnic: Virtual Network Interface Controller (VNIC) netdev
  IB/opa-vnic: VNIC Ethernet Management (EM) structure definitions
  IB/opa-vnic: VNIC statistics support
  IB/opa-vnic: VNIC MAC table support
  IB/opa-vnic: VNIC Ethernet Management Agent (VEMA) interface
  IB/opa-vnic: VNIC Ethernet Management Agent (VEMA) function
  IB/hfi1: OPA_VNIC RDMA netdev support
  IB/hfi1: Virtual Network Interface Controller (VNIC) HW support
  IB/hfi1: VNIC SDMA support

 Documentation/infiniband/opa_vnic.txt              |  153 +++
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
 drivers/infiniband/ulp/opa_vnic/Kconfig            |    8 +
 drivers/infiniband/ulp/opa_vnic/Makefile           |    7 +
 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c   |  475 +++++++++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h   |  489 +++++++++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_ethtool.c |  187 ++++
 .../infiniband/ulp/opa_vnic/opa_vnic_internal.h    |  329 ++++++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c  |  389 +++++++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c    | 1071 ++++++++++++++++++++
 .../infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c  |  390 +++++++
 include/rdma/ib_verbs.h                            |   27 +
 include/rdma/opa_port_info.h                       |    4 +-
 include/rdma/opa_vnic.h                            |  143 +++
 35 files changed, 5567 insertions(+), 114 deletions(-)  create mode 100644 Documentation/infiniband/opa_vnic.txt
 create mode 100644 drivers/infiniband/hw/hfi1/vnic.h  create mode 100644 drivers/infiniband/hw/hfi1/vnic_main.c
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_sdma.c
 create mode 100644 drivers/infiniband/ulp/opa_vnic/Kconfig
 create mode 100644 drivers/infiniband/ulp/opa_vnic/Makefile
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_ethtool.c
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c
 create mode 100644 include/rdma/opa_vnic.h

--
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
