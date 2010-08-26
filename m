From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [Bugme-new] [Bug 16529] New: xennet driver crashes when using
 with pseudowire aka l2tpv3
Date: Thu, 26 Aug 2010 08:10:40 +0100
Message-ID: <1282806640.3469.26.camel@localhost.localdomain>
References: <bug-16529-10286@https.bugzilla.kernel.org/>
	 <20100825153107.2f547f0e.akpm@linux-foundation.org>
	 <4C759F8C.9050301@goop.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-XjiNRx21YBzBCg0P06bX"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	"heil@terminal-consulting.de" <heil@terminal-consulting.de>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:57785 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579Ab0HZHKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 03:10:45 -0400
In-Reply-To: <4C759F8C.9050301@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-XjiNRx21YBzBCg0P06bX
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On Wed, 2010-08-25 at 23:56 +0100, Jeremy Fitzhardinge wrote:

> >> Here is a link for the setup
> >> http://www.pastebin.org/445975
> >> and here a link with more details about the crash http://pastebin.org/449221
> 
> Please attach these to the bug or something; pastebin is not working for
> me at the moment.

It's really slow for me but got there eventually. I've attached the
files.

It's apparently hitting this BUG_ON in __skb_pull:
        
        static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned int len)
        {
                skb->len -= len;
                BUG_ON(skb->len < skb->data_len);
                return skb->data += len;
        }

Ian.


--=-XjiNRx21YBzBCg0P06bX
Content-Disposition: attachment; filename="445975.txt"
Content-Type: text/plain; name="445975.txt"; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

cat l-01.cfg 
bootloader = "/usr/bin/pygrub"
memory = 512
name = "l-01"
disk = ['file:/etc/xen/images/l-01.img,xvda,w']
vif = [ 'bridge=xenbr0,mac=00:16:3E:1F:32:41', 'bridge=vlan222,mac=00:16:3E:1F:33:41' ]
vcpus = 1
on_reboot = 'restart'
on_crash = 'destroy'
root = '/dev/xvda2 rw'


/root/tunnel-up.sh

#!/bin/sh

l2tpv3tun add tunnel tunnel_id 1 peer_tunnel_id 1 udp_sport 5000 \
udp_dport 5000 encap udp local 172.19.0.1 remote 172.19.0.2
l2tpv3tun add session tunnel_id 1 session_id 1 peer_session_id 1
ip addr add 192.168.1.101/32 peer 192.168.1.102/32 dev l2tpeth0
ifconfig l2tpeth0 up




config interface loopback
        option ifname   lo
        option proto    static
        option ipaddr   127.0.0.1
        option netmask  255.0.0.0

config interface wan
        option ifname   eth1
        option type     bridge
        option proto    static
        option ipaddr   172.19.0.1
        option netmask  255.255.255.0

config interface lan
        option ifname   eth0
        option type     bridge
        option proto    static
        option ipaddr   192.168.1.60
        option netmask  255.255.255.0


l-02

cat l-02.cfg 
bootloader = "/usr/bin/pygrub"
memory = 512
name = "l-02"
disk = ['file:/etc/xen/images/l-02.img,xvda,w']
vif = [ 'bridge=vlan123,mac=00:16:3E:1F:32:42', 'bridge=vlan222,mac=00:16:3E:1F:33:42' ]
vcpus = 1 
on_reboot = 'restart'
on_crash = 'destroy'
root = '/dev/xvda2 rw'


#!/bin/sh
 
                                 
l2tpv3tun add tunnel tunnel_id 1 peer_tunnel_id 1 udp_sport 5000 \
udp_dport 5000 encap udp local 172.19.0.2 remote 172.19.0.1
l2tpv3tun add session tunnel_id 1 session_id 1 peer_session_id 1
ip addr add 192.168.1.102/32 peer 192.168.1.101/32 dev l2tpeth0  
ifconfig l2tpeth0 up

config interface loopback
        option ifname   lo
        option proto    static
        option ipaddr   127.0.0.1
        option netmask  255.0.0.0

config interface wan
        option ifname   eth1
        option type     bridge
        option proto    static
        option ipaddr   172.19.0.2
        option netmask  255.255.255.0

config interface lan
        option ifname   eth0
        option type     bridge
        option proto    static
        option ipaddr   192.168.1.61
        option netmask  255.255.255.0




