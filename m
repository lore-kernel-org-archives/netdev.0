From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Run-time kfree check for correct cache [plus x86_64 APIC troubles]
Date: Wed, 28 Feb 2007 17:16:55 +0300
Message-ID: <20070228141652.GA3033@2ka.mipt.ru>
References: <20070227.100052.59655152.davem@davemloft.net> <20070227.102452.102574618.davem@davemloft.net> <20070228090258.GA28336@2ka.mipt.ru> <200702281110.54619.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Cc: David Miller <davem@davemloft.net>, paul.moore@hp.com,
	kaber@trash.net, netdev@vger.kernel.org, acme@ghostprotocols.net,
	ak@suse.de
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50563 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932704AbXB1OWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 09:22:17 -0500
Content-Disposition: inline
In-Reply-To: <200702281110.54619.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

On Wed, Feb 28, 2007 at 11:10:54AM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Wednesday 28 February 2007 10:02, Evgeniy Polyakov wrote:
> > Attached patch detects in run-time things like:
> > skb = alloc_skb();
> > kfree(skb);
> >
> > where provided to kfree pointer does not belong to kmalloc caches.
> > It is turned on when slab debug config option is enabled.
> >
> > When problem is detected, following warning is printed with hint to
> > what cache/function should be used instead:
> 
> It would be less expensive to add a flag 
> #define SLAB_KFREE_NOWARNING 0x00200000UL
> 
> And OR this flags into cs->flags of all standard caches created by 
> kmem_cache_init() from malloc_sizes[]/cache_names[]
> 
> kfree() would then just test this flag.

That does not work - my x86_64 test machine fails badly with following
patch applied:

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1ef822e..acc3cfb 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -32,6 +32,7 @@ typedef struct kmem_cache kmem_cache_t __deprecated;
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
+#define SLAB_KFREE_NOWARNING 	0x00200000UL	/* Do not warn if object belongs to this cache and is freed via kfree */
 
 /* Flags passed to a constructor functions */
 #define SLAB_CTOR_CONSTRUCTOR	0x001UL		/* If not set, then deconstructor */
diff --git a/mm/slab.c b/mm/slab.c
index 8fdaffa..313014e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -177,7 +177,8 @@
 			 SLAB_CACHE_DMA | \
 			 SLAB_MUST_HWCACHE_ALIGN | SLAB_STORE_USER | \
 			 SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | \
-			 SLAB_DESTROY_BY_RCU | SLAB_MEM_SPREAD)
+			 SLAB_DESTROY_BY_RCU | SLAB_MEM_SPREAD | \
+			 SLAB_KFREE_NOWARNING )
 #else
 # define CREATE_MASK	(SLAB_HWCACHE_ALIGN | \
 			 SLAB_CACHE_DMA | SLAB_MUST_HWCACHE_ALIGN | \
@@ -814,7 +815,7 @@ static size_t slab_mgmt_size(size_t nr_objs, size_t align)
  * Calculate the number of objects and left-over bytes for a given buffer size.
  */
 static void cache_estimate(unsigned long gfporder, size_t buffer_size,
-			   size_t align, int flags, size_t *left_over,
+			   size_t align, unsigned long flags, size_t *left_over,
 			   unsigned int *num)
 {
 	int nr_objs;
@@ -1466,7 +1467,8 @@ void __init kmem_cache_init(void)
 	sizes[INDEX_AC].cs_cachep = kmem_cache_create(names[INDEX_AC].name,
 					sizes[INDEX_AC].cs_size,
 					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
+					ARCH_KMALLOC_FLAGS|SLAB_PANIC|
+						SLAB_KFREE_NOWARNING,
 					NULL, NULL);
 
 	if (INDEX_AC != INDEX_L3) {
@@ -1474,7 +1476,8 @@ void __init kmem_cache_init(void)
 			kmem_cache_create(names[INDEX_L3].name,
 				sizes[INDEX_L3].cs_size,
 				ARCH_KMALLOC_MINALIGN,
-				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
+				ARCH_KMALLOC_FLAGS|SLAB_PANIC|
+					SLAB_KFREE_NOWARNING,
 				NULL, NULL);
 	}
 
@@ -1492,7 +1495,8 @@ void __init kmem_cache_init(void)
 			sizes->cs_cachep = kmem_cache_create(names->name,
 					sizes->cs_size,
 					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
+					ARCH_KMALLOC_FLAGS|SLAB_PANIC|
+						SLAB_KFREE_NOWARNING,
 					NULL, NULL);
 		}
 #ifdef CONFIG_ZONE_DMA
