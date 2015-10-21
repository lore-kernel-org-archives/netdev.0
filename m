From: Lan Tianyu <tianyu.lan@intel.com>
Subject: [RFC Patch 00/12] IXGBE: Add live migration support
	for SRIOV NIC
Date: Thu, 22 Oct 2015 00:37:32 +0800
Message-ID: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Cc: Lan Tianyu <tianyu.lan@intel.com>
To: bhelgaas@google.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

This patchset is to propose a new solution to add live migration support for 82599
SRIOV network card.

Im our solution, we prefer to put all device specific operation into VF and
PF driver and make code in the Qemu more general.


VF status migration
=================================================================
VF status can be divided into 4 parts
1) PCI configure regs
2) MSIX configure
3) VF status in the PF driver
4) VF MMIO regs 

The first three status are all handled by Qemu. 
The PCI configure space regs and MSIX configure are originally
stored in Qemu. To save and restore "VF status in the PF driver"
by Qemu during migration, adds new sysfs node "state_in_pf" under
VF sysfs directory.

For VF MMIO regs, we introduce self emulation layer in the VF
driver to record MMIO reg values during reading or writing MMIO
and put these data in the guest memory. It will be migrated with
guest memory to new machine.


VF function restoration
================================================================
Restoring VF function operation are done in the VF and PF driver.
 
In order to let VF driver to know migration status, Qemu fakes VF
PCI configure regs to indicate migration status and add new sysfs
node "notify_vf" to trigger VF mailbox irq in order to notify VF 
about migration status change.

Transmit/Receive descriptor head regs are read-only and can't
be restored via writing back recording reg value directly and they
are set to 0 during VF reset. To reuse original tx/rx rings, shift
desc ring in order to move the desc pointed by original head reg to
first entry of the ring and then enable tx/rx rings. VF restarts to
receive and transmit from original head desc.


Tracking DMA accessed memory
=================================================================
Migration relies on tracking dirty page to migrate memory.
Hardware can't automatically mark a page as dirty after DMA
memory access. VF descriptor rings and data buffers are modified
by hardware when receive and transmit data. To track such dirty memory
manually, do dummy writes(read a byte and write it back) when receive
and transmit data.


Service down time test
=================================================================
So far, we tested migration between two laptops with 82599 nic which
are connected to a gigabit switch. Ping VF in the 0.001s interval
during migration on the host of source side. It service down
time is about 180ms.

