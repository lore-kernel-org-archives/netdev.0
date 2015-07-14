From: Cong Wang <cwang@twopensource.com>
Subject: Re: mmap()ed AF_NETLINK: lockdep and sleep-in-atomic warnings
Date: Mon, 13 Jul 2015 22:11:27 -0700
Message-ID: <CAHA+R7OPHFjL83RKkTmso3s25_f7TKA=HhFKU_yOnRhsn1WxQg@mail.gmail.com>
References: <20150713131825.GA16186@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150713131825.GA16186@node.dhcp.inet.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 13, 2015 at 6:18 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> Hi,
>
> This simple test-case trigers few locking asserts in kernel:
>
> #define _GNU_SOURCE
> #include <stdlib.h>
> #include <stdio.h>
> #include <string.h>
> #include <sys/mman.h>
> #include <sys/socket.h>
> #include <sys/types.h>
> #include <linux/netlink.h>
>
> #define SOL_NETLINK 270
>
> int main(int argc, char **argv)
> {
>         unsigned int block_size = 16 * 4096;
>         struct nl_mmap_req req = {
>                 .nm_block_size          = block_size,
>                 .nm_block_nr            = 64,
>                 .nm_frame_size          = 16384,
>                 .nm_frame_nr            = 64 * block_size / 16384,
>         };
>         unsigned int ring_size;
>         int fd;
>
>         fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
>         if (setsockopt(fd, SOL_NETLINK, NETLINK_RX_RING, &req, sizeof(req)) < 0)
>                 exit(1);
>         if (setsockopt(fd, SOL_NETLINK, NETLINK_TX_RING, &req, sizeof(req)) < 0)
>                 exit(1);
>
>         ring_size = req.nm_block_nr * req.nm_block_size;
>         mmap(NULL, 2 * ring_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
>         return 0;
> }
>
> +++ exited with 0 +++
> [    2.500126] BUG: sleeping function called from invalid context at /home/kas/git/public/linux-mm/kernel/locking/mutex.c:616
> [    2.501328] in_atomic(): 1, irqs_disabled(): 0, pid: 1, name: init
> [    2.501997] 3 locks held by init/1:
> [    2.502380]  #0:  (reboot_mutex){+.+...}, at: [<ffffffff81080959>] SyS_reboot+0xa9/0x220
> [    2.503328]  #1:  ((reboot_notifier_list).rwsem){.+.+..}, at: [<ffffffff8107f379>] __blocking_notifier_call_chain+0x39/0x70
> [    2.504659]  #2:  (rcu_callback){......}, at: [<ffffffff810d32e0>] rcu_do_batch.isra.49+0x160/0x10c0
> [    2.505724] Preemption disabled at:[<ffffffff8145365f>] __delay+0xf/0x20
> [    2.506443]
> [    2.506612] CPU: 1 PID: 1 Comm: init Not tainted 4.1.0-00009-gbddf4c4818e0 #253
> [    2.507378] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Debian-1.8.2-1 04/01/2014
> [    2.508386]  ffff88017b3d8000 ffff88027bc03c38 ffffffff81929ceb 0000000000000102
> [    2.509233]  0000000000000000 ffff88027bc03c68 ffffffff81085a9d 0000000000000002
> [    2.510057]  ffffffff81ca2a20 0000000000000268 0000000000000000 ffff88027bc03c98
> [    2.510882] Call Trace:
> [    2.511146]  <IRQ>  [<ffffffff81929ceb>] dump_stack+0x4f/0x7b
> [    2.511763]  [<ffffffff81085a9d>] ___might_sleep+0x16d/0x270
> [    2.512476]  [<ffffffff81085bed>] __might_sleep+0x4d/0x90
> [    2.513071]  [<ffffffff8192e96f>] mutex_lock_nested+0x2f/0x430
> [    2.513683]  [<ffffffff81932fed>] ? _raw_spin_unlock_irqrestore+0x5d/0x80
> [    2.514385]  [<ffffffff81464143>] ? __this_cpu_preempt_check+0x13/0x20
> [    2.515066]  [<ffffffff8182fc3d>] netlink_set_ring+0x1ed/0x350
> [    2.515694]  [<ffffffff8182e000>] ? netlink_undo_bind+0x70/0x70
> [    2.516411]  [<ffffffff8182fe20>] netlink_sock_destruct+0x80/0x150
> [    2.517070]  [<ffffffff817e484d>] __sk_free+0x1d/0x160
> [    2.517607]  [<ffffffff817e49a9>] sk_free+0x19/0x20
> [    2.518118]  [<ffffffff8182e020>] deferred_put_nlk_sk+0x20/0x30
> [    2.518735]  [<ffffffff810d391c>] rcu_do_batch.isra.49+0x79c/0x10c0

Caused by:

commit 21e4902aea80ef35afc00ee8d2abdea4f519b7f7
Author: Thomas Graf <tgraf@suug.ch>
Date:   Fri Jan 2 23:00:22 2015 +0100

    netlink: Lockless lookup with RCU grace period in socket release

    Defers the release of the socket reference using call_rcu() to
    allow using an RCU read-side protected call to rhashtable_lookup()

    This restores behaviour and performance gains as previously
    introduced by e341694 ("netlink: Convert netlink_lookup() to use
    RCU protected hash table") without the side effect of severely
    delayed socket destruction.

    Signed-off-by: Thomas Graf <tgraf@suug.ch>
    Signed-off-by: David S. Miller <davem@davemloft.net>


We can't hold mutex lock in a rcu callback, perhaps we could
defer the mmap ring cleanup to a workqueue.
