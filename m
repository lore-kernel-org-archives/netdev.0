From: Jiri Slaby <jslaby@suse.cz>
Subject: 3.13: e1000e triggers BUG in IRQ handling
Date: Sun, 26 Jan 2014 11:34:43 +0100
Message-ID: <52E4E4C3.3000302@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ML netdev <netdev@vger.kernel.org>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	jesse.brandeburg@intel.com, Bruce Allan <bruce.w.allan@intel.com>,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

after some combination of the following:
  ip link set up dev eth0
  ip link set down dev eth0
  ip link set addr ... dev eth0
  rmmod e1000e
  modprobe e1000e
I got the BUG below. It looks like some path forgot to free_irq and the
next attempt to request_irq (genirq error) or to reset_irq (the BUG) failed.

I don't know whether this is new in 3.13. It happened for me the first
time while trying to convince NetworkManager to set device address as
demanded.

genirq: Flags mismatch irq 46. 00000000 (eth0) vs. 00000000 (eth0)
------------[ cut here ]------------
kernel BUG at /drivers/pci/msi.c:376!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: e1000e ... [last unloaded: e1000e]
CPU: 2 PID: 27424 Comm: NetworkManager Not tainted 3.13.0-1-desktop #1
Hardware name: LENOVO 23252SG/23252SG, BIOS G2ET33WW (1.13 ) 07/24/2012
task: ffff8801004a2110 ti: ffff8800422a0000 task.ti: ffff8800422a0000
RIP: 0010:[<ffffffff8135328a>] [<ffffffff8135328a>]
free_msi_irqs+0x13a/0x140
RSP: 0018:ffff8800422a1708  EFLAGS: 00010286
RAX: ffff880059dc3200 RBX: 0000000000000000 RCX: 00000000fffffffa
RDX: 0000000000000000 RSI: 000000000000002e RDI: 0000000000000000
RBP: ffff880117780c00 R08: ffff880059dc3200 R09: ffff880119800020
R10: 00000000000000c8 R11: 0000000000000001 R12: 0000000000000001
R13: ffff880117c28870 R14: 0000000000000001 R15: ffff880117c28000
FS:  00007ff57f08b840(0000) GS:ffff88011e280000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000003878818 CR3: 00000000cb4b7000 CR4: 00000000001407e0
Stack:
 ffff880117c28000 ffff880117c28000 ffff8800d55a4000 ffff880117c28098
 ffff8800d55a4d78 0000000000000001 ffff8800d55a4000 ffffffff81353d2d
 ffff8800d55a4880 ffffffffa04482ad ffff8800d55a4880 ffffffffa044858f
Call Trace:
 [<ffffffff81353d2d>] pci_disable_msi+0x2d/0x50
 [<ffffffffa04482ad>] e1000e_reset_interrupt_capability+0x4d/0x60 [e1000e]
 [<ffffffffa044858f>] e1000_request_irq+0x1bf/0x280 [e1000e]
 [<ffffffffa044d75f>] e1000_open+0xff/0x5c0 [e1000e]
 [<ffffffff81517a2f>] __dev_open+0xaf/0x120
 [<ffffffff81517d25>] __dev_change_flags+0xa5/0x190
 [<ffffffff81517e49>] dev_change_flags+0x29/0x70
 [<ffffffff81525dd2>] do_setlink+0x332/0x940
 [<ffffffff81526bce>] rtnl_newlink+0x35e/0x570
 [<ffffffff815266bf>] rtnetlink_rcv_msg+0x9f/0x250
 [<ffffffff81541c99>] netlink_rcv_skb+0xa9/0xc0
 [<ffffffff81522e68>] rtnetlink_rcv+0x18/0x20
 [<ffffffff81541200>] netlink_unicast+0x100/0x180
 [<ffffffff815415b7>] netlink_sendmsg+0x337/0x760
 [<ffffffff814fd083>] sock_sendmsg+0x93/0xe0
 [<ffffffff814fd849>] ___sys_sendmsg+0x3b9/0x3d0
 [<ffffffff814fe2f4>] __sys_sendmsg+0x44/0x80
 [<ffffffff8160e9bd>] system_call_fastpath+0x1a/0x1f
 [<00007ff57c60107d>] 0x7ff57c60107c
Code: 48 8b 55 18 48 8d 45 18 48 83 ea 18 49 39 c5 75 90 48 83 c4 08 5b
5d 41 5c 41 5d 41 5e 41 5f c3 48 8b 7b 28 e8 b8 24 cf ff eb 84 <0f> 0b
0f 1f 40 00 53 31 db f6 07 10 8b 47 08 74 1e 89 f3 f7 d3
RIP
 [<ffffffff8135328a>] free_msi_irqs+0x13a/0x140
 RSP <ffff8800422a1708>
---[ end trace 71a7e89db92577e7 ]---

thanks,
-- 
js
suse labs

------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today.
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
