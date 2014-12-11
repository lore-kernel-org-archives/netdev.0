From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v7 0/4] arch: Add lightweight memory barriers for coherent
 memory access
Date: Wed, 10 Dec 2014 21:28:39 -0800
Message-ID: <54892B87.3020909@gmail.com>
References: <20141125203310.8240.27370.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@polymtl.ca, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	mingo@kernel.org, mikey@neuling.org, linux@arm.linux.org.uk,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	geert@linux-m68k.org, jeffrey.t.kirsher@intel.com,
	romieu@fr.zoreil.com, paulmck@linux.vnet.ibm.com,
	nic_swsd@realtek.com, will.deacon@arm.com, michael@ellerman.id.au,
	tony.luck@intel.com, torvalds@linux-foundation.org,
	oleg@redhat.com, schwidefsky@de.ibm.com, fweisbec@gmail.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de, davem@davemloft.net
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141125203310.8240.27370.stgit@ahduyck-server>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/25/2014 12:35 PM, Alexander Duyck wrote:
> These patches introduce two new primitives for synchronizing cache coherent
> memory writes and reads.  These two new primitives are:
> 
> 	dma_rmb()
> 	dma_wmb()
> 
> The first patch cleans up some unnecessary overhead related to the
> definition of read_barrier_depends, smp_read_barrier_depends, and comments
> related to the barrier.
> 
> The second patch adds the primitives for the applicable architectures and
> asm-generic.
> 
> The third patch adds the barriers to r8169 which turns out to be a good
> example of where the new barriers might be useful as they have full
> rmb()/wmb() barriers ordering accesses to the descriptors and the DescOwn
> bit.
> 
> The fourth patch adds support for coherent_rmb() to the Intel fm10k, igb,
> and ixgbe drivers.  Testing with the ixgbe driver has shown a processing
> time reduction of at least 7ns per 64B frame on a Core i7-4930K.
> 
> This patch series is essentially the v7 for:
> v4-6:	Add lightweight memory barriers for coherent memory access
> v3:	Add lightweight memory barriers fast_rmb() and fast_wmb()
> v2:	Introduce load_acquire() and store_release()
> v1:	Introduce read_acquire()
> 
> The key changes in this patch series versus the earlier patches are:
> v7:
> 	- Dropped test/debug patch that was accidentally slipped in
> v6:
> 	- Replaced "memory based device I/O" with "consistent memory" in
> 	  docs
> 	- Added reference to DMA-API.txt to explain consistent memory
> v5:
> 	- Renamed barriers dma_rmb and dma_wmb
> 	- Undid smp_wmb changes in x86 and PowerPC
> 	- Defined smp_rmb as __lwsync for SMP case on PowerPC
> v4:
> 	- Renamed barriers coherent_rmb and coherent_wmb
> 	- Added smp_lwsync for use in smp_load_acquire/smp_store_release
> v3:
> 	- Moved away from acquire()/store() and instead focused on barriers
> 	- Added cleanup of read_barrier_depends
> 	- Added change in r8169 to fix cur_tx/DescOwn ordering
> 	- Simplified changes to just replacing/moving barriers in r8169
> 	- Added update to documentation with code example
> v2:
> 	- Renamed read_acquire() to be consistent with smp_load_acquire()
> 	- Changed barrier used to be consistent with smp_load_acquire()
> 	- Updated PowerPC code to use __lwsync based on IBM article
> 	- Added store_release() as this is a viable use case for drivers
> 	- Added r8169 patch which is able to fully use primitives
> 	- Added fm10k/igb/ixgbe patch which is able to test performance
> 
> ---
> 
> Alexander Duyck (4):
>       arch: Cleanup read_barrier_depends() and comments
>       arch: Add lightweight memory barriers dma_rmb() and dma_wmb()
>       r8169: Use dma_rmb() and dma_wmb() for DescOwn checks
>       fm10k/igb/ixgbe: Use dma_rmb on Rx descriptor reads
> 
> 
>  Documentation/memory-barriers.txt             |   42 +++++++++++++++
>  arch/alpha/include/asm/barrier.h              |   51 ++++++++++++++++++
>  arch/arm/include/asm/barrier.h                |    4 +
>  arch/arm64/include/asm/barrier.h              |    3 +
>  arch/blackfin/include/asm/barrier.h           |   51 ++++++++++++++++++
>  arch/ia64/include/asm/barrier.h               |   25 ++++-----
>  arch/metag/include/asm/barrier.h              |   19 ++++---
>  arch/mips/include/asm/barrier.h               |   61 ++--------------------
>  arch/powerpc/include/asm/barrier.h            |   19 ++++---
>  arch/s390/include/asm/barrier.h               |    7 ++-
>  arch/sparc/include/asm/barrier_64.h           |    7 ++-
>  arch/x86/include/asm/barrier.h                |   70 ++++---------------------
>  arch/x86/um/asm/barrier.h                     |   20 ++++---
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |    6 +-
>  drivers/net/ethernet/intel/igb/igb_main.c     |    6 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 +--
>  drivers/net/ethernet/realtek/r8169.c          |   29 ++++++++--
>  include/asm-generic/barrier.h                 |    8 +++
>  18 files changed, 258 insertions(+), 179 deletions(-)
> 
> --

It occurs to me that I never got a sign off from any of the maintainers
on getting this pulled in.

Since the merge window is open I was wondering which tree I should make
sure these patches apply to and who will be the one to pull them in?
Since I was modifying network drivers should I resubmit them for netdev,
or should I submit them for asm-generic or some other tree?

- Alex
