From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net,sctp: oops in sctp_do_sm
Date: Mon, 22 Oct 2012 11:19:14 -0400
Message-ID: <20121022151914.GB24766@hmsreliant.think-freely.org>
References: <5080BBF9.1080208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, sri@us.ibm.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5080BBF9.1080208@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 18, 2012 at 10:33:29PM -0400, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools (lkvm) guest running today's linux-next, I've
> stumbled on the following:
> 
> [  439.574039] BUG: unable to handle kernel paging request at ffff88001b9f40c8
> [  439.576486] IP: [<ffffffff83746fc3>] sctp_do_sm+0x293/0x310
> [  439.578128] PGD 4e27063 PUD 4e2b063 PMD 1fa57067 PTE 1b9f4160
> [  439.580796] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  439.581635] Dumping ftrace buffer:
> [  439.582171]    (ftrace buffer empty)
> [  439.582673] CPU 3
> [  439.582957] Pid: 7101, comm: trinity-child16 Tainted: G        W    3.7.0-rc1-next-20121018-sasha-00002-g60a870d-dirty #62
> [  439.582986] RIP: 0010:[<ffffffff83746fc3>]  [<ffffffff83746fc3>] sctp_do_sm+0x293/0x310
> [  439.582986] RSP: 0018:ffff880010c57988  EFLAGS: 00010286
> [  439.582986] RAX: 0000000000000003 RBX: 0000000000000001 RCX: 0000000000000006
> [  439.582986] RDX: 0000000000000003 RSI: 0000000000000001 RDI: ffff880010c579d0
> [  439.582986] RBP: ffff880010c57ae8 R08: 0000000000000000 R09: 0000000000000000
> [  439.582986] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000004
> [  439.582986] R13: ffff88001b9f4000 R14: ffff880065d22600 R15: 0000000000000003
> [  439.582986] FS:  00007f9a949c3700(0000) GS:ffff880067600000(0000) knlGS:0000000000000000
> [  439.582986] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  439.582986] CR2: ffff88001b9f40c8 CR3: 0000000015850000 CR4: 00000000000406e0
> [  439.582986] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  439.582986] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  439.582986] Process trinity-child16 (pid: 7101, threadinfo ffff880010c56000, task ffff880010a98000)
> [  439.582986] Stack:
> [  439.582986]  ffffffff000000d0 0000000000000000 ffffffff84c92d36 ffffffff84cc4b50
> [  439.582986]  ffffffff83763b30 0000000000000004 ffffffff842c0370 0000000181152f15
> [  439.582986]  ffff880010c579f8 0000000000000002 0000000000000015 0000000000000000
> [  439.582986] Call Trace:
> [  439.582986]  [<ffffffff83763b30>] ? sctp_cname+0x70/0x70
> [  439.582986]  [<ffffffff83761403>] sctp_primitive_SHUTDOWN+0x43/0x50
> [  439.582986]  [<ffffffff8375bd70>] sctp_close+0x150/0x310
> [  439.606533]  [<ffffffff8351bf22>] inet_release+0x1b2/0x1c0
> [  439.606533]  [<ffffffff8351bd8d>] ? inet_release+0x1d/0x1c0
> [  439.606533]  [<ffffffff83578b04>] inet6_release+0x34/0x60
> [  439.606533]  [<ffffffff833c17b8>] sock_release+0x18/0x80
> [  439.610261]  [<ffffffff833c1849>] sock_close+0x29/0x30
> [  439.610261]  [<ffffffff812773f2>] __fput+0x122/0x2d0
> [  439.610261]  [<ffffffff812775a9>] ____fput+0x9/0x10
> [  439.610261]  [<ffffffff81131afe>] task_work_run+0xbe/0x100
> [  439.610261]  [<ffffffff811107e2>] do_exit+0x432/0xbd0
> [  439.610261]  [<ffffffff811243d9>] ? get_signal_to_deliver+0x899/0x910
> [  439.610261]  [<ffffffff8117b2e2>] ? get_lock_stats+0x22/0x70
> [  439.610261]  [<ffffffff8117b36e>] ? put_lock_stats.isra.16+0xe/0x40
> [  439.610261]  [<ffffffff83a6802b>] ? _raw_spin_unlock_irq+0x2b/0x80
> [  439.610261]  [<ffffffff81111044>] do_group_exit+0x84/0xd0
> [  439.610261]  [<ffffffff8112433d>] get_signal_to_deliver+0x7fd/0x910
> [  439.610261]  [<ffffffff8117dffd>] ? trace_hardirqs_off+0xd/0x10
> [  439.620391]  [<ffffffff819fe7db>] ? debug_object_assert_init+0xbb/0x110
> [  439.620391]  [<ffffffff8106d59a>] do_signal+0x3a/0x950
> [  439.620391]  [<ffffffff811c62c3>] ? rcu_cleanup_after_idle+0x23/0x170
> [  439.620391]  [<ffffffff811ca824>] ? rcu_eqs_exit_common+0x64/0x270
> [  439.620391]  [<ffffffff811c90bd>] ? rcu_user_enter+0x10d/0x140
> [  439.620391]  [<ffffffff811cae05>] ? rcu_user_exit+0xc5/0xf0
> [  439.620391]  [<ffffffff8106df1f>] do_notify_resume+0x4f/0xa0
> [  439.620391]  [<ffffffff83a69bea>] int_signal+0x12/0x17
> [  439.620391] Code: e8 eb 48 2c 00 0f 0b 90 41 b8 f4 ff ff ff 66 2e 0f 1f 84 00 00 00 00 00 8b 35 5a 0a 06 02 85 f6 74 66 4d 85
> ed 75 04 31 c0 eb 2a <41> 8b b5 c8 00 00 00 44 89 85 b8 fe ff ff 49 8b 7e 20 e8 f6 51
> [  439.630251] RIP  [<ffffffff83746fc3>] sctp_do_sm+0x293/0x310
> [  439.630251]  RSP <ffff880010c57988>
> [  439.630251] CR2: ffff88001b9f40c8
> [  439.630251] ---[ end trace aa5ad9f036ee09dd ]---
> 
> This points to the DEBUG_POST_SFX macro in sctp_do_sm().
> 
> 
> Thanks,
> Sasha
You don't have any of the logs right before this oops available do you?  It
might be helpful in determining what went wrong here

Thanks
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
