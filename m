From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: Octeon crash in virt_to_page(&core0_stack_variable)
Date: Fri, 9 Sep 2011 16:23:28 +0300
Message-ID: <201109091623.29000.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary-00=_QNhaO/I996LuNwl"
Cc: <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_QNhaO/I996LuNwl
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hello,

I've been investigating a strange crash and I wanted to ask for your help.
The crash happens when virt_to_page is called with an address from the soft=
irq=20
stack of core 0 on Cavium Octeon. It may happen on other MIPS processors as=
=20
well, but I'm not sure.

I've attached a simple kernel module to demonstrate the problem and the out=
put=20
of dmesg + the crash. Two seconds after inserting the module, the kernel=20
should crash.

=46rom what I've dug up in the kernel sources, it seems the stack for the f=
irst=20
idle task resides in the data segment (mapped in kseg2) while the rest are=
=20
allocated with kmalloc in __cpu_up() and reside in a different area (CAC_BA=
SE=20
upwards).
It seems virt_to_phys produces bogus results for kseg2 and after that,=20
virt_to_page crashes trying to access invalid memory.

This problem was discovered when doing BGP traffic with the TCP MD5 option=
=20
activated, where the following call chain caused a crash:

 * tcp_v4_rcv
 *  tcp_v4_timewait_ack
 *   tcp_v4_send_ack -> follow stack variable rep.th
 *    tcp_v4_md5_hash_hdr
 *     tcp_md5_hash_header
 *      sg_init_one
 *       sg_set_buf
 *        virt_to_page

I noticed that tcp_v4_send_reset uses a similar stack variable and also cal=
ls=20
tcp_v4_md5_hash_hdr, so it has the same problem.

I don't fully understand octeon mm details, so I wanted to bring up this is=
sue=20
in order to find a proper fix.
To avoid the problem, I've implemented a quick hack to declare those variab=
les=20
percpu instead of on the stack, so they would also reside in CAC_BASE upwar=
ds.=20
I've attached a patch against 2.6.32 for reference.

Cosmin.

--Boundary-00=_QNhaO/I996LuNwl
Content-Type: text/x-log; charset="UTF-8"; name="dmesg.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="dmesg.log"

