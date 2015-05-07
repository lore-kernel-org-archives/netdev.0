From: Casey Leedom <leedom@chelsio.com>
Subject: RE: Request for advice on where to put Root Complex "fix up" code
 for downstream device
Date: Thu, 7 May 2015 23:31:58 +0000
Message-ID: <4985EFDD773FCB459EF7915D2A3621ADBC80D4@nice.asicdesigners.com>
References: <4985EFDD773FCB459EF7915D2A3621ADBC7408@nice.asicdesigners.com>,<20150507230426.GO24643@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20150507230426.GO24643@google.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Bjorn Helgaas [bhelgaas@google.com]
| Sent: Thursday, May 07, 2015 4:04 PM
| 
| There are a lot of fixups in drivers/pci/quirks.c.  For things that have to
| be worked around either before a driver claims the device or if there is no
| driver at all, the fixup *has* to go in drivers/pci/quirks.c
| 
| But for things like this, where the problem can only occur after a driver
| claims the device, I think it makes more sense to put the fixup in the
| driver itself.  The only wrinkle here is that the fixup has to be done on a
| separate device, not the device claimed by the driver.  But I think it
| probably still makes sense to put this fixup in the driver.

  Okay, the example code that I provided (still quoted below) was indeed
done as a fix within the cxgb4 Network Driver.  I've also worked up a
version as a PCI Quirk but if you and David Miller agree that the fixup
code should go into cxgb4, I'm comfortable with that.  I can also provide
the example PCI Quirk code I worked up if you like.

  One complication to doing this in cxgb4 is that it attaches to Physical
Function 4 of our T5 chip.  Meanwhile, a completely separate storage
driver, csiostor, connections to PF5 and PF6 and there's no
requirement at all that cxgb4 be loaded.  So if we go down the road of
putting the fixup code in the cxgb4 driver, we'll also need to duplicate
that code in the csiostor driver.

| > [1] Chelsio T5 PCI-E Compliance Bug:
| >
| >     The bug is that when the Root Complex send a Transaction Layer Packet (TLP)
| >     Request downstream to a Device,the TLP may contain Attributes.  The PCI
| >     Specification states that two of these Attributes, No Snoop and Relaxed
| >     Ordering, must be included in the Device's TLP Response.  Further, the PCI
| >     Specification "encourages" Root Complexes to drop TLP Responses which
| >     are out of compliance with this rule.
| 
| Can you include a pointer to the relevant part of the spec?

  Sure:

    2.2.9. Completion Rules
    ...
    Completion headers must supply the same values for
    the Attribute as were supplied in the 20 header of
    the corresponding Request, except as explicitly
    allowed when IDO is used (see Section 2.2.6.4).
    ...
    2.3.2. Completion Handling Rules
    ...
    If a received Completion matches the Transaction ID
    of an outstanding Request, but in some other way
    does not match the corresponding Request (e.g., a
    problem with Attributes, Traffic Class, Byte Count,
    Lower Address, etc), it is strongly recommended for
    the Receiver to handle the Completion as a Malformed
    TLP. However, if the Completion is otherwise properly
    formed, it is permitted[22] for the Receiver to
    handle the Completion as an Unexpected Completion.