BusyBox v1.16.2 (2010-07-23 19:51:18 CEST) built-in shell (ash)
Enter 'help' for a list of built-in commands.

  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 KAMIKAZE (bleeding edge, r22368) ------------------
  * 10 oz Vodka       Shake well with ice and strain
  * 10 oz Triple sec  mixture into 10 shot glasses.
  * 10 oz lime juice  Salute!
 ---------------------------------------------------
root@l-02:/# sh t
tmp/          tunnel-up.sh
root@l-02:/# sh tunnel-up.sh
root@l-02:/# ------------[ cut here ]------------
kernel BUG at include/linux/skbuff.h:1185!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/kernel/uevent_seqnum
Modules linked in: nf_nat_tftp nf_conntrack_tftp nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_conntrack_ftp ipt_MASQUERADE iptable_nat nf_nat xt_NOTRACK iptable_raw xt_state nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack pppoe pppox ipt_REJECT xt_TCPMSS ipt_LOG xt_comment xt_multiport xt_mac xt_limit iptable_mangle iptable_filter ip_tables xt_tcpudp x_tables l2tp_ip l2tp_eth l2tp_netlink l2tp_core tunnel6 tunnel4 tun ppp_async ppp_generic slhc crc_ccitt xen_netfront evtchn xenfs ipv6

Pid: 0, comm: swapper Not tainted 2.6.35-rc6+ #1 /
EIP: 0061:[<c11d10a8>] EFLAGS: 00010287 CPU: 0
EAX: 0000004c EBX: dff62540 ECX: dff62540 EDX: dfe7f000
ESI: dfe7f000 EDI: dff62568 EBP: dfe7f000 ESP: c1901b4c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0069
Process swapper (pid: 0, ti=c1901000 task=c12bf9a0 task.ti=c12b6000)
Stack:
 dff62540 dfe7f000 c11bfa32 dfe3ea00 dff62540 e089a430 00000112 00000111
<0> 00000066 dff62568 dff62540 e089a2b0 dff62568 dfe3ea00 e089dc51 00000111
<0> 000001c4 0000002e 00000085 00000000 dfda645c c1006d6c a3024472 dfe3ea44
Call Trace:
 [<c11bfa32>] ? 0xc11bfa32
 [<e089a430>] ? 0xe089a430
 [<e089a2b0>] ? 0xe089a2b0
 [<e089dc51>] ? 0xe089dc51
 [<c1006d6c>] ? 0xc1006d6c
 [<e089e0e0>] ? 0xe089e0e0
 [<e089ebab>] ? 0xe089ebab
 [<c10271f2>] ? 0xc10271f2
 [<c12037e7>] ? 0xc12037e7
 [<c120401e>] ? 0xc120401e
 [<c1006d6c>] ? 0xc1006d6c
 [<c10271f2>] ? 0xc10271f2
 [<c1006d6c>] ? 0xc1006d6c
 [<c10056e6>] ? 0xc10056e6
 [<c103e586>] ? 0xc103e586
 [<e08eaaef>] ? 0xe08eaaef
 [<e0907330>] ? 0xe0907330
 [<c11dd036>] ? 0xc11dd036
 [<c11e3880>] ? 0xc11e3880
 [<c11dd26c>] ? 0xc11dd26c
 [<c11e3880>] ? 0xc11e3880
 [<c11e3984>] ? 0xc11e3984
 [<c11e3880>] ? 0xc11e3880
 [<c11e37c8>] ? 0xc11e37c8
 [<c11e34e0>] ? 0xc11e34e0
 [<c11e3250>] ? 0xc11e3250
 [<c11bec13>] ? 0xc11bec13
 [<c11bf400>] ? 0xc11bf400
 [<c122ad60>] ? 0xc122ad60
 [<c11bf45f>] ? 0xc11bf45f
 [<c122ad60>] ? 0xc122ad60
 [<c122b114>] ? 0xc122b114
 [<c122ad60>] ? 0xc122ad60
 [<c11beadc>] ? 0xc11beadc
 [<c1074658>] ? 0xc1074658
 [<c11bf45f>] ? 0xc11bf45f
 [<e087e924>] ? 0xe087e924
 [<c11c217d>] ? 0xc11c217d
 [<c103e216>] ? 0xc103e216
 [<c103e180>] ? 0xc103e180
 <IRQ>
 [<c10056e6>] ? 0xc10056e6
 [<c11474b4>] ? 0xc11474b4
 [<c1008a87>] ? 0xc1008a87
 [<c10013a7>] ? 0xc10013a7
 [<c100576f>] ? 0xc100576f
 [<c10034c9>] ? 0xc10034c9
 [<c100763c>] ? 0xc100763c
 [<c12db330>] ? 0xc12db330
 [<c12dba75>] ? 0xc12dba75
 [<c12db330>] ? 0xc12db330
 [<c12dd441>] ? 0xc12dd441