@@ -1501,7 +1505,7 @@ void __init kmem_cache_init(void)
 					sizes->cs_size,
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
-						SLAB_PANIC,
+						SLAB_PANIC|SLAB_KFREE_NOWARNING,
 					NULL, NULL);
 #endif
 		sizes++;
@@ -2827,6 +2831,16 @@ static void kfree_debugcheck(const void *objp)
 	}
 }
 
+static void kfree_debug_cache_pointer(struct kmem_cache *cachep, const void *objp)
+{
+	if (!(cachep->flags & SLAB_KFREE_NOWARNING)) {
+		printk(KERN_ERR "kfree debug: obj: %p, likely you want to use something with "
+				"'%s' in name instead of kfree().\n",
+				objp, cachep->name);
+		WARN_ON(1);
+	}
+}
+
 static inline void verify_redzone_free(struct kmem_cache *cache, void *obj)
 {
 	unsigned long redzone1, redzone2;
@@ -2938,6 +2952,7 @@ bad:
 }
 #else
 #define kfree_debugcheck(x) do { } while(0)
+#define kfree_debug_cache_pointer(x, y) do { } while(0)
 #define cache_free_debugcheck(x,objp,z) (objp)
 #define check_slabp(x,y) do { } while(0)
 #endif
@@ -3776,6 +3791,7 @@ void kfree(const void *objp)
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = virt_to_cache(objp);
+	kfree_debug_cache_pointer(c, objp);
 	debug_check_no_locks_freed(objp, obj_size(c));
 	__cache_free(c, (void *)objp);
 	local_irq_restore(flags);


Even I add a simple printk into kmalloc cache initialization path (only one)
system fails to find apic timer. The same happens if I use different bit
from higher byte (except the last one which is used).

The latest message in dmesg is:

..MP-BIOS bug: 8254 timer not connected to IO-APIC
IO-APIC+timer do not work 

(or something like that).

System boots ok with 'noapic' kernel parameter. dmesg of working system 
is attached.

I've added Andy Kleen to Cc so he would shed some light on it.

To cure (workaround) the bug, I added following patch:

diff --git a/arch/x86_64/kernel/io_apic.c b/arch/x86_64/kernel/io_apic.c
index 950682f..765278a 100644
--- a/arch/x86_64/kernel/io_apic.c
+++ b/arch/x86_64/kernel/io_apic.c
@@ -1315,7 +1315,7 @@ static int __init timer_irq_works(void)
 
 	local_irq_enable();
 	/* Let ten ticks pass... */