| > [2] Demonstration Code for clearing Root Complex No Snoop and Relaxed Ordering:
| >
| > --- a/drivers/net/ethernet/chelsio/cxgb4_main.c       Mon Apr 06 09:27:21 2015 -0700
| > +++ b/drivers/net/ethernet/chelsio/cxgb4_main.c       Tue Apr 07 13:39:05 2015 -0700
| > @@ -9956,6 +9956,36 @@ static void enable_pcie_relaxed_ordering
| >       pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
| >  }
| >
| > +/*
| > + * Find the highest PCI-Express bridge above a PCI Device.  If found, that's
| > + * the Root Complex PCI-PCI Bridge for the PCI Device.  If we find the Root
| > + * Comples, clear the Enable Relaxed Ordering and Enable No Snoop bits in that
| 
| s/Comples/Complex/, but the Root Complex itself does not appear as a PCI
| device, so we'll never actually find *it*.  But I think we should *always*
| find a Root Port.  Your code and text suggests that it's possible we
| wouldn't (since you say "*If* found, ...").  Is there a case you're
| thinking of where we wouldn't find a Root Port?

[[Thanks for the spelling correction.  I'll have others inside Chelsio scan my
  code carefully.  One of the down sides of my [excessively] [pedantic]
  commenting and a complete inability to spell.]]

  I'm relatively unfamiliar with the Linux PCI infrastructure and how its
data structures map to the physical PCI-E fabric.  I was being perhaps
excessively cautious.  I wrote this to be very defensive given my lack of 
background.

| > + * bridge's PCI-E Capability Device Control register.  This will prevent the
| > + * Root Complex from setting those attributes in the Transaction Layer Packets
| > + * of the Requests which it sends down stream to the PCI Device.
| > + */
| > +static void clear_root_complex_tlp_attributes(struct pci_dev *pdev)
| > +{
| > +     struct pci_bus *bus = pdev->bus;
| > +     struct pci_dev *highest_pcie_bridge = NULL;
| > +
| > +     while (bus) {
| > +             struct pci_dev *bridge = bus->self;
| > +
| > +             if (!bridge || !bridge->pcie_cap)
| > +                     break;
| > +             highest_pcie_bridge = bridge;
| > +             bus = bus->parent;
| > +     }
| 
| Can you use pci_upstream_bridge() here?  There are a couple places where we
| want to find the Root Port, so we might factor that out someday.  It'll be
| easier to find all those places if they use with pci_upstream_bridge().

It looks like pci_upstream_bridge() just traverses one like upstream toward the
Root Complex?  Or am I misunderstanding that function?

| > +
| > +     if (highest_pcie_bridge)
| > +             pcie_capability_clear_and_set_word(highest_pcie_bridge,
| > +                                                PCI_EXP_DEVCTL,
| > +                                                PCI_EXP_DEVCTL_RELAX_EN |
| > +                                                PCI_EXP_DEVCTL_NOSNOOP_EN,
| > +                                                0);
| 
| Please include a dmesg note here, especially since the driver is changing
| the config of a device other than its own.

  Yes, in my example PCI Quirk code I did a dev_info() for exactly that reason.
Hhmmm, now that I've mentioned that twice, I may as well include my first
effort along these lines (it's currently in internal code review).  See [3] below
so you can see how I envisioned possibly doing this.

| > +}
| > +
| >  static int init_one(struct pci_dev *pdev,
| >                             const struct pci_device_id *ent)
| >  {
| > @@ -9973,6 +10003,19 @@ static int init_one(struct pci_dev *pdev
| >               ++version_printed;
| >       }
| >
| > +     /*
| > +      * T5 has a PCI-E Compliance bug in it where it doesn't copy the
| > +      * Transaction Layer Packet Attributes from downstream Requests into
| > +      * it's upstream Responses.  Most Root Complexes are fine with this
| 
| s/it's/its/

[[Again, thanks!]]

| > +      * but a few get prissy and drop the non-compliant T5 Responses
| > +      * leading to endless Device Timeouts when TLP Attributes are set.  So
| > +      * if we're a T5, attempt to clear our Root Complex's enable bits for
| > +      * TLP Attributes ...
| > +      */
| > +     if (CHELSIO_PCI_ID_VER(pdev->device) == CHELSIO_T5 ||
| > +         CHELSIO_PCI_ID_VER(pdev->device) == CHELSIO_T5_FPGA)
| > +             clear_root_complex_tlp_attributes(pdev);
| > +
| >       err = pci_request_regions(pdev, KBUILD_MODNAME);
| >       if (err) {
| >               /* Just info, some other driver may have claimed the device. */--

Casey

[3] PCI Quirk Demonstration Code for clearing Root Complex No Snoop
    and Relaxed Ordering:

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index c6dc1df..6e93e5d 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3662,6 +3662,73 @@ DECLARE_PCI_FIXUP_HEADER(0x1283, 0x8892, quirk_use_pcie_bridge_dma_alias);
 DECLARE_PCI_FIXUP_HEADER(0x8086, 0x244e, quirk_use_pcie_bridge_dma_alias);
 
 /*
+ * Some devices violate the PCI Specification regarding echoing the Root
+ * Complex Transaction Layer Packet Request (TLP) No Snoop and Relaxed
+ * Ordering Attributes into the TLP Response.  The PCI Specification
+ * "encourages" compliant Root Complex implementation to drop such malformed
+ * TLP Responses leading to device access timeouts.  Many Root Complex
+ * implementations accept such malformed TLP Responses and a few more strict
+ * implementations do drop them.
+ *
+ * For devices which fail this part of the PCI Specification, we need to
+ * traverse up the PCI Chain to the Root Complex and turn off the Enable No
+ * Snoop and Enable Relaxed Ordering bits in the Root Complex's PCI-Express
+ * Device Control register.  This does affect all other devices which are
+ * downstream of that Root Complex but since No Snoop and Relaxed ordering are
+ * "Performance Hints," we're okay with that ...
+ *
+ * Note that Configuration Space accesses are never supposed to have TLP
+ * Attributes, so we're safe waiting till after any Configuration Space
+ * accesses to do the Root Complex "fixup" ...
+ */
+static void quirk_disable_root_complex_attributes(struct pci_dev *pdev)
+{
+       struct pci_bus *bus = pdev->bus;
+       struct pci_dev *highest_pcie_bridge = NULL;
+
+       while (bus) {
+               struct pci_dev *bridge = bus->self;
+
+               if (!bridge || !bridge->pcie_cap)
+                       break;
+               highest_pcie_bridge = bridge;
+               bus = bus->parent;
+       }
+
+       if (!highest_pcie_bridge) {
+               dev_warn(&pdev->dev, "Can't find Root Complex to disable No Snoop/Relaxed Ordering\n");
+               return;
+       }
+
+       dev_info(&pdev->dev, "Disabling No Snoop/Relaxed Ordering on Root Complex %s\n",
+                dev_name(&highest_pcie_bridge->dev));
+       pcie_capability_clear_and_set_word(highest_pcie_bridge,
+                                          PCI_EXP_DEVCTL,
+                                          PCI_EXP_DEVCTL_RELAX_EN |
+                                          PCI_EXP_DEVCTL_NOSNOOP_EN,
+                                          0);
+}
+
+/*
+ * The Chelsio T5 chip fails to return the Root Complex's TLP Attributes in
+ * its TLP responses to the Root Complex.
+ */
+static void quirk_chelsio_T5_disable_root_complex_attributes(struct pci_dev
+                                                            *pdev)
+{
+       /*
+        * This mask/compare operation selects for Physical Function 4 on a
+        * T5.  We only need to fix up the Root Complex once for any of the
+        * PFs.  PF[0..3] have PCI Device IDs of 0x50xx, but PF4 is uniquely
+        * 0x54xx so we use that one,
+        */
+       if ((pdev->device & 0xff00) == 0x5400)
+               quirk_disable_root_complex_attributes(pdev);
+}
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_CHELSIO, PCI_ANY_ID,
+                        quirk_chelsio_T5_disable_root_complex_attributes);
+
+/*
  * AMD has indicated that the devices below do not support peer-to-peer
  * in any system where they are found in the southbridge with an AMD
  * IOMMU in the system.  Multifunction devices that do not support
