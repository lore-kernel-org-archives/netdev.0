From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [netlink] WARNING: at mm/vmalloc.c:1487 __vunmap()
Date: Mon, 17 Jun 2013 22:09:38 +0200
Message-ID: <20130617200938.GA14567@localhost>
References: <20130614220119.GA12954@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130614220119.GA12954@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 15, 2013 at 06:01:19AM +0800, Fengguang Wu wrote:
>     netlink: allow large data transfers from user-space
[...]
> [   65.085802] init: plymouth-upstart-bridge main process (345) terminated with status 1
> [   65.138243] ------------[ cut here ]------------
> [   65.140281] WARNING: at /c/kernel-tests/src/tip/mm/vmalloc.c:1487 __vunmap+0x10b/0x110()
> [   65.143247] Trying to vfree() nonexistent vm area (ffffc90000810000)
> [   65.145697] CPU: 0 PID: 145 Comm: trinity Not tainted 3.10.0-rc5-00652-ge8a36a6 #9
> [   65.148822] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [   65.151073]  0000000000000009 ffff88000f3b7bc8 ffffffff81d3e5b3 ffff88000f3b7c08
> [   65.154718]  ffffffff810cf7a6 ffff88000f3b7c28 ffffc90000810000 0000000000000000
> [   65.158343]  0000000000000001 ffff88000dc36620 ffff8800091c87b0 ffff88000f3b7c68
> [   65.161574] Call Trace:
> [   65.162609]  [<ffffffff81d3e5b3>] dump_stack+0x19/0x1b
> [   65.164349]  [<ffffffff810cf7a6>] warn_slowpath_common+0x66/0x90
> [   65.166294]  [<ffffffff810cf841>] warn_slowpath_fmt+0x41/0x50
> [   65.168286]  [<ffffffff81166f7b>] __vunmap+0x10b/0x110
> [   65.170351]  [<ffffffff81166e2f>] vfree+0x2f/0x70
> [   65.172272]  [<ffffffff81afd478>] netlink_skb_destructor+0xb8/0x100
> [   65.174645]  [<ffffffff81aac8a1>] skb_release_head_state+0x51/0xb0
> [   65.177009]  [<ffffffff81aadb61>] skb_release_all+0x11/0x30
> [   65.179175]  [<ffffffff81aadb91>] __kfree_skb+0x11/0x90
> [   65.181293]  [<ffffffff81aad9d9>] kfree_skb+0x19/0x40
> [   65.183308]  [<ffffffff81ab00a8>] skb_queue_purge+0x18/0x30
> [   65.185482]  [<ffffffff81afd858>] netlink_sock_destruct+0x38/0x110
> [   65.187873]  [<ffffffff81aa8c3a>] __sk_free+0x1a/0x120
> [   65.189911]  [<ffffffff81aa9989>] sk_free+0x19/0x20
> [   65.191875]  [<ffffffff81afec77>] netlink_release+0x177/0x2d0
> [   65.194086]  [<ffffffff81aa6208>] sock_release+0x18/0x70
> [   65.196172]  [<ffffffff81aa645d>] sock_close+0xd/0x20
> [   65.198190]  [<ffffffff8118ae55>] __fput+0xf5/0x240
> [   65.200189]  [<ffffffff8118b069>] ____fput+0x9/0x10
> [   65.202139]  [<ffffffff810eb955>] task_work_run+0x85/0xc0
> [   65.204257]  [<ffffffff810d4942>] do_exit+0x232/0x920
> [   65.206262]  [<ffffffff810d50ab>] do_group_exit+0x3b/0x90
> [   65.208353]  [<ffffffff810d5112>] SyS_exit_group+0x12/0x20
> [   65.210517]  [<ffffffff81d46827>] system_call_fastpath+0x16/0x1b
> [   65.212811] ---[ end trace 9a70fd0f1776886b ]---

I've been trying to trigger this bug here with no success using
different communication configurations (userspace <-> userspace,
userspace <-> kernelspace).

The address that vfree shows seems good to me and we always set
skb->head to NULL after releasing the network buffer.

This patch also exposes the vmalloc infrastructure to user-space,
which is something that didn't happen so far. Not sure if Trinity is
uncovering a bug there.
