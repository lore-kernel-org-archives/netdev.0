From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: [E1000-devel] PROBLEM: [x86] Running ptpd2 using an Intel
 82572EI (e1000e) leads to a kernel oops (3.12.26)
Date: Wed, 6 Aug 2014 15:38:37 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD6533AC68E@ORSMSX114.amr.corp.intel.com>
References: <50f83e65cecd4882b22887858bfdf484@FE-MBX1012.de.bosch.com>
 <1407317367.1360819.149688237.188FBBFC@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Koehrer Mathias <mathias.koehrer@etas.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407317367.1360819.149688237.188FBBFC@webmail.messagingengine.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looking at your patches on netdev, it appears that there are flags set in the skb that should never be set for the 82572EI as that part doesn't have hardware timestamping. This points to a bug in the ptpd code.

Todd Fujinaka
Software Application Engineer
Networking Division (ND)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565

-----Original Message-----
From: Hannes Frederic Sowa [mailto:hannes@stressinduktion.org] 
Sent: Wednesday, August 06, 2014 2:29 AM
To: Koehrer Mathias; linux-kernel@vger.kernel.org; netdev@vger.kernel.org
Cc: e1000-devel@lists.sourceforge.net
Subject: Re: [E1000-devel] PROBLEM: [x86] Running ptpd2 using an Intel 82572EI (e1000e) leads to a kernel oops (3.12.26)

[added e1000-devel]

Hi,

On Mon, Aug 4, 2014, at 14:26, Koehrer Mathias (ETAS/ESW5) wrote:
> [1.] One line summary of the problem: 
> Running ptpd2 using an Intel 82572EI (e1000e) leads to a kernel oops
> (3.12.26)
> 
> [2.] Full description of the problem/report:
> I run the PTP daemon ptpd2 (http://ptpd.sourceforge.net/), version 
> 2.3.1 on a x86 PC using an Intel 82572EI NIC (driver e1000e).
> The ptpd2 is started as
> ptpd2 -i eth0 --masteronly --foreground --verbose I have another PC in 
> the same network that is running the PTP slave.
> After a couple of seconds the kernel generates an Oops.
> 
> Using a different network adapter works fine.
> 
> Thanks for any support on this!
> 
> [3.] Keywords (i.e., modules, networking, kernel):
> PTP, networking, e1000e
> 
> [4.] Kernel information
> 
> [4.1.] Kernel version (from /proc/version):
> Linux version 3.12.26-4 (user@rtpc) (gcc version 4.7.2 (Debian 
> 4.7.2-5) )
> #1 SMP PREEMPT Mon Aug 4 11:04:11 CEST 2014
> 
> [4.2.] Kernel .config file:
> [...]

> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 5358 at kernel/workqueue.c:1386
> __queue_work+0x18f/0x300()
> Modules linked in: e100 mii e1000 nfsd exportfs nfs lockd sunrpc igb 
> i2c_algo_bit i2c_core dca bridge stp llc e1000e smsc47b397 coretemp 
> kvm_intel kvm usb_storage tg3 psmouse ptp pps_core libphy ehci_pci 
> pcspkr processor parport_pc parport thermal_sys hwmon reiserfs sg 
> sr_mod sd_mod cdrom ahci libahci microcode uhci_hcd ehci_hcd
> CPU: 0 PID: 5358 Comm: ptpd2 Not tainted 3.12.26-4 #1 Hardware name: 
> Hewlett-Packard HP xw4600 Workstation/0AA0h, BIOS 786F3
> v01.13 06/25/2008
>  00000000 00000000 f48dfad4 c07b2d07 00000000 f48dfb04 c0440e64 
> c08ee514
>  00000000 000014ee c08f4e3c 0000056a c045775f c045775f f5877100 
> f501f900
>  f5875e80 f48dfb14 c0440ea2 00000009 00000000 f48dfb48 c045775f 
> f48dfb34 Call Trace:
>  [<c07b2d07>] dump_stack+0x4b/0x79
>  [<c0440e64>] warn_slowpath_common+0x84/0xa0  [<c045775f>] ? 
> __queue_work+0x18f/0x300  [<c045775f>] ? __queue_work+0x18f/0x300  
> [<c0440ea2>] warn_slowpath_null+0x22/0x30  [<c045775f>] 
> __queue_work+0x18f/0x300  [<c045795d>] queue_work_on+0x3d/0x50  
> [<f9f806e5>] schedule_work+0x15/0x20 [e1000e]  [<f9f845ba>] 
> e1000_xmit_frame+0xc4a/0xcb0 [e1000e]

Quick analysis so far:
Looks like the socket enabled hw timestamping but the network card (from the lspci output below) is not capable of hw timestamping. queue_work thus gets fed an uninitialized work struct and bails out here.

>  [<c07368bb>] ? harmonize_features+0x2b/0x1d0  [<c0737033>] 
> dev_hard_start_xmit+0x2c3/0x560  [<c0724e61>] ? 
> sock_alloc_send_pskb+0x161/0x380  [<c074d602>] 
> sch_direct_xmit+0xa2/0x190  [<c0737454>] dev_queue_xmit+0x184/0x410  
> [<c075f7c1>] ip_finish_output+0x1f1/0x3c0  [<c076036f>] 
> ip_mc_output+0x8f/0x140  [<c075fd60>] ip_local_out+0x20/0x30  
> [<c0760e4a>] ip_send_skb+0x1a/0x80  [<c078395a>] 
> udp_send_skb+0x1fa/0x280  [<c0783ce3>] udp_sendmsg+0x2a3/0x8b0  
> [<c075e350>] ? ip_setup_cork+0xf0/0xf0  [<c0472cf1>] ? 
> dequeue_task_fair+0x211/0x660  [<c046fa68>] ? 
> __enqueue_entity+0x78/0x80  [<c078d3d0>] inet_sendmsg+0x70/0xa0  
> [<c07213e2>] sock_sendmsg+0x62/0xa0  [<c05c67b5>] ? 
> _copy_from_user+0x35/0x50  [<c0721991>] SYSC_sendto+0xf1/0x130  
> [<c044ed4a>] ? ptrace_do_notify+0x8a/0xa0  [<c0721f5d>] 
> SyS_sendto+0x2d/0x30  [<c0722908>] SyS_socketcall+0x1c8/0x300  
> [<c07b848f>] syscall_call+0x7/0x7 ---[ end trace d87b1e283af6ddc9 ]--- 
> [7.] A small shell script or example program which triggers the
>      problem (if possible)
> ptpd2 -i eth0 --masteronly --foreground --verbose
> 

> 34:00.0 Ethernet controller: Intel Corporation 82572EI Gigabit 
> Ethernet Controller (Copper) (rev 06)

Bye,
Hannes

------------------------------------------------------------------------------
Infragistics Professional
Build stunning WinForms apps today!
Reboot your WinForms applications with our WinForms controls. 
Build a bridge from your legacy apps to the future.
http://pubads.g.doubleclick.net/gampad/clk?id=153845071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
