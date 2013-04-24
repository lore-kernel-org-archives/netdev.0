From: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] mac80211_hwsim: Register and bind to driver
Date: Wed, 24 Apr 2013 00:13:53 -0400
Message-ID: <51775C01.20807@oracle.com>
References: <20130408093001.GE2818@piware.de> <1365431569.25475.16.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Martin Pitt <martin.pitt-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1365431569.25475.16.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/08/2013 10:32 AM, Johannes Berg wrote:
> On Mon, 2013-04-08 at 11:30 +0200, Martin Pitt wrote:
>> Properly register our mac80211_hwsim_driver, attach it to the platform bus.
>> Bind newly created hwsim devices to that driver, so that our wlan devices get
>> a proper "driver" sysfs attribute.
>>
>> This makes mac80211_hwsim interfaces work with NetworkManager.
> 
> Applied.

Hi guys,

The registration of the driver here is somewhat odd.

You're trying to register a platform driver, but are not actually creating
a struct platform_driver at any point. This makes registration do the wrong
thing.

Simply booting a kernel with that patch would cause it to blow up because
running to_platform_driver() on the device_driver object would point to garbage:

[   25.349569] BUG: unable to handle kernel NULL pointer dereference at 0000000000000001
[   25.350254] IP: [<ffffffff81f39fa5>] platform_match+0x45/0xc0
[   25.350886] PGD 0
[   25.351141] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   25.351775] Dumping ftrace buffer:
[   25.352174]    (ftrace buffer empty)
[   25.352581] Modules linked in:
[   25.352949] CPU: 3 PID: 1 Comm: swapper/0 Tainted: G        W    3.9.0-rc8-next-20130423-sasha-00013-gff425d3-dirty #350
[   25.353905] task: ffff8800b9f08000 ti: ffff8800b9f10000 task.ti: ffff8800b9f10000
[   25.354577] RIP: 0010:[<ffffffff81f39fa5>]  [<ffffffff81f39fa5>] platform_match+0x45/0xc0
[   25.355485] RSP: 0000:ffff8800b9f11c98  EFLAGS: 00010202
[   25.356307] RAX: 000000000000000e RBX: ffff8800b9ad9be8 RCX: 00000000f4b5f4b4
[   25.357184] RDX: ffff8800b9f08000 RSI: 0000000000000001 RDI: 0000000000000282
[   25.357939] RBP: ffff8800b9f11cb8 R08: 0000000000000002 R09: 0000000000000000
[   25.358791] R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff86083640
[   25.359134] R13: 0000000000000001 R14: 0000000000000000 R15: ffffffff85f963c0
[   25.359134] FS:  0000000000000000(0000) GS:ffff8800bba00000(0000) knlGS:0000000000000000
[   25.359134] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   25.359134] CR2: 0000000000000001 CR3: 0000000005826000 CR4: 00000000000406e0
[   25.359134] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   25.359134] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   25.359134] Stack:
[   25.359134]  ffff8800b9f11cd8 ffff8800b9ad9be8 ffffffff86083640 ffffffff81f37f90
[   25.359134]  ffff8800b9f11ce8 ffffffff81f37fca 0000000000000000 0000000000000000
[   25.359134]  ffffffff86083640 ffffffff81f37f90 ffff8800b9f11d28 ffffffff81f35ca1
[   25.359134] Call Trace:
[   25.359134]  [<ffffffff81f37f90>] ? driver_probe_device+0x340/0x340
[   25.359134]  [<ffffffff81f37fca>] __driver_attach+0x3a/0xb0
[   25.359134]  [<ffffffff81f37f90>] ? driver_probe_device+0x340/0x340
[   25.359134]  [<ffffffff81f35ca1>] bus_for_each_dev+0x61/0xa0
[   25.359134]  [<ffffffff81f37629>] driver_attach+0x19/0x20
[   25.359134]  [<ffffffff81f37198>] bus_add_driver+0x118/0x2a0
[   25.359134]  [<ffffffff8668694e>] ? wil6210_driver_init+0x1b/0x1b
[   25.359134]  [<ffffffff81f38778>] driver_register+0xa8/0x170
[   25.359134]  [<ffffffff8668694e>] ? wil6210_driver_init+0x1b/0x1b
[   25.359134]  [<ffffffff8668694e>] ? wil6210_driver_init+0x1b/0x1b
[   25.359134]  [<ffffffff86686a3e>] init_mac80211_hwsim+0xf0/0xaaa
[   25.359134]  [<ffffffff86686933>] ? ar5523_driver_init+0x1b/0x1b
[   25.359134]  [<ffffffff86686933>] ? ar5523_driver_init+0x1b/0x1b
[   25.359134]  [<ffffffff8668694e>] ? wil6210_driver_init+0x1b/0x1b
[   25.359134]  [<ffffffff810020f2>] do_one_initcall+0xb2/0x1b0
[   25.359134]  [<ffffffff865f3021>] kernel_init_freeable+0x15d/0x1ef
[   25.359134]  [<ffffffff865f2801>] ? loglevel+0x31/0x31
[   25.359134]  [<ffffffff83f8ebd0>] ? rest_init+0x140/0x140
[   25.359134]  [<ffffffff83f8ebd9>] kernel_init+0x9/0xf0
[   25.359134]  [<ffffffff83fff1fc>] ret_from_fork+0x7c/0xb0
[   25.359134]  [<ffffffff83f8ebd0>] ? rest_init+0x140/0x140
[   25.359134] Code: 48 8b 7e 30 48 89 de e8 5d d7 c5 ff 48 85 c0 75 75 48 8b 73 f0 48 c7 c7 fa a0 20 85 e8 74 01 07 02 4d 8b 6c
24 78 4d 85 ed 74 43 <41> 80 7d 00 00 74 2f 4c 8b 63 f0 4c 89 ee 4c 89 e7 e8 35 1e ae
[   25.359134] RIP  [<ffffffff81f39fa5>] platform_match+0x45/0xc0
[   25.359134]  RSP <ffff8800b9f11c98>
[   25.359134] CR2: 0000000000000001
[   25.386186] ---[ end trace 6293fa4fd2b61873 ]---

I don't have the hardware to test out any changes I do, but I'll send out a patch
tomorrow to try and fix that unless someone beats me to it.


Thanks,
Sasha
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
