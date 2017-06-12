From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v4 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 12 Jun 2017 19:05:22 +0800
Message-ID: <1497265525-4752-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <helgaas@kernel.org>,
        <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>
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

Casey Leedom (2):
  PCI: Add new PCIe Fabric End Node flag,
    PCI_DEV_FLAGS_NO_RELAXED_ORDERING
  net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag

Ding Tianhong (1):
  PCI: Enable PCIe Relaxed Ordering if supported

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 17 ++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 +--
 drivers/pci/pci.c                               | 32 +++++++++++++++++++
 drivers/pci/probe.c                             | 41 +++++++++++++++++++++++++
 drivers/pci/quirks.c                            | 38 +++++++++++++++++++++++
 include/linux/pci.h                             |  4 +++
 7 files changed, 136 insertions(+), 2 deletions(-)

-- 
1.9.0
