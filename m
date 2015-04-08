From: Peter Hurley <peter@hurleysoftware.com>
Subject: [bnx2x] Re: Kernel 3.18.11 hangs when inserting netconsle module
 on a DELL M620 VRTX Blade
Date: Wed, 08 Apr 2015 06:50:48 -0400
Message-ID: <55250808.6000606@hurleysoftware.com>
References: <5524E669.5050903@enas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ariel Elior <ariel.elior@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Urban Loesch <bind@enas.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5524E669.5050903@enas.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ + Ariel Elior for bnx2x driver, netdev ]

On 04/08/2015 04:27 AM, Urban Loesch wrote:
> Hi,
> 
> I'have installed a new DELL VRTX M620 Blade with kernel 3.18.11.
> After system startup I tried to activate the kernel netconsole with remote logging enabled.
> 
> I executed the following command and the shell I issued it becomes unresponsive and hangs.
> 
> #  modprobe netconsole netconsole="@/eth0,514@10.1.10.197/00:10:db:fc:60:0c"
> 
> The system load increases slowly and the CPU #11 uses 100% of soft irq. Only a soft reset
> witohut loading the netconsole module after startup solves the issue.
> 
> # mpstat -P 11
> 09:23:52     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
> 09:23:53      11    0,00    0,00    0,00    0,00    0,00  100,00    0,00    0,00    0,00
> 
> 
> I found the following error in the kernel log:
> 
> ...
> Apr  8 09:22:27 server2 kernel: [  216.788670] ------------[ cut here ]------------
> Apr  8 09:22:27 server2 kernel: [  216.788676] WARNING: CPU: 11 PID: 2929 at kernel/softirq.c:147 __local_bh_enable_ip+0x72/0xa0()
> Apr  8 09:22:27 server2 kernel: [  216.788687] CPU: 11 PID: 2929 Comm: modprobe Not tainted 3.18.11-em64t-efigpt #1
> Apr  8 09:22:27 server2 kernel: [  216.788688] Hardware name: Dell Inc. PowerEdge M620/0NJVT7, BIOS 2.4.3 07/02/2014
> Apr  8 09:22:27 server2 kernel: [  216.788690]  0000000000000009 ffff881fcfaa39e8 ffffffff8174434a 0000000019af19af
> Apr  8 09:22:27 server2 kernel: [  216.788690]  0000000000000000 ffff881fcfaa3a28 ffffffff81051fac ffffffff81f4a080
> Apr  8 09:22:27 server2 kernel: [  216.788691]  0000000000000200 ffff881fcf624dd4 ffff881fcf624d58 0000000000000000
> Apr  8 09:22:27 server2 kernel: [  216.788692] Call Trace:
> Apr  8 09:22:27 server2 kernel: [  216.788696]  [<ffffffff8174434a>] dump_stack+0x46/0x58
> Apr  8 09:22:27 server2 kernel: [  216.788698]  [<ffffffff81051fac>] warn_slowpath_common+0x8c/0xc0
> Apr  8 09:22:27 server2 kernel: [  216.788699]  [<ffffffff81051ffa>] warn_slowpath_null+0x1a/0x20
> Apr  8 09:22:27 server2 kernel: [  216.788701]  [<ffffffff81055fc2>] __local_bh_enable_ip+0x72/0xa0
> Apr  8 09:22:27 server2 kernel: [  216.788704]  [<ffffffff8174a3cb>] _raw_spin_unlock_bh+0x1b/0x20
> Apr  8 09:22:27 server2 kernel: [  216.788716]  [<ffffffffa00b8f43>] bnx2x_poll+0x83/0x3e0 [bnx2x]
> Apr  8 09:22:27 server2 kernel: [  216.788720]  [<ffffffff81667de0>] netpoll_poll_dev+0x110/0x1b0
> Apr  8 09:22:27 server2 kernel: [  216.788721]  [<ffffffff81667fe7>] netpoll_send_skb_on_dev+0x167/0x240
> Apr  8 09:22:27 server2 kernel: [  216.788722]  [<ffffffff81668392>] netpoll_send_udp+0x2d2/0x400
> Apr  8 09:22:27 server2 kernel: [  216.788724]  [<ffffffffa018685f>] write_msg+0xcf/0x110 [netconsole]
> Apr  8 09:22:27 server2 kernel: [  216.788728]  [<ffffffff8109e32b>] call_console_drivers.constprop.27+0x9b/0x100
> Apr  8 09:22:27 server2 kernel: [  216.788730]  [<ffffffff8109f39a>] console_unlock+0x3ca/0x450
> Apr  8 09:22:27 server2 kernel: [  216.788731]  [<ffffffff810a073a>] register_console+0x29a/0x360
> Apr  8 09:22:27 server2 kernel: [  216.788733]  [<ffffffffa0191000>] ? 0xffffffffa0191000
> Apr  8 09:22:27 server2 kernel: [  216.788735]  [<ffffffffa01911c5>] init_netconsole+0x1c5/0x1000 [netconsole]
> Apr  8 09:22:27 server2 kernel: [  216.788737]  [<ffffffff810002dc>] do_one_initcall+0x8c/0x1c0
> Apr  8 09:22:27 server2 kernel: [  216.788740]  [<ffffffff81181042>] ? __vunmap+0xc2/0x110
> Apr  8 09:22:27 server2 kernel: [  216.788743]  [<ffffffff810d7f8d>] load_module+0x1dbd/0x25b0
> Apr  8 09:22:27 server2 kernel: [  216.788744]  [<ffffffff810d4770>] ? show_initstate+0x60/0x60
> Apr  8 09:22:27 server2 kernel: [  216.788746]  [<ffffffff8174c49f>] ? page_fault+0x1f/0x30
> Apr  8 09:22:27 server2 kernel: [  216.788747]  [<ffffffff810d881a>] SyS_init_module+0x9a/0xc0
> Apr  8 09:22:27 server2 kernel: [  216.788749]  [<ffffffff8174ab72>] system_call_fastpath+0x12/0x17
> Apr  8 09:22:27 server2 kernel: [  216.788750] ---[ end trace 224709e18793096d ]---
> ...
> 
> I installed the latest firmware driver from DELL for the Broadcom Nic's. Same problem
> and I don't know if there is only affected the netconsole module or something else.
> 
> Linked modules are:
> #  lsmod
> Module                  Size  Used by
> netconsole             23883  1
> configfs               30744  2 netconsole
> iTCO_wdt               13480  0
> iTCO_vendor_support    13718  1 iTCO_wdt
> ipmi_si                53458  0
> ipmi_msghandler        45284  1 ipmi_si
> tpm_tis                18227  0
> tpm                    35790  1 tpm_tis
> sb_edac                26792  0
> lpc_ich                21093  0
> edac_core              57597  1 sb_edac
> dcdbas                 14478  0
> shpchp                 37047  0
> pcspkr                 12718  0
> joydev                 17389  0
> hed                    13247  0
> acpi_pad               17942  0
> evbug                  12672  0
> hid_generic            12559  0
> usbkbd                 12926  0
> usbmouse               12789  0
> usbhid                 46465  0
> hid                   110129  2 hid_generic,usbhid
> ahci                   34019  0
> libahci                32177  1 ahci
> bnx2x                 726130  0
> ptp                    19445  1 bnx2x
> megaraid_sas          113654  3
> pps_core               14386  1 ptp
> mdio                   13561  1 bnx2x
> 
> 
> The system runs with 256GB RAM:
> #  free -m
>              total       used       free     shared    buffers     cached
> Mem:        257918       1834     256084          0         19         44
> -/+ buffers/cache:       1770     256148
> Swap:         7627          0       7627
> 
> And has 2 six-core cpu's:
> #  lscpu
> Architecture:          x86_64
> CPU op-mode(s):        32-bit, 64-bit
> Byte Order:            Little Endian
> CPU(s):                24
> On-line CPU(s) list:   0-23
> Thread(s) per core:    2
> Core(s) per socket:    6
> Socket(s):             2
> NUMA node(s):          2
> Vendor ID:             GenuineIntel
> CPU family:            6
> Model:                 62
> Stepping:              4
> CPU MHz:               2599.966
> BogoMIPS:              5200.39
> Virtualization:        VT-x
> L1d cache:             32K
> L1i cache:             32K
> L2 cache:              256K
> L3 cache:              15360K
> NUMA node0 CPU(s):     0,2,4,6,8,10,12,14,16,18,20,22
> NUMA node1 CPU(s):     1,3,5,7,9,11,13,15,17,19,21,23
> 
> 
> I tried kernel 3.10.40. It works correctly, but I need a newer kernel,
> because the shared PERC 8 linux driver for DELL VRTX is available since version 3.15.
> 
> Have you an idea how I can solve this? If you net more information, please let me know.
> Please cc me, because I'm not a member of lkml.
> 
> Many thanks
> Urban Loesch
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
