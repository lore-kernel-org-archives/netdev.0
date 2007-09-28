From: linux@horizon.com
Subject: 2.6.23-rc8 network problem.  Mem leak?  ip1000a?
Date: 27 Sep 2007 22:06:17 -0400
Message-ID: <20070928020617.7389.qmail@science.horizon.com>
Cc: linux@horizon.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:12804 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757568AbXI1CHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 22:07:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uniprocessor Althlon 64, 64-bit kernel, 2G ECC RAM,
2.6.23-rc8 + linuxpps (5.0.0) + ip1000a driver.
(patch from http://marc.info/?l=linux-netdev&m=118980588419882)

After a few hours of operation, ntp loses the ability to send packets.
sendto() returns -EAGAIN to everything, including the 24-byte UDP packet
that is a response to ntpq.

-EAGAIN on a sendto() makes me think of memory problems, so here's
meminfo at the time:

### FAILED state ###
# cat /proc/meminfo 
MemTotal:      2059384 kB
MemFree:         15332 kB
Buffers:        665608 kB
Cached:          18212 kB
SwapCached:          0 kB
Active:         380384 kB
Inactive:       355020 kB
SwapTotal:     5855208 kB
SwapFree:      5854552 kB
Dirty:           28504 kB
Writeback:           0 kB
AnonPages:       51608 kB
Mapped:          11852 kB
Slab:          1285348 kB
SReclaimable:   152968 kB
SUnreclaim:    1132380 kB
PageTables:       3888 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   6884900 kB
Committed_AS:   590528 kB
VmallocTotal: 34359738367 kB
VmallocUsed:    265628 kB
VmallocChunk: 34359472059 kB


Killing and restarting ntpd gets it running again for a few hours.
Here's after about two hours of successful operation.  (I'll try to
remember to run slabinfo before killing ntpd next time.)

### WORKING state ###
# cat /proc/meminfo
MemTotal:      2059384 kB
MemFree:         20252 kB
Buffers:        242688 kB
Cached:          41556 kB
SwapCached:        200 kB
Active:         285012 kB
Inactive:       147348 kB
SwapTotal:     5855208 kB
SwapFree:      5854212 kB
Dirty:              36 kB
Writeback:           0 kB
AnonPages:      148052 kB
Mapped:          12756 kB
Slab:          1582512 kB
SReclaimable:   134348 kB
SUnreclaim:    1448164 kB
PageTables:       4500 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   6884900 kB
Committed_AS:   689956 kB
VmallocTotal: 34359738367 kB
VmallocUsed:    265628 kB
VmallocChunk: 34359472059 kB
# /usr/src/linux/Documentation/vm/slabinfo
Name                   Objects Objsize    Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
:0000016                  1478      16    24.5K          6/3/1  256 0  50  96 *
:0000024                   170      24     4.0K          1/0/1  170 0   0  99 *
:0000032                  1339      32    45.0K         11/2/1  128 0  18  95 *
:0000040                   102      40     4.0K          1/0/1  102 0   0  99 *
:0000064                  5937      64   413.6K       101/15/1   64 0  14  91 *
:0000072                    56      72     4.0K          1/0/1   56 0   0  98 *
:0000088                  6946      88   618.4K        151/0/1   46 0   0  98 *
:0000096                 23851      96     2.5M      616/144/1   42 0  23  90 *
:0000128                   730     128   114.6K         28/6/1   32 0  21  81 *
:0000136                   232     136    36.8K          9/6/1   30 0  66  85 *
:0000192                   474     192    98.3K         24/4/1   21 0  16  92 *
:0000256               1385376     256   354.6M      86587/0/1   16 0   0  99 *
:0000320                    12     304     4.0K          1/0/1   12 0   0  89 *A
:0000384                   359     384   180.2K        44/23/1   10 0  52  76 *A
:0000512               1384316     512   708.7M     173040/1/1    8 0   0  99 *
:0000640                    72     616    53.2K         13/5/1    6 0  38  83 *A
:0000704                  1870     696     1.3M        170/0/1   11 1   0  93 *A
:0001024                   427    1024   454.6K        111/9/1    4 0   8  96 *
:0001472                   150    1472   245.7K         30/0/1    5 1   0  89 *
:0002048                158991    2048   325.7M     39759/25/1    4 1   0  99 *
:0004096                    51    4096   245.7K         30/9/1    2 1  30  85 *
Acpi-State                  51      80     4.0K          1/0/1   51 0   0  99 
anon_vma                  1032      16    28.6K          7/5/1  170 0  71  57 
bdev_cache                  43     720    36.8K          9/1/1    5 0  11  83 Aa
blkdev_requests             42     288    12.2K          3/0/1   14 0   0  98 
buffer_head              59173     104    11.1M    2734/1690/1   39 0  61  54 a
cfq_io_context             223     152    40.9K         10/6/1   26 0  60  82 
dentry                   98641     192    19.7M     4813/274/1   21 0   5  96 a
ext3_inode_cache        115690     688    86.3M     10545/77/1   11 1   0  92 a
file_lock_cache             23     168     4.0K          1/0/1   23 0   0  94 
idr_layer_cache            118     528    69.6K         17/1/1    7 0   5  89 
inode_cache               1365     528   798.7K        195/0/1    7 0   0  90 a
kmalloc-131072               1  131072   131.0K          1/0/1    1 5   0 100 
kmalloc-16384                8   16384   131.0K          8/0/1    1 2   0 100 
kmalloc-32768                1   32768    32.7K          1/0/1    1 3   0 100 
kmalloc-8                 1535       8    12.2K          3/1/1  512 0  33  99 
kmalloc-8192                10    8192    81.9K         10/0/1    1 1   0 100 
mm_struct                   54     800    57.3K          7/5/1    9 1  71  75 A
proc_inode_cache            12     560    16.3K          4/3/1    7 0  75  41 a
radix_tree_node          17076     552    13.5M    3319/1675/1    7 0  50  69 
raid5-md5                  258    1176   352.2K         43/0/1    6 1   0  86 
shmem_inode_cache           22     712    20.4K          5/1/1    5 0  20  76 
sighand_cache               88    2072   253.9K         31/3/1    3 1   9  71 A
signal_cache                88     720    77.8K         19/6/1    5 0  31  81 A
sigqueue                    25     160     4.0K          1/0/1   25 0   0  97 
skbuff_fclone_cache     158787     404    72.2M      17644/2/1    9 0   0  88 A
sock_inode_cache            65     600    53.2K         13/5/1    6 0  38  73 Aa
task_struct                145    1808   311.2K         38/6/1    4 1  15  84 
uhci_urb_priv               73      56     4.0K          1/0/1   73 0   0  99 
vm_area_struct            2947     168   540.6K       132/25/1   24 0  18  91 
### WORKING state ###