[    0.000/0] Linux version 2.6.32 (IxOS linux_2.6.32/main/6.20.0.298)  (ixsdk@ixca-cm-vmbld72) (gcc version 4.3.3 (Cavium Networks Version: 2_0_0 build 95) ) #1 SMP Wed Aug 24 09:26:59 PDT 2011
[    0.000/0] boot_desc_ptr 800000000fde4300 bootinfo 800000000fde5c00 phy_mem_desc_addr 24108
[    0.000/0] Ixia kernel instance 0, cores_per_instance 12, port_type 161 
[    0.000/0] CVMSEG size: 2 cache lines (256 bytes)
[    0.000/0] ixia_uart: configured at 800000000ffa9000
[    0.000/0] bootconsole [early0] enabled
[    0.000/0] CPU revision is: 000d0409 (Cavium Octeon+)
[    0.000/0] Checking for the multiply/shift bug... no.
[    0.000/0] Checking for the daddiu bug... no.
[    0.000/0] Found named block linmem0.0 @ 0x3000000, size= 0xb000000
[    0.000/0] Found named block linmem0.1 @ 0x410000000, size= 0x10000000
[    0.000/0] Found named block linmem0.2 @ 0x20000000, size= 0x20000000
[    0.000/0] Found named block linmem0.3 @ 0x40000000, size= 0xc0000000
[    0.000/0] Scan_named_regions complete
[    0.000/0] Determined physical RAM map:
[    0.000/0]  memory: 00000000008dd000 @ 00000000013f3000 (usable after init)
[    0.000/0]  memory: 000000000b000000 @ 0000000003000000 (usable)
[    0.000/0]  memory: 0000000010000000 @ 0000000410000000 (usable)
[    0.000/0]  memory: 00000000e0000000 @ 0000000020000000 (usable)
[    0.000/0] Wasting 285992 bytes for tracking 5107 unused pages
[    0.000/0] Initrd not found or empty - disabling initrd
[    0.000/0] Zone PFN ranges:
[    0.000/0]   Normal   0x000013f3 -> 0x00420000
[    0.000/0] Movable zone start PFN for each node
[    0.000/0] early_node_map[4] active PFN ranges
[    0.000/0]     0: 0x000013f3 -> 0x00001cd0
[    0.000/0]     0: 0x00003000 -> 0x0000e000
[    0.000/0]     0: 0x00020000 -> 0x00100000
[    0.000/0]     0: 0x00410000 -> 0x00420000
[    0.000/0] On node 0 totalpages: 1030365
[    0.000/0]   Normal zone: 59067 pages used for memmap
[    0.000/0]   Normal zone: 0 pages reserved
[    0.000/0]   Normal zone: 971298 pages, LIFO batch:31
[    0.000/0] Failed to allocate memory for Hotplug memory block
[    0.000/0] PERCPU: Embedded 10 pages/cpu @a8000000068a0000 s10624 r8192 d22144 u65536
[    0.000/0] pcpu-alloc: s10624 r8192 d22144 u65536 alloc=16*4096
[    0.000/0] pcpu-alloc: [0] 00 [0] 01 [0] 02 [0] 03 [0] 04 [0] 05 [0] 06 [0] 07 
[    0.000/0] pcpu-alloc: [0] 08 [0] 09 [0] 10 [0] 11 
[    0.000/0] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 971298
[    0.000/0] Kernel command line:  console=ttyS0,115200
[    0.000/0] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000/0] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000/0] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000/0] Primary instruction cache 32kB, virtually tagged, 4 way, 64 sets, linesize 128 bytes.
[    0.000/0] Primary data cache 16kB, 64-way, 2 sets, linesize 128 bytes.
[    0.000/0] Memory: 4047476k/4121460k available (2975k kernel code, 73196k reserved, 1067k data, 9076k init, 0k highmem)
[    0.000/0] Hierarchical RCU implementation.
[    0.000/0] NR_IRQS:408
[    0.000/0] console [ttyS0] enabled, bootconsole disabled
[ 1951.025/0] Calibrating delay loop (skipped) preset value.. 1200.00 BogoMIPS (lpj=600000)
[ 1951.026/0] Mount-cache hash table entries: 256
[ 1951.026/0] Checking for the daddi bug... no.
[ 1951.027/0] SMP: Booting CPU01 (CoreId  1)...
[ 1951.027/1] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.027/0] SMP: Booting CPU02 (CoreId  2)...
[ 1951.027/2] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.028/0] SMP: Booting CPU03 (CoreId  3)...
[ 1951.028/3] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.028/0] SMP: Booting CPU04 (CoreId  4)...
[ 1951.028/4] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.029/0] SMP: Booting CPU05 (CoreId  5)...
[ 1951.029/5] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.030/0] SMP: Booting CPU06 (CoreId  6)...
[ 1951.030/6] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.030/0] SMP: Booting CPU07 (CoreId  7)...
[ 1951.030/7] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.031/0] SMP: Booting CPU08 (CoreId  8)...
[ 1951.031/8] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.031/0] SMP: Booting CPU09 (CoreId  9)...
[ 1951.031/9] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.032/0] SMP: Booting CPU10 (CoreId 10)...
[ 1951.032/a] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.033/0] SMP: Booting CPU11 (CoreId 11)...
[ 1951.033/b] CPU revision is: 000d0409 (Cavium Octeon+)
[ 1951.033/0] Brought up 12 CPUs
[ 1951.033/0] CPU0 attaching sched-domain:
[ 1951.033/0]  domain 0: span 0-11 level CPU
[ 1951.033/0]   groups: 0 1 2 3 4 5 6 7 8 9 10 11
[ 1951.033/0] CPU1 attaching sched-domain:
[ 1951.033/0]  domain 0: span 0-11 level CPU
[ 1951.033/0]   groups: 1 2 3 4 5 6 7 8 9 10 11 0
[ 1951.033/0] CPU2 attaching sched-domain:
[ 1951.033/0]  domain 0: span 0-11 level CPU
[ 1951.033/0]   groups: 2 3 4 5 6 7 8 9 10 11 0 1
[ 1951.033/0] CPU3 attaching sched-domain:
[ 1951.033/0]  domain 0: span 0-11 level CPU
[ 1951.033/0]   groups: 3 4 5 6 7 8 9 10 11 0 1 2
[ 1951.033/0] CPU4 attaching sched-domain:
[ 1951.033/0]  domain 0: span 0-11 level CPU
[ 1951.033/0]   groups: 4 5 6 7 8 9 10 11 0 1 2 3
[ 1951.033/0] CPU5 attaching sched-domain:
[ 1951.033/0]  domain 0: span 0-11 level CPU
[ 1951.033/0]   groups: 5 6 7 8 9 10 11 0 1 2 3 4
[ 1951.033/0] CPU6 attaching sched-domain:
[ 1951.033/0]  domain 0: span 0-11 level CPU
[ 1951.033/0]   groups: 6 7 8 9 10 11 0 1 2 3 4 5
[ 1951.033/0] CPU7 attaching sched-domain:
[ 1951.033/0]  domain 0: span 0-11 level CPU
[ 1951.033/0]   groups: 7 8 9 10 11 0 1 2 3 4 5 6
[ 1951.034/0] CPU8 attaching sched-domain:
[ 1951.034/0]  domain 0: span 0-11 level CPU
[ 1951.034/0]   groups: 8 9 10 11 0 1 2 3 4 5 6 7
[ 1951.034/0] CPU9 attaching sched-domain:
[ 1951.034/0]  domain 0: span 0-11 level CPU
[ 1951.034/0]   groups: 9 10 11 0 1 2 3 4 5 6 7 8
[ 1951.034/0] CPU10 attaching sched-domain:
[ 1951.034/0]  domain 0: span 0-11 level CPU
[ 1951.034/0]   groups: 10 11 0 1 2 3 4 5 6 7 8 9
[ 1951.034/0] CPU11 attaching sched-domain:
[ 1951.034/0]  domain 0: span 0-11 level CPU
[ 1951.034/0]   groups: 11 0 1 2 3 4 5 6 7 8 9 10
[ 1951.039/0] NET: Registered protocol family 16
[ 1951.039/0] bio: create slab <bio-0> at 0
[ 1951.041/0] SCSI subsystem initialized
[ 1951.041/0] Switching to clocksource OCTEON_CVMCOUNT
[ 1951.043/8] [multinic] Initializing ...
[ 1951.043/8] NET: Registered protocol family 2
[ 1951.044/8] IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
[ 1951.045/8] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[ 1951.051/8] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[ 1951.052/8] TCP portaddr_bind hash table entries: 65536 (order: 8, 1048576 bytes)
[ 1951.053/8] TCP listening hash table entries: 65536 (order: 8, 1048576 bytes)
[ 1951.055/8] TCP: Hash tables configured (established 262144 bind 65536 listening 65536)
[ 1951.055/8] TCP reno registered
[ 1951.056/8] NET: Registered protocol family 1
[ 1951.057/8] RPC: Registered udp transport module.
[ 1951.057/8] RPC: Registered tcp transport module.
[ 1951.058/8] RPC: Registered tcp NFSv4.1 backchannel transport module.
[ 1952.710/8] /proc/octeon_perf: Octeon performace counter interface loaded
[ 1952.713/8] msgmni has been set to 7906
[ 1952.715/1] alg: No test for stdrng (krng)
[ 1952.715/8] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
[ 1952.715/8] io scheduler noop registered
[ 1952.715/8] io scheduler anticipatory registered
[ 1952.715/8] io scheduler deadline registered
[ 1952.716/8] io scheduler cfq registered (default)
[ 1952.720/8] Ixia Backplane UART version 0.01
[ 1952.720/8] Fixed MDIO Bus: probed
[ 1952.720/8] oprofile: using mips/octeon performance monitoring.
[ 1952.720/8] NET: Registered protocol family 26
[ 1952.722/8] [ixroute] Initialized.
[ 1952.722/8] TCP cubic registered
[ 1952.723/8] NET: Registered protocol family 10
[ 1952.742/8] [ixroute6] Initialized.
[ 1952.742/8] IPv6 over IPv4 tunneling driver
[ 1952.742/8] NET: Registered protocol family 17
[ 1952.743/8] L2 lock: TLB refill 256 bytes
[ 1952.743/8] L2 lock: General exception 128 bytes
[ 1952.743/8] L2 lock: low-level interrupt 128 bytes
[ 1952.743/8] L2 lock: interrupt 640 bytes
[ 1952.743/8] L2 lock: memcpy 1152 bytes
[ 1952.749/8] Freeing unused kernel memory: 9076k freed
[ 1953.050/8] ixsysctl: module license 'Copyright 2002, Ixia Communications; all rights reserved' taints kernel.
[ 1953.050/8] Disabling lock debugging due to kernel taint
[ 1953.051/8] ixsysctl: ixsysctl_init: Ixia System Control Utility Module Aug 25 2011 19:38:20
[ 1953.090/a] ixllm: init_module: Ixia Link Layer Manager Aug 25 2011 19:37:57
[ 1953.126/7] pcie: TX FPGA Version 0x1107
[ 1953.126/7] pcie: RX FPGA Version 0x10e5
[ 1953.132/8] octeon_msi_irq_dispatcher_init, kernel instance 0
[ 1953.132/8] ixia_irq_msi_dispatcher_init
[ 1953.195/2] cavium-ethernet: Cavium Networks Octeon SDK version 2.0.0-p4, build 373
[ 1953.195/2] Driver compiled with: USE_NAMEDBLOCK_FOR_FPA 
[ 1953.195/2] cavium-ethernet: Using dev: ixint0 as Ixia root dev
[ 1953.195/2] everest_hw_init: kernel instance 0, cores_per_os: 12
[ 1953.195/2] octeon_ethernet.ko: Enable TX 1588
[ 1953.195/2] octeon_ethernet.ko: Enable RX 1588
[ 1953.196/2] nb name: ixia-platform-control-block size: 0x10000 addr: 0xfe15000
[ 1953.196/2] >> Core 2 coremask: fff
[ 1953.196/2] cvm_eth_instance_count_add Instance count: 1
[ 1953.196/2] >> Instance 0 mac_offset: 1 fau_offset: 2044 group: 0
[ 1953.196/2] Reclaimed 0 WQE and 0 FPA entries from POW
[ 1953.196/2] fpa 0: que-available: 1fb0
[ 1953.196/2] fpa 1: que-available: 1fc0
[ 1953.196/2] fpa 2: que-available: 53
[ 1953.196/2] cvm_oct_configure_common_hw: group 0
[ 1953.196/2] cvm_eth_get_interfaces_of_interest Adding interface 0 of type 5
[ 1953.196/2] Interface 0 has 1 ports (XAUI)
[ 1953.196/2] Interface 1 has 1 ports (XAUI)
[ 1953.196/2] cvmx_helper_interface_probe_mi: Not probing Interface type 8
[ 1953.196/2] cvmx_helper_interface_probe_mi: Not probing Interface type 9
[ 1953.196/2] Checking port 0, max_port: 0 num_ports: 1
[ 1953.196/2] ixia_probe_hw
[ 1953.196/2] Bringing up device ixint0 (i/f: 0 port: 0)
[ 1953.196/2] priv->tx_port 0 priv->tx_queue 0
[ 1953.196/2] cvm_oct_init_module dev->mtu: 14000
[ 1953.196/2] cvm_oct_rx_initialize: max_rx_cpus=12
[ 1953.196/2] IRQ request for 24 succeeded
[ 1953.196/2] MSI Enable for msi_num 4 is location 0x80011f000000bc50 value 0x10
[ 1953.282/3] Basic DMA tests passed
[ 1953.301/4] IXHOST mcb->dwBootRamBase = 0x800000000ffe9000
[ 1953.301/4] CPU Frequency: 600 MHz
[ 1953.302/4] ADVERTISED FLAG = 0x0000000000008f8f
[ 1953.302/4] dma_xmit_open: dma_idx: 0, tx_fifo_base: 0x8000c00000000000  
[ 1953.302/4] MSI Enable for msi_num 0 is location 0x80011f000000bc50 value 0x11
[ 1953.302/4] CIU_INT0_EN0 = 0x10300000001
[ 1953.302/4] ixhostm: MessageQueueInit success
[ 1953.302/4] Virtual queue base =  0x800000000fb20000
[ 1953.302/4] Base physical = 0xfb20000
[ 1953.302/4] OS instance  = 0
[ 1953.302/4] Virtual chassis card map base = 0x800000000fbb0000
[ 1953.302/4] Virtual P2P rx_que_base = 0x800000000fb20000
[ 1953.302/4] [2 s. 276082 us] p2p_message_queue_init success
[ 1953.302/4] IXHOST ver 3.0.0
[ 1953.322/7] hwstate: timestamp test passed
[ 1953.617/2] [multinic] operation: +
[ 1953.617/2] [multinic] device: ixint0
[ 1953.617/2] [multinic] id: 0
[ 1996.813/0] [1315571465 s. 798972 us] Refreshing topology Chassis X2 ...
[ 1996.813/0]   ---- Slot= 1 PortType=161 PortMap=0x0000ffff
[ 1996.814/0]   ---- Slot= 2 PortType= 83 PortMap=0x000000ff
[ 2038.300/0] vcrash initializing
[ 2040.299/8] core 8: &x a80000041f98fbd0 virt_to_phys(&x) 41f98fbd0
[ 2040.299/b] core 11: &x a80000041fa0bbd0 virt_to_phys(&x) 41fa0bbd0
[ 2040.299/a] core 10: &x a80000041f9cbbd0 virt_to_phys(&x) 41f9cbbd0
[ 2040.299/1] core 1: &x a80000041f87bbd0 virt_to_phys(&x) 41f87bbd0
[ 2040.299/2] core 2: &x a80000041f8bbbd0 virt_to_phys(&x) 41f8bbbd0
[ 2040.299/3] core 3: &x a80000041f8d7bd0 virt_to_phys(&x) 41f8d7bd0
[ 2040.299/5] core 5: &x a80000041f917bd0 virt_to_phys(&x) 41f917bd0
[ 2040.299/4] core 4: &x a80000041f8f7bd0 virt_to_phys(&x) 41f8f7bd0
[ 2040.299/0] core 0: &x ffffffffc03a3b70 virt_to_phys(&x) 57ffffffc03a3b70
[ 2040.299/b] core 11: virt_to_page(&x) a800000006870268
[ 2040.299/6] core 6: &x a80000041f953bd0 virt_to_phys(&x) 41f953bd0
[ 2040.299/9] core 9: &x a80000041f9afbd0 virt_to_phys(&x) 41f9afbd0
[ 2040.299/7] core 7: &x a80000041f96fbd0 virt_to_phys(&x) 41f96fbd0
[ 2040.299/a] core 10: virt_to_page(&x) a80000000686f468
[ 2040.299/1] core 1: virt_to_page(&x) a80000000686aae8
[ 2040.299/2] core 2: virt_to_page(&x) a80000000686b8e8
[ 2040.299/3] core 3: virt_to_page(&x) a80000000686bf08
[ 2040.299/5] core 5: virt_to_page(&x) a80000000686cd08
[ 2040.299/4] core 4: virt_to_page(&x) a80000000686c608
[ 2040.299/0] CPU 0 Unable to handle kernel paging request at virtual address 00000057c0d14640, epc == ffffffffc123a054, ra == ffffffffc123a030
[ 2040.299/6] core 6: virt_to_page(&x) a80000000686da28
[ 2040.299/9] core 9: virt_to_page(&x) a80000000686ee48
[ 2040.299/7] core 7: virt_to_page(&x) a80000000686e048
[ 2040.299/0] die: oom_log() temporarily disabled on this architecture
[ 2040.299/0] Oops[#1]:
[ 2040.299/0] Cpu 0
[ 2040.299/0] $ 0   : 0000000000000000 0000000000000000 00000057c0d14640 00000057ffffffc0
[ 2040.299/0] $ 4   : ffffffffc1240000 ffffffffc0ce0000 0000000000000000 0000000000020000
[ 2040.299/0] $ 8   : ffffffffc0ce0000 ffffffffffffffff fffffffffffffffb 0000000000000010
[ 2040.299/0] $12   : 0000000000000020 00000000000186a0 0000000000000009 0000000000000000
[ 2040.300/0] $16   : 0133ffffff20cba8 0000000000000100 ffffffffc123a000 ffffffffc0d0a220
[ 2040.300/0] $20   : ffffffffc0d09e20 ffffffffc0d09a20 ffffffffc0d09620 0000000000200200
[ 2040.300/0] $24   : 0000000000000002 ffffffffc000baa4                                  
[ 2040.300/0] $28   : ffffffffc03a0000 ffffffffc03a3b70 ffffffffc03a0000 ffffffffc123a030
[ 2040.300/0] Hi    : 00000000000b6854
[ 2040.300/0] Lo    : 000000000000012b
[ 2040.300/0] epc   : ffffffffc123a054 vcrash+0x54/0x80 [vcrash]
[ 2040.300/0]     Tainted: P          
[ 2040.300/0] ra    : ffffffffc123a030 vcrash+0x30/0x80 [vcrash]
[ 2040.300/0] Status: 1000cce3    KX SX UX KERNEL EXL IE 
[ 2040.300/0] Cause : 00800008
[ 2040.300/0] BadVA : 00000057c0d14640
[ 2040.300/0] PrId  : 000d0409 (Cavium Octeon+)
[ 2040.300/0] Modules linked in: vcrash ixvaluelist(P) ixgremod(P) ixunc(P) kseusrmgr(P) evfmanager(P) filtermanager hwstate ixhostm octeon_dma octeon_ethernet octeon_mdiobus ixnam_binstats(P) octeon_msi pcie ixllm ixsysctl(P) nlproc_driver
[ 2040.300/0] Process swapper (pid: 0, threadinfo=ffffffffc03a0000, task=ffffffffc03be580, tls=0000000000000000)
[ 2040.300/0] Stack : ffffffffc03a0000 ffffffffc03a4788 ffffffffc0d08600 ffffffffc0065f28
[ 2040.300/0]         ffffffffc03a3b90 ffffffffc03a3b90 0000000000000100 0000000000000001
[ 2040.300/0]         ffffffffc03a4788 0000000000000101 0000000000000008 ffffffffc0cc31b0
[ 2040.300/0]         000000000000000a 0000000000000000 ffffffffc0d07b80 ffffffffc00609e0
[ 2040.300/0]         0000000000000000 8001070000000000 8001070000000218 8001070000000200
[ 2040.300/0]         8001070000000108 ffffffffc0ce0000 0000000000010000 000000000fde4300
[ 2040.300/0]         ffffffffc03a0000 ffffffffc0060adc 0000000000000000 ffffffffc0060cb0
[ 2040.300/0]         0000000000000000 ffffffffc000ba7c a8000000068a0058 0000000000000000
[ 2040.300/0]         0000000000000001 ffffffffc0ce0000 ffffffffc0ce0000 000000000fdd0000
[ 2040.300/0]         0000000000000000 ffffffffc0000888 0000000000000000 0000000000000000
[ 2040.300/0]         ...
[ 2040.300/0] Call Trace:
[ 2040.300/0] [<ffffffffc123a054>] vcrash+0x54/0x80 [vcrash]
[ 2040.300/0] [<ffffffffc0065f28>] run_timer_softirq+0x198/0x23c
[ 2040.300/0] [<ffffffffc00609e0>] __do_softirq+0xd8/0x188
[ 2040.300/0] [<ffffffffc0060adc>] do_softirq+0x4c/0x6c
[ 2040.300/0] [<ffffffffc0060cb0>] irq_exit+0x48/0x8c
[ 2040.300/0] [<ffffffffc000ba7c>] plat_irq_dispatch+0x128/0x150
[ 2040.300/0] [<ffffffffc0000888>] ret_from_irq+0x0/0x4
[ 2040.300/0] [<ffffffffc0000a80>] r4k_wait+0x20/0x40
[ 2040.300/0] [<ffffffffc0033fe0>] cpu_idle+0x60/0x9c
[ 2040.300/0] [<ffffffffc03f3a9c>] start_kernel+0x3e8/0x404
[ 2040.300/0] 
[ 2040.300/0] 
[ 2040.300/0] Code: 64424680  0043102d  3c04c124 <dc460000> 2402fffc  8f850020  6484a2d8  00c23024  0c001c23 
[ 2040.300/0] Kernel panic - not syncing: Fatal exception in interrupt
[ 2040.300/0] Call Trace:
[ 2040.300/0] [<ffffffffc0006ef8>] dump_stack+0x8/0x34
[ 2040.300/0] [<ffffffffc0006fa0>] panic+0x7c/0x168
[ 2040.300/0] [<ffffffffc0036bd8>] die+0x114/0x11c
[ 2040.300/0] [<ffffffffc0041468>] do_page_fault+0x314/0x39c
[ 2040.300/0] [<ffffffffc0000880>] ret_from_exception+0x0/0x8
[ 2040.300/0] [<ffffffffc123a054>] vcrash+0x54/0x80 [vcrash]
[ 2040.300/0] [<ffffffffc0065f28>] run_timer_softirq+0x198/0x23c
[ 2040.300/0] [<ffffffffc00609e0>] __do_softirq+0xd8/0x188
[ 2040.300/0] [<ffffffffc0060adc>] do_softirq+0x4c/0x6c
[ 2040.300/0] [<ffffffffc0060cb0>] irq_exit+0x48/0x8c
[ 2040.300/0] [<ffffffffc000ba7c>] plat_irq_dispatch+0x128/0x150
[ 2040.300/0] [<ffffffffc0000888>] ret_from_irq+0x0/0x4
[ 2040.300/0] [<ffffffffc0000a80>] r4k_wait+0x20/0x40
[ 2040.300/0] [<ffffffffc0033fe0>] cpu_idle+0x60/0x9c
[ 2040.300/0] [<ffffffffc03f3a9c>] start_kernel+0x3e8/0x404
[ 2040.300/0] 
[ 2040.300/0] ixhost: ENABLE Tx message checksum
[ 2040.300/0] ixhost: DISABLE Rx message checksum
[ 2040.300/0] ixhost: ENABLE SGC Communication mode
[ 2040.300/0] ixhost: ENABLE Lcpu Interrupt Host
[ 2040.300/0] ixhost: ENABLE Host Interrupt Lcpu
[ 2040.300/0] ixhost: ENABLE 32-bit Pointer mode
[ 2040.300/0] ixhost: Advertised BCAST=0x0000 
[ 2040.300/0] TxFrameCount=      1097 TxByteCount=    129484
[ 2040.300/0] H/W TxFifoBase=0xa80000041e4dc000 TxFifoEnd=0xa80000041e4dfff0 TxFifoSize=0x3ff0
[ 2040.300/0]     RRN=0xa80000041e4dfff0 RRB=0xa80000041e4dfff8 TW=0xa80000041e4dfff4
[ 2040.301/0] 
[ 2040.301/0] H/W RxFifoBase=0x800000000ff29000 RxFifoEnd=0x800000000ff38ff8 RxFifoSize=0xfff8
[ 2040.301/0]     RW=0x800000000ff38ff8 TR=0x800000000ff38ffc
[ 2040.301/0] RxWrite=0x800000000ff38ff8 RxRead=0xa80000041e4dfff0 TxWrite=0xa80000041e4dfff4 TxRead=0x800000000ff38ffc
[ 2040.301/0] ImagTransmitBase=0xa80000041e4dc000 WritePos=0x3a3c ReadPos=0x3a3c00000000 PrevWrite=0xa80000041e4dfa00
[ 2040.301/0] Receive[normal]     
[ 2040.301/0]          WritePtr              : 0x800096ac0ff2ca3c
[ 2040.301/0]          ReadPtr               : 0x800000000ff326ac
[ 2040.301/0]          Advertised Read Ptr   : 0x000096ac
[ 2040.301/0]          PrevRead              : 0x800000000ff32674
[ 2040.301/0] Receive[broadcast] 
[ 2040.301/0]          WritePtr              : 0x800000000ff39000
[ 2040.301/0]          ReadPtr               : 0x800000000ff39000
[ 2040.301/0]          Advertised Read Ptr   : 0x00000000
[ 2040.301/0]          PrevRead              : 0x800000000ff39000
[ 2040.301/0] Octeon board_info
[ 2040.301/0] ----- head=19 tail=16 buffer:
[ 2040.301/0] pData = 0xa8000000018ca800 len = 64
[ 2040.301/0] (0xa8000000018ca800) 0x0000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
[ 2040.301/0] (0xa8000000018ca810) 0x0010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
[ 2040.301/0] (0xa8000000018ca820) 0x0020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
[ 2040.301/0] (0xa8000000018ca830) 0x0030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
[ 2040.301/0] 
[ 2040.301/0] p2h_fifo_len: 0000 p2p_fifo_len: 0000 
[ 2040.301/0] p2h_count: 25524, p2p_count: 0
[ 2040.301/0] fpa 0: que-available: 1fb0
[ 2040.301/0] fpa 1: que-available: 1fc0
[ 2040.301/0] fpa 2: que-available: 53
[ 2040.301/0] ixhost::panic_handler: setting kProcessorHalted bit
[ 2040.301/0] ixhost::panic_handler: done
[ 2041.634/0] Reclaimed 0 WQE and 0 FPA entries from POW



--Boundary-00=_QNhaO/I996LuNwl
Content-Type: text/x-csrc; charset="UTF-8"; name="vcrash.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="vcrash.c"

/*
 * A module that should crash the kernel on mips master core by using virt_to_page on a
 * softirq stack address.
 *
 * Cosmin Ratiu <cratiu@ixiacom.com>
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/cpu.h>
#include <linux/timer.h>
#include <linux/mm.h>

struct timer_list t[NR_CPUS];

void vcrash(unsigned long data)
{
	int x;

	printk("core %i: &x %p virt_to_phys(&x) %lx\n", smp_processor_id(), &x, virt_to_phys(&x));
	printk("core %i: virt_to_page(&x) %p\n", smp_processor_id(), virt_to_page(&x));
}

int vcrash_init(void)
{
	int cpu;

	printk("vcrash initializing\n");
	for_each_online_cpu(cpu) {
		init_timer(t + cpu);
		t[cpu].expires = jiffies + 2 * HZ;
		t[cpu].function = vcrash;
		add_timer_on(t + cpu, cpu);
	}

	return 0;
}

void vcrash_exit(void)
{
	int cpu;

	for_each_online_cpu(cpu) {
		del_timer_sync(t + cpu);
	}
	printk("vcrash exiting\n");
}

module_init(vcrash_init);
module_exit(vcrash_exit);

MODULE_AUTHOR("Cosmin Ratiu");
MODULE_LICENSE("GPL");

--Boundary-00=_QNhaO/I996LuNwl
Content-Type: text/x-patch; charset="UTF-8"; name="tcp-md5-crash.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="tcp-md5-crash.diff"

Change 3360379 by cratiu@cratiu on 2011/09/02 09:44:48 *pending*

	TCP/md5: Switch from a stack var to a percpu var to avoid a crash.
	
	tcp_v4_send_ack uses a stack variable to construct the TCP header for
	the response packet.
	When using TCP MD5 signatures on mips architecture a crash happens
	sometimes when the current core is the master core using the initial
	stack allocated in vmlinux.
	The reason for this is that the initial stack is mapped in kseg2
	so it can't be directly translated to a physical address by
	virt_to_phys as expected by sg_set_buf from the following call chain:
	
	> (optimized: sg_set_buf)
	> sg_init_one+0x58/0xa4
	> tcp_md5_hash_header+0x30/0x64
	> tcp_v4_md5_hash_hdr+0xb4/0x134
	> tcp_v4_send_ack+0x16c/0x25c
	> (optimized: tcp_v4_timewait_ack)
	> tcp_v4_rcv+0x1b3c/0x1e58
	
	As a temporary fix that should not affect performance, the stack
	variable is converted in a percpu variable allocated at boot time.

Affected files ...

... //packages/linux_2.6.32/main/src/include/net/tcp.h#6 edit
... //packages/linux_2.6.32/main/src/net/ipv4/tcp.c#11 edit
... //packages/linux_2.6.32/main/src/net/ipv4/tcp_ipv4.c#15 edit

 include/net/tcp.h   |   10 +++++++++
 net/ipv4/tcp.c      |    5 ++++
 net/ipv4/tcp_ipv4.c |   53 ++++++++++++++++++++++++----------------------------
 3 files changed, 40 insertions(+), 28 deletions(-)

Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
--- src/include/net/tcp.h~
+++ src/include/net/tcp.h
@@ -1570,5 +1570,15 @@
 	return skc->skc_net_params->tcp.rmem;
 }
 
+struct tcp_reply_hdr {
+	struct tcphdr th;
+	__be32 opt[(TCPOLEN_TSTAMP_ALIGNED >> 2)
+#ifdef CONFIG_TCP_MD5SIG
+		   + (TCPOLEN_MD5SIG_ALIGNED >> 2)
+#endif
+		];
+};
+
+extern struct tcp_reply_hdr *tcp_rep_percpu;
 
 #endif	/* _TCP_H */
--- src/net/ipv4/tcp.c~
+++ src/net/ipv4/tcp.c
@@ -3150,6 +3150,11 @@
 	       tcp_hashinfo.lhash_size);
 
 	tcp_register_congestion_control(&tcp_reno);
