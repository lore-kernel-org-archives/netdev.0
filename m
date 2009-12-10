From: chavey@google.com
Subject: Re: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
Date: Wed, 09 Dec 2009 17:15:10 -0800
Message-ID: <pvmiqcfbpep.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:33544 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbZLJBPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 20:15:12 -0500
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id nBA1FHKN014937
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 01:15:17 GMT
Received: from gxk23 (gxk23.prod.google.com [10.202.11.23])
	by spaceape24.eur.corp.google.com with ESMTP id nBA1FEGc026124
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 17:15:15 -0800
Received: by gxk23 with SMTP id 23so4914283gxk.2
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2009 17:15:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Adds SR-IOV features supported by the 82599 controller to the main driver
module.  If the CONFIG_PCI_IOV kernel option is selected then the SR-IOV
features are enabled.  Use the max_vfs module option to allocate up to 63
virtual functions per physical port.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

+static inline void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
+{
+       struct ixgbe_hw *hw = &adapter->hw;
+       u32 gcr;
+       u32 gpie;
+       u32 vmdctl;
+
+#ifdef CONFIG_PCI_IOV
+       /* disable iov and allow time for transactions to clear */
+       pci_disable_sriov(adapter->pdev);
+#endif
+       msleep(500);

what is the sleep used for ?
if this is to wait for pci_disable then add it
in the #ifdef above.
i s there a registerthat can be checked to ensure that
the device is in the expected state ? (similar to line 311 of
the orginal patch)


@@ -2269,6 +2376,20 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
       }
       IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);

+       if (adapter->num_vfs) {
+               u32 reg;
+
+               /* Map PF MAC address in RAR Entry 0 to first pool
+                * following VFs */
+               hw->mac.ops.set_vmdq(hw, 0, adapter->num_vfs);
+
+               /* Set up VF register offsets for selected VT Mode, i.e.
+                * 64 VFs for SR-IOV */
+               reg = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
+               reg |= 0x80000003;

what is the significance of the 0x80000003 ?

