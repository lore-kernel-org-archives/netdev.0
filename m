From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v3 01/11] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) documentation
Date: Tue,  7 Feb 2017 12:23:00 -0800
Message-ID: <1486498990-76562-2-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add HFI VNIC design document explaining the VNIC architecture and the
driver design.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 Documentation/infiniband/hfi_vnic.txt | 102 ++++++++++++++++++++++++++++++++++
 1 file changed, 102 insertions(+)
 create mode 100644 Documentation/infiniband/hfi_vnic.txt

diff --git a/Documentation/infiniband/hfi_vnic.txt b/Documentation/infiniband/hfi_vnic.txt
new file mode 100644
index 0000000..c6c801e
--- /dev/null
+++ b/Documentation/infiniband/hfi_vnic.txt
@@ -0,0 +1,102 @@
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
+
+Intel HFI VNIC software design is presented in the below diagram.
+HFI VNIC functionality has a HW dependent component and a HW
+independent component.
+
+The support has been added for IB device to allocate and free the RDMA
+netdev devices. The RDMA netdev supports interfacing with the network
+stack thus creating standard network interfaces. HFI_VNIC is an RDMA
+netdev device type.
+
+The HW dependent VNIC functionality is part of the HFI1 driver. It
+implements the verbs to allocate and free the HFI_VNIC RDMA netdev.
+It involves HW resource allocation/management for VNIC functionality.
+It interfaces with the network stack and implements the required
+net_device_ops functions. It expects Omni-Path encapsulated Ethernet
+packets in the transmit path and provides HW access to them. It strips
+the Omni-Path header from the received packets before passing them up
+the network stack. It also implements the RDMA netdev control operations.
+
+The HFI VNIC module implements the HW independent VNIC functionality.
+It consists of two parts. The VNIC Ethernet Management Agent (VEMA)
+registers itself with IB core as an IB client and interfaces with the
+IB MAD stack. It exchanges the management information with the Ethernet
+Manager (EM) and the VNIC netdev. The VNIC netdev part allocates and frees
+the HFI_VNIC RDMA netdev devices. It overrides the net_device_ops functions
+set by HW dependent VNIC driver where required to accommodate any control
+operation. It also handles the encapsulation of Ethernet packets with an
+Omni-Path header in the transmit path. For each VNIC interface, the
+information required for encapsulation is configured by the EM via VEMA MAD
+interface. It also passes any control information to the HW dependent driver
+by invoking the RDMA netdev control operations.
+
+        +-------------------+ +----------------------+
+        |                   | |       Linux          |
+        |     IB MAD        | |      Network         |
+        |                   | |       Stack          |
+        +-------------------+ +----------------------+
+                 |               |          |
+                 |               |          |
+        +----------------------------+      |
+        |                            |      |
+        |      HFI VNIC Module       |      |
+        |  (HFI VNIC RDMA Netdev     |      |
+        |     & EMA functions)       |      |
+        |                            |      |
+        +----------------------------+      |
+                    |                       |
+                    |                       |
+           +------------------+             |
+           |     IB core      |             |
+           +------------------+             |
+                    |                       |
+                    |                       |
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
