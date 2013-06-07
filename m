From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: NULL pointer dereference when loading the gre module (3.10.0-rc4)
Date: Thu, 6 Jun 2013 23:06:48 -0400
Message-ID: <20130607030648.GA28618@home.goodmis.org>
References: <20130606221656.GA11475@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130606221656.GA11475@uio.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 07, 2013 at 12:16:56AM +0200, Steinar H. Gunderson wrote:
> Hi,
> 
> In 3.10.0-rc4, I get this on boot:
> 
> [   16.871043] BUG: unable to handle kernel NULL pointer dereference at 0000000000000003
> [   16.879453] IP: [<ffffffffa0e52002>] 0xffffffffa0e52001

Strange, kallsyms should have registered the address already, even if it
crashed on early module load. Not sure why it's not reporting it. Well,
it seems to have reported some of the symbols of ip_gre below. Maybe
this pointer is just totally screwed up.

> [   16.884995] PGD 0 
> [   16.887313] Oops: 0000 [#1] SMP 
> [   16.890904] Modules linked in: ip_gre(+) gre ip_tunnel psmouse ide_generic ide_gd_mod ide_cd_mod cdrom acpi_cpufreq mperf coretemp kvm_intel kvm iTCO_wdt iTCO_vendor_support i2c_i801 microcode lpc_ich pcspkr i2c_core mfd_core ehci_pci evbug evdev ext4 crc16 jbd2 mbcache dm_mod raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid6_pq raid1 md_mod sg sd_mod usbhid ide_pci_generic ide_core crc32c_intel e1000e ata_piix ptp pps_core uhci_hcd ehci_hcd mpt2sas raid_class unix

The ip_gre(+) shows that this is indeed happening while the ip_gre
module is being loaded.

> [   16.939181] CPU: 0 PID: 3261 Comm: modprobe Not tainted 3.10.0-rc4 #1
> [   16.945873] Hardware name: Supermicro X8DTL/X8DTL, BIOS 2.1a       12/30/2011
> [   16.953252] task: ffff880621662d60 ti: ffff8806227de000 task.ti: ffff8806227de000
> [   16.961184] RIP: 0010:[<ffffffffa0e52002>]  [<ffffffffa0e52002>] 0xffffffffa0e52001
> [   16.969346] RSP: 0018:ffff8806227dfca8  EFLAGS: 00010246
> [   16.974903] RAX: ffffffffa0e5d000 RBX: ffff880623ebe280 RCX: 0000000000000000
> [   16.982285] RDX: ffffffffa0e5aa40 RSI: 0000000000000003 RDI: ffffffffa0e5d018
> [   16.989674] RBP: ffff8806227dfca8 R08: 000000000000072f R09: ffffffff812bae96
> [   16.997051] R10: ffffea00188d1200 R11: 0000000000000000 R12: ffff88061f874900
> [   17.004440] R13: ffffffffa0e5a9c0 R14: ffff8806227dfef8 R15: 0000000000000002
> [   17.011818] FS:  00007f7da1d97700(0000) GS:ffff880627200000(0000) knlGS:0000000000000000
> [   17.020357] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   17.026349] CR2: 0000000000000003 CR3: 0000000621b84000 CR4: 00000000000007f0
> [   17.033734] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   17.041110] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   17.048494] Stack:
> [   17.050757]  ffff8806227dfcf8 ffffffff812baf26 2222222222222222 2222222222222222
> [   17.058857]  2222222222222222 ffffffffa0e5a9c0 0000000000000000 0000000000000000
> [   17.066933]  ffff8806227dfef8 ffffffffa0e5ab60 ffff8806227dfd28 ffffffff812bafb6
> [   17.075008] Call Trace:
> [   17.077703]  [<ffffffff812baf26>] ops_init.constprop.7+0xc6/0xf5

This looks like something really bad happened net_namespace.c with
ops->init(net). If ops is corrupted here, it would explain why calling
ops->init might do something nasty and we get a bad instruction pointer.

> [   17.083956]  [<ffffffff812bafb6>] register_pernet_operations.isra.4+0x61/0x91
> [   17.091340]  [<ffffffff8138486f>] ? mutex_lock+0xf/0x20
> [   17.096822]  [<ffffffff812bb006>] register_pernet_device+0x20/0x51
> [   17.103254]  [<ffffffffa0e5d034>] ? ipgre_tap_init_net+0x1a/0x1a [ip_gre]
> [   17.110298]  [<ffffffffa0e5d055>] ipgre_init+0x21/0xc9 [ip_gre]
> [   17.116470]  [<ffffffffa0e5d034>] ? ipgre_tap_init_net+0x1a/0x1a [ip_gre]

Note the faulting address is 0xffffffffa0e52001, which is around the
above address, be interesting to know what was at that location.

> [   17.123515]  [<ffffffff81000263>] do_one_initcall+0x7b/0x10c
> [   17.129422]  [<ffffffff8107e5db>] load_module+0x1b1f/0x1e19
> [   17.135241]  [<ffffffff8107a4f8>] ? sys_getegid16+0x44/0x44
> [   17.141058]  [<ffffffff81386cf2>] ? page_fault+0x22/0x30
> [   17.146618]  [<ffffffff8107e969>] SyS_init_module+0x94/0xa1
> [   17.152440]  [<ffffffff8138cf12>] system_call_fastpath+0x16/0x1b
> [   17.158695] Code: <6e> 65 77 6c 69 6e 6b 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
> [   17.168440] RIP  [<ffffffffa0e52002>] 0xffffffffa0e52001
> [   17.174058]  RSP <ffff8806227dfca8>
> [   17.177798] CR2: 0000000000000003
> [   17.181730] ---[ end trace 531fea804a54bcad ]---
> 
> I assume this is from loading ip_gre, given that it's somewhere in the call
> stack; amazingly enough, GRE tunnels seem to actually still work, though,
> although I cannot load other modules such as ip_tables (modprobe hangs).

Well, probably a lock was held when this crashed, and never got to be
released. Which would explain the modprobe hangs. There's a few net
mutexes held in that location too.

-- Steve
