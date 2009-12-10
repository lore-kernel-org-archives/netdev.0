From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
Date: Wed, 9 Dec 2009 17:40:33 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07558C3DEDB1@orsmsx508.amr.corp.intel.com>
References: <pvmiqcfbpep.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "chavey@google.com" <chavey@google.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:50929 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759373AbZLJBka convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 20:40:30 -0500
In-Reply-To: <pvmiqcfbpep.fsf@chavey.mtv.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: chavey@google.com [mailto:chavey@google.com]
>Sent: Wednesday, December 09, 2009 5:15 PM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V;
>Waskiewicz Jr, Peter P
>Subject: Re: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
>
>From: Greg Rose <gregory.v.rose@intel.com>
>
>Adds SR-IOV features supported by the 82599 controller to the main
>driver
>module.  If the CONFIG_PCI_IOV kernel option is selected then the SR-IOV
>features are enabled.  Use the max_vfs module option to allocate up to
>63
>virtual functions per physical port.
>
>---
>
>+static inline void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
>+{
>+       struct ixgbe_hw *hw = &adapter->hw;
>+       u32 gcr;
>+       u32 gpie;
>+       u32 vmdctl;
>+
>+#ifdef CONFIG_PCI_IOV
>+       /* disable iov and allow time for transactions to clear */
>+       pci_disable_sriov(adapter->pdev);
>+#endif
>+       msleep(500);
>
>what is the sleep used for ?
[Rose, Gregory V] 

It's mostly a safety valve to give plenty of time for all bus transactions to complete or time out.

>if this is to wait for pci_disable then add it
>in the #ifdef above.
>i s there a registerthat can be checked to ensure that
>the device is in the expected state ? (similar to line 311 of
>the orginal patch)
[Rose, Gregory V] 

Not reliably.

>
>
>@@ -2269,6 +2376,20 @@ static void ixgbe_configure_rx(struct
>ixgbe_adapter *adapter)
>       }
>       IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
>
>+       if (adapter->num_vfs) {
>+               u32 reg;
>+
>+               /* Map PF MAC address in RAR Entry 0 to first pool
>+                * following VFs */
>+               hw->mac.ops.set_vmdq(hw, 0, adapter->num_vfs);
>+
>+               /* Set up VF register offsets for selected VT Mode, i.e.
>+                * 64 VFs for SR-IOV */
>+               reg = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
>+               reg |= 0x80000003;
>
>what is the significance of the 0x80000003 ?

[Rose, Gregory V] 

Oh, a magic number.  We'll fix that.

In this case it's to set up the correct PCIe configuration on the device.

- Greg

