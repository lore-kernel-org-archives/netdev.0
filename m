From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH v5 0/4] arch: Add lightweight memory barriers for coherent
 memory access
Date: Tue, 18 Nov 2014 17:23:28 -0800
Message-ID: <20141119012205.9563.95544.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@polymtl.ca, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	mingo@kernel.org, mikey@neuling.org, linux@arm.linux.org.uk,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	geert@linux-m68k.org, jeffrey.t.kirsher@intel.com,
	romieu@fr.zoreil.com, paulmck@linux.vnet.ibm.com,
	nic_swsd@realtek.com, will.deacon@arm.com, michael@ellerman.id.au,
	tony.luck@intel.com, torvalds@linux-foundation.org,
	oleg@redhat.com, schwidefsky@de.ibm.com, fweisbec@gmail.com,
	davem@davemloft.net
To: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-arch-owner@vger.kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches introduce two new primitives for synchronizing cache coherent
memory writes and reads.  These two new primitives are:

	dma_rmb()
	dma_wmb()

The first patch cleans up some unnecessary overhead related to the
definition of read_barrier_depends, smp_read_barrier_depends, and comments
related to the barrier.

The second patch adds the primitives for the applicable architectures and
asm-generic.

The third patch adds the barriers to r8169 which turns out to be a good
example of where the new barriers might be useful as they have full
rmb()/wmb() barriers ordering accesses to the descriptors and the DescOwn
bit.

The fourth patch adds support for coherent_rmb() to the Intel fm10k, igb,
and ixgbe drivers.  Testing with the ixgbe driver has shown a processing
time reduction of at least 7ns per 64B frame on a Core i7-4930K.

This patch series is essentially the v4 for:
v4:	Add lightweight memory barriers for coherent memory access
v3:	Add lightweight memory barriers fast_rmb() and fast_wmb()
v2:	Introduce load_acquire() and store_release()
v1:	Introduce read_acquire()

The key changes in this patch series versus the earlier patches are:
v5:
	- Renamed barriers dma_rmb and dma_wmb
	- Undid smp_wmb changes in x86 and PowerPC
	- Defined smp_rmb as __lwsync for SMP case on PowerPC
v4:
	- Renamed barriers coherent_rmb and coherent_wmb
	- Added smp_lwsync for use in smp_load_acquire/smp_store_release
v3:
	- Moved away from acquire()/store() and instead focused on barriers
	- Added cleanup of read_barrier_depends
	- Added change in r8169 to fix cur_tx/DescOwn ordering
	- Simplified changes to just replacing/moving barriers in r8169
	- Added update to documentation with code example
v2:
	- Renamed read_acquire() to be consistent with smp_load_acquire()
	- Changed barrier used to be consistent with smp_load_acquire()
	- Updated PowerPC code to use __lwsync based on IBM article
	- Added store_release() as this is a viable use case for drivers
	- Added r8169 patch which is able to fully use primitives
	- Added fm10k/igb/ixgbe patch which is able to test performance

---

Alexander Duyck (4):
      arch: Cleanup read_barrier_depends() and comments
      arch: Add lightweight memory barriers dma_rmb() and dma_wmb()
      r8169: Use dma_rmb() and dma_wmb() for DescOwn checks
      fm10k/igb/ixgbe: Use dma_rmb on Rx descriptor reads


 Documentation/memory-barriers.txt             |   41 +++++++++++++++
 arch/alpha/include/asm/barrier.h              |   51 ++++++++++++++++++
 arch/arm/include/asm/barrier.h                |    4 +
 arch/arm64/include/asm/barrier.h              |    3 +
 arch/blackfin/include/asm/barrier.h           |   51 ++++++++++++++++++
 arch/ia64/include/asm/barrier.h               |   25 ++++-----
 arch/metag/include/asm/barrier.h              |   19 ++++---
 arch/mips/include/asm/barrier.h               |   61 ++--------------------
 arch/powerpc/include/asm/barrier.h            |   19 ++++---
 arch/s390/include/asm/barrier.h               |    7 ++-
 arch/sparc/include/asm/barrier_64.h           |    7 ++-
 arch/x86/include/asm/barrier.h                |   70 ++++---------------------
 arch/x86/um/asm/barrier.h                     |   20 ++++---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    6 +-
 drivers/net/ethernet/intel/igb/igb_main.c     |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 +--
 drivers/net/ethernet/realtek/r8169.c          |   29 ++++++++--
 include/asm-generic/barrier.h                 |    8 +++
 18 files changed, 257 insertions(+), 179 deletions(-)

--