+
+	/* Hack alert: a proper fix should be implemented for the md5 crash */
+	tcp_rep_percpu = alloc_percpu(struct tcp_reply_hdr);
+	if (!tcp_rep_percpu)
+		panic("Cannot allocate per cpu tcp reply hdr\n");
 }
 
 EXPORT_SYMBOL(tcp_close);
--- src/net/ipv4/tcp_ipv4.c~
+++ src/net/ipv4/tcp_ipv4.c
@@ -680,6 +680,8 @@
 	SOCK_STAT_INC(groupptr, TcpRstSent, skb_get_portid(skb));
 }
 
+struct tcp_reply_hdr *tcp_rep_percpu;
+
 /* The code following below sending ACKs in SYN-RECV and TIME-WAIT states
    outside socket context is ugly, certainly. What can I do?
  */
@@ -691,53 +693,48 @@
 			    int reply_flags, u32 vlanprio)
 {
 	struct tcphdr *th = tcp_hdr(skb);
-	struct {
-		struct tcphdr th;
-		__be32 opt[(TCPOLEN_TSTAMP_ALIGNED >> 2)
-#ifdef CONFIG_TCP_MD5SIG
-			   + (TCPOLEN_MD5SIG_ALIGNED >> 2)
-#endif
-			];
-	} rep;
+	struct tcp_reply_hdr *rep;
 	struct ip_reply_arg arg;
 
-	memset(&rep.th, 0, sizeof(struct tcphdr));
+	rep = per_cpu_ptr(tcp_rep_percpu, get_cpu());
+
+	memset(&rep->th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));
 
