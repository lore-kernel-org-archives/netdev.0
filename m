From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: Re: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
Date: Wed, 27 Aug 2014 10:33:05 +0100
Message-ID: <20140827093305.GB1827@sucs.org>
References: <20140819123655.GC12160@sucs.org> <20140825093648.GB5046@mwanda>
 <20140825214303.GA32390@sucs.org>
 <d282e41ecdb54a2ab3012a3471f649f3@BY2PR0301MB0711.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jason Wang <jasowang@redhat.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Daniel Borkmann <dborkman@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "David S. Miller" <davem@davemloft.net>,
 Dan Carpenter <dan.carpenter@oracle.com>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <d282e41ecdb54a2ab3012a3471f649f3@BY2PR0301MB0711.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 25, 2014 at 09:48:31PM +0000, KY Srinivasan wrote:
> 
> > There is also a case of the BUG_ON at line 460 being hit (from
> > https://lkml.org/lkml/2014/8/19/708 ):
> > 
> > 457        ret = vmbus_post_msg(msg,
> > 458                                       sizeof(struct vmbus_channel_gpadl_teardown));
> > 459
> > 460        BUG_ON(ret != 0);
> 
> I will take care of all BUG_ON() instances in channel.c

Running a kernel patched with "Drivers: hv: vmbus: Eliminate calls to
BUG_ON()" boots but repeatedly changing the MTU with the following script now
results in a GPF in netvsc_open:

dev=eth1; while true; do ifconfig eth1 down; ifconfig eth1 mtu 1500; ifconfig eth1 up; ifconfig eth1 mtu 9000; done

[   58.031328] hv_netvsc vmbus_0_15: net device safe to remove
[   58.083975] hv_netvsc: hv_netvsc channel opened successfully
[   58.973625] hv_netvsc vmbus_0_15: Send section size: 6144, Section count:2560
[   59.030456] hv_netvsc vmbus_0_15: Device MAC 00:15:5d:6f:02:a5 link state up
[   59.142723] hv_netvsc vmbus_0_15: net device safe to remove
[   59.184701] hv_netvsc: hv_netvsc channel opened successfully
[   59.867690] hv_netvsc vmbus_0_15: Send section size: 6144, Section count:2560
[   59.919317] hv_netvsc vmbus_0_15: Device MAC 00:15:5d:6f:02:a5 link state up
[   59.988054] hv_netvsc vmbus_0_15 eth1: unable to teardown receive buffer's gpadl
[   60.038752] hv_netvsc vmbus_0_15: net device safe to remove
[   60.070163] hv_vmbus: Close failed: close post msg return is 4
[   60.121381] hv_vmbus: Close failed: close post msg return is 4
[   60.157974] hv_vmbus: Close failed: close post msg return is 4
[   60.190205] hv_vmbus: Close failed: close post msg return is 4
[   60.232070] hv_vmbus: Close failed: close post msg return is 4
[   65.275820] hv_netvsc vmbus_0_15 eth1: unable to open channel: -110
[   65.325009] general protection fault: 0000 [#1] SMP
[   65.356804] CPU: 7 PID: 852 Comm: ifconfig Not tainted 3.17.0-rc1.x86_64-dirty #127
[   65.356804] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   65.356804] task: ffff8800f268b9f0 ti: ffff8800eed38000 task.ti: ffff8800eed38000
[   65.356804] RIP: 0010:[<ffffffff814e9fff>]  [<ffffffff814e9fff>] rndis_filter_open+0x1f/0x60
[   65.356804] RSP: 0018:ffff8800eed3bd28  EFLAGS: 00010246
[   65.356804] RAX: 0000000000000000 RBX: 6b6b6b6b6b6b6b6b RCX: 0000000000000006
[   65.356804] RDX: 0000000000000006 RSI: ffff8800f268c130 RDI: ffff8801fbb8d480
[   65.356804] RBP: ffff8800eed3bd30 R08: 0000000000000000 R09: 0000000000000000
[   65.356804] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8801fbb8d480
[   65.356804] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000001
[   65.356804] FS:  00007fdfdbf94740(0000) GS:ffff880207ce0000(0000) knlGS:0000000000000000
[   65.356804] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   65.356804] CR2: 00007fdfdc1b51c4 CR3: 00000000ec53b000 CR4: 00000000000406e0
[   65.356804] Stack:
[   65.356804]  ffff8800f1021160 ffff8800eed3bd58 ffffffff814e6515 ffff8800f1021160
[   65.356804]  ffffffff8188f980 0000000000000000 ffff8800eed3bd80 ffffffff815d0998
[   65.356804]  ffff8800f1021160 ffff8800f1021160 0000000000001043 ffff8800eed3bdb8
[   65.356804] Call Trace:
[   65.356804]  [<ffffffff814e6515>] netvsc_open+0x25/0xb0
[   65.356804]  [<ffffffff815d0998>] __dev_open+0x98/0x110
[   65.356804]  [<ffffffff815d0c99>] __dev_change_flags+0xb9/0x160
[   65.356804]  [<ffffffff815d0d69>] dev_change_flags+0x29/0x60
[   65.356804]  [<ffffffff81641b6b>] devinet_ioctl+0x31b/0x6f0
[   65.356804]  [<ffffffff81642c4d>] inet_ioctl+0x6d/0xa0
[   65.356804]  [<ffffffff815b27c0>] sock_ioctl+0x1e0/0x210
[   65.356804]  [<ffffffff811d4dc0>] do_vfs_ioctl+0x4d0/0x510
[   65.356804]  [<ffffffff816a2d55>] ? sysret_check+0x22/0x5d
[   65.356804]  [<ffffffff810b976d>] ? trace_hardirqs_on_caller+0x17d/0x210
[   65.356804]  [<ffffffff811d4e53>] SyS_ioctl+0x53/0x90
[   65.356804]  [<ffffffff816a2d29>] system_call_fastpath+0x16/0x1b
[   65.356804] Code: 41 5e 41 5f 5d c3 66 0f 1f 44 00 00 66 66 66 66 90 48 8b 87 20 01 00 00 48 85 c0 74 2f 55 48 89 e5 53 48 8b 98 40 02 00 00 31 c0 <83> 7b 08 02 75 2b be 0d 00 00 00 48 89 df e8 9e f9 ff ff 85 c0
[   65.356804] RIP  [<ffffffff814e9fff>] rndis_filter_open+0x1f/0x60
[   65.356804]  RSP <ffff8800eed3bd28>
[   66.789324] ---[ end trace 1b6075f9340eb5bc ]---

-- 
Sitsofe | http://sucs.org/~sits/
