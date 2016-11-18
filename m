From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC 01/10] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) documentation
Date: Fri, 18 Nov 2016 14:42:09 -0800
Message-ID: <1479508938-63799-2-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add HFI VNIC design document explaining the VNIC architecture and the
driver design.

Change-Id: I7baa39444579dc582fe1e49b86e9cfc71f0a41a4
Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 Documentation/infiniband/hfi_vnic.txt | 97 +++++++++++++++++++++++++++++++++++
 1 file changed, 97 insertions(+)
 create mode 100644 Documentation/infiniband/hfi_vnic.txt

diff --git a/Documentation/infiniband/hfi_vnic.txt b/Documentation/infiniband/hfi_vnic.txt
new file mode 100644
index 0000000..3501288
--- /dev/null
+++ b/Documentation/infiniband/hfi_vnic.txt
@@ -0,0 +1,97 @@
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
+independent component. HFI VNIC Bus module decouples these two
+functionalities.
+
+The HW dependent VNIC functionality is part of the HFI1 driver. It
+implements the bus operations to do various tasks including HW resource
+allocation for VNIC functionality and actual transmission and reception
+of encapsulated Ethernet packets over the fabric. It creates a control
+device (per HFI) on the HFI VNIC bus for the control plane operations
+and VNIC devices for the data plane. Each VNIC device on the HFI VNIC
+bus is addressed by the HFI instance, HFI port, and a VNIC port number
+on the HFI port.
+
+The HFI VNIC module implements the HW independent VNIC functionality.
+It consists of two drivers. The VNIC Ethernet Management Agent (VEMA)
+driver binds with the control device on the VNIC bus and interfaces with
+the Infiniband MAD stack. It exchanges the management information with
+the Ethernet Manager (EM). The VNIC netdev driver binds with the VNIC
+devices on the HFI VNIC bus and interfaces with the Linux network stack,
+thus providing standard Ethernet network interfaces. The VNIC netdev
+driver encapsulates the Ethernet packets with an Omni-Path header before
+passing them to the HFI1 driver for transmission. Similarly, it
+de-encapsulates the received Omni-Path packets before passing them to the
+network stack. For each VNIC interface, the information required for
+encapsulation is configured by EM via VEMA MAD interface.
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
+        +--------------------------------------------+
+        |              HFI VNIC Bus                  |
+        +--------------------------------------------+
+                             |
+                             |
+        +--------------------------------------------+
+        |                                            |
+        |      HFI1 Driver with VNIC support         |
+        |                                            |
+        +--------------------------------------------+
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