After quite a few hours (about 15h40m), it failed again.  I'm leaving it
in the failed state for now so I can answer questions.  ntpd is running and
receiving packets, it just can't send any.

### FAILED state ###
# cat /proc/meminfo
MemTotal:      2059384 kB
MemFree:         98556 kB
Buffers:          3224 kB
Cached:          18888 kB
SwapCached:       3876 kB
Active:          16688 kB
Inactive:        13068 kB
SwapTotal:     5855208 kB
SwapFree:      5822068 kB
Dirty:              32 kB
Writeback:           0 kB
AnonPages:        6960 kB
Mapped:           4752 kB
Slab:          1907828 kB
SReclaimable:     1916 kB
SUnreclaim:    1905912 kB
PageTables:       3888 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   6884900 kB
Committed_AS:   575652 kB
VmallocTotal: 34359738367 kB
VmallocUsed:    265628 kB
VmallocChunk: 34359472059 kB
# /usr/src/linux/Documentation/vm/slabinfo
Name                   Objects Objsize    Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
:0000016                  1533      16    32.7K          8/5/1  256 0  62  74 *
:0000024                   170      24     4.0K          1/0/1  170 0   0  99 *
:0000032                  1339      32    45.0K         11/2/1  128 0  18  95 *
:0000040                   102      40     4.0K          1/0/1  102 0   0  99 *
:0000064                  3295      64   278.5K        68/24/1   64 0  35  75 *
:0000072                    56      72     4.0K          1/0/1   56 0   0  98 *
:0000088                  6946      88   618.4K        151/0/1   46 0   0  98 *
:0000096                  2110      96   233.4K         57/9/1   42 0  15  86 *
:0000128                   726     128    98.3K         24/2/1   32 0   8  94 *
:0000136                   255     136    40.9K         10/6/1   30 0  60  84 *
:0000192                   457     192    98.3K         24/4/1   21 0  16  89 *
:0000256               1893104     256   484.6M     118319/0/1   16 0   0 100 *
:0000320                    12     304     4.0K          1/0/1   12 0   0  89 *A
:0000384                   423     384   188.4K        46/14/1   10 0  30  86 *A
:0000512               1892180     512   968.8M     236524/4/1    8 0   0  99 *
:0000640                    68     616    49.1K         12/4/1    6 0  33  85 *A
:0000704                  2043     696     1.5M        186/1/1   11 1   0  93 *A
:0001024                   435    1024   462.8K       113/11/1    4 0   9  96 *
:0001472                   240    1472   393.2K         48/0/1    5 1   0  89 *
:0002048                196191    2048   401.8M     49052/14/1    4 1   0  99 *
:0004096                    51    4096   237.5K         29/7/1    2 1  24  87 *
Acpi-State                  51      80     4.0K          1/0/1   51 0   0  99 
anon_vma                   796      16    24.5K          6/4/1  170 0  66  51 
bdev_cache                  43     720    36.8K          9/1/1    5 0  11  83 Aa
blkdev_requests             46     288    16.3K          4/1/1   14 0  25  80 
buffer_head                888     104    94.2K         23/2/1   39 0   8  98 a
cfq_io_context             249     152    45.0K         11/6/1   26 0  54  84 
dentry                    4242     192   831.4K        203/0/1   21 0   0  97 a
ext3_inode_cache          1341     688     1.0M       129/11/1   11 1   8  87 a
file_lock_cache             23     168     4.0K          1/0/1   23 0   0  94 
idr_layer_cache            118     528    69.6K         17/1/1    7 0   5  89 
inode_cache                959     528   565.2K        138/0/1    7 0   0  89 a
kmalloc-131072               1  131072   131.0K          1/0/1    1 5   0 100 
kmalloc-16384                8   16384   131.0K          8/0/1    1 2   0 100 
kmalloc-32768                1   32768    32.7K          1/0/1    1 3   0 100 
kmalloc-8                 1535       8    12.2K          3/1/1  512 0  33  99 
kmalloc-8192                10    8192    81.9K         10/0/1    1 1   0 100 
mm_struct                   54     800    65.5K          8/6/1    9 1  75  65 A
proc_inode_cache            42     560    24.5K          6/0/1    7 0   0  95 a
radix_tree_node            985     552   811.0K       198/73/1    7 0  36  67 
raid5-md5                  258    1176   352.2K         43/0/1    6 1   0  86 
shmem_inode_cache           24     712    20.4K          5/1/1    5 0  20  83 
sighand_cache               86    2072   237.5K         29/1/1    3 1   3  75 A
signal_cache                85     720    77.8K         19/8/1    5 0  42  78 A
sigqueue                    25     160     4.0K          1/0/1   25 0   0  97 
skbuff_fclone_cache     196031     404    89.2M      21782/5/1    9 0   0  88 A
sock_inode_cache            62     600    53.2K         13/6/1    6 0  46  69 Aa
task_struct                140    1808   311.2K         38/9/1    4 1  23  81 
uhci_urb_priv               73      56     4.0K          1/0/1   73 0   0  99 
vm_area_struct            2666     168   466.9K        114/7/1   24 0   6  95 
### FAILED state ###


