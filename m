From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [RFC v2 01/10] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) documentation
Date: Wed, 14 Dec 2016 23:59:33 -0800
Message-ID: <1481788782-89964-2-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:35381 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754934AbcLOIAE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 03:00:04 -0500
In-Reply-To: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add HFI VNIC design document explaining the VNIC architecture and the
driver design.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
---
 Documentation/infiniband/hfi_vnic.txt | 95 +++++++++++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)
 create mode 100644 Documentation/infiniband/hfi_vnic.txt

diff --git a/Documentation/infiniband/hfi_vnic.txt b/Documentation/infiniband/hfi_vnic.txt
new file mode 100644
index 0000000..1f39d8b
--- /dev/null
+++ b/Documentation/infiniband/hfi_vnic.txt
@@ -0,0 +1,95 @@
+Intel Omni-Path Host Fabric Interface (HFI) Virtual Network Interface
+Controller (VNIC) feature supports Ethernet functionality over Omni-Path
+fabric by encapsulating the Ethernet packets between HFI nodes.
+
+The patterns of exchanges of Omni-Path encapsulated Ethernet packets
+involves one or more virtual Ethernet switches overlaid on the Omni-Path
+fabric topology. A subset of HFI nodes on the Omni-Path fabric are
+permitted to exchange encapsulated Ethernet packets across a particular
+virtual Ethernet switch. The virtual Ethernet switches are logical
+abstractions achieved by configuring the HFI nodes on the fabric for
+header generation and processing. In the simplest configuration all HFI
+nodes across the fabric exchange encapsulated Ethernet packets over a
+single virtual Ethernet switch. A virtual Ethernet switch, is effectively
+an independent Ethernet network. The configuration is performed by an
+Ethernet Manager (EM) which is part of the trusted Fabric Manager (FM)
+application. HFI nodes can have multiple VNICs each connected to a
+different virtual Ethernet switch. The below diagram presents a case
+of two virtual Ethernet switches with two HFI nodes.
+
+                             +-------------------+
+                             |      Subnet/      |
+                             |     Ethernet      |
+                             |      Manager      |
+                             +-------------------+
+                                /          /
+                              /           /
+                            /            /
+                          /             /
++-----------------------------+  +------------------------------+
+|  Virtual Ethernet Switch    |  |  Virtual Ethernet Switch     |
+|  +---------+    +---------+ |  | +---------+    +---------+   |
+|  | VPORT   |    |  VPORT  | |  | |  VPORT  |    |  VPORT  |   |
++--+---------+----+---------+-+  +-+---------+----+---------+---+
+         |                 \        /                 |
+         |                   \    /                   |
+         |                     \/                     |
+         |                    /  \                    |
+         |                  /      \                  |
+     +-----------+------------+  +-----------+------------+
+     |   VNIC    |    VNIC    |  |    VNIC   |    VNIC    |
+     +-----------+------------+  +-----------+------------+
+     |          HFI           |  |          HFI           |
+     +------------------------+  +------------------------+
+
+Intel HFI VNIC software design is presented in the below diagram.
+HFI VNIC functionality has a HW dependent component and a HW
+independent component.
+
+The HW dependent VNIC functionality is part of the HFI1 driver. It
+implements the callback functions to do various tasks which includes
+adding and removing of VNIC ports, HW resource allocation for VNIC
+functionality and actual transmission and reception of encapsulated
+Ethernet packets over the fabric. Each VNIC port is addressed by the
+HFI port number, and the VNIC port number on that HFI port.
+
+The HFI VNIC module implements the HW independent VNIC functionality.
+It consists of two parts. The VNIC Ethernet Management Agent (VEMA)
+registers itself with IB core as an IB client and interfaces with the
+IB MAD stack. It exchanges the management information with the Ethernet
+Manager (EM) and the VNIC netdev. The VNIC netdev part interfaces with
+the Linux network stack, thus providing standard Ethernet network
+interfaces. It invokes HFI device's VNIC callback functions for HW access.
+The VNIC netdev encapsulates the Ethernet packets with an Omni-Path
+header before passing them to the HFI1 driver for transmission.
+Similarly, it de-encapsulates the received Omni-Path packets before
+passing them to the network stack. For each VNIC interface, the
+information required for encapsulation is configured by EM via VEMA MAD
+interface.
+
+
+        +-------------------+ +----------------------+
+        |                   | |       Linux          |
+        |     IB MAD        | |      Network         |
+        |                   | |       Stack          |
+        +-------------------+ +----------------------+
+                 |                       |
+                 |                       |
+        +--------------------------------------------+
+        |                                            |
+        |             HFI VNIC Module                |
+        |    (HFI VNIC Netdev and EMA drivers)       |
+        |                                            |
+        +--------------------------------------------+
+                             |
+                             |
+                    +------------------+
+                    |      IB core     |
+                    +------------------+
+                             |
+                             |
+        +--------------------------------------------+
+        |                                            |
+        |      HFI1 Driver with VNIC support         |
+        |                                            |
+        +--------------------------------------------+
-- 
1.8.3.1
