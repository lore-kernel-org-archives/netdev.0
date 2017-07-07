From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Fri, 7 Jul 2017 21:48:48 +0000
Message-ID: <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Ding Tianhong <dingtianhong@huawei.com>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        "Michael Werner" <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "will.deacon@arm.com" <will.deacon
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0115.outbound.protection.outlook.com ([104.47.34.115]:62176
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751001AbdGGVs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Jul 2017 17:48:58 -0400
In-Reply-To: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Ding, Bjorn, Alexander, et.al.,

  Sorry for the insane delay in getting to this and thanks especially to
Ding for picking up the ball on this feature.  I got side=3D-tracked into a
multi-week rewrite of our Firmware/Host Driver Port Capabilities code, then
to the recent Ethernet Plug-Fest at the University of New Hampshire for a
week, and finally the 4th of July weekend.  Digging out from under email ha=
s
been non-amusing.  In any case, enough excuses.
=20
  I'm looking at the "v6" version of the patches.  If this isn't the corect
version, please yell at me and I'll look at the correct one immediately.

  In the change to drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c (patch
3/3) it looks like the code is checking the Chelsio Adapter PCI Device to
see if Relaxed Ordering is supported.  But what we really want to test is
the Root Complex port.  I.e. something like:

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/=
ethernet/chelsio/cxgb4/cxgb4_main.c
index 38a5c67..546538d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4620,6 +4620,7 @@ static int init_one(struct pci_dev *pdev, const struc=
t pci_device_id *ent)
        struct port_info *pi;
        bool highdma =3D false;
        struct adapter *adapter =3D NULL;
+       struct pci_dev *root;
        struct net_device *netdev;
        void __iomem *regs;
        u32 whoami, pl_rev;
@@ -4726,6 +4727,24 @@ static int init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
        adapter->msg_enable =3D DFLT_MSG_ENABLE;
        memset(adapter->chan_map, 0xff, sizeof(adapter->chan_map));

+       /* If possible, we use PCIe Relaxed Ordering Attribute to deliver
+        * Ingress Packet Data to Free List Buffers in order to allow for
+        * chipset performance optimizations between the Root Complex and
+        * Memory Controllers.  (Messages to the associated Ingress Queue
+        * notifying new Packet Placement in the Free Lists Buffers will be
+        * send without the Relaxed Ordering Attribute thus guaranteeing th=
at
+        * all preceding PCIe Transaction Layer Packets will be processed
+        * first.)  But some Root Complexes have various issues with Upstre=
am
+        * Transaction Layer Packets with the Relaxed Ordering Attribute se=
t.
+        * The PCIe devices which under the Root Complexes will be cleared =
the
+        * Relaxed Ordering bit in the configuration space, So we check our
+        * PCIe configuration space to see if it's flagged with advice agai=
nst
+        * using Relaxed Ordering.
+        */
+       root =3D pci_find_pcie_root_port(pdev);
+       if (!pcie_relaxed_ordering_supported(root))
+               adapter->flags |=3D ROOT_NO_RELAXED_ORDERING;
+
        spin_lock_init(&adapter->stats_lock);
        spin_lock_init(&adapter->tid_release_lock);
        spin_lock_init(&adapter->win0_lock);

The basic idea is that we want to find out if the Root Complex is okay with
TLPs directed its way with the Relaxed Ordering Attribute set.

  I also have to say that I'm a bit confused by the
pcie_relaxed_ordering_supported() in use here.  It seems that it's testing
whether the PCI Device's own Relaxed Ordering Enable is set which governs
whether it will send TLPs with the Relaxed Ordering Attribute set.  It has
nothing to do with whether or not the device responds well to incoming TLPs
with the Relaxed Ordering Attribute set.  I think that we really want to us=
e
the pci_dev_should_disable_relaxed_ordering() API on the Root Complex Port
because that tests whether the quirck fired on it?  I.e.:

+       root =3D pci_find_pcie_root_port(pdev);
+       if (!pci_dev_should_disable_relaxed_ordering(root))
+               adapter->flags |=3D ROOT_NO_RELAXED_ORDERING;


Casey
