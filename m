From: Casey Leedom <leedom@chelsio.com>
Subject: Request for advice on where to put Root Complex "fix up" code for
 downstream device
Date: Thu, 7 May 2015 00:34:51 +0000
Message-ID: <4985EFDD773FCB459EF7915D2A3621ADBC7408@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25304 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbbEGAey convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 20:34:54 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

  I've included both the Network and PCI Development mailing lists because this crosses both domains.  If this violates protocols, I apologise in advance.  I believe that this ~probably~ will be a "PCI Development" issue but since it affects a Network Device, I figured input from that quarter should be solicited as well.

  We have a Network Device, T5, which unfortunately has a PCI Compliance bug in it[1].  Doubly unfortunately, the PCI SIG 3.0 Compliance Tests which we dutifully ranb before releasing the silicon two years ago didn't include a vector for this, so it wasn't discovered till very recently.  In order to solve this bug, we need to modify the Root Complex's PCI Express Capability Device Control register in order to turn off the Enable No Snoop and Enable Relaxed Ordering features.

  I've cons'ed up demonstration code within the Device Driver for T5, cxgb4, to traverse the PCI graph to the Root Complex for the T5 Device and perform this modification[2].  This demonstrates the "workability" of doing the operation, but I'm betting that this is _not_ where either the Network or PCI Development teams would like such code to go.  My expectation is that this code needs to go into drivers/pci/quirks.c.

  So, this mail is a request for advice on how the Network and PCI Development teams would like this handled.  Once I receive this input, I will submit a patch to the correct team for inclusion in the kernel.  Thank you for your time and attention.

Casey

[1] Chelsio T5 PCI-E Compliance Bug:

    The bug is that when the Root Complex send a Transaction Layer Packet (TLP)
    Request downstream to a Device,the TLP may contain Attributes.  The PCI
    Specification states that two of these Attributes, No Snoop and Relaxed
    Ordering, must be included in the Device's TLP Response.  Further, the PCI
    Specification "encourages" Root Complexes to drop TLP Responses which
    are out of compliance with this rule.

[2] Demonstration Code for clearing Root Complex No Snoop and Relaxed Ordering:

--- a/drivers/net/ethernet/chelsio/cxgb4_main.c	Mon Apr 06 09:27:21 2015 -0700
+++ b/drivers/net/ethernet/chelsio/cxgb4_main.c	Tue Apr 07 13:39:05 2015 -0700
@@ -9956,6 +9956,36 @@ static void enable_pcie_relaxed_ordering
 	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
 }
 
+/*
+ * Find the highest PCI-Express bridge above a PCI Device.  If found, that's
+ * the Root Complex PCI-PCI Bridge for the PCI Device.  If we find the Root
+ * Comples, clear the Enable Relaxed Ordering and Enable No Snoop bits in that
+ * bridge's PCI-E Capability Device Control register.  This will prevent the
+ * Root Complex from setting those attributes in the Transaction Layer Packets
+ * of the Requests which it sends down stream to the PCI Device.
+ */
+static void clear_root_complex_tlp_attributes(struct pci_dev *pdev)
+{
+	struct pci_bus *bus = pdev->bus;
+	struct pci_dev *highest_pcie_bridge = NULL;
+
+	while (bus) {
+		struct pci_dev *bridge = bus->self;
+
+		if (!bridge || !bridge->pcie_cap)
+			break;
+		highest_pcie_bridge = bridge;
+		bus = bus->parent;
+	}
+
+	if (highest_pcie_bridge)
+		pcie_capability_clear_and_set_word(highest_pcie_bridge,
+						   PCI_EXP_DEVCTL,
+						   PCI_EXP_DEVCTL_RELAX_EN |
+						   PCI_EXP_DEVCTL_NOSNOOP_EN,
+						   0);
+}
+
 static int init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
@@ -9973,6 +10003,19 @@ static int init_one(struct pci_dev *pdev
 		++version_printed;
 	}
 
+	/*
+	 * T5 has a PCI-E Compliance bug in it where it doesn't copy the
+	 * Transaction Layer Packet Attributes from downstream Requests into
+	 * it's upstream Responses.  Most Root Complexes are fine with this
+	 * but a few get prissy and drop the non-compliant T5 Responses
+	 * leading to endless Device Timeouts when TLP Attributes are set.  So
+	 * if we're a T5, attempt to clear our Root Complex's enable bits for
+	 * TLP Attributes ...
+	 */
+	if (CHELSIO_PCI_ID_VER(pdev->device) == CHELSIO_T5 ||
+	    CHELSIO_PCI_ID_VER(pdev->device) == CHELSIO_T5_FPGA)
+		clear_root_complex_tlp_attributes(pdev);
+
 	err = pci_request_regions(pdev, KBUILD_MODNAME);
 	if (err) {
 		/* Just info, some other driver may have claimed the device. */