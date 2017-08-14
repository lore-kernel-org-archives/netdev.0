From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v10 0/5] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 14 Aug 2017 23:44:54 +0800
Message-ID: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <bhelgaas@google.com>,
        <helgaas@kernel.org>, <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some devices have problems with Transaction Layer Packets with the Relaxed
Ordering Attribute set.  This patch set adds a new PCIe Device Flag,
PCI_DEV_FLAGS_NO_RELAXED_ORDERING, a set of PCI Quirks to catch some known
devices with Relaxed Ordering issues, and a use of this new flag by the
cxgb4 driver to avoid using Relaxed Ordering with problematic Root Complex
Ports.

It's been years since I've submitted kernel.org patches, I appolgise for the
almost certain submission errors.

v2: Alexander point out that the v1 was only a part of the whole solution,
    some platform which has some issues could use the new flag to indicate
    that it is not safe to enable relaxed ordering attribute, then we need
    to clear the relaxed ordering enable bits in the PCI configuration when
    initializing the device. So add a new second patch to modify the PCI
    initialization code to clear the relaxed ordering enable bit in the
    event that the root complex doesn't want relaxed ordering enabled.

    The third patch was base on the v1's second patch and only be changed
    to query the relaxed ordering enable bit in the PCI configuration space
    to allow the Chelsio NIC to send TLPs with the relaxed ordering attributes
    set.

    This version didn't plan to drop the defines for Intel Drivers to use the
    new checking way to enable relaxed ordering because it is not the hardest
    part of the moment, we could fix it in next patchset when this patches
    reach the goal.

v3: Redesigned the logic for pci_configure_relaxed_ordering when configuration,
    If a PCIe device didn't enable the relaxed ordering attribute default,
    we should not do anything in the PCIe configuration, otherwise we
    should check if any of the devices above us do not support relaxed
    ordering by the PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag, then base on
    the result if we get a return that indicate that the relaxed ordering
    is not supported we should update our device to disable relaxed ordering
    in configuration space. If the device above us doesn't exist or isn't
    the PCIe device, we shouldn't do anything and skip updating relaxed ordering
    because we are probably running in a guest.

v4: Rename the functions pcie_get_relaxed_ordering and pcie_disable_relaxed_ordering
    according John's suggestion, and modify the description, use the true/false
    as the return value.

    We shouldn't enable relaxed ordering attribute by the setting in the root
    complex configuration space for PCIe device, so fix it for cxgb4.

    Fix some format issues.

v5: Removed the unnecessary code for some function which only return the bool
    value, and add the check for VF device.

    Make this patch set base on 4.12-rc5.

v6: Fix the logic error in the need to enable the relaxed ordering attribute for cxgb4.

v7: The cxgb4 drivers will enable the PCIe Capability Device Control[Relaxed
    Ordering Enable] in PCI Probe() routine, this will break our current
    solution for some platform which has problematic when enable the relaxed
    ordering attribute. According to the latest recommendations, remove the
    enable_pcie_relaxed_ordering(), although it could not cover the Peer-to-Peer
    scene, but we agree to leave this problem until we really trigger it.

    Make this patch set base on 4.12 release version.

v8: Change the second patch title and description to make it more reasonable,
    add the acked-by from Alex and Ashok.

    Add a new patch to enable the Relaxed Ordering Attribute for cxgb4vf driver.

    Make this patch set base on 4.13-rc2.

v9: The document (https://software.intel.com/sites/default/files/managed/9e/
    bc/64-ia-32-architectures-optimization-manual.pdf) indicate that the Xeon
    processors based on Broadwell/Haswell microarchitecture has the problem
    with Relaxed Ordering Attribute enabled, so add the whole list Device ID
    from Intel to the patch.

v10: Significant rework based on Bjorn's feedback, reorganize the first 2 patches,
     now the Intel and AMD erratum soc has been divided to the different patches,
     rename the pcie_relaxed_ordering_supported() to pcie_relaxed_ordering_enabled(),
     and no need to check every intervening switch except the root ports, update
     some commits.

Casey Leedom (2):
  net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
  net/cxgb4vf: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag

Ding Tianhong (3):
  PCI: Disable PCIe Relaxed Ordering if unsupported
  PCI: Disable Relaxed Ordering for some Intel processors
  PCI: Disable Relaxed Ordering Attributes for AMD A1100

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 23 ++++--
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  5 +-
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |  1 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 18 +++++
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  3 +
 drivers/pci/probe.c                                | 43 +++++++++++
 drivers/pci/quirks.c                               | 89 ++++++++++++++++++++++
 include/linux/pci.h                                |  3 +
 9 files changed, 178 insertions(+), 8 deletions(-)

-- 
1.8.3.1