-	mdelay((10 * 1000) / HZ);
+	mdelay((10 * 10000) / HZ);
 
 	/*
 	 * Expect a few ticks at least, to be sure some possible


After applied system boots fine, but above message 
	..MP-BIOS bug: 8254 timer not connected to IO-APIC
still exist.
-- 
	Evgeniy Polyakov

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename=dmesg

[    0.000000] Linux version 2.6.21-rc1-kevent (s0mbre@uganda) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #50 SMP PREEMPT Wed Feb 28 12:31:20 EST 2007
[    0.000000] Command line: root=/dev/mapper/uganda-root ro idle=poll
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003fff0000 (usable)
[    0.000000]  BIOS-e820: 000000003fff0000 - 000000003fff3000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003fff3000 - 0000000040000000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fef00000 (reserved)
[    0.000000]  BIOS-e820: 00000000fefffc00 - 00000000ff000000 (reserved)
[    0.000000]  BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
[    0.000000] Entering add_active_range(0, 0, 159) 0 entries of 3200 used
[    0.000000] Entering add_active_range(0, 256, 262128) 1 entries of 3200 used
[    0.000000] end_pfn_map = 1048576
[    0.000000] DMI 2.2 present.
[    0.000000] ACPI: RSDP 000F7150, 0014 (r0 Nvidia)
[    0.000000] ACPI: RSDT 3FFF3000, 002C (r1 Nvidia AWRDACPI 42302E31 AWRD        0)
[    0.000000] ACPI: FACP 3FFF3040, 0074 (r1 Nvidia AWRDACPI 42302E31 AWRD        0)
[    0.000000] ACPI: DSDT 3FFF30C0, 48E5 (r1 NVIDIA AWRDACPI     1000 MSFT  100000E)
[    0.000000] ACPI: FACS 3FFF0000, 0040
[    0.000000] ACPI: APIC 3FFF79C0, 006E (r1 Nvidia AWRDACPI 42302E31 AWRD        0)
[    0.000000] Scanning NUMA topology in Northbridge 24
[    0.000000] Number of nodes 1
[    0.000000] Node 0 MemBase 0000000000000000 Limit 000000003fff0000
[    0.000000] Entering add_active_range(0, 0, 159) 0 entries of 3200 used
[    0.000000] Entering add_active_range(0, 256, 262128) 1 entries of 3200 used
[    0.000000] NUMA: Using 63 for the hash shift.
[    0.000000] Using node hash shift of 63
[    0.000000] Bootmem setup node 0 0000000000000000-000000003fff0000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   262128
[    0.000000] On node 0 totalpages: 262031
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 866 pages reserved
[    0.000000]   DMA zone: 3077 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 3527 pages used for memmap
[    0.000000]   DMA32 zone: 254505 pages, LIFO batch:31
[    0.000000]   Normal zone: 0 pages used for memmap
[    0.000000] ACPI: PM-Timer IO Port: 0x4008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] Processor #0 (Bootup-CPU)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high edge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high edge)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ14 used by override.
[    0.000000] ACPI: IRQ15 used by override.
[    0.000000] Setting APIC routing to physical flat
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] Nosave address range: 000000000009f000 - 00000000000a0000
[    0.000000] Nosave address range: 00000000000a0000 - 00000000000f0000
[    0.000000] Nosave address range: 00000000000f0000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 50000000 (gap: 40000000:bec00000)
[    0.000000] SMP: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] PERCPU: Allocating 36480 bytes of per cpu data
[    0.000000] Built 1 zonelists.  Total pages: 257582
[    0.000000] Kernel command line: root=/dev/mapper/uganda-root ro idle=poll
[    0.000000] using polling idle threads.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[   14.727825] time.c: Detected 2210.086 MHz processor.
[   14.732799] Console: colour VGA+ 80x25
[   14.736484] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[   14.737520] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[   14.737705] Checking aperture...
[   14.737756] CPU 0: aperture @ e8000000 size 128 MB
[   14.747216] Memory: 1017920k/1048512k available (1824k kernel code, 30204k reserved, 829k data, 280k init)
[   14.825760] Calibrating delay using timer specific routine.. 4422.90 BogoMIPS (lpj=8845806)
[   14.826180] Mount-cache hash table entries: 256
[   14.826595] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
[   14.826653] CPU: L2 Cache: 512K (64 bytes/line)
[   14.826706] CPU 0/0 -> Node 0
[   14.826770] SMP alternatives: switching to UP code
[   14.826948] Freeing SMP alternatives: 24k freed
[   14.827009] ACPI: Core revision 20070126
[   15.233589] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
[   16.133751] Using local APIC timer interrupts.
[   16.179018] result 12557308
[   16.179068] Detected 12.557 MHz APIC timer.
[   16.180933] Brought up 1 CPUs
[   16.181012] testing NMI watchdog ... OK.
[   16.221513] NET: Registered protocol family 16
[   16.221781] ACPI: bus type pci registered
[   16.221839] PCI: Using configuration type 1
[   16.231013] ACPI: Interpreter enabled
[   16.231068] ACPI: (supports S0 S1 S4 S5)
[   16.231298] ACPI: Using IOAPIC for interrupt routing
[   16.249674] ACPI: PCI Root Bridge [PCI0] (0000:00)
[   16.249734] PCI: Probing PCI hardware (bus 00)
[   16.250331] Boot video device is 0000:01:00.0
[   16.250518] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[   16.250825] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
[   16.251494] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGPB._PRT]
[   16.321783] ACPI: PCI Interrupt Link [LNK1] (IRQs *3 4 5 6 7 10 11 12 14 15)
[   16.322391] ACPI: PCI Interrupt Link [LNK2] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.323069] ACPI: PCI Interrupt Link [LNK3] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.323742] ACPI: PCI Interrupt Link [LNK4] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.324423] ACPI: PCI Interrupt Link [LNK5] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[   16.325037] ACPI: PCI Interrupt Link [LUBA] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[   16.325640] ACPI: PCI Interrupt Link [LUBB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[   16.326239] ACPI: PCI Interrupt Link [LMAC] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.326912] ACPI: PCI Interrupt Link [LAPU] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.327590] ACPI: PCI Interrupt Link [LACI] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[   16.328190] ACPI: PCI Interrupt Link [LMCI] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.328876] ACPI: PCI Interrupt Link [LSMB] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[   16.329483] ACPI: PCI Interrupt Link [LUB2] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[   16.330082] ACPI: PCI Interrupt Link [LFIR] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.330755] ACPI: PCI Interrupt Link [L3CM] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.331429] ACPI: PCI Interrupt Link [LIDE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   16.332116] ACPI: PCI Interrupt Link [LSID] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[   16.332730] ACPI: PCI Interrupt Link [LFID] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[   16.333309] ACPI: PCI Interrupt Link [APC1] (IRQs *16)
[   16.333603] ACPI: PCI Interrupt Link [APC2] (IRQs *17), disabled.
[   16.333933] ACPI: PCI Interrupt Link [APC3] (IRQs *18), disabled.
[   16.334262] ACPI: PCI Interrupt Link [APC4] (IRQs *19), disabled.
[   16.334586] ACPI: PCI Interrupt Link [APC5] (IRQs *16)
[   16.334978] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[   16.335483] ACPI: PCI Interrupt Link [APCG] (IRQs 20 21 22 23) *0
[   16.335988] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0, disabled.
[   16.336523] ACPI: PCI Interrupt Link [APCI] (IRQs 20 21 22 23) *0, disabled.
[   16.337076] ACPI: PCI Interrupt Link [APCJ] (IRQs 20 21 22 23) *0
[   16.337583] ACPI: PCI Interrupt Link [APCK] (IRQs 20 21 22 23) *0, disabled.
[   16.338119] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[   16.338624] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[   16.339129] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0, disabled.
[   16.339666] ACPI: PCI Interrupt Link [AP3C] (IRQs 20 21 22 23) *0, disabled.
[   16.340202] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0, disabled.
[   16.340748] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[   16.341269] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[   16.341734] ACPI: Power Resource [ISAV] (on)
[   16.341803] Linux Plug and Play Support v0.97 (c) Adam Belay
[   16.341881] pnp: PnP ACPI init
[   16.341953] pnp: ACPI device : hid PNP0C02
[   16.342116] pnp: ACPI device : hid PNP0C01
[   16.342507] pnp: ACPI device : hid PNP0A03
[   16.344779] pnp: ACPI device : hid PNP0C02
[   16.344901] pnp: ACPI device : hid PNP0200
[   16.345011] pnp: ACPI device : hid PNP0B00
[   16.345125] pnp: ACPI device : hid PNP0800
[   16.345241] pnp: ACPI device : hid PNP0C04
[   16.345515] pnp: ACPI device : hid PNP0700
[   16.345981] pnp: ACPI device : hid PNP0501
[   16.346964] pnp: ACPI device : hid PNP0400
[   16.347704] pnp: ACPI device : hid PNP0F13
[   16.347945] pnp: ACPI device : hid PNP0303
[   16.348122] pnp: PnP ACPI: found 13 devices
[   16.348345] usbcore: registered new interface driver usbfs
[   16.348496] usbcore: registered new interface driver hub
[   16.348644] usbcore: registered new device driver usb
[   16.348764] PCI: Using ACPI for IRQ routing
[   16.348819] PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
[   16.348899] PCI: Cannot allocate resource region 0 of device 0000:00:00.0
[   16.349111] agpgart: Detected AGP bridge 0
[   16.349166] agpgart: Setting up Nforce3 AGP.
[   16.352775] agpgart: AGP aperture is 128M @ 0xe8000000
[   16.352872] pnp: the driver 'system' has been registered
[   16.352956] pnp: match found with the PnP device '00:00' and the driver 'system'
[   16.352962] pnp: 00:00: ioport range 0x4000-0x407f has been reserved
[   16.353020] pnp: 00:00: ioport range 0x4080-0x40ff has been reserved
[   16.353078] pnp: 00:00: ioport range 0x4400-0x447f has been reserved
[   16.353134] pnp: 00:00: ioport range 0x4480-0x44ff has been reserved
[   16.353196] pnp: 00:00: ioport range 0x4800-0x487f has been reserved
[   16.353254] pnp: 00:00: ioport range 0x4880-0x48ff has been reserved
[   16.353314] pnp: match found with the PnP device '00:01' and the driver 'system'
[   16.353318] pnp: 00:01: iomem range 0xd5000-0xd7fff has been reserved
[   16.353376] pnp: 00:01: iomem range 0xf0000-0xf7fff could not be reserved
[   16.353434] pnp: 00:01: iomem range 0xf8000-0xfbfff could not be reserved
[   16.353492] pnp: 00:01: iomem range 0xfc000-0xfffff could not be reserved
[   16.353556] pnp: match found with the PnP device '00:03' and the driver 'system'
[   16.354392] PCI: Bridge: 0000:00:0b.0
[   16.354443]   IO window: disabled.
[   16.354495]   MEM window: f4000000-f5ffffff
[   16.354548]   PREFETCH window: f0000000-f3ffffff
[   16.354603] PCI: Bridge: 0000:00:0e.0
[   16.354654]   IO window: 9000-9fff
[   16.354705]   MEM window: f6000000-f7ffffff
[   16.354758]   PREFETCH window: 50000000-500fffff
[   16.354817] PCI: Setting latency timer of device 0000:00:0e.0 to 64
[   16.354973] NET: Registered protocol family 2
[   16.392796] IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
[   16.393320] TCP established hash table entries: 131072 (order: 9, 3145728 bytes)
[   16.395359] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[   16.396005] TCP: Hash tables configured (established 131072 bind 65536)
[   16.396064] TCP reno registered
[   16.405349] checking if image is initramfs... it is
[   17.388326] Freeing initrd memory: 10736k freed
[   17.395912] KEVENT: Added callbacks for type 8.
[   17.396154] KEVENT subsystem has been successfully registered.
[   17.396210] KEVENT: Added callbacks for type 2.
[   17.396303] KEVENT: Added callbacks for type 3.
[   17.396355] Kevent poll()/select() subsystem has been initialized.
[   17.396410] KEVENT: Added callbacks for type 0.
[   17.396462] KEVENT: Added callbacks for type 6.
[   17.396514] KEVENT: Added callbacks for type 7.
[   17.396567] KEVENT: Added callbacks for type 9.
[   17.396812] KEVENT: Added callbacks for type 5.
[   17.397384] io scheduler noop registered
[   17.397464] io scheduler anticipatory registered
[   17.402262] io scheduler deadline registered
[   17.402385] io scheduler cfq registered (default)
[   17.466236] Real Time Clock Driver v1.12ac
[   17.466504] Linux agpgart interface v0.102 (c) Dave Jones
[   17.466559] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
[   17.466818] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   17.467394] pnp: the driver 'serial' has been registered
[   17.467523] pnp: match found with the PnP device '00:09' and the driver 'serial'
[   17.467679] 00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   17.469763] RAMDISK driver initialized: 16 RAM disks of 65536K size 1024 blocksize
[   17.470201] pnp: the driver 'i8042 kbd' has been registered
[   17.470297] pnp: match found with the PnP device '00:0c' and the driver 'i8042 kbd'
[   17.470303] pnp: the driver 'i8042 aux' has been registered
[   17.470389] pnp: match found with the PnP device '00:0b' and the driver 'i8042 aux'
[   17.470396] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[   17.473025] serio: i8042 KBD port at 0x60,0x64 irq 1
[   17.473193] serio: i8042 AUX port at 0x60,0x64 irq 12
[   17.473528] mice: PS/2 mouse device common for all mice
[   17.473804] TCP cubic registered
[   17.473875] NET: Registered protocol family 1
[   17.473930] NET: Registered protocol family 17
[   17.474294] Freeing unused kernel memory: 280k freed
[   17.476018] Time: tsc clocksource has been installed.
[   17.515535] input: AT Translated Set 2 keyboard as /class/input/input0
[   17.858119] ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
[   17.858616] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[   17.858677] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] -> GSI 23 (level, high) -> IRQ 23
[   17.858826] PCI: Setting latency timer of device 0000:00:02.0 to 64
[   17.858829] ohci_hcd 0000:00:02.0: OHCI Host Controller
[   17.859006] ohci_hcd 0000:00:02.0: new USB bus registered, assigned bus number 1
[   17.859100] ohci_hcd 0000:00:02.0: irq 23, io mem 0xf8002000
[   17.920999] usb usb1: configuration #1 chosen from 1 choice
[   17.921121] hub 1-0:1.0: USB hub found
[   17.921184] hub 1-0:1.0: 4 ports detected
[   17.935079] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
[   17.935140] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[   18.028773] ACPI: PCI Interrupt Link [APCG] enabled at IRQ 22
[   18.028835] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCG] -> GSI 22 (level, high) -> IRQ 22
[   18.028985] PCI: Setting latency timer of device 0000:00:02.1 to 64
[   18.028988] ohci_hcd 0000:00:02.1: OHCI Host Controller
[   18.029386] ohci_hcd 0000:00:02.1: new USB bus registered, assigned bus number 2
[   18.029483] ohci_hcd 0000:00:02.1: irq 22, io mem 0xf8003000
[   18.089683] usb usb2: configuration #1 chosen from 1 choice
[   18.089801] hub 2-0:1.0: USB hub found
[   18.089862] hub 2-0:1.0: 4 ports detected
[   18.198211] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 21
[   18.198276] ACPI: PCI Interrupt 0000:00:02.2[C] -> Link [APCL] -> GSI 21 (level, high) -> IRQ 21
[   18.198424] PCI: Setting latency timer of device 0000:00:02.2 to 64
[   18.198427] ehci_hcd 0000:00:02.2: EHCI Host Controller
[   18.198563] ehci_hcd 0000:00:02.2: new USB bus registered, assigned bus number 3
[   18.198698] ehci_hcd 0000:00:02.2: debug port 1
[   18.198751] PCI: cache line size of 64 is not supported by device 0000:00:02.2
[   18.198763] ehci_hcd 0000:00:02.2: irq 21, io mem 0xf8004000
[   18.198820] ehci_hcd 0000:00:02.2: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[   18.199088] usb usb3: configuration #1 chosen from 1 choice
[   18.199206] hub 3-0:1.0: USB hub found
[   18.199267] hub 3-0:1.0: 8 ports detected
[   18.304779] NFORCE3-250: IDE controller at PCI slot 0000:00:08.0
[   18.304940] NFORCE3-250: chipset revision 162
[   18.304992] NFORCE3-250: not 100% native mode: will probe irqs later
[   18.305050] NFORCE3-250: BIOS didn't set cable bits correctly. Enabling workaround.
[   18.305124] NFORCE3-250: 0000:00:08.0 (rev a2) UDMA133 controller
[   18.305186]     ide0: BM-DMA at 0xf000-0xf007, BIOS settings: hda:DMA, hdb:DMA
[   18.305321]     ide1: BM-DMA at 0xf008-0xf00f, BIOS settings: hdc:DMA, hdd:DMA
[   18.305456] Probing IDE interface ide0...
[   18.323179] SCSI subsystem initialized
[   18.329510] libata version 2.10 loaded.
[   18.595212] hda: ST340016A, ATA DISK drive
[   18.879007] hdb: Maxtor 6E040L0, ATA DISK drive
[   18.939367] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   18.940186] Probing IDE interface ide1...
[   19.510898] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[   19.511222] ACPI: PCI Interrupt Link [APC5] enabled at IRQ 16
[   19.511281] ACPI: PCI Interrupt 0000:02:0d.0[A] -> Link [APC5] -> GSI 16 (level, low) -> IRQ 16
[   19.511905] eth0: RTL8169s/8110s at 0xffffc20000016000, 00:11:09:61:eb:0e, IRQ 16
[   19.515217] sata_nv 0000:00:09.0: version 3.3
[   19.515724] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 20
[   19.515781] ACPI: PCI Interrupt 0000:00:09.0[A] -> Link [APSI] -> GSI 20 (level, high) -> IRQ 20
[   19.515932] PCI: Setting latency timer of device 0000:00:09.0 to 64
[   19.516072] ata1: SATA max UDMA/133 cmd 0x00000000000109e0 ctl 0x0000000000010be2 bmdma 0x000000000001c800 irq 20
[   19.516234] ata2: SATA max UDMA/133 cmd 0x0000000000010960 ctl 0x0000000000010b62 bmdma 0x000000000001c808 irq 20
[   19.516323] scsi0 : sata_nv
[   19.830257] ata1: SATA link down (SStatus 0 SControl 300)
[   19.830325] scsi1 : sata_nv
[   20.361888] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[   20.392535] ata2.00: ATA-6: ST3120026AS, 3.05, max UDMA/133
[   20.392591] ata2.00: 234441648 sectors, multi 1: LBA48 
[   20.424589] ata2.00: configured for UDMA/133
[   20.424793] scsi 1:0:0:0: Direct-Access     ATA      ST3120026AS      3.05 PQ: 0 ANSI: 5
[   20.426132] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 23
[   20.426188] ACPI: PCI Interrupt 0000:00:0a.0[A] -> Link [APSJ] -> GSI 23 (level, high) -> IRQ 23
[   20.426347] PCI: Setting latency timer of device 0000:00:0a.0 to 64
[   20.426457] ata3: SATA max UDMA/133 cmd 0x00000000000109f0 ctl 0x0000000000010bf2 bmdma 0x000000000001e000 irq 23
[   20.426625] ata4: SATA max UDMA/133 cmd 0x0000000000010970 ctl 0x0000000000010b72 bmdma 0x000000000001e008 irq 23
[   20.426709] scsi2 : sata_nv
[   20.741602] ata3: SATA link down (SStatus 0 SControl 300)
[   20.741661] scsi3 : sata_nv
[   21.057374] ata4: SATA link down (SStatus 0 SControl 300)
[   21.068785] hda: max request size: 128KiB
[   21.078573] hda: 78165360 sectors (40020 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(100)
[   21.078767] hda: cache flushes not supported
[   21.078909]  hda:<5>SCSI device sda: 234441648 512-byte hdwr sectors (120034 MB)
[   21.079769] sda: Write Protect is off
[   21.079820] sda: Mode Sense: 00 3a 00 00
[   21.079844] SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   21.079992] SCSI device sda: 234441648 512-byte hdwr sectors (120034 MB)
[   21.080059] sda: Write Protect is off
[   21.080110] sda: Mode Sense: 00 3a 00 00
[   21.080133] SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   21.080240]  sda: sda1 sda2 < sda5 >
[   21.096375] sd 1:0:0:0: Attached scsi disk sda
[   21.097068]  hda1 hda2 hda3 hda4 < hda5 hda6 hda7 hda8 hda9 hda10 >
[   21.167060] hdb: max request size: 128KiB
[   21.170201] hdb: 80293248 sectors (41110 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(133)
[   21.170485] hdb: cache flushes supported
[   21.170611]  hdb: hdb1 < hdb5 hdb6 >
[   21.852968] Probing IDE interface ide1...
[   22.522187] device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
[   23.148782] kjournald starting.  Commit interval 5 seconds
[   23.148850] EXT3-fs: mounted filesystem with ordered data mode.
[   25.145115] i2c_adapter i2c-0: nForce2 SMBus adapter at 0x4c00
[   25.145244] i2c_adapter i2c-1: nForce2 SMBus adapter at 0x4c40
[   25.209108] ACPI: PCI Interrupt Link [APCJ] enabled at IRQ 22
[   25.209168] ACPI: PCI Interrupt 0000:00:06.0[A] -> Link [APCJ] -> GSI 22 (level, high) -> IRQ 22
[   25.209324] PCI: Setting latency timer of device 0000:00:06.0 to 64
[   25.513961] input: ImExPS/2 Generic Explorer Mouse as /class/input/input1
[   25.534205] intel8x0_measure_ac97_clock: measured 58518 usecs
[   25.534264] intel8x0: clocking to 46945
[   25.920831] EXT3 FS on dm-0, internal journal
[   26.796050] loop: loaded (max 8 devices)
[   34.998273] kjournald starting.  Commit interval 5 seconds
[   34.998593] EXT3 FS on sda1, internal journal
[   34.998677] EXT3-fs: mounted filesystem with ordered data mode.
[   35.025366] kjournald starting.  Commit interval 5 seconds
[   35.025761] EXT3 FS on dm-5, internal journal
[   35.025844] EXT3-fs: mounted filesystem with ordered data mode.
[   35.046464] kjournald starting.  Commit interval 5 seconds
[   35.046859] EXT3 FS on dm-4, internal journal
[   35.046943] EXT3-fs: mounted filesystem with ordered data mode.
[   35.064748] kjournald starting.  Commit interval 5 seconds
[   35.065096] EXT3 FS on dm-1, internal journal
[   35.065180] EXT3-fs: mounted filesystem with ordered data mode.
[   35.086883] kjournald starting.  Commit interval 5 seconds
[   35.087202] EXT3 FS on dm-2, internal journal
[   35.087285] EXT3-fs: mounted filesystem with ordered data mode.
[   35.113017] Adding 3084280k swap on /dev/mapper/uganda-swap_1.  Priority:-1 extents:1 across:3084280k
[   36.065137] r8169: eth0: link up
[   36.957758] input: Power Button (FF) as /class/input/input2
[   36.967303] ACPI: Power Button (FF) [PWRF]
[   36.972128] input: Power Button (CM) as /class/input/input3
[   36.981319] ACPI: Power Button (CM) [PWRB]
[   80.633043] bhtest: module license 'unspecified' taints kernel.
[   80.633967] bhtest_init: skb: ffff8100375c9bf8.
[   80.634023] kfree debug: obj: ffff8100375c9bf8, likely you want to use something with 'skbuff_head_cache' in name instead of kfree().
[   80.634105] bhtest_init: data: ffff81003b0bca60.

--UlVJffcvxoiEqYs2--
