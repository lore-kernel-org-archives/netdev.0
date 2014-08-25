From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: Re: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
Date: Mon, 25 Aug 2014 22:43:03 +0100
Message-ID: <20140825214303.GA32390@sucs.org>
References: <20140819123655.GC12160@sucs.org>
 <20140825093648.GB5046@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jason Wang <jasowang@redhat.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
 netdev@vger.kernel.org, devel@linuxdriverproject.org,
 "David S. Miller" <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20140825093648.GB5046@mwanda>
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

On Mon, Aug 25, 2014 at 12:36:48PM +0300, Dan Carpenter wrote:
> The code here is:
> 
> drivers/hv/channel.c
>    460          BUG_ON(ret != 0);
>    461          t = wait_for_completion_timeout(&info->waitevent, 5*HZ);
>    462          BUG_ON(t == 0);
> 

There is also a case of the BUG_ON at line 460 being hit
(from https://lkml.org/lkml/2014/8/19/708 ):

457        ret = vmbus_post_msg(msg,
458                                       sizeof(struct vmbus_channel_gpadl_teardown));
459
460        BUG_ON(ret != 0);

Aug 20 03:42:58 ubuntuhv kernel: [   13.028182] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/input/input4
Aug 20 03:41:09 ubuntuhv kernel: [  179.973064] hv_netvsc vmbus_0_14: net device safe to remove
Aug 20 03:41:09 ubuntuhv kernel: [  179.974995] hv_netvsc: hv_netvsc channel opened successfully
Aug 20 03:41:10 ubuntuhv kernel: [  180.402957] hv_netvsc vmbus_0_14 eth0: unable to establish send buffer's gpadl
Aug 20 03:41:10 ubuntuhv kernel: [  180.403080] ------------[ cut here ]------------
Aug 20 03:41:10 ubuntuhv kernel: [  180.403141] kernel BUG at drivers/hv/channel.c:460!
Aug 20 03:41:10 ubuntuhv kernel: [  180.403253] invalid opcode: 0000 [#1] SMP 
Aug 20 03:41:10 ubuntuhv kernel: [  180.403328] CPU: 1 PID: 1482 Comm: ifconfig Not tainted 3.17.0-rc1.x86_64 #1
Aug 20 03:41:10 ubuntuhv kernel: [  180.403431] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] task: ffff88006e45b9f0 ti: ffff880070b20000 task.ti: ffff880070b20000
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] RIP: 0010:[<ffffffff815a9901>]  [<ffffffff815a9901>] vmbus_teardown_gpadl+0xc1/0x130
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] RSP: 0018:ffff880070b23c00  EFLAGS: 00010202
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] RAX: 0000000000000004 RBX: ffff88006fef0e38 RCX: 0000000000000006
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] RDX: 0000000000000006 RSI: ffff88006e45c130 RDI: 0000000000000246
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] RBP: ffff880070b23c20 R08: 0000000000000000 R09: 0000000000000000
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000296
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] R13: ffff88007b911520 R14: ffff88006fef0e58 R15: 0000000000000004
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] FS:  00007fe5cd41d740(0000) GS:ffff88007fc20000(0000) knlGS:0000000000000000
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] CR2: 00007f4e3766d410 CR3: 0000000074bcb000 CR4: 00000000000406e0
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] Stack:
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  ffff880074550000 0000000000000000 ffff880078154520 ffff880074550000
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  ffff880070b23c48 ffffffff814e8276 ffff88007b916458 ffff880078154520
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  ffff880074550000 ffff880070b23cb8 ffffffff814e957f ffff88007b911520
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] Call Trace:
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff814e8276>] netvsc_destroy_buf+0xb6/0x210
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff814e957f>] netvsc_device_add+0x6ef/0x7c0
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff814ea6e0>] rndis_filter_device_add+0x80/0x430
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff810b16c0>] ? __wake_up_common+0x90/0x90
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff814e6dfc>] netvsc_change_mtu+0x15c/0x1f0
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff815d19d0>] dev_set_mtu+0x80/0x130
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff815e67b4>] dev_ifsioc+0x124/0x390
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff815e7006>] dev_ioctl+0x516/0x5e0
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff815b339d>] sock_ioctl+0x1fd/0x210
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff811d54b0>] do_vfs_ioctl+0x4d0/0x510
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff8132aa9e>] ? file_has_perm+0x7e/0x90
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff811d5543>] SyS_ioctl+0x53/0x90
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  [<ffffffff816a38e9>] system_call_fastpath+0x16/0x1b
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] Code: 89 df e8 c3 ba df ff 4c 89 e6 48 c7 c7 40 27 ce 81 e8 24 93 0f 00 48 8d bb 88 00 00 00 be 10 00 00 00 e8 13 f2 ff ff 85 c0 74 07 <0f> 0b 0f 1f 44 00 00 be 88 13 00 00 4c 89 f7 e8 5b 4d 0f 00 85 
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536] RIP  [<ffffffff815a9901>] vmbus_teardown_gpadl+0xc1/0x130
Aug 20 03:41:10 ubuntuhv kernel: [  180.403536]  RSP <ffff880070b23c00>
Aug 20 03:41:10 ubuntuhv kernel: [  180.405770] ---[ end trace 9ec56592fdff213b ]---

-- 
Sitsofe | http://sucs.org/~sits/