Code: c4 08 c3 56 89 c1 53 89 d6 8b 80 a8 00 00 00 89 51 14 89 81 98 00 00 00 8b 41 50 83 f8 0d 76 1c 83 e8 0e 3b 41 54 89 41 50 73 0a <0f> 0b 8d b6 00 00 00 00 eb fe 83 81 a8 00 00 00 0e 8b 99 98 00
EIP: [<c11d10a8>]  SS:ESP 0069:c1901b4c
---[ end trace 38eccb6087791f3d ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D     2.6.35-rc6+ #1
Call Trace:
 [<c10393ff>] ? 0xc10393ff
 [<c100b9b3>] ? 0xc100b9b3
 [<c10095d0>] ? 0xc10095d0
 [<c1009657>] ? 0xc1009657
 [<c11d10a8>] ? 0xc11d10a8
 [<c10271f2>] ? 0xc10271f2
 [<c1146675>] ? 0xc1146675
 [<c11469a0>] ? 0xc11469a0
 [<c10271f2>] ? 0xc10271f2
 [<c1006d6c>] ? 0xc1006d6c
 [<c1146675>] ? 0xc1146675
 [<c11469a0>] ? 0xc11469a0
 [<c124a406>] ? 0xc124a406
 [<c10095d0>] ? 0xc10095d0
 [<c11d10a8>] ? 0xc11d10a8
 [<c11bfa32>] ? 0xc11bfa32
 [<e089a430>] ? 0xe089a430
 [<e089a2b0>] ? 0xe089a2b0
 [<e089dc51>] ? 0xe089dc51
 [<c1006d6c>] ? 0xc1006d6c
 [<e089e0e0>] ? 0xe089e0e0
 [<e089ebab>] ? 0xe089ebab
 [<c10271f2>] ? 0xc10271f2
 [<c12037e7>] ? 0xc12037e7
 [<c120401e>] ? 0xc120401e
 [<c1006d6c>] ? 0xc1006d6c
 [<c10271f2>] ? 0xc10271f2
 [<c1006d6c>] ? 0xc1006d6c
 [<c10056e6>] ? 0xc10056e6
 [<c103e586>] ? 0xc103e586
 [<e08eaaef>] ? 0xe08eaaef
 [<e0907330>] ? 0xe0907330
 [<c11dd036>] ? 0xc11dd036
 [<c11e3880>] ? 0xc11e3880
 [<c11dd26c>] ? 0xc11dd26c
 [<c11e3880>] ? 0xc11e3880
 [<c11e3984>] ? 0xc11e3984
 [<c11e3880>] ? 0xc11e3880
 [<c11e37c8>] ? 0xc11e37c8
 [<c11e34e0>] ? 0xc11e34e0
 [<c11e3250>] ? 0xc11e3250
 [<c11bec13>] ? 0xc11bec13
 [<c11bf400>] ? 0xc11bf400
 [<c122ad60>] ? 0xc122ad60
 [<c11bf45f>] ? 0xc11bf45f
 [<c122ad60>] ? 0xc122ad60
 [<c122b114>] ? 0xc122b114
 [<c122ad60>] ? 0xc122ad60
 [<c11beadc>] ? 0xc11beadc
 [<c1074658>] ? 0xc1074658
 [<c11bf45f>] ? 0xc11bf45f
 [<e087e924>] ? 0xe087e924
 [<c11c217d>] ? 0xc11c217d
 [<c103e216>] ? 0xc103e216
 [<c103e180>] ? 0xc103e180
 <IRQ>  [<c10056e6>] ? 0xc10056e6
 [<c11474b4>] ? 0xc11474b4
 [<c1008a87>] ? 0xc1008a87
 [<c10013a7>] ? 0xc10013a7
 [<c100576f>] ? 0xc100576f
 [<c10034c9>] ? 0xc10034c9
 [<c100763c>] ? 0xc100763c
 [<c12db330>] ? 0xc12db330
 [<c12dba75>] ? 0xc12dba75
 [<c12db330>] ? 0xc12db330
 [<c12dd441>] ? 0xc12dd441
Rebooting in 3 seconds..


--=-XjiNRx21YBzBCg0P06bX
Content-Disposition: attachment; filename="449221.txt"
Content-Type: text/plain; name="449221.txt"; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

[root@node04 images]# xm console l-01

Reserving virtual address space above 0xf5800000
Linux version 2.6.35+ (heil@jun) (gcc version 4.1.2) #1 SMP Thu Aug 5 20:13:55 CEST 2010
BIOS-provided physical RAM map:
 Xen: 0000000000000000 - 00000000000a0000 (usable)
 Xen: 00000000000a0000 - 0000000000100000 (reserved)
 Xen: 0000000000100000 - 0000000020000000 (usable)
NX (Execute Disable) protection: active
last_pfn = 0x20000 max_arch_pfn = 0x1000000
init_memory_mapping: 0000000000000000-0000000020000000
512MB LOWMEM available.
  mapped low ram: 0 - 20000000
  low ram: 0 - 20000000
  node 0 low ram: 00000000 - 20000000
  node 0 bootmap 00003000 - 00007000
(7/32 early reservations) ==> bootmem [0000000000 - 0020000000]
  #0 [0001589000 - 0001597000]   XEN PAGETABLES ==> [0001589000 - 0001597000]
  #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
  #2 [0001000000 - 00013f0ce4]    TEXT DATA BSS ==> [0001000000 - 00013f0ce4]
  #3 [0001506000 - 0001589000]   XEN START INFO ==> [0001506000 - 0001589000]
  #4 [0000002000 - 0000003000]       TRAMPOLINE ==> [0000002000 - 0000003000]
  #5 [0000100000 - 00001f0000]          PGTABLE ==> [0000100000 - 00001f0000]
  #6 [0000003000 - 0000007000]          BOOTMAP ==> [0000003000 - 0000007000]
Zone PFN ranges:
  DMA      0x00000001 -> 0x00001000
  Normal   0x00001000 -> 0x00020000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000001 -> 0x000000a0
    0: 0x00000100 -> 0x00020000
Using APIC driver default
SMP: Allowing 1 CPUs, 0 hotplug CPUs
Local APIC disabled by BIOS -- you can enable it with "lapic"
APIC: disable apic facility
APIC: switched to apic NOOP
Allocating PCI resources starting at 20000000 (gap: 20000000:e0000000)
Booting paravirtualized kernel on Xen
Xen version: 3.1.2-194.8.1.el5 (preserve-AD)
setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:1 nr_node_ids:1
PERCPU: Embedded 14 pages/cpu @c199b000 s36736 r0 d20608 u65536
pcpu-alloc: s36736 r0 d20608 u65536 alloc=16*4096
pcpu-alloc: [0] 0
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129951
Kernel command line:  root=/dev/xvda2 rw root=/dev/xvda2 rootfstype=ext2 rootwait xencons=hvc console=tty0 console=hvc0,38400n8 noinitrd reboot=bios
PID hash table entries: 2048 (order: 1, 8192 bytes)
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
Memory: 513736k/524288k available (2500k kernel code, 10164k reserved, 851k data, 348k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xf5767000 - 0xf57ff000   ( 608 kB)
    vmalloc : 0xe0800000 - 0xf5765000   ( 335 MB)
    lowmem  : 0xc0000000 - 0xe0000000   ( 512 MB)
      .init : 0xc1346000 - 0xc139d000   ( 348 kB)
      .data : 0xc1271161 - 0xc1345d80   ( 851 kB)
      .text : 0xc1000000 - 0xc1271161   (2500 kB)
SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Hierarchical RCU implementation.
        RCU-based detection of stalled CPUs is disabled.
        Verbose stalled-CPUs detection is disabled.
NR_IRQS:2304 nr_irqs:256
console [hvc0] enabled
installing Xen timer for CPU 0
Detected 2836.024 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 5672.04 BogoMIPS (lpj=28360240)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 512
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
Performance Events:
no APIC, boot with the "lapic" boot parameter to force-enable it.
no hardware sampling interrupt available.
AMD PMU driver.
... version:                0
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             00007fffffffffff
... fixed-purpose events:   0
... event mask:             000000000000000f
SMP alternatives: switching to UP code
Freeing SMP alternatives: 12k freed
ftrace: converting mcount calls to 0f 1f 44 00 00
ftrace: allocating 11377 entries in 23 pages
cpu 0 spinlock event irq 1
Brought up 1 CPUs
Grant table initialized
NET: Registered protocol family 16
PCI: Fatal: No config space access function found
bio: create slab <bio-0> at 0
xen_balloon: Initialising balloon driver.
SCSI subsystem initialized
PCI: System does not support PCI
PCI: System does not support PCI
Switching to clocksource xen
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 5, 131072 bytes)
TCP bind hash table entries: 16384 (order: 5, 131072 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
TCP reno registered
UDP hash table entries: 256 (order: 1, 8192 bytes)
UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
NET: Registered protocol family 1
platform rtc_cmos: registered platform RTC device (no PNP device found)
scx200: NatSemi SCx200 Driver
microcode: no support for this CPU vendor
------------[ cut here ]------------
WARNING: at arch/x86/mm/ioremap.c:111 __ioremap_caller+0x188/0x380()
Modules linked in:
Pid: 1, comm: swapper Not tainted 2.6.35+ #1
Call Trace:
 [<c102b198>] ? __ioremap_caller+0x188/0x380
 [<c103ddd3>] warn_slowpath_common+0x63/0x80
 [<c102b198>] ? __ioremap_caller+0x188/0x380
 [<c103de12>] warn_slowpath_null+0x22/0x30
 [<c102b198>] __ioremap_caller+0x188/0x380
 [<c11095c5>] ? internal_create_group+0xf5/0x160
 [<c135b864>] ? crashlog_init_fs+0x24/0xb0
 [<c102b46f>] ioremap_nocache+0x1f/0x30
 [<c135b864>] ? crashlog_init_fs+0x24/0xb0
 [<c135b840>] ? crashlog_init_fs+0x0/0xb0
 [<c135b864>] crashlog_init_fs+0x24/0xb0
 [<c1005526>] ? __raw_callee_save_xen_save_fl+0x6/0x8
 [<c1002072>] do_one_initcall+0x62/0x190
 [<c114ac0a>] ? radix_tree_lookup+0xa/0x10
 [<c106f344>] ? irq_to_desc+0x14/0x20
 [<c134671a>] kernel_init+0x13a/0x1e0
 [<c13465e0>] ? kernel_init+0x0/0x1e0
 [<c1008436>] kernel_thread_helper+0x6/0x10
---[ end trace 6d450e935ee1897c ]---
squashfs: version 4.0 (2009/01/31) Phillip Lougher
Registering mini_fo version $Id$
JFFS2 version 2.2 (NAND) (SUMMARY) (LZMA) (RTIME) (CMODE_PRIORITY) (c) 2001-2006 Red Hat, Inc.
msgmni has been set to 1003
io scheduler noop registered
io scheduler deadline registered (default)
rtc: I/O resource 70 is not free.
Non-volatile memory driver v1.3
Serial: 8250/16550 driver, 2 ports, IRQ sharing disabled
i8042.c: No controller found.
cpuidle: using governor ladder
TCP westwood registered
NET: Registered protocol family 17
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
Using IPI No-Shortcut mode
 xvda: xvda1 xvda2
xvda: p2 size 98721 extends beyond EOD, truncated
XENBUS: Device with no driver: device/vif/0
XENBUS: Device with no driver: device/vif/1
EXT2-fs (xvda2): warning: mounting unchecked fs, running e2fsck is recommended
VFS: Mounted root (ext2 filesystem) on device 202:2.
Freeing unused kernel memory: 348k freed
- preinit -
Press the [f] key and hit [enter] to enter failsafe mode


- regular preinit -
- init -

Please press Enter to activate this console. Event-channel device installed.
Initialising Xen virtual ethernet driver.
device eth0 entered promiscuous mode
br-lan: port 1(eth0) entering forwarding state
br-lan: port 1(eth0) entering forwarding state
L2TP core driver, V2.0
L2TP netlink interface
L2TP ethernet pseudowire support (L2TPv3)
device eth1 entered promiscuous mode
br-wan: port 1(eth1) entering forwarding state
br-wan: port 1(eth1) entering forwarding state
fuse init (API version 7.14)



BusyBox v1.16.2 (2010-08-05 19:55:24 CEST) built-in shell (ash)
Enter 'help' for a list of built-in commands.

  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 KAMIKAZE (bleeding edge, r22497) ------------------
  * 10 oz Vodka       Shake well with ice and strain
  * 10 oz Triple sec  mixture into 10 shot glasses.
  * 10 oz lime juice  Salute!
 ---------------------------------------------------
root@l-01:/# sh tunnel-up.sh
tunnel-up.sh: line 8: ip: not found
tunnel-up.sh: line 9: ip: not found
root@l-01:/# ------------[ cut here ]------------
kernel BUG at include/linux/skbuff.h:1185!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/kernel/uevent_seqnum
Modules linked in: fuse l2tp_eth l2tp_netlink l2tp_core crc_ccitt xen_netfront evtchn xenfs

Pid: 0, comm: swapper Tainted: G        W   2.6.35+ #1 /
EIP: 0061:[<c1202cd0>] EFLAGS: 00010287 CPU: 0
EIP is at eth_type_trans+0x30/0xf0
EAX: 0000001c EBX: dfadccc0 ECX: dfadccc0 EDX: df85f800
ESI: df85f800 EDI: df85f800 EBP: c131f93c ESP: c131f934
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0069
Process swapper (pid: 0, ti=c131e000 task=c1326820 task.ti=c131e000)
Stack:
 dfadccc0 df85f800 c131f94c c11f1283 df93a400 dfadccc0 c131f974 e08873f3
<0> c126fabc 00000008 00000036 c1005526 00000000 dfadccc0 e08872d0 dfadcce8
<0> c131f9d4 e088ad0d c131fa60 c1238fff dfaea802 c131fa00 00000003 00000003
Call Trace:
 [<c11f1283>] ? dev_forward_skb+0xa3/0xc0
 [<e08873f3>] ? l2tp_eth_dev_setup+0x3f3/0x4e0 [l2tp_eth]
 [<c126fabc>] ? _raw_spin_unlock_irqrestore+0x1c/0x20
 [<c1005526>] ? __raw_callee_save_xen_save_fl+0x6/0x8
 [<e08872d0>] ? l2tp_eth_dev_setup+0x2d0/0x4e0 [l2tp_eth]
 [<e088ad0d>] ? l2tp_recv_common+0x70d/0x7d0 [l2tp_core]
 [<c1238fff>] ? icmp_send+0x37f/0x390
 [<e088b1aa>] ? l2tp_udp_recv_core+0x2fa/0x520 [l2tp_core]
 [<e088bcef>] ? l2tp_udp_encap_recv+0x7f/0xd0 [l2tp_core]
 [<c12460a5>] ? fib4_rule_action+0x55/0x70
 [<c1234d5a>] ? udp_queue_rcv_skb+0x7a/0x260
 [<c1235628>] ? __udp4_lib_rcv+0x628/0x8a0
 [<c12460a5>] ? fib4_rule_action+0x55/0x70
 [<c12460f2>] ? fib_lookup+0x32/0x40
 [<c1005526>] ? __raw_callee_save_xen_save_fl+0x6/0x8
 [<c10433ee>] ? local_bh_enable_ip+0x1e/0x90
 [<c126fcc6>] ? _raw_spin_unlock_bh+0x16/0x20
 [<c12114f4>] ? rt_intern_hash+0x514/0x550
 [<c1212c21>] ? ip_route_input_common+0xdd1/0xf20
 [<c10beaba>] ? kmem_cache_free+0x9a/0xe0
 [<c11e8f18>] ? __kfree_skb+0x38/0xa0
 [<c12358b7>] ? udp_rcv+0x17/0x20
 [<c1214df7>] ? ip_local_deliver_finish+0xb7/0x110
 [<c100552e>] ? __raw_callee_save_xen_restore_fl+0x6/0x8
 [<c1215167>] ? ip_local_deliver+0x87/0xa0
 [<c1214d18>] ? ip_rcv_finish+0x288/0x2b0
 [<c12150ac>] ? ip_rcv+0x25c/0x290
 [<c100552e>] ? __raw_callee_save_xen_restore_fl+0x6/0x8
 [<c10bc90c>] ? kfree+0x10c/0x120
 [<c11e928b>] ? skb_release_data+0x8b/0x90
 [<c1214e50>] ? ip_rcv+0x0/0x290
 [<c11efb21>] ? __netif_receive_skb+0x3e1/0x410
 [<c10beaba>] ? kmem_cache_free+0x9a/0xe0
 [<c11e8f18>] ? __kfree_skb+0x38/0xa0
 [<c11f039f>] ? netif_receive_skb+0x6f/0x80
 [<c1252407>] ? br_handle_frame_finish+0x1a7/0x1d0
 [<c1252605>] ? br_handle_frame+0x1d5/0x200
 [<c10bbce9>] ? __slab_free+0x79/0x2a0
 [<c100552e>] ? __raw_callee_save_xen_restore_fl+0x6/0x8
 [<c11efa29>] ? __netif_receive_skb+0x2e9/0x410
 [<c11e928b>] ? skb_release_data+0x8b/0x90
 [<e0823775>] ? skb_entry_set_link+0x1775/0x23a0 [xen_netfront]
 [<c11f039f>] ? netif_receive_skb+0x6f/0x80
 [<e082390c>] ? skb_entry_set_link+0x190c/0x23a0 [xen_netfront]
 [<c100552e>] ? __raw_callee_save_xen_restore_fl+0x6/0x8
 [<c11f330d>] ? net_rx_action+0x7d/0x160
 [<c1043298>] ? __do_softirq+0xe8/0x1d0
 [<c1171269>] ? unmask_evtchn+0x39/0xe0
 [<c1005536>] ? __raw_callee_save_xen_irq_disable+0x6/0x8
 [<c106f280>] ? handle_IRQ_event+0x120/0x130
 [<c106f344>] ? irq_to_desc+0x14/0x20
 [<c10433b9>] ? do_softirq+0x39/0x50
 [<c104375e>] ? irq_exit+0x2e/0x40
 [<c1171e84>] ? xen_evtchn_do_upcall+0x154/0x170
 [<c1008487>] ? xen_do_upcall+0x7/0xc
 [<c10013a7>] ? hypercall_page+0x3a7/0x1010
 [<c10055b2>] ? xen_safe_halt+0x12/0x30
 [<c100357c>] ? xen_idle+0x2c/0x40
 [<c100700c>] ? cpu_idle+0x4c/0x70
 [<c1346350>] ? unknown_bootoption+0x0/0x1c0
 [<c125d1e1>] ? rest_init+0x71/0x80
 [<c1346aba>] ? start_kernel+0x2fa/0x310
 [<c1346350>] ? unknown_bootoption+0x0/0x1c0
 [<c1346103>] ? i386_start_kernel+0xe3/0xf0
 [<c13486ad>] ? xen_start_kernel+0x3cd/0x3e0
Code: 0f 1f 44 00 00 89 c1 8b 80 a0 00 00 00 89 d6 89 51 14 89 81 90 00 00 00 8b 41 4c 83 f8 0d 76 24 83 e8 0e 3b 41 50 89 41 4c 73 12 <0f> 0b 8d b4 26 00 00 00 00 8d bc 27 00 00 00 00 eb fe 83 81 a0
EIP: [<c1202cd0>] eth_type_trans+0x30/0xf0 SS:ESP 0069:c131f934
---[ end trace 6d450e935ee1897e ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D W   2.6.35+ #1
Call Trace:
 [<c103df24>] panic+0x64/0xe0
 [<c100b373>] oops_end+0xa3/0xd0
 [<c100b49d>] die+0x6d/0x80
 [<c1008918>] do_trap+0x98/0xc0
 [<c1009060>] ? do_invalid_op+0x0/0xa0
 [<c10090f2>] do_invalid_op+0x92/0xa0
 [<c1202cd0>] ? eth_type_trans+0x30/0xf0
 [<c1005526>] ? __raw_callee_save_xen_save_fl+0x6/0x8
 [<c1043fde>] ? local_bh_enable+0x1e/0x90
 [<c11f4455>] ? dev_queue_xmit+0x445/0x480
 [<c12198ca>] ? ip_finish_output+0x21a/0x270
 [<c1270596>] error_code+0x66/0x6c
 [<c1009060>] ? do_invalid_op+0x0/0xa0
 [<c1202cd0>] ? eth_type_trans+0x30/0xf0
 [<c11f1283>] dev_forward_skb+0xa3/0xc0
 [<e08873f3>] l2tp_eth_dev_setup+0x3f3/0x4e0 [l2tp_eth]
 [<c126fabc>] ? _raw_spin_unlock_irqrestore+0x1c/0x20
 [<c1005526>] ? __raw_callee_save_xen_save_fl+0x6/0x8
 [<e08872d0>] ? l2tp_eth_dev_setup+0x2d0/0x4e0 [l2tp_eth]
 [<e088ad0d>] l2tp_recv_common+0x70d/0x7d0 [l2tp_core]
 [<c1238fff>] ? icmp_send+0x37f/0x390
 [<e088b1aa>] l2tp_udp_recv_core+0x2fa/0x520 [l2tp_core]
 [<e088bcef>] l2tp_udp_encap_recv+0x7f/0xd0 [l2tp_core]
 [<c12460a5>] ? fib4_rule_action+0x55/0x70
 [<c1234d5a>] udp_queue_rcv_skb+0x7a/0x260
 [<c1235628>] __udp4_lib_rcv+0x628/0x8a0
 [<c12460a5>] ? fib4_rule_action+0x55/0x70
 [<c12460f2>] ? fib_lookup+0x32/0x40
 [<c1005526>] ? __raw_callee_save_xen_save_fl+0x6/0x8
 [<c10433ee>] ? local_bh_enable_ip+0x1e/0x90
 [<c126fcc6>] ? _raw_spin_unlock_bh+0x16/0x20
 [<c12114f4>] ? rt_intern_hash+0x514/0x550
 [<c1212c21>] ? ip_route_input_common+0xdd1/0xf20
 [<c10beaba>] ? kmem_cache_free+0x9a/0xe0
 [<c11e8f18>] ? __kfree_skb+0x38/0xa0
 [<c12358b7>] udp_rcv+0x17/0x20
 [<c1214df7>] ip_local_deliver_finish+0xb7/0x110
 [<c100552e>] ? __raw_callee_save_xen_restore_fl+0x6/0x8
 [<c1215167>] ip_local_deliver+0x87/0xa0
 [<c1214d18>] ip_rcv_finish+0x288/0x2b0
 [<c12150ac>] ip_rcv+0x25c/0x290
 [<c100552e>] ? __raw_callee_save_xen_restore_fl+0x6/0x8
 [<c10bc90c>] ? kfree+0x10c/0x120
 [<c11e928b>] ? skb_release_data+0x8b/0x90
 [<c1214e50>] ? ip_rcv+0x0/0x290
 [<c11efb21>] __netif_receive_skb+0x3e1/0x410
 [<c10beaba>] ? kmem_cache_free+0x9a/0xe0
 [<c11e8f18>] ? __kfree_skb+0x38/0xa0
 [<c11f039f>] netif_receive_skb+0x6f/0x80
 [<c1252407>] br_handle_frame_finish+0x1a7/0x1d0
 [<c1252605>] br_handle_frame+0x1d5/0x200
 [<c10bbce9>] ? __slab_free+0x79/0x2a0
 [<c100552e>] ? __raw_callee_save_xen_restore_fl+0x6/0x8
 [<c11efa29>] __netif_receive_skb+0x2e9/0x410
 [<c11e928b>] ? skb_release_data+0x8b/0x90
 [<e0823775>] ? skb_entry_set_link+0x1775/0x23a0 [xen_netfront]
 [<c11f039f>] netif_receive_skb+0x6f/0x80
 [<e082390c>] skb_entry_set_link+0x190c/0x23a0 [xen_netfront]
 [<c100552e>] ? __raw_callee_save_xen_restore_fl+0x6/0x8
 [<c11f330d>] net_rx_action+0x7d/0x160
 [<c1043298>] __do_softirq+0xe8/0x1d0
 [<c1171269>] ? unmask_evtchn+0x39/0xe0
 [<c1005536>] ? __raw_callee_save_xen_irq_disable+0x6/0x8
 [<c106f280>] ? handle_IRQ_event+0x120/0x130
 [<c106f344>] ? irq_to_desc+0x14/0x20
 [<c10433b9>] do_softirq+0x39/0x50
 [<c104375e>] irq_exit+0x2e/0x40
 [<c1171e84>] xen_evtchn_do_upcall+0x154/0x170
 [<c1008487>] xen_do_upcall+0x7/0xc
 [<c10013a7>] ? hypercall_page+0x3a7/0x1010
 [<c10055b2>] ? xen_safe_halt+0x12/0x30
 [<c100357c>] xen_idle+0x2c/0x40
 [<c100700c>] cpu_idle+0x4c/0x70
 [<c1346350>] ? unknown_bootoption+0x0/0x1c0
 [<c125d1e1>] rest_init+0x71/0x80
 [<c1346aba>] start_kernel+0x2fa/0x310
 [<c1346350>] ? unknown_bootoption+0x0/0x1c0
 [<c1346103>] i386_start_kernel+0xe3/0xf0
 [<c13486ad>] xen_start_kernel+0x3cd/0x3e0
[
--=-XjiNRx21YBzBCg0P06bX--
