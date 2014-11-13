From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 0/3] Introduce load_acquire() and store_release()
Date: Thu, 13 Nov 2014 11:27:10 -0800
Message-ID: <20141113191250.12579.19694.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mikey@neuling.org, tony.luck@intel.com,
	mathieu.desnoyers@polymtl.ca, donald.c.skidmore@intel.com,
	peterz@infradead.org, benh@kernel.crashing.org,
	heiko.carstens@de.ibm.com, oleg@redhat.com, will.deacon@arm.com,
	davem@davemloft.net, michael@ellerman.id.au,
	matthew.vick@intel.com, nic_swsd@realtek.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, fweisbec@gmail.com,
	schwidefsky@de.ibm.com, linux@arm.linux.org.uk,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@kernel.org
To: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches introduce uniprocessor or CPU<->device equivalents for
smp_load_acquire() and smp_store_release().  These two new primitives are:

	load_acquire()
	store_release()

The first patch adds the primitives for the applicable architectures and
asm-generic.

The second patch adds the primitives to r8169 which turns out to be a good
example of where the new primitives might be useful as they have memory
barriers ordering accesses to the descriptors and the DescOwn bit within the
descriptors which follow acquire/release style semantics.

The third patch adds support for load_acquire() to the Intel fm10k, igb,
and ixgbe drivers.  Testing with the ixgbe driver has shown a processing
time reduction of at least 7ns per 64B frame on a Core i7-4930K.

This patch series is essentially the v2 for:
	arch: Introduce read_acquire()

The key changes in this patch series versus that patch are:
	- Renamed read_acquire() to be consistent with smp_load_acquire()
	- Changed barrier used to be consistent with smp_load_acquire()
	- Updated PowerPC code to use __lwsync based on IBM article
	- Added store_release() as this is a viable use case for drivers
	- Added r8169 patch which is able to fully use primitives
	- Added fm10k/igb/ixgbe patch which is able to test performance

---

Alexander Duyck (3):
      arch: Introduce load_acquire() and store_release()
      r8169: Use load_acquire() and store_release() to reduce memory barrier overhead
      fm10k/igb/ixgbe: Use load_acquire on Rx descriptor


 arch/arm/include/asm/barrier.h                |   15 ++++++
 arch/arm64/include/asm/barrier.h              |   59 +++++++++++++------------
 arch/ia64/include/asm/barrier.h               |    7 ++-
 arch/metag/include/asm/barrier.h              |   15 ++++++
 arch/mips/include/asm/barrier.h               |   15 ++++++
 arch/powerpc/include/asm/barrier.h            |   24 ++++++++--
 arch/s390/include/asm/barrier.h               |    7 ++-
 arch/sparc/include/asm/barrier_64.h           |    6 ++-
 arch/x86/include/asm/barrier.h                |   22 ++++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    8 +--
 drivers/net/ethernet/intel/igb/igb_main.c     |    8 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   11 ++---
 drivers/net/ethernet/realtek/r8169.c          |   23 ++++------
 include/asm-generic/barrier.h                 |   15 ++++++
 14 files changed, 163 insertions(+), 72 deletions(-)

--
