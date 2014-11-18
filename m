From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb()
 and fast_wmb()
Date: Tue, 18 Nov 2014 11:38:03 +1100
Message-ID: <1416271083.18381.14.camel@kernel.crashing.org>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
	 <20141117171812.22333.90395.stgit@ahduyck-server>
	 <20141117201823.GD5050@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mathieu.desnoyers@polymtl.ca,
	peterz@infradead.org, heiko.carstens@de.ibm.com, mingo@kernel.org,
	mikey@neuling.org, linux@arm.linux.org.uk,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	geert@linux-m68k.org, jeffrey.t.kirsher@intel.com,
	romieu@fr.zoreil.com, nic_swsd@realtek.com, will.deacon@arm.com,
	michael@ellerman.id.au, tony.luck@intel.com,
	torvalds@linux-foundation.org, oleg@redhat.com,
	schwidefsky@de.ibm.com, fweisbec@gmail.com, davem@davemloft.net
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141117201823.GD5050@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-17 at 12:18 -0800, Paul E. McKenney wrote:
> On Mon, Nov 17, 2014 at 09:18:13AM -0800, Alexander Duyck wrote:
> > There are a number of situations where the mandatory barriers rmb() and
> > wmb() are used to order memory/memory operations in the device drivers
> > and those barriers are much heavier than they actually need to be.  For
> > example in the case of PowerPC wmb() calls the heavy-weight sync
> > instruction when for memory/memory operations all that is really needed is
> > an lsync or eieio instruction.
> 
> Is this still the case if one of the memory operations is MMIO?  Last
> I knew, it was not.

I *think* (Alexander, correct me if I'm wrong), that what he wants is
the memory<->memory barriers (the smp_* ones) basically for ordering his
loads or stores from/to the DMA area.

The problem is that the smp_* ones aren't compiled for !CONFIG_SMP

IE. Something like:

  - Read valid bit from descriptor

  - Read rest of descriptor

That needs an rmb of some sort in between, but a full blown "rmb" will
also order vs. MMIOs and end up being a full sync, while an smp_rmb is a
lwsync which is more lightweight.

Similarily:

 - Populate descriptor

 - Write valid bit

Same deal with wmb ...

Basically, rmb and wmb order both cachable and non-cachable (memory and
MMIO) which makes them needlessly heavy on powerpc and possibly others
when all you need is to order memory accesses to some DMA data
structures. In that case you really want the normal smp_* variants
except they may not be around...

Cheers,
Ben.