I'm not sure quite where to point the blame.  This hardware used to
run ntpd just fine with a 2.6.22 kernel, but I upgraded the base kernel,
the ip1000a driver, and the linuxpps patches at the same time.
With this time to failure, bisection is a challenge.

I'm not quite sure how it could be the ip1000a driver's fault, in a way
that breaks ntp but leaves ssh and other network services running.

And the linuxpps patches are very localized and only allocate
at initialization time.  It's hard to see how they could cause
this effect.

There is a newly recompiled (new linuxpps API) ntpd, but it's hard to
see how it could cause the given symptoms, and the exact same source
code is running on a 32-bit machine (2.6.23-rc6 + linuxpps 5.0) just fine.

But it's also hard to imagine that I've found a new generic networking bug
that nobody else has noticed.

Can anyone offer some diagnosis advice?


This is actually the second (and third) time it's happened.  The first
time, I ran strace and saw the same -EBUSY, but assumed I'd misconfigured
ntpd and bounced it.  It started working, so I left it, then noticed
that it had stopped again and looked more closely.

FWIW, a "stuck" ntpd still responds to UDP queries from a localhost ntpd.

Here's the .config:
CONFIG_X86_64=y
CONFIG_64BIT=y
CONFIG_X86=y
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_ZONE_DMA32=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_SEMAPHORE_SLEEPERS=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_RWSEM_GENERIC_SPINLOCK=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_X86_CMPXCHG=y
CONFIG_EARLY_PRINTK=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_DMI=y
CONFIG_AUDIT_ARCH=y
CONFIG_GENERIC_BUG=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_EXPERIMENTAL=y
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=15
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_ANON_INODES=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_SLUB=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_KMOD=y
CONFIG_BLOCK=y
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_CFQ=y
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_X86_PC=y
CONFIG_MK8=y
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_TSC=y
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_MTRR=y
CONFIG_PREEMPT_NONE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_RESOURCES_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_HPET_TIMER=y
CONFIG_IOMMU=y
CONFIG_SWIOTLB=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_AMD=y
CONFIG_PHYSICAL_START=0x200000
CONFIG_SECCOMP=y
CONFIG_HZ_250=y
CONFIG_HZ=250
CONFIG_K8_NB=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_ISA_DMA_API=y
CONFIG_PM=y
CONFIG_SUSPEND_UP_POSSIBLE=y
CONFIG_HIBERNATION_UP_POSSIBLE=y
CONFIG_ACPI=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_BLACKLIST_YEAR=0
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_SYSTEM=y
CONFIG_X86_PM_TIMER=y
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_X86_POWERNOW_K8=y
CONFIG_X86_POWERNOW_K8_ACPI=y
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
CONFIG_HT_IRQ=y
CONFIG_BINFMT_ELF=y
CONFIG_IA32_EMULATION=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_NET=y
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=y
CONFIG_NET_KEY=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_ASK_IP_FIB_HASH=y
CONFIG_IP_FIB_HASH=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_MROUTE=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_NETFILTER=y
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NETFILTER_XTABLES=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_IP_NF_QUEUE=m
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_TOS=y
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_OWNER=y
CONFIG_IP_NF_MATCH_ADDRTYPE=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_ULOG=y
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_TOS=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_VLAN_8021Q=y
CONFIG_NET_SCHED=y
CONFIG_NET_SCH_FIFO=y
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_RR=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_INGRESS=y
CONFIG_NET_CLS=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_ROUTE=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_IPT=y
CONFIG_NET_ACT_PEDIT=y
CONFIG_NET_ACT_SIMP=y
CONFIG_NET_CLS_POLICE=y
CONFIG_FIB_RULES=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_PC_FIFO=y
CONFIG_PARPORT_PC_SUPERIO=y
CONFIG_PARPORT_1284=y
CONFIG_PNP=y
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_CRYPTOLOOP=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
CONFIG_BLK_DEV_RAM_BLOCKSIZE=4096
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_IDE=y
CONFIG_BLK_DEV_IDE=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDEACPI=y
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_SHARE_IRQ=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AMD74XX=m
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_IDEDMA=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_BLK_DEV_SD=y
CONFIG_SCSI_WAIT_SCAN=m
CONFIG_ATA=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_NV=y
CONFIG_SATA_SIL24=y
CONFIG_SATA_VIA=m
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_SBP2=m
CONFIG_NETDEVICES=y
CONFIG_DUMMY=y
CONFIG_TUN=y
CONFIG_IP1000=y
CONFIG_NET_ETHERNET=y
CONFIG_MII=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_TULIP=m
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_NET_PCI=y
CONFIG_FORCEDETH=y
CONFIG_NETDEV_1000=y
CONFIG_SKGE=y
CONFIG_INPUT=y
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_INPUT_MISC=y
CONFIG_INPUT_PCSPKR=y
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_LIBPS2=y
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_UNIX98_PTYS=y
CONFIG_PRINTER=y
CONFIG_RTC=y
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_DRM=y
CONFIG_DRM_RADEON=y
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_ALGOBIT=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_VIAPRO=y
CONFIG_SENSORS_EEPROM=y
CONFIG_PPS=y
CONFIG_PPS_CLIENT_UART=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_W83627HF=m
CONFIG_VGA_CONSOLE=y
CONFIG_VIDEO_SELECT=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_SOUND=m
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_MPU401_UART=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_VIA82XX=m
CONFIG_AC97_BUS=m
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
CONFIG_USB_HID=y
CONFIG_USB_HIDDEV=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
CONFIG_USB_DEVICEFS=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_SPLIT_ISO=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_OHCI_HCD=m
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_PRINTER=m
CONFIG_USB_STORAGE=m
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP2101=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_MCT_U232=m
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7840=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_TI=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_EZUSB=y
CONFIG_EDAC=y
CONFIG_EDAC_MM_EDAC=y
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_DRV_CMOS=y
CONFIG_DMIID=y
CONFIG_EXT2_FS=m
CONFIG_EXT3_FS=y
CONFIG_JBD=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_DNOTIFY=y
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_RAMFS=y
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_TCP=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="cp437"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_UTF8=y
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DETECT_SOFTLOCKUP=y
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_CRYPTO=y
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_DEFLATE=y
CONFIG_BITREVERSE=y
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