[983769928.053604] 64 bytes from 10.239.48.100: icmp_seq=4131 ttl=64 time=2.79 ms
[983769928.056422] 64 bytes from 10.239.48.100: icmp_seq=4132 ttl=64 time=2.79 ms
[983769928.059241] 64 bytes from 10.239.48.100: icmp_seq=4133 ttl=64 time=2.79 ms
[983769928.062071] 64 bytes from 10.239.48.100: icmp_seq=4134 ttl=64 time=2.80 ms
[983769928.064890] 64 bytes from 10.239.48.100: icmp_seq=4135 ttl=64 time=2.79 ms
[983769928.067716] 64 bytes from 10.239.48.100: icmp_seq=4136 ttl=64 time=2.79 ms
[983769928.070538] 64 bytes from 10.239.48.100: icmp_seq=4137 ttl=64 time=2.79 ms
[983769928.073360] 64 bytes from 10.239.48.100: icmp_seq=4138 ttl=64 time=2.79 ms
[983769928.083444] no answer yet for icmp_seq=4139
[983769928.093524] no answer yet for icmp_seq=4140
[983769928.103602] no answer yet for icmp_seq=4141
[983769928.113684] no answer yet for icmp_seq=4142
[983769928.123763] no answer yet for icmp_seq=4143
[983769928.133854] no answer yet for icmp_seq=4144
[983769928.143931] no answer yet for icmp_seq=4145
[983769928.154008] no answer yet for icmp_seq=4146
[983769928.164084] no answer yet for icmp_seq=4147
[983769928.174160] no answer yet for icmp_seq=4148
[983769928.184236] no answer yet for icmp_seq=4149
[983769928.194313] no answer yet for icmp_seq=4150
[983769928.204390] no answer yet for icmp_seq=4151
[983769928.214468] no answer yet for icmp_seq=4152
[983769928.224556] no answer yet for icmp_seq=4153
[983769928.234632] no answer yet for icmp_seq=4154
[983769928.244709] no answer yet for icmp_seq=4155
[983769928.254783] no answer yet for icmp_seq=4156
[983769928.256094] 64 bytes from 10.239.48.100: icmp_seq=4139 ttl=64 time=182 ms
[983769928.256107] 64 bytes from 10.239.48.100: icmp_seq=4140 ttl=64 time=172 ms
[983769928.256114] no answer yet for icmp_seq=4157
[983769928.256236] 64 bytes from 10.239.48.100: icmp_seq=4141 ttl=64 time=162 ms
[983769928.256245] 64 bytes from 10.239.48.100: icmp_seq=4142 ttl=64 time=152 ms
[983769928.256272] 64 bytes from 10.239.48.100: icmp_seq=4143 ttl=64 time=142 ms
[983769928.256310] 64 bytes from 10.239.48.100: icmp_seq=4144 ttl=64 time=132 ms
[983769928.256325] 64 bytes from 10.239.48.100: icmp_seq=4145 ttl=64 time=122 ms
[983769928.256332] 64 bytes from 10.239.48.100: icmp_seq=4146 ttl=64 time=112 ms
[983769928.256440] 64 bytes from 10.239.48.100: icmp_seq=4147 ttl=64 time=102 ms
[983769928.256455] 64 bytes from 10.239.48.100: icmp_seq=4148 ttl=64 time=92.3 ms
[983769928.256494] 64 bytes from 10.239.48.100: icmp_seq=4149 ttl=64 time=82.3 ms
[983769928.256503] 64 bytes from 10.239.48.100: icmp_seq=4150 ttl=64 time=72.2 ms
[983769928.256631] 64 bytes from 10.239.48.100: icmp_seq=4158 ttl=64 time=0.500 ms
[983769928.257284] 64 bytes from 10.239.48.100: icmp_seq=4159 ttl=64 time=0.154 ms
[983769928.258297] 64 bytes from 10.239.48.100: icmp_seq=4160 ttl=64 time=0.165 ms

Todo
=======================================================
So far, the patchset isn't perfect. VF net interface can't be open, closed, down 
and up during migration. Will prevent such operation during migration in the
future job.

Very appreciate for your comments.


Lan Tianyu (12):
  PCI: Add virtfn_index for struct pci_device
  IXGBE: Add new mail box event to restore VF status in the PF driver
  IXGBE: Add sysfs interface for Qemu to migrate VF status in the PF
    driver
  IXGBE: Add ixgbe_ping_vf() to notify a specified VF via mailbox msg.
  IXGBE: Add new sysfs interface of "notify_vf"
  IXGBEVF: Add self emulation layer
  IXGBEVF: Add new mail box event for migration
  IXGBEVF: Rework code of finding the end transmit desc of package
  IXGBEVF: Add live migration support for VF driver
  IXGBEVF: Add lock to protect tx/rx ring operation
  IXGBEVF: Migrate VF statistic data
  IXGBEVF: Track dma dirty pages

 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     | 245 ++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   4 +
 drivers/net/ethernet/intel/ixgbevf/Makefile        |   3 +-
 drivers/net/ethernet/intel/ixgbevf/defines.h       |   6 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |  10 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 179 ++++++++++++++-
 drivers/net/ethernet/intel/ixgbevf/mbx.h           |   3 +
 .../net/ethernet/intel/ixgbevf/self-emulation.c    | 133 +++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.c            |  10 +
 drivers/net/ethernet/intel/ixgbevf/vf.h            |   6 +-
 drivers/pci/iov.c                                  |   1 +
 include/linux/pci.h                                |   1 +
 15 files changed, 582 insertions(+), 22 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbevf/self-emulation.c

-- 
1.8.4.rc0.1.g8f6a3e5.dirty
