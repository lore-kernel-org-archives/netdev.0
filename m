From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFT 0/3] netfilter: lock free tables
Date: Tue, 03 Feb 2009 17:40:11 -0800
Message-ID: <4988F1FB.5020303@hp.com>
References: <20090204001202.724266235@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090204001202.724266235@vyatta.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This is the "swap" version of lock less iptables counter update.
> It gets rid of the expensive reader/writer lock and uses RCU
> and swapping to accomplish the same thing.
> 
> Patches are against current net-next tree.
> It is not ready for inclusion until it is tested by others who
> actually use iptables heavily.

Patches applied with minimal fuzz on a net-next I snapped this afternoon. 
Resulting kernel booted on my 32-core IA64 system.  I was able to run the "none" 
case - no iptables --list command.

When I executed an iptables --list command to setup the "empty" test case, the 
following appeared on the console:

sut42:~# [ 1670.161689] ip_tables: (C) 2000-2006 Netfilter Core Team
[ 1670.235690] Unable to handle kernel paging request at virtual address 
a00000021e468000
[ 1670.235917] iptables[5723]: Oops 8813272891392 [1]
[ 1670.236060] Modules linked in: iptable_filter ip_tables x_tables s2io ipv6 
loop evdev ext3 jbd mbcache sg st sr_mod osst cdrom sd_mod mptspi mptscsih 
mptbase scsi_transport_spi scsi_mod tg3 libphy [last unloaded: s2io]
[ 1670.236716]
[ 1670.236717] Pid: 5723, CPU 7, comm:             iptables
[ 1670.236922] psr : 00001010085a6010 ifs : 8000000000000389 ip  : 
[<a00000021e421cb0>]    Not tainted (2.6.29-rc3-nexthemminger3)
[ 1670.237263] ip is at alloc_counters+0x170/0x280 [ip_tables]
[ 1670.237425] unat: 0000000000000000 pfs : 0000000000000389 rsc : 0000000000000003
[ 1670.237635] rnat: 0000000000000000 bsps: 0000000000000000 pr  : 00000000a695a599
[ 1670.237846] ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
[ 1670.238057] csd : 0000000000000000 ssd : 0000000000000000
[ 1670.238213] b0  : a00000021e421c60 b6  : a000000100074800 b7  : a00000010000b700
[ 1670.238628] f6  : 0fffbfffffffff0000000 f7  : 0ffebfc62000000000000
[ 1670.238807] f8  : 1003e00000000a0000000 f9  : 1003e0000009bf42aa33e
[ 1670.238987] f10 : 1003e789aa606c0000000 f11 : 1003e0000000000000061
[ 1670.239166] r1  : a00000021e424cd0 r2  : 0000000000000000 r3  : 0000000000000000
[ 1670.239378] r8  : 0000000000000040 r9  : 0000000000000278 r10 : 0000000000000011
[ 1670.239589] r11 : e000070f85837308 r12 : e000070f8dc47de0 r13 : e000070f8dc40000
[ 1670.239628] r14 : 0000000000000278 r15 : 0000000000000400 r16 : 0000000000000000
[ 1670.239628] r17 : e000070f8dc40cc4 r18 : a00000021e468000 r19 : e000070f87e119e8
[ 1670.239628] r20 : e000070f87e119e0 r21 : 0000000000000000 r22 : 0000000000000401
[ 1670.239628] r23 : e000070f85837390 r24 : 0000000000000000 r25 : bea7a9a2c2b9b978
[ 1670.239628] r26 : e000070f87e119da r27 : 6e6e6e6e6e6e6e6e r28 : c1d5909426a6ead0
[ 1670.239628] r29 : 6e6e6e6e6e6e6e6e r30 : 50393b34544b4b0a r31 : e000070f87e11980
[ 1670.239628]
[ 1670.239628] Call Trace:
[ 1670.239628]  [<a000000100014cb0>] show_stack+0x50/0xa0
[ 1670.239628]                                 sp=e000070f8dc479b0 
bsp=e000070f8dc411e0
[ 1670.239628]  [<a000000100015520>] show_regs+0x820/0x860
[ 1670.239628]                                 sp=e000070f8dc47b80 
bsp=e000070f8dc41188
[ 1670.239628]  [<a000000100039f60>] die+0x1a0/0x2c0
[ 1670.239628]                                 sp=e000070f8dc47b80 
bsp=e000070f8dc41148
[ 1670.239628]  [<a000000100059370>] ia64_do_page_fault+0x8b0/0x9e0
[ 1670.239628]                                 sp=e000070f8dc47b80 
bsp=e000070f8dc410f8
[ 1670.239628]  [<a00000010000bf20>] ia64_native_leave_kernel+0x0/0x270
[ 1670.239628]                                 sp=e000070f8dc47c10 
bsp=e000070f8dc410f8
[ 1670.239628]  [<a00000021e421cb0>] alloc_counters+0x170/0x280 [ip_tables]
[ 1670.239628]                                 sp=e000070f8dc47de0 
bsp=e000070f8dc410b0
[ 1670.239628]  [<a00000021e422040>] do_ipt_get_ctl+0x280/0x8e0 [ip_tables]
[ 1670.239628]                                 sp=e000070f8dc47de0 
bsp=e000070f8dc41018
[ 1670.239628]  [<a00000010055c080>] nf_sockopt+0xc0/0x160
[ 1670.239628]                                 sp=e000070f8dc47e10 
bsp=e000070f8dc40fc0
[ 1670.239628]  [<a00000010055c160>] nf_getsockopt+0x40/0x60
[ 1670.239628]                                 sp=e000070f8dc47e10 
bsp=e000070f8dc40f80
[ 1670.239628]  [<a000000100578fd0>] ip_getsockopt+0x170/0x280
[ 1670.239628]                                 sp=e000070f8dc47e10 
bsp=e000070f8dc40f40
[ 1670.239628]  [<a0000001005c1700>] raw_getsockopt+0x40/0xa0
[ 1670.239628]                                 sp=e000070f8dc47e20 
bsp=e000070f8dc40f00
[ 1670.239628]  [<a0000001004ebeb0>] sock_common_getsockopt+0x70/0xa0
[ 1670.239628]                                 sp=e000070f8dc47e20 
bsp=e000070f8dc40ec0
[ 1670.239628]  [<a0000001004e77f0>] sys_getsockopt+0x110/0x1c0
[ 1670.239628]                                 sp=e000070f8dc47e20 
bsp=e000070f8dc40e40
[ 1670.239628]  [<a00000010000bd80>] ia64_ret_from_syscall+0x0/0x20
[ 1670.239628]                                 sp=e000070f8dc47e30 
bsp=e000070f8dc40e40
[ 1670.239628]  [<a000000000010720>] __start_ivt_text+0xffffffff00010720/0x400
[ 1670.239628]                                 sp=e000070f8dc48000 
bsp=e000070f8dc40e40
[ 1670.367369] Kernel panic - not syncing: Aiee, killing interrupt handler!


I'm in the midst of rebooting the system to try to pull the typescript from the 
compilation.

rick jones