-	arg.iov[0].iov_base = (unsigned char *)&rep;
-	arg.iov[0].iov_len  = sizeof(rep.th);
+	arg.iov[0].iov_base = (unsigned char *)rep;
+	arg.iov[0].iov_len  = sizeof(rep->th);
 	if (ts) {
-		rep.opt[0] = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
+		rep->opt[0] = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				   (TCPOPT_TIMESTAMP << 8) |
 				   TCPOLEN_TIMESTAMP);
-		rep.opt[1] = htonl(tcp_time_stamp);
-		rep.opt[2] = htonl(ts);
+		rep->opt[1] = htonl(tcp_time_stamp);
+		rep->opt[2] = htonl(ts);
 		arg.iov[0].iov_len += TCPOLEN_TSTAMP_ALIGNED;
 	}
 
 	/* Swap the send and the receive. */
-	rep.th.dest    = th->source;
-	rep.th.source  = th->dest;
-	rep.th.doff    = arg.iov[0].iov_len / 4;
-	rep.th.seq     = htonl(seq);
-	rep.th.ack_seq = htonl(ack);
-	rep.th.ack     = 1;
-	rep.th.window  = htons(win);
+	rep->th.dest    = th->source;
+	rep->th.source  = th->dest;
+	rep->th.doff    = arg.iov[0].iov_len / 4;
+	rep->th.seq     = htonl(seq);
+	rep->th.ack_seq = htonl(ack);
+	rep->th.ack     = 1;
+	rep->th.window  = htons(win);
 
 #ifdef CONFIG_TCP_MD5SIG
 	if (key) {
 		int offset = (ts) ? 3 : 0;
 
-		rep.opt[offset++] = htonl((TCPOPT_NOP << 24) |
-					  (TCPOPT_NOP << 16) |
-					  (TCPOPT_MD5SIG << 8) |
-					  TCPOLEN_MD5SIG);
+		rep->opt[offset++] = htonl((TCPOPT_NOP << 24) |
+					   (TCPOPT_NOP << 16) |
+					   (TCPOPT_MD5SIG << 8) |
+					   TCPOLEN_MD5SIG);
 		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
-		rep.th.doff = arg.iov[0].iov_len/4;
+		rep->th.doff = arg.iov[0].iov_len/4;
 
-		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[offset],
+		tcp_v4_md5_hash_hdr((__u8 *) &rep->opt[offset],
 				    key, ip_hdr(skb)->saddr,
-				    ip_hdr(skb)->daddr, &rep.th);
+				    ip_hdr(skb)->daddr, &rep->th);
 	}
 #endif
 	arg.flags = reply_flags;

--Boundary-00=_QNhaO/I996LuNwl--
